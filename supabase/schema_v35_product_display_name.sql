-- MY ORDER PRO — Schema v35 (customer-facing product display name)
--
-- The bill/supplier product name is internal (admin only). The app must show a separate
-- customer-facing "display name" to retailers/firm owners — and must NEVER show the bill
-- name. Products with NO display_name are hidden in the app until the admin sets one.
--
--   products.name         = internal / bill name (admin only)
--   products.display_name = shown in the app (NULL => product hidden in the app)

ALTER TABLE products
  ADD COLUMN IF NOT EXISTS display_name TEXT;
