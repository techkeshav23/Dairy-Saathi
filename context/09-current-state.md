# 09 · Current State (authoritative — read this first)

> **This doc supersedes the auth / roles / admin-CRUD details in 02–04 where they conflict.**
> Docs 01–08 describe the original build; this captures the major changes since.
> Last updated **2026-07-05**.

The platform is now a **role-based single mobile app + a real-auth admin console**, both on
live Supabase with real CRUD. Below is exactly how it works today.

---

## 1. Authentication (rewritten — no more phone OTP)

**Mobile app** — **email + password** via Supabase Auth (`supabase_flutter`):
- Retailers **self sign-up** in the app (email, password, shop name, owner, phone, area, GST) →
  instant, no approval → an `app_users` profile row is created (`created_by='self'`, `role='retailer'`).
- Or a retailer signs in with a login the **distributor created** for them in the admin.
- Files: [`lib/providers/auth_provider.dart`](../lib/providers/auth_provider.dart) (`signIn`, `signUp`),
  [`lib/features/auth/sign_in_screen.dart`](../lib/features/auth/sign_in_screen.dart),
  [`lib/features/auth/sign_up_screen.dart`](../lib/features/auth/sign_up_screen.dart).
- **Removed:** phone OTP, `verify_otp_screen.dart`. (`Repository.requestOtp/verifyOtp` remain as dead interface methods.)
- ⚠️ **Supabase setting:** for instant self-signup, **"Confirm email" must be OFF** (Auth → Providers → Email).

**Admin console** — **email + password** via `@supabase/ssr` (cookie sessions):
- Login: [`admin-next/src/app/login/page.tsx`](../admin-next/src/app/login/page.tsx) → `signInWithPassword`.
- **Route guard:** [`admin-next/src/proxy.ts`](../admin-next/src/proxy.ts) (Next.js 16 "proxy", formerly middleware) —
  every page **and** `/api/*` requires a session, else redirect to `/login`.
- Clients: [`supabase-browser.ts`](../admin-next/src/lib/supabase-browser.ts) (auth),
  [`supabase-admin.ts`](../admin-next/src/lib/supabase-admin.ts) (service_role, server-only writes).
- The demo admin user: **`admin@admin.com`** (create/manage in Supabase → Authentication → Users).

---

## 2. Roles — one app, two experiences

`app_users.role` = `'retailer'` (default) or `'distributor'`. The mobile app resolves the role on
login and shows a different shell:

| Role | Shell | Contents |
|------|-------|----------|
| **retailer** | [`DashboardScreen`](../lib/features/dashboard/dashboard_screen.dart) | Lean 4-tab: **Home · Orders · Khata · Account** |
| **distributor** | [`DistributorDashboard`](../lib/features/dashboard/distributor_dashboard.dart) | **Dashboard + drawer** (Parties, Sale, Purchase, Expense, Cash & Bank, Items, Online Store, Sync, Backup) + **POS** |

**Who is a distributor:** the configured owner email **OR** any account with `role='distributor'` in the DB.
- Config email: `AuthProvider.distributorEmail` = **`admin@admin.com`** ([`auth_provider.dart`](../lib/providers/auth_provider.dart)).
- So by default there is **one distributor** (the owner). Set `role='distributor'` on another `app_users`
  row in Supabase to add more — no rebuild needed.
- Routing: `RouteHelper.homeFor(isDistributor)` used by sign-in + splash (splash re-fetches the role each launch).
- The distributor drawer lives in [`app_drawer.dart`](../lib/common/widgets/app_drawer.dart); `AnandaTopBar`
  shows a hamburger only when a drawer is present.

> The distributor's accounting screens are Vyapar-style and **scoped to the distributor's own uid** (RLS),
> i.e. their own books — separate from retailers' data.

---

## 3. Admin console — now fully live CRUD

All admin data is live from Supabase via **server-only `service_role`** (RLS-bypassing) API routes /
server components. Enterprise redesign: **dark sidebar + cobalt accent** (see 03 for the design system,
but note the palette moved from red → cobalt/graphite).

| Area | Status | Backing |
|------|--------|---------|
| Dashboard (KPIs + **charts** + recent orders) | ✅ live | `supabase-data.ts` (service_role) |
| Orders | ✅ live + **status lifecycle** (Confirmed→Packed→Dispatched→Delivered/Cancelled via `OrderStatusSelect`) | [`/api/orders`](../admin-next/src/app/api/orders/route.ts) |
| **Retailers** | ✅ **CRUD** — create (auth login + profile), edit, block, delete, role | [`/api/retailers`](../admin-next/src/app/api/retailers/route.ts) |
| **Retailer 360** | ✅ per-retailer CRM page (orders, ledger, notes/interaction log) | [`/retailers/[id]`](../admin-next/src/app/(app)/retailers/[id]/page.tsx) + [`/api/retailers/[id]/notes`](../admin-next/src/app/api/retailers/[id]/notes/route.ts) |
| **Products** | ✅ **CRUD** + image + category filter | [`/api/products`](../admin-next/src/app/api/products/route.ts) |
| **Categories** | ✅ **CRUD** | [`/api/categories`](../admin-next/src/app/api/categories/route.ts) |
| **Banners** | ✅ **CRUD** + image + colour-overlay toggle | [`/api/banners`](../admin-next/src/app/api/banners/route.ts) |
| **Ledger** | ✅ live + manual khata entries (recharges) from admin | [`/api/ledger`](../admin-next/src/app/api/ledger/route.ts) |
| **Settings** | ✅ persisted (`store_settings`, v21) | [`/api/settings`](../admin-next/src/app/api/settings/route.ts) |
| **Purchase / Stock-In** | ✅ live — supplier bill → `apply_purchase` RPC restocks real products + records `purchases` (v24) | [`/api/purchases`](../admin-next/src/app/api/purchases/route.ts) |
| **Reports** | ✅ live charts + real business summary + working CSV exports (fabricated GST table removed) | `supabase-data.ts` + [`ReportDownloads`](../admin-next/src/components/ReportDownloads.tsx) |

