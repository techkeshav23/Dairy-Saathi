-- MY ORDER PRO — Security hardening v9 (2026-07-02). CRITICAL — run after v1..v8.
-- Fixes 3 verified critical holes from the max-scrutiny audit:
--   1. Multi-tenant data leak: parties/invoices/purchases/payments/expenses/documents
--      had NO user_id and RLS USING(true) -> every user could read/write all data.
--   2. Global party collision: party id was md5(name) with no user scope -> balances merged.
--   3. Client-trusted pricing: place_order took client total/price -> ledger manipulation.
-- Also: atomic party-balance increment (fixes lost-update race) + SET search_path=''.

-- ========== 1. ADD user_id (tenant isolation) ==========
ALTER TABLE parties            ADD COLUMN IF NOT EXISTS user_id UUID;
ALTER TABLE sale_invoices      ADD COLUMN IF NOT EXISTS user_id UUID;
ALTER TABLE sale_invoice_items ADD COLUMN IF NOT EXISTS user_id UUID;
ALTER TABLE purchases          ADD COLUMN IF NOT EXISTS user_id UUID;
ALTER TABLE purchase_items     ADD COLUMN IF NOT EXISTS user_id UUID;
ALTER TABLE payments           ADD COLUMN IF NOT EXISTS user_id UUID;
ALTER TABLE expenses           ADD COLUMN IF NOT EXISTS user_id UUID;
ALTER TABLE documents          ADD COLUMN IF NOT EXISTS user_id UUID;

CREATE INDEX IF NOT EXISTS idx_parties_user       ON parties(user_id);
CREATE INDEX IF NOT EXISTS idx_sale_invoices_user ON sale_invoices(user_id);
CREATE INDEX IF NOT EXISTS idx_purchases_user     ON purchases(user_id);
CREATE INDEX IF NOT EXISTS idx_payments_user      ON payments(user_id);
CREATE INDEX IF NOT EXISTS idx_expenses_user      ON expenses(user_id);
CREATE INDEX IF NOT EXISTS idx_documents_user     ON documents(user_id);

-- ========== 2. Replace permissive RLS with per-user policies ==========
DO $$
DECLARE t TEXT;
BEGIN
  FOREACH t IN ARRAY ARRAY['parties','sale_invoices','sale_invoice_items','purchases',
                           'purchase_items','payments','expenses','documents']
  LOOP
    -- drop the old USING(true) policies (names from v2/v7/v8)
    EXECUTE format('DROP POLICY IF EXISTS %I_auth_all ON %I;', t, t);
    EXECUTE format('DROP POLICY IF EXISTS "%s_auth_all" ON %I;', t, t);
    -- new owner-only policy: a user sees/writes only their own rows
    EXECUTE format($f$
      CREATE POLICY %I_owner ON %I FOR ALL TO authenticated
      USING (user_id = (SELECT auth.uid()))
      WITH CHECK (user_id = (SELECT auth.uid()));
    $f$, t, t);
  END LOOP;
END $$;

-- ========== 3. Atomic party-balance increment (fixes lost-update race) ==========
CREATE OR REPLACE FUNCTION increment_party_balance(p_id TEXT, delta NUMERIC)
RETURNS VOID
LANGUAGE plpgsql SECURITY DEFINER SET search_path = ''
AS $$
BEGIN
  IF auth.uid() IS NULL THEN RAISE EXCEPTION 'not authenticated'; END IF;
  UPDATE public.parties
     SET balance = balance + delta
   WHERE id = p_id AND user_id = auth.uid();  -- atomic; owner-scoped
END; $$;
GRANT EXECUTE ON FUNCTION increment_party_balance(TEXT, NUMERIC) TO authenticated;

-- ========== 4. place_order — server-computes price (no client trust) ==========
CREATE OR REPLACE FUNCTION place_order(total NUMERIC, items JSONB)
RETURNS UUID
LANGUAGE plpgsql SECURITY DEFINER SET search_path = ''
AS $$
DECLARE
  v_uid UUID := auth.uid();
  v_order_id UUID;
  v_item JSONB;
  v_pid TEXT;
  v_qty INT;
  v_price NUMERIC;
  v_server_total NUMERIC := 0;
BEGIN
  IF v_uid IS NULL THEN RAISE EXCEPTION 'not authenticated'; END IF;

  INSERT INTO public.app_users (id, phone)
  SELECT v_uid, COALESCE(u.phone, v_uid::text) FROM auth.users u WHERE u.id = v_uid
  ON CONFLICT (id) DO NOTHING;

  INSERT INTO public.orders (user_id, status, total) VALUES (v_uid, 'placed', 0)
  RETURNING id INTO v_order_id;

  FOR v_item IN SELECT jsonb_array_elements(items) LOOP
    v_pid := v_item->>'product_id';
    v_qty := GREATEST(COALESCE((v_item->>'qty')::INT, 1), 1);   -- no zero/negative qty
    -- authoritative price: best matching slab for this qty, else product MRP
    v_price := COALESCE(
      (SELECT price_per_unit FROM public.price_slabs
        WHERE product_id = v_pid AND min_qty <= v_qty
        ORDER BY min_qty DESC LIMIT 1),
      (SELECT mrp FROM public.products WHERE id = v_pid),
      0);
    v_server_total := v_server_total + (v_qty * v_price);
    INSERT INTO public.order_items (order_id, product_id, qty, unit_price)
    VALUES (v_order_id, v_pid, v_qty, v_price);
  END LOOP;

  IF v_server_total <= 0 THEN RAISE EXCEPTION 'order total must be positive'; END IF;

  UPDATE public.orders SET total = v_server_total WHERE id = v_order_id;

  -- ledger uses the SERVER total, never the client's number
  INSERT INTO public.ledger_entries (user_id, type, amount, note)
  VALUES (v_uid, 'debit', v_server_total, 'Order ' || substr(v_order_id::text, 1, 8));

  RETURN v_order_id;
