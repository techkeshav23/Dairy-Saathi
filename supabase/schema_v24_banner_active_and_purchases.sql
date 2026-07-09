-- MY ORDER PRO — Schema v24
-- Two things:
--   1. banners.active — so the admin Active/Inactive toggle actually persists and the
--      mobile app only shows active banners.
--   2. stock_purchases + stock_purchase_items — so the admin "Purchase / Stock-In" screen
--      persists supplier bills and bumps real catalog product stock.
--
-- NOTE: the distributor's Flutter accounting module already owns `purchases` /
-- `purchase_items` tables (supplier_name / purchase_date / subtotal / gst / user_id,
-- owner-scoped). Those are a DIFFERENT feature (the distributor's own books). We DO NOT
-- touch them — the admin catalog stock-in uses its own `stock_*` tables.

-- ------------------------------------------------------------------ 1. Banner active
ALTER TABLE banners
  ADD COLUMN IF NOT EXISTS active BOOLEAN NOT NULL DEFAULT TRUE;

-- Existing banners stay visible by default (DEFAULT TRUE handles the backfill).

-- ------------------------------------------------------------------ 2. Admin stock-in
CREATE TABLE IF NOT EXISTS stock_purchases (
    id          TEXT PRIMARY KEY,
    supplier    TEXT,
    bill_no     TEXT,
    bill_date   TEXT,               -- kept as free text to match the parsed bill's date string
    item_count  INT  NOT NULL DEFAULT 0,
    amount      NUMERIC(12, 2) NOT NULL DEFAULT 0,
    source_file TEXT,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS stock_purchase_items (
    id           BIGSERIAL PRIMARY KEY,
    purchase_id  TEXT NOT NULL REFERENCES stock_purchases(id) ON DELETE CASCADE,
    product_id   TEXT REFERENCES products(id) ON DELETE SET NULL,
    name         TEXT NOT NULL,
    qty          INT  NOT NULL DEFAULT 0,
    unit         TEXT,
    rate         NUMERIC(10, 2) NOT NULL DEFAULT 0,
    amount       NUMERIC(12, 2) NOT NULL DEFAULT 0
);

CREATE INDEX IF NOT EXISTS idx_stock_purchase_items_purchase ON stock_purchase_items(purchase_id);

-- RLS: admin-only via the service_role client (bypasses RLS). Enable RLS, grant service_role.
ALTER TABLE stock_purchases      ENABLE ROW LEVEL SECURITY;
ALTER TABLE stock_purchase_items ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "stock_purchases service_role all" ON stock_purchases;
CREATE POLICY "stock_purchases service_role all"
  ON stock_purchases FOR ALL TO service_role USING (TRUE) WITH CHECK (TRUE);

DROP POLICY IF EXISTS "stock_purchase_items service_role all" ON stock_purchase_items;
CREATE POLICY "stock_purchase_items service_role all"
  ON stock_purchase_items FOR ALL TO service_role USING (TRUE) WITH CHECK (TRUE);

-- Table-level GRANTs — remember: RLS is not enough, service_role also needs GRANTs.
GRANT ALL ON stock_purchases      TO service_role;
GRANT ALL ON stock_purchase_items TO service_role;
GRANT USAGE, SELECT ON SEQUENCE stock_purchase_items_id_seq TO service_role;

-- ------------------------------------------------------------------ 3. Stock-in RPC
-- Atomically apply a stock-in: insert the purchase master, its items, and bump product
-- stock for matched products. Called by the admin /api/purchases route (service_role).
CREATE OR REPLACE FUNCTION apply_stock_purchase(
    p_supplier   TEXT,
    p_bill_no    TEXT,
    p_bill_date  TEXT,
    p_source     TEXT,
    p_items      JSONB          -- [{product_id?, name, qty, unit, rate, amount}]
)
RETURNS TEXT
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    v_id     TEXT := 'stp_' || to_char(NOW(), 'YYYYMMDDHH24MISS') || '_' || floor(random() * 1000)::TEXT;
    v_item   JSONB;
    v_count  INT := 0;
    v_total  NUMERIC(12,2) := 0;
    v_pid    TEXT;
    v_qty    INT;
BEGIN
    INSERT INTO stock_purchases (id, supplier, bill_no, bill_date, item_count, amount, source_file)
    VALUES (v_id, p_supplier, p_bill_no, p_bill_date, 0, 0, p_source);

    FOR v_item IN SELECT jsonb_array_elements(p_items)
    LOOP
        v_pid := NULLIF(v_item->>'product_id', '');
        v_qty := COALESCE((v_item->>'qty')::INT, 0);

        INSERT INTO stock_purchase_items (purchase_id, product_id, name, qty, unit, rate, amount)
        VALUES (
            v_id,
            v_pid,
            COALESCE(v_item->>'name', ''),
            v_qty,
            v_item->>'unit',
            COALESCE((v_item->>'rate')::NUMERIC, 0),
            COALESCE((v_item->>'amount')::NUMERIC, 0)
        );

        -- Restock a matched product.
        IF v_pid IS NOT NULL AND v_qty > 0 THEN
            UPDATE products SET stock = stock + v_qty WHERE id = v_pid;
        END IF;

        v_count := v_count + 1;
        v_total := v_total + COALESCE((v_item->>'amount')::NUMERIC, 0);
    END LOOP;

    UPDATE stock_purchases SET item_count = v_count, amount = v_total WHERE id = v_id;
    RETURN v_id;
END;
$$;

GRANT EXECUTE ON FUNCTION apply_stock_purchase(TEXT, TEXT, TEXT, TEXT, JSONB) TO service_role;
