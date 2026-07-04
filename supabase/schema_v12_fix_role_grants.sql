-- schema_v12_fix_role_grants.sql
-- ROOT-CAUSE FIX for "permission denied for table ..." (SQLSTATE 42501) that made the
-- app show blank / "No categories found" even for logged-in users.
--
-- The original schema created RLS *policies* (TO authenticated / service_role) but never
-- granted the underlying TABLE-LEVEL privileges to the `anon` and `authenticated` roles.
-- In Supabase, both are required: the GRANT lets the role touch the table at all, and RLS
-- then filters which rows it may see. Without the GRANT, every query fails with 42501.
--
-- v11 fixed only `anon` (so anonymous REST/curl worked), but the mobile app runs as
-- `authenticated` (a signed-in session), which was still missing the grant. This migration
-- restores the standard Supabase grants for BOTH roles across ALL tables + sequences, and
-- sets default privileges so future tables are covered too. RLS still enforces row access,
-- so this is safe (anon/authenticated only ever see rows their policies allow).
--
-- Run this ONCE in the Supabase SQL Editor (Role: postgres). Safe to re-run.

-- Schema usage
GRANT USAGE ON SCHEMA public TO anon, authenticated;

-- Existing tables: catalog is public-read; authenticated gets full DML (RLS gates rows)
GRANT SELECT ON ALL TABLES IN SCHEMA public TO anon;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO authenticated;

-- Sequences (needed for BIGSERIAL PKs: order_items, ledger_entries, price_slabs, *_items, ...)
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO anon, authenticated;

-- Future tables/sequences inherit the same grants (matches Supabase defaults)
ALTER DEFAULT PRIVILEGES IN SCHEMA public
  GRANT SELECT ON TABLES TO anon;
ALTER DEFAULT PRIVILEGES IN SCHEMA public
  GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO authenticated;
ALTER DEFAULT PRIVILEGES IN SCHEMA public
  GRANT USAGE, SELECT ON SEQUENCES TO anon, authenticated;

-- Verify afterwards (should return rows, no 42501):
--   select count(*) from categories;
--   select count(*) from products;
