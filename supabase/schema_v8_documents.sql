-- MY ORDER PRO — Documents schema v8 (added 2026-07-02).
-- Backs the generic DocumentFormScreen (Estimate, Sale Order, Delivery Challan,
-- Credit Note, Debit Note, Purchase Order) so those documents PERSIST, not just
-- print/share. One table, discriminated by doc_type, items stored as JSONB.
-- Run AFTER schema_v2..v7. Idempotent.

CREATE TABLE IF NOT EXISTS documents (
    id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    doc_type     TEXT NOT NULL,                 -- 'ESTIMATE' | 'SALE ORDER' | 'DELIVERY CHALLAN' | 'CREDIT NOTE' | 'DEBIT NOTE' | 'PURCHASE ORDER'
    doc_no       TEXT,
    party_name   TEXT,
    party_gstin  TEXT DEFAULT '',
    doc_date     DATE NOT NULL DEFAULT CURRENT_DATE,
    subtotal     NUMERIC(12,2) NOT NULL DEFAULT 0,
    cgst         NUMERIC(12,2) NOT NULL DEFAULT 0,
    sgst         NUMERIC(12,2) NOT NULL DEFAULT 0,
    total        NUMERIC(12,2) NOT NULL DEFAULT 0,
    items        JSONB NOT NULL DEFAULT '[]'::jsonb,
    created_at   TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS idx_documents_type ON documents(doc_type);

ALTER TABLE documents ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS documents_auth_all ON documents;
CREATE POLICY documents_auth_all ON documents FOR ALL TO authenticated USING (true) WITH CHECK (true);