- **Banners:** admin **Active/Inactive toggle now persists** (`banners.active`, v24); the mobile app only fetches `active=true`. Earlier the admin showed 3 hardcoded demo banners as a fallback when the table was empty — that mock fallback is **removed**, so an empty table now honestly shows "No banners yet".
- **Dashboard KPIs:** now show **real** values (no mock fallback to fake ₹48L revenue); delta % and sparkline are computed from real monthly data and hidden when there isn't enough history.

- **Add Retailer** = `supabaseAdmin.auth.admin.createUser()` (email+password, pre-confirmed) **+** `app_users`
  profile insert (rolls back the auth user if the profile fails). That login then works in the mobile app.
- Client pages fetch these `/api/*` routes; the **proxy gates them behind admin login**.

---

## 4. Backend — migrations & mechanics

Run `schema.sql` → **`schema_v23`** **in order**. Migrations **v11–v23** (added since the original build):

| File | Purpose |
|------|---------|
| `schema_v11_public_catalog_read.sql` | anon read grants for catalog (fixed blank Place Order) |
| `schema_v12_fix_role_grants.sql` | table GRANTs for `anon` + `authenticated` (RLS ≠ grants) |
| `schema_v13_demo_seed.sql` | banners + per-user demo data (orders/ledger/parties/invoices…) |
| `schema_v14_rich_ledger.sql` | ~28 rich ledger rows/user for a full Statement |
| `schema_v15_service_role_grants.sql` | **GRANTs for `service_role`** — the admin read fix |
| `schema_v16_product_images.sql` | product images loremflickr → reliable picsum |
| `schema_v17_retailer_accounts.sql` | enrich `app_users` (email, business_name, owner_name, area, credit_limit, status, code, created_by) |
| `schema_v18_user_roles.sql` | `app_users.role` (retailer/distributor) |
| `schema_v19_storage.sql` | Supabase Storage bucket for product/banner images (+ policies) |
| `schema_v20_stock_ledger_triggers.sql` | Postgres triggers: order confirm → stock decrement, cancel → restore |
| `schema_v21_settings.sql` | `store_settings` table (admin settings persistence) |
| `schema_v22_retailer_notes.sql` | retailer notes / interaction log (Retailer 360) |
| `schema_v23_qr_payments.sql` | QR payment mode: payment columns on orders, `payment_screenshots` bucket, updated `place_order` |
| `schema_v24_banner_active_and_purchases.sql` | `banners.active` (admin toggle now persists; app shows only active) + `purchases`/`purchase_items` tables + `apply_purchase()` RPC (Purchase/Stock-In now real) |
| `wipe_demo_data.sql` | utility — clears demo/seed data (not a migration; run only on purpose) |

- **P0 Priority backlog is DONE:**
  - **Orders:** Fully manageable (Confirmed/Packed/Dispatched/Delivered) from the Admin panel via `OrderStatusSelect`.
  - **Ledger:** Manual entries for Khata (Retailer Recharges) can be logged directly from Admin panel.
  - **Stock Sync:** Automated stock deduction via Postgres triggers (`schema_v20`).
  - **Credit Limits:** Fetch real `credit_limit` limits in Flutter `auth_provider.dart` and block if exceeded.
  - **Invoices:** Mobile app has a "Download Bill" PDF generator built-in.
- **P1/P2 CRM backlog implemented:**
  - **Settings Persistence:** Store profile settings in `store_settings` table (migration `schema_v21`).
  - **Retailer 360:** Individual CRM dashboards for retailers in Admin panel `/retailers/[id]` with interaction logs (`schema_v22`).

- **Key lesson baked into the migrations:** in Supabase, **RLS policies are not enough — every role
  (`anon`, `authenticated`, `service_role`) also needs table-level `GRANT`s.** Missing grants = SQLSTATE
  42501 "permission denied for table" even for service_role.
- Catalog (categories/products/price_slabs/banners) is **public-read**; user/business tables are **owner-only**
  (`user_id = auth.uid()`); `service_role` bypasses RLS (used by the admin).
- Live project ref: `hkvbietffnfuecxwwsni`. Mobile ships the **publishable** key; the **service_role** key is
  in `admin-next/.env.local` only (gitignored — never commit it).

---

## 5. What's next

The full prioritized backlog is in **[`../ROADMAP.md`](../ROADMAP.md)** (P0 core commerce → P2 CRM depth).
**P0 is complete** (order lifecycle, payments/khata wiring, stock triggers, credit limits, invoices) plus
settings persistence and Retailer 360. Biggest open gaps now: **deployment** (Vercel + Play Store),
**notifications** (new order / status change), reports & exports, pagination/search, and the remaining CRM
depth (segments & tags, follow-ups/tasks, collections & credit risk, campaigns, analytics).

---

## 6. Run / build reminders

- Mobile & admin **must build from a path without `&`/spaces** — the repo lives under `…\Distributor & Retailer`,
  so a clean copy at **`C:\my_order_pro`** is used for `flutter`/`npm`. Edits are made in the repo and synced.
- Admin dev: `cd C:\my_order_pro\admin-next && npm run dev` (needs `.env.local` with URL + anon + **service_role**).
- Mobile release APK: `flutter build apk --release --split-per-abi --no-tree-shake-icons` (the icon flag is
  required — category icons are built dynamically). Release arm64 ≈ 24 MB (debug is ~194 MB).
