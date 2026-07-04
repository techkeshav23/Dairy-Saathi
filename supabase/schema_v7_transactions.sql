-- MY ORDER PRO — Transactions schema v7 (added 2026-07-01).
-- Backs the new transaction screens: Payment-In / Payment-Out and Expenses.
-- Run AFTER schema_v2..v6. Idempotent (IF NOT EXISTS + drop-then-create policies).

-- ============================ PAYMENTS ============================
CREATE TABLE IF NOT EXISTS payments (
    id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    party_name   TEXT,
    direction    TEXT NOT NULL DEFAULT 'in',   -- 'in' (received) | 'out' (paid)
    amount       NUMERIC(12,2) NOT NULL DEFAULT 0,
    mode         TEXT NOT NULL DEFAULT 'cash',  -- 'cash' | 'upi' | 'bank' | 'cheque'
    note         TEXT DEFAULT '',
    payment_date DATE NOT NULL DEFAULT CURRENT_DATE,
    created_at   TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS idx_payments_direction ON payments(direction);

-- ============================ EXPENSES ============================
CREATE TABLE IF NOT EXISTS expenses (
    id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    category     TEXT NOT NULL DEFAULT 'General',
    amount       NUMERIC(12,2) NOT NULL DEFAULT 0,
    note         TEXT DEFAULT '',
    expense_date DATE NOT NULL DEFAULT CURRENT_DATE,
    created_at   TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS idx_expenses_category ON expenses(category);

-- ============================== RLS ==============================
ALTER TABLE payments ENABLE ROW LEVEL SECURITY;
ALTER TABLE expenses ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS payments_auth_all ON payments;
CREATE POLICY payments_auth_all ON payments FOR ALL TO authenticated USING (true) WITH CHECK (true);

DROP POLICY IF EXISTS expenses_auth_all ON expenses;
CREATE POLICY expenses_auth_all ON expenses FOR ALL TO authenticated USING (true) WITH CHECK (true);
