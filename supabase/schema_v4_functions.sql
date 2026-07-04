-- MY ORDER PRO — RPC functions v4 (added 2026-07-01).
-- Run this AFTER schema.sql, schema_v2_persistence.sql, schema_v3_write_policies.sql.
--
-- WHY: the mobile services call three Postgres RPCs for atomic master-detail
-- writes, but the functions were never created. Without them every order /
-- invoice / purchase silently fails (the client catches the error and returns
-- null/false). These SECURITY DEFINER functions do the multi-row insert in one
-- transaction and are scoped by auth.uid(). CREATE OR REPLACE = safe to re-run.

-- ============================ place_order ============================
-- order_service.placeOrder -> rpc('place_order', {total, items:[{product_id, qty, unit_price}]})
CREATE OR REPLACE FUNCTION place_order(total NUMERIC, items JSONB)
RETURNS UUID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_uid      UUID := auth.uid();
  v_order_id UUID;
  v_item     JSONB;
BEGIN
  IF v_uid IS NULL THEN
    RAISE EXCEPTION 'not authenticated';
  END IF;

  -- Ensure the profile row exists (orders.user_id FK -> app_users.id).
  INSERT INTO app_users (id, phone)
  SELECT v_uid, COALESCE(u.phone, v_uid::text)
  FROM auth.users u
  WHERE u.id = v_uid
  ON CONFLICT (id) DO NOTHING;

  INSERT INTO orders (user_id, status, total)
  VALUES (v_uid, 'placed', total)
  RETURNING id INTO v_order_id;

  FOR v_item IN SELECT jsonb_array_elements(items)
  LOOP
    INSERT INTO order_items (order_id, product_id, qty, unit_price)
    VALUES (
      v_order_id,
      v_item->>'product_id',
      COALESCE((v_item->>'qty')::INT, 1),
      COALESCE((v_item->>'unit_price')::NUMERIC, 0)
    );
  END LOOP;

  RETURN v_order_id;
END;
$$;
GRANT EXECUTE ON FUNCTION place_order(NUMERIC, JSONB) TO authenticated;

-- ======================= create_sale_invoice =======================
-- invoice_service.saveInvoice -> rpc('create_sale_invoice',
--   {party_name, subtotal, gst_amount, total, created_at, items:[{item_name, qty, rate, amount}]})
CREATE OR REPLACE FUNCTION create_sale_invoice(
  party_name TEXT,
  subtotal   NUMERIC,
  gst_amount NUMERIC,
  total      NUMERIC,
  created_at TIMESTAMPTZ,
  items      JSONB
)
RETURNS UUID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_invoice_id UUID;
  v_item       JSONB;
BEGIN
  IF auth.uid() IS NULL THEN
    RAISE EXCEPTION 'not authenticated';
  END IF;

  INSERT INTO sale_invoices (party_name, subtotal, gst_amount, total, created_at)
  VALUES (
    create_sale_invoice.party_name,
    create_sale_invoice.subtotal,
    create_sale_invoice.gst_amount,
    create_sale_invoice.total,
    COALESCE(create_sale_invoice.created_at, now())
  )
  RETURNING id INTO v_invoice_id;

  FOR v_item IN SELECT jsonb_array_elements(items)
  LOOP
    INSERT INTO sale_invoice_items (invoice_id, item_name, qty, rate, amount)
    VALUES (
      v_invoice_id,
      v_item->>'item_name',
      COALESCE((v_item->>'qty')::NUMERIC, 1),
      COALESCE((v_item->>'rate')::NUMERIC, 0),
      COALESCE((v_item->>'amount')::NUMERIC, 0)
    );
  END LOOP;

  RETURN v_invoice_id;
END;
$$;
GRANT EXECUTE ON FUNCTION create_sale_invoice(TEXT, NUMERIC, NUMERIC, NUMERIC, TIMESTAMPTZ, JSONB) TO authenticated;

-- ==================== create_purchase_with_items ====================
-- purchase_service.savePurchase -> rpc('create_purchase_with_items',
--   {purchase_data:{supplier_name, bill_no, subtotal, gst_amount, total, created_at},
--    items_data:[{item_name, quantity, rate, total}]})
-- NOTE: the app sends item keys 'quantity' and 'total'; the purchase_items table
-- columns are 'qty' and 'amount' — mapped below.
CREATE OR REPLACE FUNCTION create_purchase_with_items(purchase_data JSONB, items_data JSONB)
RETURNS UUID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_purchase_id UUID;
  v_item        JSONB;
BEGIN
  IF auth.uid() IS NULL THEN
    RAISE EXCEPTION 'not authenticated';
  END IF;

  INSERT INTO purchases (supplier_name, bill_no, subtotal, gst_amount, total, created_at)
  VALUES (
    purchase_data->>'supplier_name',
    purchase_data->>'bill_no',
    COALESCE((purchase_data->>'subtotal')::NUMERIC, 0),
    COALESCE((purchase_data->>'gst_amount')::NUMERIC, 0),
    COALESCE((purchase_data->>'total')::NUMERIC, 0),
    COALESCE((purchase_data->>'created_at')::TIMESTAMPTZ, now())
  )
  RETURNING id INTO v_purchase_id;

  FOR v_item IN SELECT jsonb_array_elements(items_data)
  LOOP
    INSERT INTO purchase_items (purchase_id, item_name, qty, rate, amount)
    VALUES (
      v_purchase_id,
      v_item->>'item_name',
      COALESCE((v_item->>'quantity')::NUMERIC, 0),  -- 'quantity' -> qty
      COALESCE((v_item->>'rate')::NUMERIC, 0),
      COALESCE((v_item->>'total')::NUMERIC, 0)       -- 'total' -> amount
    );
  END LOOP;

  RETURN v_purchase_id;
END;
$$;
GRANT EXECUTE ON FUNCTION create_purchase_with_items(JSONB, JSONB) TO authenticated;
