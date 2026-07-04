-- schema_v15_service_role_grants.sql
-- Admin console read fix. The admin uses the service_role key (server-side) to read
-- every retailer's data, bypassing RLS. But service_role — like anon/authenticated
-- earlier (v12) — was never granted table-level privileges, so even it hit
-- "permission denied for table orders" (SQLSTATE 42501). RLS bypass does NOT bypass
-- table GRANTs. This grants full access to service_role across the schema.
--
-- Run ONCE in the Supabase SQL Editor (Role: postgres). Safe to re-run.

GRANT USAGE ON SCHEMA public TO service_role;

GRANT ALL PRIVILEGES ON ALL TABLES    IN SCHEMA public TO service_role;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO service_role;
GRANT ALL PRIVILEGES ON ALL FUNCTIONS IN SCHEMA public TO service_role;

-- future objects inherit the same
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES    TO service_role;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON SEQUENCES TO service_role;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON FUNCTIONS TO service_role;

-- Verify: this should now return rows (not 42501):
--   select count(*) from orders;
