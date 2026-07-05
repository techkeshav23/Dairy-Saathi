-- schema_v18_user_roles.sql
-- Role-based single app: the SAME mobile app shows a lean retailer experience OR the
-- full distributor/accounting experience, based on the logged-in user's role.
--
-- Run in the Supabase SQL Editor (Role: postgres). Safe to re-run.

ALTER TABLE app_users ADD COLUMN IF NOT EXISTS role TEXT NOT NULL DEFAULT 'retailer';  -- 'retailer' | 'distributor'

CREATE INDEX IF NOT EXISTS idx_app_users_role ON app_users(role);

-- ============================================================
-- Mark YOUR distributor account as a distributor.
-- Replace the email below with the account you'll use as the distributor in the app,
-- then uncomment and run this line:
--
--   UPDATE app_users SET role = 'distributor' WHERE email = 'distributor@myorderpro.in';
--
-- (That account must first exist — sign it up in the app, or create it from the admin
--  Retailers page — so it has an app_users row to update.)
-- ============================================================

-- Verify:
--   select email, business_name, role from app_users;
