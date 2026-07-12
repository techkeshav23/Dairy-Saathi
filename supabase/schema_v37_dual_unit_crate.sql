-- v37 — Dual-unit selling: PIECE (EA) or CRATE.
-- A product's stock is always tracked in PIECES (EA). A crate is just a bundle of
-- `ea_per_crate` pieces. The admin sets a separate crate_price (per full crate).
-- Retailers can order in either unit; a crate line removes `qty * ea_per_crate` pieces
-- from stock. place_order now also decrements stock (previously it never did).

-- 1) Products: pieces-per-crate + crate sell price -----------------------------
ALTER TABLE products ADD COLUMN IF NOT EXISTS ea_per_crate INT NOT NULL DEFAULT 0;
ALTER TABLE products ADD COLUMN IF NOT EXISTS crate_price   NUMERIC(10, 2) NOT NULL DEFAULT 0;

COMMENT ON COLUMN products.ea_per_crate IS
  'Pieces (EA) in one crate. 0 = product has no crate option (piece-only).';
COMMENT ON COLUMN products.crate_price IS
  'Admin-set sell price for one full crate. Used when a retailer orders in the crate unit.';

-- 2) Order items: which unit this line was ordered in --------------------------
--    unit = ''ea''    -> qty is PIECES,  unit_price is per piece   (also covers KG lines)
--    unit = ''crate'' -> qty is CRATES,  unit_price is per crate
ALTER TABLE order_items ADD COLUMN IF NOT EXISTS unit TEXT NOT NULL DEFAULT 'ea';

COMMENT ON COLUMN order_items.unit IS
  'ea = qty in pieces (per-piece price); crate = qty in crates (per-crate price).';

-- 3) place_order — crate-aware pricing + stock deduction -----------------------
--    Keeps all existing behaviour: order-window enforcement, server-authoritative
--    pricing, positive-total guard, credit-limit check + ledger debit.
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
AS $function$
DECLARE
  v_uid          UUID := auth.uid();
  v_order_id     UUID;
  v_item         JSONB;
  v_pid          TEXT;
  v_unit         TEXT;
  v_qty          INT;
  v_pieces       INT;
  v_price        NUMERIC;
  v_epc          INT;
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

  -- Order window (IST) — retailers can only order between open & cutoff.
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
    v_pid  := v_item->>'product_id';
    v_unit := COALESCE(NULLIF(v_item->>'unit', ''), 'ea');
    v_qty  := GREATEST(COALESCE((v_item->>'qty')::INT, 1), 1);

    IF v_unit = 'crate' THEN
      -- Crate line: qty = number of crates; server-authoritative crate price.
      SELECT crate_price, GREATEST(COALESCE(ea_per_crate, 0), 0)
        INTO v_price, v_epc
        FROM products WHERE id = v_pid;
      v_price  := COALESCE(v_price, 0);
      v_pieces := v_qty * GREATEST(v_epc, 1);   -- pieces to remove from stock
    ELSE
      -- Piece line (also KG, resolved to pieces client-side): best matching slab, else MRP.
      v_price := COALESCE(
        (SELECT price_per_unit FROM price_slabs
           WHERE product_id = v_pid AND min_qty <= v_qty
           ORDER BY min_qty DESC LIMIT 1),
        (SELECT mrp FROM products WHERE id = v_pid),
        0);
      v_pieces := v_qty;
    END IF;

    v_server_total := v_server_total + (v_qty * v_price);

    INSERT INTO order_items (order_id, product_id, qty, unit_price, unit)
    VALUES (v_order_id, v_pid, v_qty, v_price, v_unit);

    -- Decrement stock by the pieces sold (never below 0).
    UPDATE products
       SET stock = GREATEST(COALESCE(stock, 0) - v_pieces, 0)
     WHERE id = v_pid;
  END LOOP;

  IF v_server_total <= 0 THEN
    RAISE EXCEPTION 'order total must be positive';
  END IF;

  UPDATE orders SET total = v_server_total WHERE id = v_order_id;

  -- Credit orders: enforce the retailer's credit limit, then post the ledger debit.
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
$function$;
