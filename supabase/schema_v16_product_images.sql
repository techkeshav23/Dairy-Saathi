-- schema_v16_product_images.sql
-- The v5 seed set product image_url to loremflickr.com URLs, which are now slow /
-- unreliable and often fail to load in the admin portal and mobile app. This swaps
-- them for reliable picsum.photos images (one distinct image per product, keyed by id).
--
-- Only touches seeded/empty images — any product you gave a real image URL is left alone.
-- Run in the Supabase SQL Editor (Role: postgres). Safe to re-run.

UPDATE products
SET image_url = 'https://picsum.photos/seed/mop-' || id || '/600/600'
WHERE image_url LIKE '%loremflickr%'
   OR image_url IS NULL
   OR image_url = '';

-- Verify:
--   select name, image_url from products limit 5;
