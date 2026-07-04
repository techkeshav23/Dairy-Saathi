# 07 · Known Issues, Gaps & TODOs

Snapshot as of **2026-07-03**. Verify against current code before acting — some may be fixed.

## 🔴 Security / correctness

1. **Live Supabase credentials committed to source.**
   [`lib/data/supabase_config.dart`](../lib/data/supabase_config.dart) contains a real project
   URL + publishable key. The publishable/anon key is browser-safe and RLS-gated, so this is
   *lower* risk — but the URL + key are public in the repo. Never commit the **service_role**
   key. Consider moving config to a build-time env / `--dart-define` for cleanliness.
2. **Admin has no real auth.** `admin-next/src/app/login/page.tsx` is mock — any credentials
   log in, and the `(app)` route group has **no guard**. Anyone who reaches the URL sees the
   dashboard. Needs Supabase Auth (or an equivalent) before public deployment.
3. **Admin uses the anon key for everything.** Distributor-level writes/reads should be gated
   by proper policies or a service-role server route — the anon key + client-side writes are
   not a trust boundary.

## 🟠 Mock-vs-live gaps (admin)

Even when Supabase is configured, these admin pages are **still mock / client-only**:
- **Products** — add/edit updates in-memory only, not persisted.
- **Purchase** — PDF extraction + stock update are client-side, not saved.
- **Ledger, Reports, Banners, Settings** — hardcoded; writes are no-ops.
- **Dashboard** — only the KPI cards are live; the **charts + recent orders are hardcoded**
  (TODO markers present).
- **Retailers** — "add retailer" button has no modal.

To finish: wire these to `supabase-data.ts` fetchers + add write functions (INSERT/UPDATE via
service role or authored RPCs).

## 🟠 Two data layers in the mobile app

The abstract `Repository` (catalog/ledger/OTP) and the `services/*` accounting stack
(invoices, parties, payments, purchases, documents) are **parallel** systems. They are not
fully unified — when adding features, pick the right layer and keep both mock paths intact
(see [05-data-flow-and-conventions.md](05-data-flow-and-conventions.md)).

## 🟠 Branding inconsistency (admin)

Admin still identifies as **"DAIRY DEMO"**: page metadata (`layout.tsx`), login domain
(`admin@dairydemo.in`), and dairy-themed seed data (`data.ts`). The mobile app is fully
rebranded to "MY ORDER PRO" (red). Align admin branding before launch if this is one product.

## 🟡 Build / tooling

- **Gradle fails on paths with `&`/spaces** — must build from a clean path like
  `C:\my_order_pro` (see [06-setup-and-build.md](06-setup-and-build.md)).
- SharedPreferences keys remain `saathi_*` (legacy). Intentional — don't rename.
- `theme-toggle.tsx` exists in admin but isn't wired into the shell (light-only enforced).

## ✅ Founder / launch TODO (from AGENT_BUILD_SUMMARY.md)

1. Move project to a path without `&`/spaces for builds.
2. Ensure all `supabase/schema_v*.sql` migrations are applied to the live project.
3. Confirm URL + anon key in `supabase_config.dart` (mobile) and `admin-next/.env.local`.
4. Add real product data; replace app icon + splash art (`assets/brand/`).
5. Enable Supabase Phone auth + SMS provider (MSG91/Twilio) for OTP.
6. Add real admin auth + persist the mock-only admin pages.
7. Follow `DEPLOY_GUIDE.md` for APK + Vercel deploy.

## Suggested next steps (priority order)

1. Add real **admin authentication** + route guard.
2. Persist admin writes (products, banners, purchase stock, settings).
3. Wire dashboard **charts + recent orders** to live data.
4. Unify / document the mobile Repository vs services split.
5. Move Supabase config to env-based injection; keep service_role server-side only.
6. Align admin branding with "MY ORDER PRO".
