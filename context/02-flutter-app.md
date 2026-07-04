# 02 · Flutter Mobile App (`lib/`)

The retailer-facing app. 98 Dart files, 39 screens. Entry point: [`lib/main.dart`](../lib/main.dart).

## Boot sequence (`main.dart`)

1. `WidgetsFlutterBinding.ensureInitialized()` + lock to portrait.
2. If `SupabaseConfig.useSupabase` is true → `Supabase.initialize(url, anonKey)`.
3. Load `SharedPreferences`.
4. `Repository repository = RepositoryProvider.instance;` — auto-picks Supabase or Mock.
5. `runApp(MyOrderProApp(...))` with a `MultiProvider` of 5 providers.
6. `MaterialApp` uses `AppTheme.light/dark`, `initialRoute = RouteHelper.splash`,
   `onGenerateRoute = RouteHelper.onGenerateRoute`.
7. If Supabase is live, an auth-state listener redirects to sign-in on `signedOut`.

---

## Routing — [`lib/helper/route_helper.dart`](../lib/helper/route_helper.dart)

Named routes via `onGenerateRoute`. Arguments passed through route settings.

| Route | Screen | Args |
|-------|--------|------|
| `splash` `/` | SplashScreen | — |
| `onboarding` | OnboardingScreen | — |
| `signIn` | SignInScreen | — |
| `verifyOtp` | VerifyOtpScreen | phone |
| `dashboard` | DashboardScreen | — |
| `placeOrder` | PlaceOrderScreen | — |
| `categoryProducts` | CategoryProductsScreen | CategoryModel |
| `productDetail` | ProductDetailScreen | Product |
| `search` | SearchScreen | — |
| `cart` | CartScreen | — |
| `checkout` | CheckoutScreen | — |
| `orderSuccess` | OrderSuccessScreen | OrderModel |
| `allOrders` | AllOrdersScreen | — |
| `orderDetail` | OrderDetailScreen | OrderModel |
| `statement` | StatementScreen | — |
| `wallet` | WalletScreen | — |
| `manualRecharge` | ManualRechargeScreen | — |
| `ledger` | LedgerScreen | — |
| `accountPreferences` | AccountPreferencesScreen | — |
| `profile` | ProfileScreen | — |

> Some transaction routes (`sale`, `purchase`, `expense`, `cashBank`, `paymentIn`,
> `paymentOut`) exist as placeholders in the route table; the actual transaction
> **screens** live under `lib/features/transactions/` and are reached via widgets/sheets.

---

## Data models — [`lib/data/models/`](../lib/data/models/)

| Model | Key fields | Purpose |
|-------|-----------|---------|
| **Product** | id, name, brand, categoryId, imageUrl, unit, mrp, `slabs: List<PriceSlab>`, moq, stock, isPopular, isFeatured, description | Catalog item. Methods: `priceForQty(qty)` (auto-applies slab), `basePrice`, `bestPrice`, `resalePrice`, `marginPercent`. |
| **PriceSlab** (nested) | minQty, pricePerUnit | Volume-discount tier. |
| **CategoryModel** | id, name, icon (IconData), color, itemCount | Product category tile. |
| **CartItem** | product, quantity (mutable) | Cart line. Getters: `unitPrice` (slab-aware), `totalPrice`, `savings`. |
| **OrderModel** | id, placedAt, `lines: List<OrderLine>`, subtotal, gst, deliveryCharge, total, savings, status, paymentMode, address | A placed order. |
| **OrderLine** | productId, name, unit, imageUrl, quantity, unitPrice | Denormalized snapshot (frozen at order time). |
| **OrderStatus** (enum) | placed, confirmed, packed, dispatched, delivered, cancelled | Lifecycle. |
| **PaymentMode** (enum) | cod, online, credit | `credit` = Khata / Pay Later. |
| **Party** | id, name, phone, type ("supplier"/"customer"), address, gstin, openingBalance, balance | Accounting counterparty. `fromJson/toJson/copyWith`. |
| **LedgerEntry** | id, date, title, amount, isDebit | One khata line. `isDebit` true = retailer owes. |
| **UserModel** | name, shopName, phone, address, gstin | Signed-in retailer. `copyWith`. |
| **BannerModel** | title, subtitle, tag, image, accent | Home promo card. |

Mock seed data: [`lib/data/mock_data.dart`](../lib/data/mock_data.dart).

---

## Providers (state) — [`lib/providers/`](../lib/providers/)

