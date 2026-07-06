# MY ORDER PRO — Product Roadmap & Backlog

> Hand-off backlog to take the platform from **working MVP** to a **real production CRM**.
> Priorities: 🔴 **P0** (core, must work) · 🟠 **P1** (production-ready) · 🟣 **P2** (CRM depth) · 🟢 **P3** (polish/scale).
> Effort: **S** = <1 day · **M** = 1–3 days · **L** = 3+ days. Last updated 2026-07-05.

---

## ✅ Already built (current state)

**Mobile app (Flutter)** — role-based single app:
- Retailer: email/password self sign-up + sign-in, browse catalog, cart, checkout → **order persists to Supabase** (`place_order` RPC), order history, khata/statement (running balance), wallet, account. Lean 4-tab UI.
- Distributor (`admin@admin.com`): full accounting console (Parties, Sale, Purchase, Expense, Cash & Bank, Items, POS, Reports) via drawer.
- Role resolution: config owner email **OR** `app_users.role='distributor'`.

**Admin panel (Next.js 16)** — real auth (email/password + proxy route-guard), enterprise UI:
- Dashboard (live KPIs + charts), Orders (list), Retailers (full CRUD — creates login + profile), Products (CRUD + image), Categories (CRUD), Banners (CRUD + image + overlay), Ledger, Reports, Purchase, Settings.
- Writes via server-only `service_role` API routes.

**Backend (Supabase)** — Postgres + RLS + `service_role`, email/password auth, migrations `schema.sql` → `schema_v18`, retailer accounts, roles.

**Not done:** deployment (local dev + debug APK only), notifications.
All core P0 commerce loop features are complete (order lifecycle, payments wiring, stock sync, credit limits, invoices).
Settings persistence and Retailer 360 CRM profile are complete.

---

## 🔴 P0 — Core commerce (must work before real launch) - ✅ ALL COMPLETE

| # | Item | Why | Where | Status |
|---|------|-----|-------|--------|
| 1 | **Order lifecycle management** | Distributor confirms → packs → dispatches → delivers. | admin `orders` + mobile order-detail | ✅ Done |
| 2 | **Payments & credit wiring** | Retailer Khata manual entries via Admin panel updates outstanding balance. | admin `ledger` | ✅ Done |
| 3 | **Stock / inventory sync** | Order confirmed = stock decrements. Cancelled = stock increments. | `schema_v20` triggers | ✅ Done |
| 4 | **Order → notification** | Not yet implemented (shifted to later phase). | - | ⏳ Pending |
| 5 | **GST invoice generation** | Generate + share the tax invoice PDF for an order. | mobile order-detail | ✅ Done |
| 6 | **Credit-limit enforcement** | Retailer blocked if over their real limit from backend. | `auth_provider` + `order_provider` | ✅ Done |

---

## 🟠 P1 — Production readiness

| # | Item | Why | Effort |
|---|------|-----|--------|
| 7 | **Deploy** — admin → Vercel, app → Play Store (release AAB, real signing), Supabase → prod project, custom domain, env vars in dashboards | Ship it | M |
| 8 | **Image upload (Supabase Storage)** — replace image-URL fields with real file upload (products, banners, logo) | UX; no external hosting | M |
| 9 | **Security pass** — RLS audit, remove any committed keys from history, `service_role` only server-side (done, re-verify), rate-limit auth, password policy | Trust | M |
| 10 | **Admin users & permissions** — password reset, invite multiple admins, roles (owner/staff/viewer) | Team use | M |
| 11 | **Error tracking + logging** — Sentry (app + admin), structured logs, uptime monitor | Ops | S |
| 12 | **Pagination + search** — orders/products/retailers lists paginate; make the global ⌘K + per-page search actually query | Scale | M |
| 13 | **Settings persistence** — admin + mobile settings actually save (business profile, GST, preferences) | Correctness | ✅ Done |
| 14 | **Reports & exports** — real GSTR-1/2/3B summaries, CSV/PDF export of orders/ledger/retailers | Compliance | M |
| 15 | **Reconcile mobile data layers** — order state mixes local `OrderProvider` + server RPC; unify. Retire the dead `Repository.requestOtp/verifyOtp` OTP methods | Tech debt | S |

