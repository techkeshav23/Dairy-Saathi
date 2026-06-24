# Saathi — Wholesale B2B Ordering App

**Aapka Wholesale Partner.** A Flutter mobile app where retailers (kirana shops) order
FMCG stock from a wholesaler at **bulk wholesale rates**. The UI follows the clean,
familiar SixamMart-style layout (used as design reference) but is rebuilt from scratch
for the wholesale/B2B use case.

---

## What makes it "wholesale" (B2B), not a normal shopping app

| Feature | Why it matters for wholesale |
|--------|------------------------------|
| **Bulk price slabs** | Each product has quantity-based pricing tiers ("2–4 units ₹1850, 5–9 ₹1790, 10+ ₹1720"). The right slab auto-applies as quantity grows. |
| **MOQ (Minimum Order Quantity)** | Products enforce a minimum quantity per order — core to wholesale. |
| **Margin calculator** | Product page shows the retailer's resale margin vs MRP ("Earn ₹350/unit at MRP"). |
| **MRP vs wholesale savings** | Strike-through MRP + savings badge everywhere; cart shows total savings vs MRP. |
| **Khata / Pay Later (credit ledger)** | Retailers can buy on credit and settle the khata later; outstanding balance + transaction history. |
| **Free-delivery threshold** | Order above ₹5,000 → free delivery, with a progress nudge in the cart. |

---

## Run it

```bash
flutter pub get
flutter run                  # debug on a connected device/emulator
flutter build apk --release  # release APK
```

**Demo login:** enter any 10-digit number → OTP screen auto-shows the demo OTP `1234`.

---

## Architecture

State management is **Provider** (rock-solid, no version risk). Data flows through a
`Repository` interface that is currently backed by `MockRepository` (in-memory seed
catalog) — so the app is fully demoable offline. Swapping to a real Laravel/REST
backend is a drop-in: implement `Repository` as `ApiRepository`, change one line in
`main.dart`. Models already carry `fromJson`/`toJson`.

```
lib/
├── main.dart                  # providers + MaterialApp + routes
├── util/                      # app_colors, dimensions, styles, app_constants, images
├── theme/                     # light_theme, dark_theme
├── data/
│   ├── models/                # product (+ price slabs), category, cart_item, order, ledger, user, banner
│   ├── mock_data.dart         # seed catalog (30 products, 8 categories, banners, khata)
│   └── repository.dart        # Repository interface + MockRepository
├── providers/                 # auth, catalog, cart, order, theme (ChangeNotifier)
├── helper/                    # route_helper (named routes), price_converter (₹ INR)
├── common/widgets/            # reusable UI (buttons, product cards, qty stepper, shimmer, ...)
└── features/                  # feature-first screens
    ├── splash/  onboard/  auth/            # splash → onboarding → phone+OTP
    ├── dashboard/                          # 5-tab bottom-nav shell
    ├── home/  category/  item/  search/    # catalog: home, categories, product detail, search
    ├── cart/  checkout/                    # cart → checkout → order success
    ├── order/                              # orders list + tracking timeline
    ├── account/  profile/  ledger/         # account, edit profile, khata
```

## Screen flow

`Splash → Onboarding → Sign in (phone) → Verify OTP → Dashboard`

Dashboard tabs: **Home · Categories · Cart · Orders · Account**

Stack routes: Category products, Product detail (bulk slabs), Search, Checkout,
Order success, Order detail (tracking), Khata/Ledger, Edit profile.

---

## Tech

- Flutter 3.41 / Dart 3.11
- `provider`, `shared_preferences`, `intl`, `cached_network_image`, `carousel_slider`,
  `pin_code_fields`, `shimmer`
- Light + dark theme; brand colour is a single token in `util/app_colors.dart`.

## Next steps (when wiring a backend)

1. Implement `ApiRepository implements Repository` (Laravel/REST) and inject it in `main.dart`.
2. Replace demo OTP with real WhatsApp/SMS OTP.
3. Wire real payments (Razorpay/UPI) in checkout.
4. Add product images CDN URLs to the catalog response (the UI already caches + falls back).
