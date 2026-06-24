# DAIRY DEMO — Admin Console (Next.js)

Production-grade admin dashboard for the DAIRY DEMO distribution platform, built the
way real companies build them: **Next.js 16 (App Router) + TypeScript + Tailwind v4 +
Recharts + lucide-react**, with the **Geist** typeface and a restrained Stripe/Linear-style
design system (neutral surfaces, one red brand accent, semantic colors for status, light + dark).

## Run

```bash
cd admin-next
npm install      # already done
npm run dev      # http://localhost:3000  (dev)
# or
npm run build && npm run start   # production
```

Open the URL → **Login** (any credentials) → console.

## Features
- **Login** — split screen with cover image + branded panel.
- **Dashboard** — animated KPI cards + sparklines, Sales-vs-Target area chart, category
  donut, top-products bars, recent orders.
- **Orders** — status filter chips + search, full data table.
- **Products** — catalog table (MRP/Rate/Resale/MOQ/stock) + Add-product modal.
- **Purchase / Stock-In** — **upload a supplier PDF bill → auto-extract line items
  (pdf.js) → review/edit + catalog auto-match → one click updates inventory** + GRN log.
- **Retailers** — credit limit, outstanding, KYC.
- **Ledger & Payments** — debit/credit statement + recharge approvals.
- **Reports** — revenue chart, category mix, GST summary, report downloads.
- **Banners** — promo cards with active toggles.
- **Settings** — business profile + preference switches.
- **Dark mode** toggle, fully responsive (off-canvas sidebar on mobile).

## Structure
```
src/
├── app/
│   ├── login/page.tsx
│   └── (app)/                 # authed shell group
│       ├── layout.tsx         # Sidebar + Topbar shell
│       ├── dashboard, orders, products, purchase,
│       └── retailers, ledger, reports, banners, settings
├── components/  shell, charts, kpi, theme-toggle, ui
└── lib/         data.ts (mock), format.ts, pdf-extract.ts
public/pdf.worker.min.mjs       # bundled pdf.js worker (offline)
```

Data is in `src/lib/data.ts`. To wire a real backend, replace those exports with API calls.
