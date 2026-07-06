# 08 · Handover Guide (for the next AI agent / developer)

> ⚠️ **Read [09-current-state.md](09-current-state.md) first** — auth (email/password), roles
> (retailer/distributor shells), and live admin CRUD (`src/app/api/*`) landed after this guide.
> Quick "where to change X" additions: **mobile auth** → [`auth_provider.dart`](../lib/providers/auth_provider.dart)
> + `sign_in_screen`/`sign_up_screen`; **who is a distributor** → `AuthProvider.distributorEmail`;
> **admin auth/guard** → [`proxy.ts`](../admin-next/src/proxy.ts) + `supabase-browser.ts`; **admin writes**
> → the `src/app/api/*` routes (service_role). Backlog → [`../ROADMAP.md`](../ROADMAP.md).

You're picking up **MY ORDER PRO**. Read [01-overview.md](01-overview.md) first, then this.
This page is the "where do I look for X" cheat sheet.

## Mental model in 3 sentences
1. A Flutter app (retailers) and a Next.js admin (wholesaler) both talk **directly** to
   Supabase with the anon key — there is no middle server.
2. Everything runs on **mock data** and silently upgrades to **live Supabase** when
   credentials exist (a master switch in one file per app).
3. All server logic (pricing, invoices, party balances, invoice numbers) lives in Postgres
   **RPC functions** protected by **RLS**.

## "Where do I change…?"

| I want to… | Go to |
|-----------|-------|
| Add/modify a mobile screen | `lib/features/<area>/` + register route in `lib/helper/route_helper.dart` |
| Add mobile app state | a provider in `lib/providers/` (register in `lib/main.dart` MultiProvider) |
| Change how data is fetched (catalog) | `lib/data/repository.dart` + `supabase_repository.dart` (keep Mock in sync) |
| Change accounting logic (invoices, parties…) | `lib/data/services/*.dart` |
| Change colors/spacing/fonts (mobile) | `lib/util/app_colors.dart`, `dimensions.dart`, `styles.dart` |
| Change business constants (GST, delivery) | `lib/util/app_constants.dart` |
| Toggle mobile Mock↔live | `lib/data/supabase_config.dart` |
| Add/modify an admin page | `admin-next/src/app/(app)/<page>/page.tsx` |
| Change admin data fetch | `admin-next/src/lib/supabase-data.ts` (+ types in `data.ts`) |
| Change admin styling/components | `admin-next/src/components/*.tsx`, `src/app/globals.css` |
| Toggle admin Mock↔live | `admin-next/.env.local` |
| Change DB schema | add a new `supabase/schema_v11_*.sql` (additive; never rewrite old files) |
| Change server-side pricing/invoicing | the RPC functions (redefine in a new migration) |

## Golden rules (don't break these)
- **Keep the mock path working.** Every new Supabase call needs a mock fallback guarded by
  `SupabaseConfig.useSupabase` (mobile) or graceful `[]`/seed fallback (admin). This is what
  lets the app run without a backend.
- **Screens never call Supabase directly** — go through a Repository or service.
- **Never trust client prices** — pricing is recomputed in `place_order()` from `price_slabs`.
  Follow that pattern for any new money-handling RPC.
- **Migrations are additive** — new `schema_v*.sql`, copy the v9 owner-only RLS pattern
  (`user_id = auth.uid()`), and `SET search_path = ''` on functions.
- **Don't rename** `saathi_*` SharedPreferences keys or the deterministic party-ID scheme
  (`md5(uid‖name)`) — you'll orphan existing data/balances.
- **Don't commit the service_role key.** Anon/publishable key only on clients.

## Verify your change
```bash
flutter analyze                      # mobile — expect: No issues found!
cd admin-next && npx tsc --noEmit    # admin — expect exit 0
```
For release APK builds, first copy the project to a clean path (`C:\my_order_pro`) — Gradle
fails on the `&`/spaces in this folder name.

## First things worth doing (see [07](07-known-issues-and-todos.md))
1. Real admin auth + route guard (currently mock, unguarded).
2. Persist admin writes (products/banners/purchase/settings are client-only).
3. Wire dashboard charts + recent orders to live data.

## Docs map recap
`context/` 01–08 cover overview → flutter → admin → supabase → conventions → build →
issues → this guide. Root docs: `README.md`, `AGENT_BUILD_SUMMARY.md`, `DEPLOY_GUIDE.md`,
`SUPABASE_SETUP.md`.

---
*Keep these docs current: when you change architecture, update the matching context file so
the next agent inherits an accurate map.*