---

## 🟣 P2 — Real CRM depth (the "CRM" you want)

| # | Item | Why | Effort |
|---|------|-----|--------|
| 16 | **Retailer 360 profile** — one screen per retailer: full order history, payments, ledger, credit, notes, contact | Core CRM | ✅ Done |
| 17 | **Segments & tags** — group retailers by area / volume / credit-risk / custom tags; filter & bulk-act | Targeting | M |
| 18 | **Follow-ups & tasks** — reminders ("collect ₹X from Sharma Kirana", "call new lead"); a task inbox for the distributor | Sales ops | M |
| 19 | **Communication log** — log every call / WhatsApp / note against a retailer; one-tap call & WhatsApp (mobile has `whatsapp_helper`) | Relationship history | M |
| 20 | **Leads / onboarding pipeline** — track prospective retailers (Lead → Contacted → Onboarded → Active); convert to account | Growth | M |
| 21 | **Collections & credit risk** — overdue ageing (30/60/90), auto payment reminders (WhatsApp/SMS), simple credit score | Cash flow | L |
| 22 | **Campaigns & targeted offers** — push offers/banners to a segment; schedule; measure uptake | Revenue | L |
| 23 | **CRM analytics** — retailer-wise sales, top / churning retailers, area heatmap, product performance, credit exposure, repeat-order rate | Decisions | L |

---

## 🟢 P3 — Polish & scale

| # | Item | Effort |
|---|------|--------|
| 24 | **Delivery management** — assign delivery, live status, optional "delivery boy" role (3rd role — architecture already supports it) | L |
| 25 | **Offline support / sync** (mobile) — cache catalog + queue orders when offline | L |
| 26 | **Localization** — Hindi ⇄ English toggle | M |
| 27 | **Empty / loading / error states** — audit every screen for graceful states | M |
| 28 | **Automated tests** — unit (providers/services), widget, admin API, one E2E happy-path | M |
| 29 | **In-app onboarding** — first-run tutorial for retailer & distributor | S |
| 30 | **Store presence** — app icon polish, screenshots, listing (assets in `store/`), reviews flow | S |

---

## ⚠️ Known issues / tech debt (fix opportunistically)

- **Payments/recharge not persisted** — mobile wallet/recharge is UI-only (see P0 #2).
- **Order state duplication** — `OrderProvider` keeps a local list *and* the server has the order; can drift.
- **Two mobile data layers** — abstract `Repository` (catalog) vs `services/*` (accounting) aren't unified.
- **Dead code** — distributor accounting screens are only reachable in the distributor shell; mock data + unused OTP methods remain.
- **Committed keys** — `supabase_config.dart` ships the *publishable* key (browser-safe, RLS-gated — acceptable, but keep the **service_role** key server-only, never commit it).
- **SharedPreferences keys** still prefixed `saathi_*` (harmless legacy — don't rename or users lose cached data).
- **Build path** — release/Gradle build must run from a path **without `&`/spaces** (e.g. `C:\my_order_pro`); admin `npm` too.

---

## Suggested build order

1. **P0 #1–3, 6** (order lifecycle + payments + stock + credit) → the loop actually works end-to-end.
2. **P0 #4–5** (notifications + invoices) → feels like a real product.
3. **P1 #7, 9, 11** (deploy + security + monitoring) → safely live.
4. **P2 #16–19** (retailer 360, segments, follow-ups, comms) → the CRM.
5. Iterate on the rest by business need.

_Architecture notes and file-level maps live in [`context/`](context/) — start there for onboarding a developer._
