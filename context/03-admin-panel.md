# 03 · Next.js Admin Console (`admin-next/`)

> ⚠️ **Updated:** the admin now has **real email/password auth** (proxy-guarded), **live CRUD** for
> retailers/products/categories/banners via `src/app/api/*` (service_role), live dashboard charts, and a
> **cobalt/graphite** redesign (was red). "Mock/demo" notes below are historical — see
> **[09-current-state.md](09-current-state.md) §1, §3**.

The wholesaler/distributor-facing web dashboard. Next.js 16 App Router, React 19,
Tailwind 4, TypeScript.

## Config

- [`package.json`](../admin-next/package.json) — deps: `@supabase/supabase-js`, `recharts`,
  `lucide-react`, `pdfjs-dist`. Scripts: `dev`, `build`, `start`, `lint`.
- `next.config.ts` — React Compiler enabled (`reactCompiler: true`).
- `tsconfig.json` — strict, path alias `@/*` → `./src/*`, target ES2017.
- `postcss.config.mjs` — `@tailwindcss/postcss` v4. No `tailwind.config.ts`; theme is
  inline `@theme` in [`src/app/globals.css`](../admin-next/src/app/globals.css).
- **Env vars** (`.env.local`, template `.env.local.example`) — names only:
  - `NEXT_PUBLIC_SUPABASE_URL`
  - `NEXT_PUBLIC_SUPABASE_ANON_KEY` (publishable `sb_publishable_*` key)

## Routing (App Router — `src/app/`)

- `layout.tsx` — root layout. Metadata **"DAIRY DEMO · Admin Console"**, Geist font,
  light theme forced.
- `page.tsx` — redirects to `/login`.
- `login/page.tsx` — **mock** login (`admin@dairydemo.in` / `demo1234`, 500ms delay →
  `/dashboard`). No real session/auth.
- `(app)/layout.tsx` — route group wrapping all admin pages in `<Shell>` (sidebar + header).
  **No auth guard** on this group.

### Pages (under `(app)/`)

| Route | Shows | Live or Mock |
|-------|-------|--------------|
| `/dashboard` | KPIs, sales chart, category mix, recent orders, top products | **KPIs LIVE** (`getDashboardKpis`); charts + recent orders **MOCK** (TODO) |
| `/orders` | Order list, status filter, search, export | **LIVE** (`getOrders`) else mock |
| `/products` | Catalog (mrp, rate, resale, moq, stock, pack); add via modal | **MOCK only** (client state, no persistence) |
| `/retailers` | Business, owner, area, phone, credit limit, outstanding, KYC | **LIVE** (`getRetailers`) else mock |
| `/purchase` | Upload supplier PDF bill → extract items → update stock | **MOCK** (extraction + client-side stock; not persisted) |
| `/ledger` | Debit/credit/net outstanding + recharge approvals | **MOCK** (hardcoded) |
| `/reports` | GST summary (GSTR-1/2/3B), category mix, download buttons | **MOCK** |
| `/banners` | Promo banner editor (title/tag/color/active toggle) | **MOCK** (client state) |
| `/settings` | Business profile (GSTIN, address, email) + preference toggles | **MOCK** (no save backend) |

## Data layer (`src/lib/`)

- [`supabase.ts`](../admin-next/src/lib/supabase.ts) — creates the client from env vars using
  the **anon/publishable key** (RLS-gated). Exports `useSupabase` (boolean) + `supabase`
  (client or null). Falls back to mock when unconfigured.
- [`supabase-data.ts`](../admin-next/src/lib/supabase-data.ts) — async fetchers, each falling
  back to `[]` on error:
  - `getProducts()` → `products` (+ joined `categories`, `price_slabs`)
  - `getOrders()` → `orders` (+ `app_users`, `order_items`)
  - `getRetailers()` → `app_users` (+ `orders`)
  - `getLedger()` → `ledger_entries`
  - `getBanners()` → `banners`
  - `getDashboardKpis()` → parallel `orders` + `app_users` (revenue excludes Cancelled)
- [`data.ts`](../admin-next/src/lib/data.ts) — TypeScript types + **mock seed** (24 orders,
  14 products, 10 retailers, 14 ledger rows, 3 banners, 3 purchases). Dairy-themed demo data
  (Milk, Dahi, Paneer, Ghee; UP-region retailers).
- [`format.ts`](../admin-next/src/lib/format.ts) — `inr(n)`, `inrFull(n)` currency formatters.
- [`pdf-extract.ts`](../admin-next/src/lib/pdf-extract.ts) — `extractBill(file)` (pdfjs parse),
  `matchProduct(name)` (fuzzy match to catalog). Falls back to demo extraction.

## Components (`src/components/`)

| Component | Purpose |
|-----------|---------|
| `shell.tsx` | Layout: sidebar nav, sticky header, breadcrumb, avatar, notifications |
| `kpi.tsx` | Animated KPI card (counter, delta arrow, sparkline, staggered entry) |
| `charts.tsx` | `SalesArea`, `CategoryDonut`, `TopProductsBars` (recharts) |
| `ui.tsx` | `Card`, `CardHead`, `Badge`, `Pill`; `statusTone()` maps status→color |
| `theme-toggle.tsx` | Light/dark toggle (built but **not wired** into shell) |

## Styling

`globals.css` — custom CSS variables, **light-only** (OS dark ignored, localStorage cleared
on init). Brand red `#e2231a`, success `#16a34a`, warning `#d97706`, info `#2563eb`,
danger `#dc2626`. Fonts: Geist Sans / Geist Mono. Animations: `fade-up`, `spin`.

## Key gaps (see [07](07-known-issues-and-todos.md))

- Login is **demo-only** — no real auth/session. Any input works.
- Writes (products, banners, settings, purchase stock) are **client-side only** — not
  persisted to Supabase.
- Dashboard charts + recent orders are still **hardcoded** even when Supabase is live.
- Admin uses the **anon key**; distributor-level writes would need Supabase Auth + policies
  or a service-role server route.
