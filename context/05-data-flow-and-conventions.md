# 05 · Data Flow & Conventions

> ⚠️ **Updated:** the admin no longer relies on the "mock fallback" for the CRUD entities — it reads/writes
> **live** via server-only `service_role` routes (`src/app/api/*`). Mobile auth is email/password. The
> Mock↔live conventions below still apply to the mobile catalog. See [09-current-state.md](09-current-state.md).

## The Mock ↔ Live switch (most important concept)

Both clients run **fully offline on mock data** by default and **auto-upgrade to live
Supabase** the moment credentials are present. Nothing else changes — same UI, same models.

### Mobile
- Master switch: [`lib/data/supabase_config.dart`](../lib/data/supabase_config.dart) →
  `SupabaseConfig.useSupabase` is `true` when `url` starts with `https://` and `anonKey`
  is not a `PASTE_...` placeholder.
- `RepositoryProvider.instance` returns `SupabaseRepository` (live) or `MockRepository` (offline).
- Every **service** in `lib/data/services/` independently checks `SupabaseConfig.useSupabase`
  and switches between a Supabase call and an in-memory list.
- **Currently LIVE** — real project URL + publishable key are committed in that file.

### Admin
- Master switch: `admin-next/.env.local` → `NEXT_PUBLIC_SUPABASE_URL` +
  `NEXT_PUBLIC_SUPABASE_ANON_KEY`. `supabase.ts` exports `useSupabase`.
- Fetchers in `supabase-data.ts` return live data or fall back to the mock seed in `data.ts`.

## Order-placement flow (end to end)

```
Retailer taps "Place Order" (checkout_screen)
  → CartProvider builds line items (slab-aware unitPrice)
  → OrderProvider.placeOrder()  /  order_service.dart
  → RPC place_order(total, items)          [Supabase]
       · server recomputes price from price_slabs (ignores client total)
       · inserts orders + order_items (one txn)
       · if credit: inserts ledger_entries (type=debit)
  → order appears in admin /orders (getOrders) and in retailer khata/statement
```

## Accounting flow (invoices / purchases / parties)

```
sale_invoice_screen → invoice_service → RPC create_sale_invoice()
   → inserts sale_invoices + items
   → auto-creates/updates customer Party balance (md5(uid‖name) ID)

purchase_screen → purchase_service → RPC create_purchase_with_items()
   → inserts purchases + items
   → auto-creates/updates supplier Party balance

payment_in/out_screen → payment_service → payments table
   → (balance adjustments via increment_party_balance)

Invoice numbers → invoice_number_service → RPC next_counter('sale_invoice')
   → formatted INV/2526/0001 (GST Rule 46(b))
```

## Conventions to follow when editing

### Flutter
- **Never call Supabase directly from a screen.** Go through a `Repository` method or a
  `services/*.dart` service, so the Mock path keeps working.
- **Respect the switch:** any new backend call must have a mock fallback guarded by
  `if (SupabaseConfig.useSupabase) { ... } else { ...mock... }`.
- **State via Provider:** add to an existing `ChangeNotifier` or create one, then register
  it in the `MultiProvider` in `main.dart`. Call `notifyListeners()` after mutations.
- **Routing:** add the route constant + case in `route_helper.dart`; navigate with
  `Navigator.pushNamed(context, RouteHelper.x, arguments: ...)`.
- **Pricing:** use `Product.priceForQty(qty)` / `CartItem.unitPrice` — don't hand-pick slabs.
- **Money:** amounts are `double`, currency is `₹` (`AppConstants.currencySymbol`),
  GST 5% (`AppConstants.gstPercent`), delivery ₹49 free ≥ ₹5000.
- **Design system:** use `AppColors`, `Dimensions`, `styles.dart` — don't hardcode colors/sizes.

### Admin (Next.js)
- Read data through `supabase-data.ts` fetchers (they already fall back to mock).
- Types live in `data.ts` — keep the live-fetch mapping in `supabase-data.ts` matching them.
- Format money with `inr()` / `inrFull()` from `format.ts`.
- Use `Card`, `Badge`, `Pill` from `ui.tsx` and charts from `charts.tsx` for consistency.

### Supabase
- **Additive migrations only:** create a new `schema_v11_*.sql`; don't rewrite old files.
- Every new business table needs a `user_id` column + owner-only RLS (copy the v9 pattern)
  and, if catalog-shared, read-only-for-authenticated.
- Multi-row writes → a `SECURITY DEFINER` RPC with `SET search_path = ''`, granted to
  `authenticated`. Never trust client-supplied prices — compute server-side.

## Naming / legacy notes

- Package renamed `saathi` → `my_order_pro` (imports migrated). SharedPreferences keys are
  still `saathi_*` — **leave them** (renaming would log users out / drop cached data).
- Admin still shows **"DAIRY DEMO"** branding + dairy seed data — this is demo leftover,
  not a separate product.
