-- ==========================================
-- WIPE DEMO DATA SCRIPT
-- ==========================================
-- Run this script in your Supabase SQL Editor ONLY WHEN YOU WANT TO START FRESH.
-- It will delete all Products, Categories, Orders, and Ledger entries.
-- It WILL NOT delete your users/retailers.

TRUNCATE TABLE 
  order_items, 
  orders, 
  ledger_entries, 
  retailer_notes, 
  price_slabs, 
  products, 
  categories 
RESTART IDENTITY CASCADE;

-- If you also want to delete all Retailers (except yourself), you can run:
-- DELETE FROM app_users WHERE role = 'retailer';
