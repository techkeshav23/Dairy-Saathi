# 📚 Context Folder — MY ORDER PRO

> **Purpose:** This folder is a complete handover pack. If you are a new AI agent or
> developer picking up this project, **read the files here in order** and you will
> understand the entire codebase without having to reverse-engineer it.
>
> Last mapped: **2026-07-05**. Keep these docs updated when architecture changes.

> 🟢 **START HERE:** [`09-current-state.md`](09-current-state.md) is the **authoritative current
> architecture** (email/password auth, roles, live admin CRUD, migrations v11–v18). Docs 01–08 are
> the original build; where they conflict with 09, **09 wins**. Backlog: [`../ROADMAP.md`](../ROADMAP.md).

---

## What this project is (one line)

**MY ORDER PRO** — a B2B wholesale ordering SaaS for Indian kirana retailers.
A **role-based Flutter app** (retailers self-sign-up and order; the distributor gets a full
accounting console — same app, gated by `app_users.role`) + a **real-auth Next.js admin console**
(wholesaler manages orders/retailers/products), both on live Supabase. India-first: Hinglish,
₹/GST-native, khata (credit ledger) aware. Was "Saathi" → **MY ORDER PRO**.

---

## Read these in order

| # | File | What it covers |
|---|------|----------------|
| 1 | [01-overview.md](01-overview.md) | High-level architecture, the 3 parts, repo layout, tech stack |
| 2 | [02-flutter-app.md](02-flutter-app.md) | The Flutter mobile app — routes, models, providers, services, screens, theme |
| 3 | [03-admin-panel.md](03-admin-panel.md) | The Next.js admin console — pages, data layer, components, auth |
| 4 | [04-supabase-backend.md](04-supabase-backend.md) | Database schema, all 10 migrations, tables, RLS, RPC functions, seed data |
| 5 | [05-data-flow-and-conventions.md](05-data-flow-and-conventions.md) | How data flows Mock↔Supabase, naming conventions, patterns to follow |
| 6 | [06-setup-and-build.md](06-setup-and-build.md) | How to run/build both apps, the build gotchas, env config |
| 7 | [07-known-issues-and-todos.md](07-known-issues-and-todos.md) | Open issues, security notes (see also ROADMAP) |
| 8 | [08-handover-guide.md](08-handover-guide.md) | Quick-start for the next AI agent — where to look for X, how to make changes safely |
| **9** | **[09-current-state.md](09-current-state.md)** | **⭐ Current auth / roles / admin-CRUD / migrations — authoritative, read first** |

---

## Fastest orientation (30 seconds)

- **Mobile app code:** [`lib/`](../lib/) — Flutter, Provider state. Two shells by role: retailer
  ([`dashboard_screen.dart`](../lib/features/dashboard/dashboard_screen.dart)) vs distributor
  ([`distributor_dashboard.dart`](../lib/features/dashboard/distributor_dashboard.dart)).
- **Admin app code:** [`admin-next/`](../admin-next/) — Next.js 16 App Router, real auth
  ([`proxy.ts`](../admin-next/src/proxy.ts) guards everything), CRUD via `src/app/api/*` (service_role).
- **Backend:** [`supabase/`](../supabase/) — run `schema.sql` → **`schema_v18_*.sql`** in order.
- **Auth:** email/password (Supabase Auth) on **both** app and admin. Mobile retailers self-sign-up;
  distributor = `admin@admin.com` (or `role='distributor'`).
- **Supabase is LIVE.** Mobile ships the publishable key; the **service_role** key is only in
  `admin-next/.env.local` (gitignored — never commit).

## Existing root docs (also useful)

- [`../ROADMAP.md`](../ROADMAP.md) — **prioritized backlog** to reach a production CRM (P0→P3).
- [`../README.md`](../README.md) — public-facing project readme.
- [`../AGENT_BUILD_SUMMARY.md`](../AGENT_BUILD_SUMMARY.md) — original build phases.
- [`../DEPLOY_GUIDE.md`](../DEPLOY_GUIDE.md) — deploy steps (APK + Vercel).
- [`../SUPABASE_SETUP.md`](../SUPABASE_SETUP.md) & [`../admin-next/SUPABASE_ADMIN_SETUP.md`](../admin-next/SUPABASE_ADMIN_SETUP.md) — backend wiring.
