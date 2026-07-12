-- MY ORDER PRO — Schema v34 (admin AI config: Gemini key + model)
--
-- Holds the admin's Gemini API key + chosen model for the AI Bill Reader. This is
-- SENSITIVE (the API key), so the table is SERVICE_ROLE ONLY — no anon/authenticated
-- policy exists, meaning the mobile app (retailers) can NEVER read the key. Only the
-- admin API routes (service_role, server-side) touch it.

CREATE TABLE IF NOT EXISTS admin_config (
  id             INT PRIMARY KEY DEFAULT 1,
  gemini_api_key TEXT,
  gemini_model   TEXT NOT NULL DEFAULT 'gemini-2.5-flash',
  ai_enabled     BOOLEAN NOT NULL DEFAULT FALSE,
  updated_at     TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  CONSTRAINT admin_config_single_row CHECK (id = 1)
);

ALTER TABLE admin_config ENABLE ROW LEVEL SECURITY;

-- Only service_role. (No anon/authenticated policy => they get zero access.)
DROP POLICY IF EXISTS "admin_config service_role all" ON admin_config;
CREATE POLICY "admin_config service_role all"
  ON admin_config FOR ALL TO service_role USING (TRUE) WITH CHECK (TRUE);

GRANT ALL ON admin_config TO service_role;

-- Seed the single config row.
INSERT INTO admin_config (id) VALUES (1) ON CONFLICT (id) DO NOTHING;