END; $$;
GRANT EXECUTE ON FUNCTION place_order(NUMERIC, JSONB) TO authenticated;

-- ========== 5. create_sale_invoice — user_id + per-user party ==========
CREATE OR REPLACE FUNCTION create_sale_invoice(
  party_name TEXT, subtotal NUMERIC, gst_amount NUMERIC, total NUMERIC,
  created_at TIMESTAMPTZ, items JSONB)
RETURNS UUID
LANGUAGE plpgsql SECURITY DEFINER SET search_path = ''
AS $$
DECLARE v_uid UUID := auth.uid(); v_invoice_id UUID; v_item JSONB;
        v_name TEXT := trim(coalesce(party_name,''));
BEGIN
  IF v_uid IS NULL THEN RAISE EXCEPTION 'not authenticated'; END IF;

  INSERT INTO public.sale_invoices (user_id, party_name, subtotal, gst_amount, total, created_at)
  VALUES (v_uid, create_sale_invoice.party_name, create_sale_invoice.subtotal,
          create_sale_invoice.gst_amount, create_sale_invoice.total,
          COALESCE(create_sale_invoice.created_at, now()))
  RETURNING id INTO v_invoice_id;

  FOR v_item IN SELECT jsonb_array_elements(items) LOOP
    INSERT INTO public.sale_invoice_items (user_id, invoice_id, item_name, qty, rate, amount)
    VALUES (v_uid, v_invoice_id, v_item->>'item_name',
            COALESCE((v_item->>'qty')::NUMERIC, 1), COALESCE((v_item->>'rate')::NUMERIC, 0),
            COALESCE((v_item->>'amount')::NUMERIC, 0));
  END LOOP;

  IF length(v_name) > 0 THEN
    INSERT INTO public.parties (id, user_id, name, type, balance)
    VALUES ('cust_' || md5(v_uid::text || lower(v_name)), v_uid, v_name, 'customer', create_sale_invoice.total)
    ON CONFLICT (id) DO UPDATE
      SET balance = public.parties.balance + EXCLUDED.balance, name = EXCLUDED.name;
  END IF;

  RETURN v_invoice_id;
END; $$;
GRANT EXECUTE ON FUNCTION create_sale_invoice(TEXT, NUMERIC, NUMERIC, NUMERIC, TIMESTAMPTZ, JSONB) TO authenticated;

-- ========== 6. create_purchase_with_items — user_id + per-user supplier ==========
CREATE OR REPLACE FUNCTION create_purchase_with_items(purchase_data JSONB, items_data JSONB)
RETURNS UUID
LANGUAGE plpgsql SECURITY DEFINER SET search_path = ''
AS $$
DECLARE v_uid UUID := auth.uid(); v_purchase_id UUID; v_item JSONB;
        v_name TEXT := trim(coalesce(purchase_data->>'supplier_name',''));
        v_total NUMERIC := COALESCE((purchase_data->>'total')::NUMERIC, 0);
BEGIN
  IF v_uid IS NULL THEN RAISE EXCEPTION 'not authenticated'; END IF;

  INSERT INTO public.purchases (user_id, supplier_name, bill_no, subtotal, gst_amount, total, created_at)
  VALUES (v_uid, purchase_data->>'supplier_name', purchase_data->>'bill_no',
          COALESCE((purchase_data->>'subtotal')::NUMERIC, 0),
          COALESCE((purchase_data->>'gst_amount')::NUMERIC, 0), v_total,
          COALESCE((purchase_data->>'created_at')::TIMESTAMPTZ, now()))
  RETURNING id INTO v_purchase_id;

  FOR v_item IN SELECT jsonb_array_elements(items_data) LOOP
    INSERT INTO public.purchase_items (user_id, purchase_id, item_name, qty, rate, amount)
    VALUES (v_uid, v_purchase_id, v_item->>'item_name',
            COALESCE((v_item->>'quantity')::NUMERIC, 0), COALESCE((v_item->>'rate')::NUMERIC, 0),
            COALESCE((v_item->>'total')::NUMERIC, 0));
  END LOOP;

  IF length(v_name) > 0 THEN
    INSERT INTO public.parties (id, user_id, name, type, balance)
    VALUES ('supp_' || md5(v_uid::text || lower(v_name)), v_uid, v_name, 'supplier', v_total)
    ON CONFLICT (id) DO UPDATE
      SET balance = public.parties.balance + EXCLUDED.balance, name = EXCLUDED.name;
  END IF;

  RETURN v_purchase_id;
END; $$;
GRANT EXECUTE ON FUNCTION create_purchase_with_items(JSONB, JSONB) TO authenticated;
