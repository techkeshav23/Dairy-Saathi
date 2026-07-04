-- schema_v11_public_catalog_read.sql
-- FIX: "Place Order" (and Home) showed blank because the catalog tables were
-- readable only by the `authenticated` role. When the app runs without a signed-in
-- Supabase session, requests go as `anon`, which had NO grant -> "permission denied
-- for table categories" (SQLSTATE 42501). The catalog provider swallows that error
-- and renders an empty list, so the screen looks blank.
--
-- The catalog (categories, products, price_slabs, banners) is PUBLIC, non-sensitive
-- data — a wholesale catalog meant to be browseable. This migration makes it
-- readable by BOTH anon and authenticated roles. All private/business tables stay
-- owner-only (unchanged).
--
-- Run this in the Supabase SQL Editor AFTER schema.sql .. schema_v10, and make sure
-- schema_v5_seed.sql has been run so there is actual catalog data to show.

-- 1) Table-level SELECT grants for the anon role (RLS still applies on top).
GRANT SELECT ON public.categories  TO anon;
GRANT SELECT ON public.products    TO anon;
GRANT SELECT ON public.price_slabs TO anon;
GRANT SELECT ON public.banners     TO anon;

-- 2) RLS policies allowing anon (public) reads on the catalog.
--    (Existing "authenticated" read policies remain; these add the anon path.)

DROP POLICY IF EXISTS "Allow public read access on categories" ON public.categories;
CREATE POLICY "Allow public read access on categories"
ON public.categories FOR SELECT TO anon USING (true);

DROP POLICY IF EXISTS "Allow public read access on products" ON public.products;
CREATE POLICY "Allow public read access on products"
ON public.products FOR SELECT TO anon USING (true);

DROP POLICY IF EXISTS "Allow public read access on price_slabs" ON public.price_slabs;
CREATE POLICY "Allow public read access on price_slabs"
ON public.price_slabs FOR SELECT TO anon USING (true);

DROP POLICY IF EXISTS "Allow public read access on banners" ON public.banners;
CREATE POLICY "Allow public read access on banners"
ON public.banners FOR SELECT TO anon USING (true);

-- After running this, verify with (should return rows, not a 42501 error):
--   select count(*) from categories;
--   select count(*) from products;
