# 04 · Supabase Backend (`supabase/`)

> ⚠️ **Updated:** there are now **18 migrations** (v11–v18 add catalog grants, service_role grants,
> demo seed, retailer accounts, and `role`). Run `schema.sql` → `schema_v18` in order. See
> **[09-current-state.md](09-current-state.md) §4** for the migration table and the "RLS ≠ GRANTs" lesson.

A multi-tenant PostgreSQL backend. **No app server** — all logic is in RLS policies and
`SECURITY DEFINER` RPC functions. Run the migrations **in order**: `schema.sql` first,
then `schema_v2` … `schema_v10`.

## Migration timeline

| File | Adds |
|------|------|
| `schema.sql` | Core catalog + user tables (categories, products, price_slabs, banners, app_users, orders, order_items, ledger_entries) + base RLS (auth read catalog; own-row read for user data). |
| `schema_v2_persistence.sql` | Business layer: parties, sale_invoices(+items), purchases(+items). Initially permissive auth. |
| `schema_v3_write_policies.sql` | **Fix:** INSERT/UPDATE policies for `authenticated` (owner-scoped writes) — without this, clients could only SELECT. |
| `schema_v4_functions.sql` | Atomic RPCs: `place_order()`, `create_sale_invoice()`, `create_purchase_with_items()` (master+detail in one txn). |
| `schema_v5_seed.sql` | Seeds 8 categories, 30 products (p1–p30), 73 price slabs. Idempotent (`ON CONFLICT DO UPDATE`). |
| `schema_v6_realtime.sql` | RPC side-effects: invoices/purchases auto-create+update party balances; orders auto-post a debit ledger entry. Deterministic MD5 party IDs so repeat bills consolidate. |
| `schema_v7_transactions.sql` | payments (in/out; cash/upi/bank/cheque) + expenses tables. |
| `schema_v8_documents.sql` | Polymorphic `documents` table (ESTIMATE/SALE ORDER/DELIVERY CHALLAN/CREDIT NOTE/DEBIT NOTE/PURCHASE ORDER), items as JSONB, discriminated by `doc_type`. |
| `schema_v9_security.sql` | **CRITICAL hardening** (see below). |
| `schema_v10_invoice_seq.sql` | GST Rule 46(b): per-user `counters` table + `next_counter()` RPC → sequential invoice numbers (`INV/2526/0001`, ≤16 chars). |

## Tables

| Table | Key columns | FKs / notes |
|-------|-------------|-------------|
| **categories** | id, name, icon_code, color_hex, item_count | 8 seeded |
| **products** | id, name, brand, category_id, image_url, unit, mrp, moq, stock, is_popular, is_featured, description | category_id→categories (SET NULL); 30 seeded |
| **price_slabs** | id, product_id, min_qty, price_per_unit | product_id→products (CASCADE); 73 seeded |
| **banners** | id, image_url, title, action_url | — |
| **app_users** | id (UUID), phone (UNIQUE), name, shop_name, gst, created_at | id→auth.users (CASCADE) |
| **orders** | id (UUID), user_id, status, total, created_at | user_id→app_users (CASCADE) |
| **order_items** | id, order_id, product_id, qty, unit_price | order_id→orders (CASCADE); product_id→products (RESTRICT) |
| **ledger_entries** | id, user_id, type, amount, note, created_at | user_id→app_users (CASCADE) |
| **parties** | id, **user_id**, name, phone, type, address, gstin, opening_balance, balance | PK = `cust_`/`supp_` + md5(user_id‖name) |
| **sale_invoices** | id (UUID), **user_id**, party_name, invoice_date, subtotal, gst_amount, total | auto-creates customer party |
| **sale_invoice_items** | id, invoice_id, **user_id**, item_name, qty, rate, amount | invoice_id→sale_invoices (CASCADE) |
| **purchases** | id (UUID), **user_id**, supplier_name, bill_no, purchase_date, subtotal, gst_amount, total | auto-creates supplier party |
| **purchase_items** | id, purchase_id, **user_id**, item_name, qty, rate, amount | purchase_id→purchases (CASCADE) |
| **payments** | id (UUID), **user_id**, party_name, direction, amount, mode, note, payment_date | modes: cash/upi/bank/cheque |
| **expenses** | id (UUID), **user_id**, category, amount, note, expense_date | — |
| **documents** | id (UUID), **user_id**, doc_type, doc_no, party_name, party_gstin, doc_date, subtotal, cgst, sgst, total, items (JSONB) | polymorphic |
| **counters** | user_id (PK), key (PK), value | per-user atomic sequence (v10) |

