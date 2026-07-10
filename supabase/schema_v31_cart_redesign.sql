-- MY ORDER PRO — Schema v31 (cart redesign: resale price, EA/KG units, order window)
--
-- 1. products.resale_price  — suggested resale price shown to the retailer (per EA/pack).
--    products.ea_per_kg      — how many base units (EA/pack) make 1 KG. 0 = no KG option
--                              (product is ordered only in EA). Prices are stored per EA;
--                              the KG price is derived as (price * ea_per_kg) in the app.
-- 2. store_settings.ship_from_address — the plant/warehouse address ("Ship From").
--    store_settings.order_open_time / order_cutoff_time — daily order window ("HH:MM").
--    After the cutoff, the app blocks Place Order ("Order taking time is over").

ALTER TABLE products
  ADD COLUMN IF NOT EXISTS resale_price NUMERIC(10, 2) NOT NULL DEFAULT 0,
  ADD COLUMN IF NOT EXISTS ea_per_kg    NUMERIC(10, 2) NOT NULL DEFAULT 0;

ALTER TABLE store_settings
  ADD COLUMN IF NOT EXISTS ship_from_address TEXT,
  ADD COLUMN IF NOT EXISTS order_open_time   TEXT,
  ADD COLUMN IF NOT EXISTS order_cutoff_time TEXT;