| Provider | State | Key methods |
|----------|-------|-------------|
| **AuthProvider** | loading, lastOtp, user | `isLoggedIn` (checks Supabase session), `requestOtp(phone)` (E.164 SMS OTP), `verifyOtp`, `loadUser`, `updateProfile` (→ `app_users`), `logout` |
| **CartProvider** | items | `add`, `increment/decrement`, `setQuantity` (enforces MOQ), `remove`, `clear`. Getters: subtotal, `gst` (5%), `deliveryCharge` (₹49, free ≥₹5000), `grandTotal`, `totalSavings` |
| **CatalogProvider** | categories, banners, featured, popular, loading | `loadHome()` (parallel fetch), `productsForCategory`, `search`, `categoryById` |
| **OrderProvider** | orders, ledger, creditLimit (₹50k demo), outstanding | `loadLedger`, `refreshLedger`, `placeOrder()` (builds order from cart, posts khata debit if credit mode), `orderById`. Getter: `usableCredit` |
| **ThemeProvider** | dark (persisted) | `toggle()` |

---

## Repository layer

- [`lib/data/repository.dart`](../lib/data/repository.dart) — abstract `Repository` contract
  (getCategories, getProducts, getFeatured, getPopular, getProduct, getBanners, getLedger,
  requestOtp, verifyOtp) + `MockRepository` (returns `MockData` with fake 200–800ms delay,
  demo OTP `1234`).
- [`lib/data/supabase_repository.dart`](../lib/data/supabase_repository.dart) — real Supabase
  implementation (parses rows → models, joins `price_slabs`).
- [`lib/data/repository_provider.dart`](../lib/data/repository_provider.dart) — singleton:
  `SupabaseConfig.useSupabase ? SupabaseRepository() : MockRepository()`.

### Services — [`lib/data/services/`](../lib/data/services/)

These sit **beside** the Repository and back the accounting/transaction screens. Each
checks `SupabaseConfig.useSupabase` and either calls a Supabase table/RPC or uses
in-memory mock data.

| Service | Does | Backend |
|---------|------|---------|
| `order_service.dart` | Place wholesale orders atomically | RPC `place_order()` |
| `party_service.dart` | CRUD parties, balance tracking | `parties` table + RPC `increment_party_balance()`, SQLite fallback |
| `item_service.dart` | Add/list catalog products | `products` table |
| `payment_service.dart` | Payment in/out | `payments` table |
| `expense_service.dart` | Business expenses | `expenses` table |
| `purchase_service.dart` | Purchase orders (master-detail) | RPC `create_purchase_with_items()` |
| `invoice_service.dart` | Sale invoices (master-detail) | RPC `create_sale_invoice()` |
| `invoice_number_service.dart` | Sequential GST invoice numbers | RPC `next_counter()` (+ timestamp fallback) |
| `analytics_service.dart` | Dashboard KPI aggregates | Supabase aggregation |
| `document_service.dart` | Estimate/SO/Challan/CN/DN/PO | `documents` table (JSONB items) |

---

## Feature screens — [`lib/features/`](../lib/features/) (grouped)

- **Auth/onboard/splash:** sign_in, verify_otp, onboarding, splash.
- **Home & catalog:** home_screen (banners+categories+featured), online_store_screen,
  place_order_screen (category grid), category_products_screen, product_detail_screen
  (slabs, MRP, margin), search_screen.
- **Ordering:** cart_screen, checkout_screen (address, payment mode, discounts),
  order_success_screen, items_screen.
- **Orders:** all_orders_screen (status filter), order_detail_screen.
- **Ledger / khata:** ledger_screen, statement_screen, wallet_screen, manual_recharge_screen.
- **Transactions / billing:** sale_invoice_screen, purchase_screen, payment_in_screen,
  payment_out_screen, party_transfer_screen, document_form_screen.
- **Parties:** parties_screen (supplier/customer directory + balances).
- **Expenses / cash:** expense_screen, cash_bank_screen.
- **POS:** mobile_pos_screen (quick invoice terminal).
- **Reports:** report_screen (KPIs).
- **Profile/settings:** profile_screen, account_preferences_screen, settings_screen, more_screen.
- **System:** backup_restore_screen, sync_share_screen.

---

## Theme & constants

- **Colors** [`lib/util/app_colors.dart`](../lib/util/app_colors.dart): brand red `primary #E2231A`,
  `primaryDark #C2121C`, success green `#1FA64F`, error `#E23B3B`, warning `#F5A623`,
  link blue `#1565D8`. Dark theme: bg `#14151C`, card `#1E2029`.
- **Styles** [`lib/util/styles.dart`](../lib/util/styles.dart): Roboto weights (regular→black),
  base font size 14.
- **Dimensions** [`lib/util/dimensions.dart`](../lib/util/dimensions.dart): font/padding/radius/icon
  scale constants; `webMaxWidth = 1170`.
- **Constants** [`lib/util/app_constants.dart`](../lib/util/app_constants.dart): `appName "MY ORDER PRO"`,
  `gstPercent 5.0`, `deliveryCharge 49.0`, `freeDeliveryThreshold 5000.0`, currency `₹`.
  SharedPreferences keys are still prefixed `saathi_*` (legacy — safe to leave).
- **Helpers** [`lib/helper/`](../lib/helper/): `price_converter`, `number_to_words`
  (₹ amount → words for invoices), `pdf_invoice_helper` (PDF gen), `whatsapp_helper`
  (share via WhatsApp / call).