**Bold `user_id`** columns were added in v9 for multi-tenant isolation.

## RLS

- **Catalog** (categories, products, price_slabs, banners): read-only for all
  `authenticated`; `service_role` full access. (Shared across tenants.)
- **User & business data** (everything else): owner-only after v9 —
  `USING (user_id = (SELECT auth.uid())) WITH CHECK (user_id = (SELECT auth.uid()))`.
- `service_role` has full access everywhere (used by admin/service tasks).

## RPC functions (all `SECURITY DEFINER`, `GRANT EXECUTE` to authenticated)

| Function | Purpose |
|----------|---------|
| `place_order(total, items)` | v9: **computes total server-side from price_slabs** (ignores client price), validates qty ≥ 1, inserts order+items, posts debit ledger entry. |
| `create_sale_invoice(party_name, subtotal, gst_amount, total, created_at, items)` | Inserts invoice+items, auto-creates/updates customer party balance. |
| `create_purchase_with_items(purchase_data, items_data)` | Inserts purchase+items, auto-creates/updates supplier party balance. |
| `increment_party_balance(p_id, delta)` | Atomic `balance = balance + delta` (prevents lost-update race). |
| `next_counter(p_key)` | Per-user atomic sequence bump; returns next invoice number. |

All v9+ functions set `search_path = ''` (schema-injection defense).

## v9 security hardening (why it matters)

Fixed 3 verified vulnerabilities:
1. **Multi-tenant leak** — added `user_id` to all business tables; replaced permissive
   `USING(true)` with owner-only policies.
2. **Global party collision** — party ID changed from `md5(name)` to `md5(auth.uid()‖name)`
   so balances don't merge across users.
3. **Pricing trust** — `place_order()` now computes prices from `price_slabs` server-side,
   rejecting client-supplied totals.

## Seed data (v5)

- **8 categories:** Groceries & Staples, Beverages, Snacks & Namkeen, Personal Care,
  Home Care, Dairy & Bakery, Packaged Food, Stationery.
- **30 products** across real FMCG brands (India Gate, Aashirvaad, Fortune, Tata, Coca-Cola,
  Lay's, Haldiram, Parle, Colgate, Amul, Britannia, Maggi, etc.), each with MRP/MOQ/stock.
- **73 price slabs** (1–3 tiers per product) for bulk discounts.

## Realtime (v6)

Not websockets — the RPCs perform **synchronous side effects** in the same transaction:
invoice→party balance, purchase→supplier balance, order→ledger debit. Client sees final
state immediately.

## Setup (see [`SUPABASE_SETUP.md`](../SUPABASE_SETUP.md) + [`admin-next/SUPABASE_ADMIN_SETUP.md`](../admin-next/SUPABASE_ADMIN_SETUP.md))

1. Create a Supabase project (region Mumbai for India).
2. SQL Editor → run `schema.sql` then each `schema_v*.sql` in order (run v5 seed for demo data).
3. Project Settings → API → copy URL + anon (publishable) key.
4. Mobile: paste into [`lib/data/supabase_config.dart`](../lib/data/supabase_config.dart).
   Admin: paste into `admin-next/.env.local`.
5. Enable **Phone** auth provider + an SMS provider (MSG91/Twilio) for OTP in production.
