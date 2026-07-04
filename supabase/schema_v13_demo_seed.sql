-- schema_v13_demo_seed.sql
-- Rich DEMO DATA for the whole app so every screen looks populated.
-- Safe to run in the Supabase SQL Editor (Role: postgres). Idempotent:
--   * catalog banners use fixed ids (ON CONFLICT DO UPDATE)
--   * per-user transactional data is skipped for any user already demo-seeded
--     (marker: an expense row with note = 'DEMO_SEED')
--
-- It also re-asserts the role grants from v12 (harmless if already run), so running
-- THIS file alone is enough to both fix permissions AND load demo data.
--
-- NOTE: orders / ledger / parties / invoices / purchases / payments / expenses /
-- documents are per-user (RLS: user_id = auth.uid()). This seeds them for EVERY
-- existing auth user, so whoever is logged in on the app will see the data.

-- =============================================================
-- 0) ROLE GRANTS (same as v12 — idempotent safety net)
-- =============================================================
GRANT USAGE ON SCHEMA public TO anon, authenticated;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO anon;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO authenticated;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO anon, authenticated;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT ON TABLES TO anon;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO authenticated;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT USAGE, SELECT ON SEQUENCES TO anon, authenticated;

-- =============================================================
-- 1) BANNERS — the app reads columns title, subtitle, tag, image, accent_hex
--    but the base table only had image_url/title/action_url. Add the missing
--    columns, then seed a few promo banners for the Home carousel.
-- =============================================================
ALTER TABLE banners ADD COLUMN IF NOT EXISTS subtitle   TEXT;
ALTER TABLE banners ADD COLUMN IF NOT EXISTS tag        TEXT;
ALTER TABLE banners ADD COLUMN IF NOT EXISTS image      TEXT;
ALTER TABLE banners ADD COLUMN IF NOT EXISTS accent_hex TEXT;

-- NOTE: base `banners` table has image_url NOT NULL, so we fill both image_url and image.
INSERT INTO banners (id, title, subtitle, tag, image_url, image, accent_hex) VALUES
  ('b1','Aaj ka Bumper Stock','Basmati • Atta • Oil — bulk rate par', 'STOCK AVAILABLE',
     'https://picsum.photos/seed/mop-rice/900/360', 'https://picsum.photos/seed/mop-rice/900/360', '#E2231A'),
  ('b2','Free Delivery ₹5000+','Bade order par delivery bilkul free', 'OFFER',
     'https://picsum.photos/seed/mop-delivery/900/360', 'https://picsum.photos/seed/mop-delivery/900/360', '#0CA678'),
  ('b3','Khata pe Saman Lo','Aaj order, baad me payment — Pay Later', 'KHATA',
     'https://picsum.photos/seed/mop-khata/900/360', 'https://picsum.photos/seed/mop-khata/900/360', '#7048E8')
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title, subtitle = EXCLUDED.subtitle, tag = EXCLUDED.tag,
  image_url = EXCLUDED.image_url, image = EXCLUDED.image, accent_hex = EXCLUDED.accent_hex;

-- =============================================================
-- 2) PER-USER TRANSACTIONAL DEMO DATA
-- =============================================================
DO $$
DECLARE
  v_uid  UUID;
  v_oid  UUID;
  v_inv  UUID;
  v_pur  UUID;
  v_ph   TEXT;
