# MY ORDER PRO

**Aapka daily wholesale partner.** A B2B Flutter app where kirana retailers reorder FMCG stock daily from a wholesaler at bulk wholesale rates. Built for India-first retail commerce — Hinglish-fluent, ₹/GST-native, khata-aware.

_Powered by CodeBlimp — `codeblimp.com`_

---

## What makes it B2B (not a normal shopping app)

| Feature | Why it matters for wholesale |
|--------|------------------------------|
| **Bulk price slabs** | Each product has quantity-based pricing tiers; right slab auto-applies. |
| **MOQ enforcement** | Minimum order quantity per product. |
| **Margin calculator** | Shows retailer's resale margin vs MRP. |
| **MRP vs wholesale savings** | Strike-through MRP + savings badge everywhere. |
| **Khata / Pay Later** | Credit ledger for daily reorder cycle. |
| **Free-delivery threshold** | Order above ₹X = free delivery, with cart progress nudge. |

## Stack

- Flutter (mobile) — `lib/`
- Next.js 16 admin panel — `admin-next/`
- Backend: Supabase (PostgreSQL + auth) — Phase 4 wire-up

## Run it

```bash
flutter pub get
flutter run                  # debug
flutter build apk --release  # release APK
```

## Admin panel

```bash
cd admin-next
npm install
npm run dev    # http://localhost:3000
```
