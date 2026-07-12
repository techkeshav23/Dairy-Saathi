-- MY ORDER PRO — Schema v36 (server-side order-window enforcement)
--
-- The app already blocks ordering outside the window (Settings → Order Window). This adds
-- a SERVER-SIDE guard in place_order so it cannot be bypassed by changing the device clock
-- or calling the RPC directly. Times are compared in IST (Asia/Kolkata). Blank = no limit.

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
  v_open         TEXT;
  v_cut          TEXT;
  v_now          TEXT := to_char(now() AT TIME ZONE 'Asia/Kolkata', 'HH24:MI');
BEGIN
  IF v_uid IS NULL THEN
    RAISE EXCEPTION 'not authenticated';
  END IF;

  -- Order window (IST). "HH:MM" strings compare correctly lexicographically. Blank = off.
  SELECT order_open_time, order_cutoff_time INTO v_open, v_cut FROM store_settings WHERE id = 1;
  IF v_open IS NOT NULL AND v_open <> '' AND v_now < v_open THEN
    RAISE EXCEPTION 'ordering is closed';
  END IF;
  IF v_cut IS NOT NULL AND v_cut <> '' AND v_now > v_cut THEN
    RAISE EXCEPTION 'ordering is closed';
  END IF;

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

  IF payment_mode = 'credit' THEN
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
