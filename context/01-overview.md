# 01 · Project Overview & Architecture

## The product

**MY ORDER PRO** ("Aapka daily wholesale partner") is a two-sided B2B commerce platform:

- **Retailer side (mobile):** A kirana shop owner opens the Flutter app, browses the
  wholesaler's catalog, and reorders FMCG stock daily at **bulk wholesale rates**.
  They pay by COD, online, or on **khata (credit / pay-later)**.
- **Wholesaler/distributor side (web):** The distributor uses the Next.js admin console
  to manage orders, products, retailers, ledger/credit, purchases, banners and reports.

The app also carries a full **Vyapar-style accounting layer** (GST invoices, purchases,
parties, payments, expenses, documents) — see [02-flutter-app.md](02-flutter-app.md).

### What makes it B2B (not a normal shopping app)

| Feature | Why it matters |
|--------|----------------|
| **Bulk price slabs** | Each product has quantity-based pricing tiers; the right slab auto-applies. |
| **MOQ enforcement** | Minimum order quantity per product. |
| **Margin calculator** | Shows the retailer's resale margin vs MRP. |
| **MRP vs wholesale savings** | Strike-through MRP + savings badge everywhere. |
| **Khata / Pay Later** | Credit ledger for the daily reorder cycle. |
| **Free-delivery threshold** | Order above ₹5000 = free delivery, with a cart-progress nudge. |

---

## The three parts

```
┌─────────────────────┐        ┌─────────────────────┐
│   Flutter mobile     │        │   Next.js admin      │
│   (retailer)         │        │   (wholesaler)       │
│   lib/               │        │   admin-next/        │
└──────────┬──────────┘        └──────────┬──────────┘
           │                              │
           │  supabase_flutter            │  @supabase/supabase-js
           │  (publishable/anon key,      │  (anon key, RLS-gated)
           │   RLS-gated)                 │
           ▼                              ▼
        ┌────────────────────────────────────────┐
        │        Supabase (PostgreSQL)            │
        │   supabase/*.sql — tables, RLS,         │
        │   RPC functions, auth (Phone OTP)       │
        └────────────────────────────────────────┘
```

Both clients talk **directly** to Supabase using the browser/mobile-safe **anon /
publishable key**. There is **no custom backend server** — all server-side logic lives
in Postgres **RPC functions** (`SECURITY DEFINER`) and **Row-Level Security** policies.

---

## Tech stack

### Mobile (`lib/`)
- **Flutter** (Dart SDK `^3.11.5`), Material 3.
- **State:** `provider` (ChangeNotifier).
- **Persistence:** `shared_preferences` (local prefs), `sqflite` (offline party fallback).
- **Backend client:** `supabase_flutter ^2.5.6`.
- **PDF / share:** `pdf`, `printing`, `share_plus` (GST invoice generation).
- **Misc:** `cached_network_image`, `carousel_slider`, `pin_code_fields` (OTP), `shimmer`,
  `google_fonts`, `url_launcher` (tap-to-WhatsApp / call reminders).
- App package name: **`my_order_pro`** (was `saathi` — 298 imports were migrated).

### Admin (`admin-next/`)
- **Next.js 16.2.9** (App Router, React Server Components, React Compiler enabled).
- **React 19.2.4**, **TypeScript 5**, **Tailwind CSS 4** (via `@tailwindcss/postcss`).
- **Charts:** `recharts`. **Icons:** `lucide-react`. **PDF parse:** `pdfjs-dist`.
- **Backend client:** `@supabase/supabase-js ^2.45.0`.

### Backend (`supabase/`)
- **PostgreSQL** via Supabase, 10 incremental SQL migration files.
- **Auth:** Supabase Phone OTP (needs an SMS provider like MSG91/Twilio for production).
- **Security:** RLS on every table; server-side pricing; per-user (multi-tenant) scoping.

---

## Repository layout (root)

```
Distributor & Retailer/
├── context/                  ← YOU ARE HERE (handover docs)
├── lib/                      ← Flutter app source (98 dart files, 39 screens)
│   ├── common/widgets/       ← reusable UI widgets
│   ├── data/                 ← models, repository, services, supabase config
│   ├── features/             ← screens grouped by feature
│   ├── helper/               ← routes, pdf, whatsapp, price/number formatting
│   ├── providers/            ← 5 ChangeNotifier providers
│   ├── theme/ + util/        ← design system (colors, styles, dimensions, constants)
│   └── main.dart             ← entry point
├── admin-next/               ← Next.js admin console
│   └── src/{app,components,lib}
├── supabase/                 ← schema.sql + schema_v2..v10 migrations
├── android/ ios/ web/        ← Flutter platform folders
├── assets/                   ← images, brand assets
├── store/                    ← Play Store listing, privacy policy, terms, brand concepts
├── test/                     ← Flutter tests
├── tool/                     ← build/utility scripts
├── pubspec.yaml              ← Flutter deps
├── README.md, AGENT_BUILD_SUMMARY.md, DEPLOY_GUIDE.md, SUPABASE_SETUP.md
```

> **Naming note:** The Flutter app self-identifies as "MY ORDER PRO" (red brand,
> `app_colors.dart` = `#E2231A`). The admin console's demo metadata/login still say
> **"DAIRY DEMO"** (`admin@dairydemo.in` / `demo1234`) and its seed data is dairy-themed.
> This is a **demo/branding leftover** — see [07-known-issues-and-todos.md](07-known-issues-and-todos.md).
