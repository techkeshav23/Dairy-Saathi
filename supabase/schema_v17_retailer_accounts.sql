-- schema_v17_retailer_accounts.sql
-- Phase 1 of the full retailer onboarding system. Enriches app_users so the
-- distributor (admin) can create/manage retailer accounts and retailers can self
-- sign up with email + password. Also fixes the admin<->schema column mismatch.
--
-- Run in the Supabase SQL Editor (Role: postgres). Safe to re-run.

ALTER TABLE app_users ADD COLUMN IF NOT EXISTS email               TEXT;
ALTER TABLE app_users ADD COLUMN IF NOT EXISTS business_name       TEXT;
ALTER TABLE app_users ADD COLUMN IF NOT EXISTS owner_name          TEXT;
ALTER TABLE app_users ADD COLUMN IF NOT EXISTS area                TEXT;
ALTER TABLE app_users ADD COLUMN IF NOT EXISTS credit_limit        NUMERIC(12,2) NOT NULL DEFAULT 0;
ALTER TABLE app_users ADD COLUMN IF NOT EXISTS outstanding_balance NUMERIC(12,2) NOT NULL DEFAULT 0;
ALTER TABLE app_users ADD COLUMN IF NOT EXISTS status              TEXT NOT NULL DEFAULT 'active';   -- 'active' | 'blocked'
ALTER TABLE app_users ADD COLUMN IF NOT EXISTS code                TEXT;
ALTER TABLE app_users ADD COLUMN IF NOT EXISTS created_by          TEXT NOT NULL DEFAULT 'self';     -- 'self' | 'admin'

-- Email is now the primary login identifier; phone becomes optional.
ALTER TABLE app_users ALTER COLUMN phone DROP NOT NULL;

-- Backfill the new display fields from existing data.
UPDATE app_users
SET business_name = COALESCE(business_name, NULLIF(shop_name, ''), 'My Shop'),
    owner_name    = COALESCE(owner_name, NULLIF(name, ''), '')
WHERE business_name IS NULL OR owner_name IS NULL;

-- Give existing retailers a simple sequential code where missing.
WITH numbered AS (
  SELECT id, 1000 + row_number() OVER (ORDER BY created_at) AS n
  FROM app_users WHERE code IS NULL
)
UPDATE app_users a SET code = 'R' || numbered.n
FROM numbered WHERE a.id = numbered.id;

CREATE INDEX IF NOT EXISTS idx_app_users_status ON app_users(status);

-- Verify:
--   select code, business_name, owner_name, email, status, credit_limit from app_users;
