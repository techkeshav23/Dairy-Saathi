-- schema_v21_settings.sql
-- Table to store global settings for the distributor/admin.
-- Includes a constraint to ensure only a single row exists.
-- Run in Supabase SQL Editor.

CREATE TABLE IF NOT EXISTS store_settings (
    id INT PRIMARY KEY DEFAULT 1,
    business_name TEXT DEFAULT 'MY ORDER PRO',
    gstin TEXT DEFAULT '',
    contact TEXT DEFAULT '',
    email TEXT DEFAULT '',
    address TEXT DEFAULT '',
    preferences JSONB DEFAULT '{"new_order_alerts": true, "low_stock_warnings": true, "daily_sales_digest": false, "auto_approve_recharges": false, "allow_khata": true}'::jsonb,
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    CONSTRAINT single_row CHECK (id = 1)
);

-- Insert the default row if it doesn't exist
INSERT INTO store_settings (id) VALUES (1) ON CONFLICT (id) DO NOTHING;

-- Enable RLS
ALTER TABLE store_settings ENABLE ROW LEVEL SECURITY;

-- Allow read access for authenticated users (retailers need it for invoices)
CREATE POLICY "Allow authenticated read access on store_settings" 
ON store_settings FOR SELECT TO authenticated USING (true);

-- Allow full access for service_role
CREATE POLICY "Allow service role full access on store_settings" 
ON store_settings FOR ALL TO service_role USING (true) WITH CHECK (true);
