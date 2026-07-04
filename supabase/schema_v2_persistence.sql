-- MY ORDER PRO — Persistence schema v2 (additive).
-- Run this AFTER schema.sql in the Supabase SQL editor. Adds the tables the
-- write/CRUD services need: parties, sale invoices, purchases.
-- Idempotent-ish: uses IF NOT EXISTS where possible.

-- ============================ PARTIES ============================
CREATE TABLE IF NOT EXISTS parties (
    id              TEXT PRIMARY KEY,
    name            TEXT NOT NULL,
    phone           TEXT,
    type            TEXT NOT NULL DEFAULT 'customer',   -- 'customer' | 'supplier'
    address         TEXT DEFAULT '',
    gstin           TEXT DEFAULT '',
    opening_balance NUMERIC(12,2) NOT NULL DEFAULT 0,
    balance         NUMERIC(12,2) NOT NULL DEFAULT 0,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS idx_parties_type ON parties(type);

-- ========================= SALE INVOICES =========================
CREATE TABLE IF NOT EXISTS sale_invoices (
    id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    party_name    TEXT,
    invoice_date  DATE NOT NULL DEFAULT CURRENT_DATE,
    subtotal      NUMERIC(12,2) NOT NULL DEFAULT 0,
    gst_amount    NUMERIC(12,2) NOT NULL DEFAULT 0,
    total         NUMERIC(12,2) NOT NULL DEFAULT 0,
    created_at    TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE TABLE IF NOT EXISTS sale_invoice_items (
    id          BIGSERIAL PRIMARY KEY,
    invoice_id  UUID NOT NULL REFERENCES sale_invoices(id) ON DELETE CASCADE,
    item_name   TEXT NOT NULL,
    qty         NUMERIC(12,2) NOT NULL DEFAULT 1,
    rate        NUMERIC(12,2) NOT NULL DEFAULT 0,
    amount      NUMERIC(12,2) NOT NULL DEFAULT 0
);
CREATE INDEX IF NOT EXISTS idx_sale_invoice_items_invoice ON sale_invoice_items(invoice_id);

-- =========================== PURCHASES ===========================
CREATE TABLE IF NOT EXISTS purchases (
    id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    supplier_name TEXT,
    bill_no       TEXT,
    purchase_date DATE NOT NULL DEFAULT CURRENT_DATE,
    subtotal      NUMERIC(12,2) NOT NULL DEFAULT 0,
    gst_amount    NUMERIC(12,2) NOT NULL DEFAULT 0,
    total         NUMERIC(12,2) NOT NULL DEFAULT 0,
    created_at    TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE TABLE IF NOT EXISTS purchase_items (
    id          BIGSERIAL PRIMARY KEY,
    purchase_id UUID NOT NULL REFERENCES purchases(id) ON DELETE CASCADE,
    item_name   TEXT NOT NULL,
    qty         NUMERIC(12,2) NOT NULL DEFAULT 1,
    rate        NUMERIC(12,2) NOT NULL DEFAULT 0,
    amount      NUMERIC(12,2) NOT NULL DEFAULT 0
);
CREATE INDEX IF NOT EXISTS idx_purchase_items_purchase ON purchase_items(purchase_id);

-- ============================== RLS ==============================
ALTER TABLE parties            ENABLE ROW LEVEL SECURITY;
ALTER TABLE sale_invoices      ENABLE ROW LEVEL SECURITY;
ALTER TABLE sale_invoice_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE purchases          ENABLE ROW LEVEL SECURITY;
ALTER TABLE purchase_items     ENABLE ROW LEVEL SECURITY;

-- Simple policies: authenticated users can do everything (tighten later per-tenant).
DO $$
DECLARE t TEXT;
BEGIN
  FOREACH t IN ARRAY ARRAY['parties','sale_invoices','sale_invoice_items','purchases','purchase_items']
  LOOP
    EXECUTE format('CREATE POLICY %I_auth_all ON %I FOR ALL TO authenticated USING (true) WITH CHECK (true);', t, t);
  END LOOP;
END $$;
