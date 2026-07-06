-- MY ORDER PRO - one-time live catalog cleanup.
--
-- Use this ONLY when the distributor wants to remove the demo catalog and start
-- adding their own categories/products from the admin panel.
--
-- WARNING:
-- - This is destructive.
-- - It removes existing catalog products/categories/banners.
-- - It also removes order rows that reference those products, because
--   order_items.product_id is protected by a foreign key.
-- - Do not run this after real customer orders have started.
--
-- Run in Supabase SQL Editor after taking a database backup.

BEGIN;

-- Orders depend on products through order_items.product_id.
-- Clear child rows first, then order masters.
DELETE FROM public.order_items;
DELETE FROM public.orders;

-- Ledger rows in the demo/current setup can include order debits/recharges.
-- Keep this reset aligned with a fresh catalog launch.
DELETE FROM public.ledger_entries;

-- Product prices depend on products.
DELETE FROM public.price_slabs;

-- Shared catalog content.
DELETE FROM public.products;
DELETE FROM public.categories;
DELETE FROM public.banners;

COMMIT;

-- After running:
-- 1. Open admin panel -> Categories -> Add Category.
-- 2. Open admin panel -> Products -> Add Product.
-- 3. Add banners if needed from admin panel -> Banners.
