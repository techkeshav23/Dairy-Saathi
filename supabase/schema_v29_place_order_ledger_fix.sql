-- MY ORDER PRO — Schema v29 (fix: orders not hitting the khata / statement)
--
-- Bug: the v23 payment-aware place_order(total, items, payment_mode, payment_screenshot)
-- created the order + items but NEVER wrote a ledger_entries row, so khata (pay-later)
-- orders never showed up in the retailer's Statement. It also trusted the client's total
-- and unit_price.
--
-- Fix: compute authoritative pricing server-side from price_slabs (never trust the client),
-- write a ledger DEBIT for pay-later ('credit') orders, and enforce the credit limit
-- server-side as a backstop. COD / online / QR orders are settled outside khata, so they
-- do not create a ledger debit.

CREATE OR REPLACE FUNCTION public.place_order(
  total numeric,
  items jsonb,
  payment_mode text DEFAULT 'cod',
  payment_screenshot text DEFAULT NULL
)
RETURNS uuid
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'public'
AS $$
DECLARE
  v_uid          UUID := auth.uid();
  v_order_id     UUID;
  v_item         JSONB;
  v_pid          TEXT;
  v_qty          INT;
  v_price        NUMERIC;
  v_server_total NUMERIC := 0;
  v_limit        NUMERIC;
  v_outstanding  NUMERIC;
BEGIN
  IF v_uid IS NULL THEN
    RAISE EXCEPTION 'not authenticated';
  END IF;

  -- Ensure the profile row exists.
  INSERT INTO app_users (id, phone)
  SELECT v_uid, COALESCE(u.phone, v_uid::text)
  FROM auth.users u WHERE u.id = v_uid
  ON CONFLICT (id) DO NOTHING;

  INSERT INTO orders (user_id, status, total, payment_mode, payment_screenshot, payment_status)
  VALUES (
    v_uid, 'placed', 0, payment_mode, payment_screenshot,
    CASE WHEN payment_mode = 'qr' THEN 'pending' ELSE 'verified' END
  )
  RETURNING id INTO v_order_id;

  -- Authoritative pricing: best matching slab for the qty, else product MRP.
  FOR v_item IN SELECT jsonb_array_elements(items)
  LOOP
    v_pid := v_item->>'product_id';
    v_qty := GREATEST(COALESCE((v_item->>'qty')::INT, 1), 1);
    v_price := COALESCE(
      (SELECT price_per_unit FROM price_slabs
         WHERE product_id = v_pid AND min_qty <= v_qty
         ORDER BY min_qty DESC LIMIT 1),
      (SELECT mrp FROM products WHERE id = v_pid),
      0);
    v_server_total := v_server_total + (v_qty * v_price);
    INSERT INTO order_items (order_id, product_id, qty, unit_price)
    VALUES (v_order_id, v_pid, v_qty, v_price);
  END LOOP;

  IF v_server_total <= 0 THEN
    RAISE EXCEPTION 'order total must be positive';
  END IF;

  UPDATE orders SET total = v_server_total WHERE id = v_order_id;

  -- Only pay-later (khata) orders affect the retailer's ledger.
  IF payment_mode = 'credit' THEN
    -- Server-side credit-limit backstop (the app also checks this).
    SELECT COALESCE(credit_limit, 50000) INTO v_limit FROM app_users WHERE id = v_uid;
    SELECT COALESCE(SUM(CASE WHEN type = 'debit' THEN amount ELSE -amount END), 0)
      INTO v_outstanding FROM ledger_entries WHERE user_id = v_uid;

    IF v_outstanding + v_server_total > v_limit THEN
      RAISE EXCEPTION 'credit limit exceeded';
    END IF;

    INSERT INTO ledger_entries (user_id, type, amount, note)
    VALUES (v_uid, 'debit', v_server_total, 'Order ' || substr(v_order_id::text, 1, 8));
  END IF;

  RETURN v_order_id;
END;
$$;

GRANT EXECUTE ON FUNCTION public.place_order(numeric, jsonb, text, text) TO authenticated;