BEGIN
  FOR v_uid IN SELECT id FROM auth.users LOOP

    -- skip users that already have demo data
    IF EXISTS (SELECT 1 FROM public.expenses WHERE user_id = v_uid AND note = 'DEMO_SEED') THEN
      CONTINUE;
    END IF;

    -- ---- app_users profile (unique phone per user) ----
    v_ph := COALESCE((SELECT phone FROM auth.users WHERE id = v_uid), 'demo_' || left(v_uid::text, 8));
    INSERT INTO public.app_users (id, phone, name, shop_name, gst)
    VALUES (v_uid, v_ph, 'Demo Retailer', 'Sharma Kirana Store', '09ABCDE1234F1Z5')
    ON CONFLICT (id) DO UPDATE
      SET name      = COALESCE(public.app_users.name, EXCLUDED.name),
          shop_name = COALESCE(public.app_users.shop_name, EXCLUDED.shop_name),
          gst       = COALESCE(public.app_users.gst, EXCLUDED.gst);

    -- ---- LEDGER / KHATA (debit = you owe, credit = paid) ----
    INSERT INTO public.ledger_entries (user_id, type, amount, note, created_at) VALUES
      (v_uid,'debit', 12500,'Order SA1001 (Khata)', now() - interval '9 days'),
      (v_uid,'credit',10000,'Payment received (UPI)', now() - interval '7 days'),
      (v_uid,'debit',  8400,'Order SA1002 (Khata)', now() - interval '5 days'),
      (v_uid,'debit',  6200,'Order SA1003 (Khata)', now() - interval '3 days'),
      (v_uid,'credit', 5000,'Cash payment', now() - interval '2 days'),
      (v_uid,'debit',  3100,'Order SA1004 (Khata)', now() - interval '1 days');

    -- ---- ORDERS + line items (product ids p1..p30 exist from v5 seed) ----
    INSERT INTO public.orders (user_id, status, total, created_at)
      VALUES (v_uid,'delivered', 12500, now() - interval '9 days') RETURNING id INTO v_oid;
    INSERT INTO public.order_items (order_id, product_id, qty, unit_price) VALUES
      (v_oid,'p1', 5, 1790), (v_oid,'p2', 3, 410), (v_oid,'p7', 2, 5100);

    INSERT INTO public.orders (user_id, status, total, created_at)
      VALUES (v_uid,'dispatched', 8400, now() - interval '5 days') RETURNING id INTO v_oid;
    INSERT INTO public.order_items (order_id, product_id, qty, unit_price) VALUES
      (v_oid,'p12', 10, 760), (v_oid,'p13', 4, 200);

    INSERT INTO public.orders (user_id, status, total, created_at)
      VALUES (v_uid,'placed', 3100, now() - interval '1 days') RETURNING id INTO v_oid;
    INSERT INTO public.order_items (order_id, product_id, qty, unit_price) VALUES
      (v_oid,'p20', 6, 300), (v_oid,'p21', 2, 650);

    -- ---- PARTIES (customers + suppliers), same id scheme as the app ----
    INSERT INTO public.parties (id, user_id, name, phone, type, address, gstin, balance) VALUES
      ('cust_' || md5(v_uid::text || 'ramesh general store'), v_uid,'Ramesh General Store','9812345670','customer','MG Road, Kanpur','09AAAAA0000A1Z1', 4200),
      ('cust_' || md5(v_uid::text || 'gupta provision'),      v_uid,'Gupta Provision',     '9812345671','customer','Civil Lines, Kanpur','', 0),
      ('supp_' || md5(v_uid::text || 'agarwal distributors'), v_uid,'Agarwal Distributors','9898989890','supplier','Wholesale Market, Kanpur','09BBBBB1111B1Z2', 15000),
      ('supp_' || md5(v_uid::text || 'sharma traders'),       v_uid,'Sharma Traders',      '9898989891','supplier','Grain Mandi, Kanpur','', 8000)
    ON CONFLICT (id) DO NOTHING;

    -- ---- SALE INVOICE + items ----
    INSERT INTO public.sale_invoices (user_id, party_name, subtotal, gst_amount, total)
      VALUES (v_uid,'Ramesh General Store', 4000, 200, 4200) RETURNING id INTO v_inv;
    INSERT INTO public.sale_invoice_items (user_id, invoice_id, item_name, qty, rate, amount) VALUES
      (v_uid, v_inv,'Aashirvaad Atta 10kg', 5, 400, 2000),
      (v_uid, v_inv,'Fortune Sunflower Oil 1L', 4, 500, 2000);

    -- ---- PURCHASE + items ----
    INSERT INTO public.purchases (user_id, supplier_name, bill_no, subtotal, gst_amount, total)
      VALUES (v_uid,'Agarwal Distributors','BILL-2231', 14300, 700, 15000) RETURNING id INTO v_pur;
    INSERT INTO public.purchase_items (user_id, purchase_id, item_name, qty, rate, amount) VALUES
      (v_uid, v_pur,'India Gate Basmati Rice 25kg', 10, 1200, 12000),
      (v_uid, v_pur,'Tata Salt 1kg', 100, 23, 2300);

    -- ---- PAYMENTS (in/out) ----
    INSERT INTO public.payments (user_id, party_name, direction, amount, mode, note, payment_date) VALUES
      (v_uid,'Ramesh General Store','in', 10000,'upi','Against invoice', current_date - 2),
      (v_uid,'Agarwal Distributors','out', 8000,'bank','Part payment',    current_date - 1);

    -- ---- EXPENSES (last row is the DEMO_SEED marker) ----
    INSERT INTO public.expenses (user_id, category, amount, note, expense_date) VALUES
      (v_uid,'Transport',   1200,'Tempo hire',  current_date - 3),
      (v_uid,'Electricity', 2400,'Shop bill',   current_date - 2),
      (v_uid,'Staff',       8000,'Salary',      current_date - 1),
      (v_uid,'General',        0,'DEMO_SEED',   current_date);

    -- ---- DOCUMENTS (estimate + purchase order) ----
    INSERT INTO public.documents (user_id, doc_type, doc_no, party_name, party_gstin, subtotal, cgst, sgst, total, items) VALUES
      (v_uid,'ESTIMATE','EST-001','Gupta Provision','', 5000, 125, 125, 5250,
        '[{"item_name":"Sugar 50kg","qty":1,"rate":2100,"amount":2100},{"item_name":"Maida 25kg","qty":2,"rate":1450,"amount":2900}]'::jsonb),
      (v_uid,'PURCHASE ORDER','PO-014','Sharma Traders','', 8000, 200, 200, 8400,
        '[{"item_name":"Toor Dal 30kg","qty":2,"rate":4000,"amount":8000}]'::jsonb);

  END LOOP;
END $$;

-- Verify afterwards:
--   select count(*) from banners;                         -- 3
--   select count(*) from orders;                          -- 3 per logged-in user
--   select count(*) from ledger_entries;                  -- 6 per logged-in user
--   select count(*) from parties;                         -- 4 per logged-in user
