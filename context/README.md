# 📚 Context Folder — MY ORDER PRO

> **Purpose:** This folder is a complete handover pack. If you are a new AI agent or
> developer picking up this project, **read the files here in order** and you will
> understand the entire codebase without having to reverse-engineer it.
>
> Last mapped: **2026-07-03**. Keep these docs updated when architecture changes.

---

## What this project is (one line)

**MY ORDER PRO** — a B2B wholesale ordering SaaS for Indian kirana retailers.
A Flutter mobile app (retailer side) + a Next.js admin console (wholesaler side),
both backed by a multi-tenant Supabase (PostgreSQL) backend. India-first: Hinglish,
₹/GST-native, khata (credit ledger) aware. Originally named **"Saathi"**, rebranded
to **MY ORDER PRO**. Built by the CodeBlimp / Blimp Labs agent factory.

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
| 7 | [07-known-issues-and-todos.md](07-known-issues-and-todos.md) | Open issues, mock-vs-live gaps, security notes, TODOs |
| 8 | [08-handover-guide.md](08-handover-guide.md) | Quick-start for the next AI agent — where to look for X, how to make changes safely |

---

## Fastest orientation (30 seconds)

- **Mobile app code:** [`lib/`](../lib/) — Flutter, Provider state, repository pattern.
- **Admin app code:** [`admin-next/`](../admin-next/) — Next.js 16 App Router.
- **Backend:** [`supabase/`](../supabase/) — run `schema.sql` → `schema_v10_*.sql` in order.
- **Master switch Mock↔live:** [`lib/data/supabase_config.dart`](../lib/data/supabase_config.dart) (mobile) and `admin-next/.env.local` (admin). Both auto-fall-back to mock data if not configured.
- **Currently Supabase is LIVE** — real credentials are committed in `supabase_config.dart`.

## Existing root docs (also useful)

- [`../README.md`](../README.md) — public-facing project readme.
- [`../AGENT_BUILD_SUMMARY.md`](../AGENT_BUILD_SUMMARY.md) — how the app was originally built, phases.
- [`../DEPLOY_GUIDE.md`](../DEPLOY_GUIDE.md) — deploy steps (APK + Vercel).
- [`../SUPABASE_SETUP.md`](../SUPABASE_SETUP.md) & [`../admin-next/SUPABASE_ADMIN_SETUP.md`](../admin-next/SUPABASE_ADMIN_SETUP.md) — backend wiring.
