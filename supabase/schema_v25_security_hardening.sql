-- MY ORDER PRO — Schema v25 (security hardening for launch)
--
-- Fixes real holes found by the Supabase security linter:
--   1. Catalog tables (products / categories / price_slabs / banners) had a
--      `... write authed` policy that let ANY signed-in user (including retailers)
--      insert/update/delete the catalog. Restrict writes to the distributor only.
--      (Admin panel is unaffected — it writes via the service_role client, bypassing RLS.)
--   2. apply_stock_purchase (admin stock-in RPC) was executable by anon/authenticated.
--      Lock it to service_role only.
--   3. update_stock_on_order_confirm() had a mutable search_path — pin it.
--
-- Catalog READ stays public (anon + authenticated) — retailers still browse normally.

-- ------------------------------------------------------------------ 1. Catalog writes → distributor only
-- Distributor = an app_users row for the current uid with role = 'distributor'.
-- (Users can read their own app_users row, so this EXISTS check works under RLS.)

DROP POLICY IF EXISTS "products write authed" ON products;
CREATE POLICY "products write distributor" ON products FOR ALL TO authenticated
  USING      (EXISTS (SELECT 1 FROM app_users u WHERE u.id = auth.uid() AND u.role = 'distributor'))
  WITH CHECK (EXISTS (SELECT 1 FROM app_users u WHERE u.id = auth.uid() AND u.role = 'distributor'));

DROP POLICY IF EXISTS "categories write authed" ON categories;
CREATE POLICY "categories write distributor" ON categories FOR ALL TO authenticated
  USING      (EXISTS (SELECT 1 FROM app_users u WHERE u.id = auth.uid() AND u.role = 'distributor'))
  WITH CHECK (EXISTS (SELECT 1 FROM app_users u WHERE u.id = auth.uid() AND u.role = 'distributor'));

DROP POLICY IF EXISTS "price_slabs write authed" ON price_slabs;
CREATE POLICY "price_slabs write distributor" ON price_slabs FOR ALL TO authenticated
  USING      (EXISTS (SELECT 1 FROM app_users u WHERE u.id = auth.uid() AND u.role = 'distributor'))
  WITH CHECK (EXISTS (SELECT 1 FROM app_users u WHERE u.id = auth.uid() AND u.role = 'distributor'));

DROP POLICY IF EXISTS "banners write authed" ON banners;
CREATE POLICY "banners write distributor" ON banners FOR ALL TO authenticated
  USING      (EXISTS (SELECT 1 FROM app_users u WHERE u.id = auth.uid() AND u.role = 'distributor'))
  WITH CHECK (EXISTS (SELECT 1 FROM app_users u WHERE u.id = auth.uid() AND u.role = 'distributor'));

-- ------------------------------------------------------------------ 2. Lock admin stock-in RPC
REVOKE EXECUTE ON FUNCTION apply_stock_purchase(text, text, text, text, jsonb) FROM PUBLIC, anon, authenticated;
-- service_role keeps EXECUTE (granted in v24) — the admin API uses it.

-- ------------------------------------------------------------------ 3. Pin mutable search_path
ALTER FUNCTION public.update_stock_on_order_confirm() SET search_path = public;
