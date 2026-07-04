-- MY ORDER PRO — Realtime data-flow patch v6 (added 2026-07-01).
-- Run AFTER schema_v4_functions.sql. Re-defines the 3 write RPCs so that saving a
-- bill/order ALSO flows data into the connected modules in one atomic transaction:
--   * Sale invoice  -> auto-adds/updates the CUSTOMER party + bumps their balance
--   * Purchase      -> auto-adds/updates the SUPPLIER party + bumps their balance
--   * Order         -> posts a debit to the retailer's ledger (khata/statement realtime)
-- CREATE OR REPLACE = safe to re-run. Party id is a deterministic hash of the name so
-- repeat bills to the same party accumulate onto ONE party row (running balance).

-- ============================ place_order ============================
CREATE OR REPLACE FUNCTION place_order(total NUMERIC, items JSONB)
RETURNS UUID
LANGUAGE plpgsql SECURITY DEFINER SET search_path = public
AS $$
DECLARE v_uid UUID := auth.uid(); v_order_id UUID; v_item JSONB;
BEGIN
  IF v_uid IS NULL THEN RAISE EXCEPTION 'not authenticated'; END IF;

  INSERT INTO app_users (id, phone)
  SELECT v_uid, COALESCE(u.phone, v_uid::text) FROM auth.users u WHERE u.id = v_uid
  ON CONFLICT (id) DO NOTHING;

  INSERT INTO orders (user_id, status, total) VALUES (v_uid, 'placed', total)
  RETURNING id INTO v_order_id;

  FOR v_item IN SELECT jsonb_array_elements(items) LOOP
    INSERT INTO order_items (order_id, product_id, qty, unit_price)
    VALUES (v_order_id, v_item->>'product_id',
            COALESCE((v_item->>'qty')::INT, 1), COALESCE((v_item->>'unit_price')::NUMERIC, 0));
  END LOOP;

  -- realtime: post the order to the retailer's ledger so the statement updates live
  INSERT INTO ledger_entries (user_id, type, amount, note)
  VALUES (v_uid, 'debit', total, 'Order ' || substr(v_order_id::text, 1, 8));

  RETURN v_order_id;
END; $$;
GRANT EXECUTE ON FUNCTION place_order(NUMERIC, JSONB) TO authenticated;

-- ======================= create_sale_invoice =======================
CREATE OR REPLACE FUNCTION create_sale_invoice(
  party_name TEXT, subtotal NUMERIC, gst_amount NUMERIC, total NUMERIC,
  created_at TIMESTAMPTZ, items JSONB)
RETURNS UUID
LANGUAGE plpgsql SECURITY DEFINER SET search_path = public
AS $$
DECLARE v_invoice_id UUID; v_item JSONB; v_name TEXT := trim(coalesce(party_name,''));
BEGIN
  IF auth.uid() IS NULL THEN RAISE EXCEPTION 'not authenticated'; END IF;

  INSERT INTO sale_invoices (party_name, subtotal, gst_amount, total, created_at)
  VALUES (create_sale_invoice.party_name, create_sale_invoice.subtotal,
          create_sale_invoice.gst_amount, create_sale_invoice.total,
          COALESCE(create_sale_invoice.created_at, now()))
  RETURNING id INTO v_invoice_id;

  FOR v_item IN SELECT jsonb_array_elements(items) LOOP
    INSERT INTO sale_invoice_items (invoice_id, item_name, qty, rate, amount)
    VALUES (v_invoice_id, v_item->>'item_name',
            COALESCE((v_item->>'qty')::NUMERIC, 1), COALESCE((v_item->>'rate')::NUMERIC, 0),
            COALESCE((v_item->>'amount')::NUMERIC, 0));
  END LOOP;

  -- realtime: auto-add/update the CUSTOMER party from the bill + running balance
  IF length(v_name) > 0 THEN
    INSERT INTO parties (id, name, type, balance)
    VALUES ('cust_' || md5(lower(v_name)), v_name, 'customer', create_sale_invoice.total)
    ON CONFLICT (id) DO UPDATE
      SET balance = parties.balance + EXCLUDED.balance, name = EXCLUDED.name;
  END IF;

  RETURN v_invoice_id;
END; $$;
GRANT EXECUTE ON FUNCTION create_sale_invoice(TEXT, NUMERIC, NUMERIC, NUMERIC, TIMESTAMPTZ, JSONB) TO authenticated;

-- ==================== create_purchase_with_items ====================
CREATE OR REPLACE FUNCTION create_purchase_with_items(purchase_data JSONB, items_data JSONB)
RETURNS UUID
LANGUAGE plpgsql SECURITY DEFINER SET search_path = public
AS $$
DECLARE v_purchase_id UUID; v_item JSONB;
        v_name TEXT := trim(coalesce(purchase_data->>'supplier_name',''));
        v_total NUMERIC := COALESCE((purchase_data->>'total')::NUMERIC, 0);
BEGIN
  IF auth.uid() IS NULL THEN RAISE EXCEPTION 'not authenticated'; END IF;

  INSERT INTO purchases (supplier_name, bill_no, subtotal, gst_amount, total, created_at)
  VALUES (purchase_data->>'supplier_name', purchase_data->>'bill_no',
          COALESCE((purchase_data->>'subtotal')::NUMERIC, 0),
          COALESCE((purchase_data->>'gst_amount')::NUMERIC, 0), v_total,
          COALESCE((purchase_data->>'created_at')::TIMESTAMPTZ, now()))
  RETURNING id INTO v_purchase_id;

  FOR v_item IN SELECT jsonb_array_elements(items_data) LOOP
    INSERT INTO purchase_items (purchase_id, item_name, qty, rate, amount)
    VALUES (v_purchase_id, v_item->>'item_name',
            COALESCE((v_item->>'quantity')::NUMERIC, 0), COALESCE((v_item->>'rate')::NUMERIC, 0),
            COALESCE((v_item->>'total')::NUMERIC, 0));
  END LOOP;

  -- realtime: auto-add/update the SUPPLIER party from the purchase bill + running balance
  IF length(v_name) > 0 THEN
    INSERT INTO parties (id, name, type, balance)
    VALUES ('supp_' || md5(lower(v_name)), v_name, 'supplier', v_total)
    ON CONFLICT (id) DO UPDATE
      SET balance = parties.balance + EXCLUDED.balance, name = EXCLUDED.name;
  END IF;

  RETURN v_purchase_id;
END; $$;
GRANT EXECUTE ON FUNCTION create_purchase_with_items(JSONB, JSONB) TO authenticated;
