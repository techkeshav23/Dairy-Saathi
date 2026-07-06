-- schema_v22_retailer_notes.sql
-- Table to store interactions/notes for a specific retailer.
-- Run in Supabase SQL Editor.

CREATE TABLE IF NOT EXISTS retailer_notes (
    id BIGSERIAL PRIMARY KEY,
    retailer_id UUID NOT NULL REFERENCES app_users(id) ON DELETE CASCADE,
    note TEXT NOT NULL,
    type TEXT NOT NULL DEFAULT 'note', -- 'note', 'call', 'whatsapp'
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_retailer_notes_retailer_id ON retailer_notes(retailer_id);

-- Enable RLS
ALTER TABLE retailer_notes ENABLE ROW LEVEL SECURITY;

-- Allow read access for authenticated users
CREATE POLICY "Allow authenticated read access on retailer_notes" 
ON retailer_notes FOR SELECT TO authenticated USING (auth.uid() = retailer_id);

-- Allow full access for service_role
CREATE POLICY "Allow service role full access on retailer_notes" 
ON retailer_notes FOR ALL TO service_role USING (true) WITH CHECK (true);
