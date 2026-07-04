-- MY ORDER PRO — Write policies patch v3 (added 2026-07-01).
-- Run this AFTER schema.sql and schema_v2_persistence.sql.
--
-- WHY: schema.sql only granted authenticated SELECT on its core tables, and
-- full access only to service_role. The mobile app talks to Supabase with the
-- *publishable* key (authenticated role after login), NOT the secret key — so
-- without these INSERT/UPDATE policies every write (create profile, place order,
-- add ledger) fails Row Level Security. This patch adds the missing writes.
--
-- Idempotent: each policy is dropped-if-exists first, so re-running is safe.

-- ===================== app_users (own profile only) =====================
DROP POLICY IF EXISTS "app_users insert own" ON app_users;
CREATE POLICY "app_users insert own" ON app_users
  FOR INSERT TO authenticated WITH CHECK (auth.uid() = id);

DROP POLICY IF EXISTS "app_users update own" ON app_users;
CREATE POLICY "app_users update own" ON app_users
  FOR UPDATE TO authenticated USING (auth.uid() = id) WITH CHECK (auth.uid() = id);

-- ===================== orders (own orders only) =====================
DROP POLICY IF EXISTS "orders insert own" ON orders;
CREATE POLICY "orders insert own" ON orders
  FOR INSERT TO authenticated WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "orders update own" ON orders;
CREATE POLICY "orders update own" ON orders
  FOR UPDATE TO authenticated USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);

-- ============== order_items (rows under an order the user owns) ==============
DROP POLICY IF EXISTS "order_items insert own" ON order_items;
CREATE POLICY "order_items insert own" ON order_items
  FOR INSERT TO authenticated WITH CHECK (
    EXISTS (
      SELECT 1 FROM orders
      WHERE orders.id = order_items.order_id
        AND orders.user_id = auth.uid()
    )
  );

-- ===================== ledger_entries (own rows only) =====================
DROP POLICY IF EXISTS "ledger insert own" ON ledger_entries;
CREATE POLICY "ledger insert own" ON ledger_entries
  FOR INSERT TO authenticated WITH CHECK (auth.uid() = user_id);

-- ===================== catalog (Phase-1 self-use) =====================
-- Any authenticated user (i.e. the founder via the admin panel) can manage
-- the catalog. TODO(Phase 2): restrict to an admin role or write via the
-- secret key server-side once real retailers use the app.
DROP POLICY IF EXISTS "categories write authed" ON categories;
CREATE POLICY "categories write authed" ON categories
  FOR ALL TO authenticated USING (true) WITH CHECK (true);

DROP POLICY IF EXISTS "products write authed" ON products;
CREATE POLICY "products write authed" ON products
  FOR ALL TO authenticated USING (true) WITH CHECK (true);

DROP POLICY IF EXISTS "price_slabs write authed" ON price_slabs;
CREATE POLICY "price_slabs write authed" ON price_slabs
  FOR ALL TO authenticated USING (true) WITH CHECK (true);

DROP POLICY IF EXISTS "banners write authed" ON banners;
CREATE POLICY "banners write authed" ON banners
  FOR ALL TO authenticated USING (true) WITH CHECK (true);
