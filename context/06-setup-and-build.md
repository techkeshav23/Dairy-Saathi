# 06 · Setup, Run & Build

> ⚠️ **Updated:** auth is **email/password** now. For instant retailer self-signup, turn **OFF**
> Supabase → Auth → Providers → Email → **"Confirm email"**. The admin needs `SUPABASE_SERVICE_ROLE_KEY`
> in `admin-next/.env.local` (server-only) for live data. Release APK needs `--no-tree-shake-icons`.
> See [09-current-state.md](09-current-state.md) §6. Build still requires a clean path (no `&`/spaces).

## Prerequisites
- **Flutter SDK** `^3.11.5` (Dart), Android Studio / Xcode toolchains.
- **Node.js** 20+ and npm (for the admin console).
- A **Supabase project** (optional — both apps run on mock data without it).

## Run the mobile app
```bash
flutter pub get
flutter run                  # debug on a connected device/emulator
```
- Runs on **MockRepository** unless `lib/data/supabase_config.dart` has real credentials
  (it currently does — the app is wired to a live Supabase project).
- Demo OTP in mock mode: **`1234`**.

## Build a release APK
```bash
flutter build apk --release
```

### ⚠️ Build gotcha (important)
The Android Gradle build **fails when the project path contains `&` or spaces** — and this
folder is literally `...\Distributor & Retailer`. The code is fine; Gradle is not.

**Fix:** copy/move the project to a clean path before building, e.g.:
```
C:\my_order_pro
```
Then run the build from there. (This is documented in
[`AGENT_BUILD_SUMMARY.md`](../AGENT_BUILD_SUMMARY.md) — the debug APK built successfully
from `C:\my_order_pro_build`.)

- App icon + splash are generated from `assets/brand/app_icon.png` via
  `flutter_launcher_icons` / `flutter_native_splash` (config in `pubspec.yaml`).

## Run the admin console
```bash
cd admin-next
npm install
npm run dev        # http://localhost:3000  → redirects to /login
npm run build      # production build
npm start          # serve production build
```
- Demo login: **`admin@dairydemo.in` / `demo1234`** (any input works — mock auth).
- Runs on mock seed data unless `admin-next/.env.local` is set (copy from
  `.env.local.example`).

## Configure Supabase (go live)
1. Create the project; run `supabase/schema.sql` then `schema_v2..v10` in order
   (include `schema_v5_seed.sql` for demo catalog). See [04-supabase-backend.md](04-supabase-backend.md).
2. Copy Project URL + anon (publishable) key.
3. Paste into:
   - Mobile → [`lib/data/supabase_config.dart`](../lib/data/supabase_config.dart)
   - Admin → `admin-next/.env.local` (`NEXT_PUBLIC_SUPABASE_URL`, `NEXT_PUBLIC_SUPABASE_ANON_KEY`)
4. Enable **Phone** auth + an SMS provider (MSG91 / Twilio) for real OTP.

## Verify before shipping
```bash
flutter analyze          # should be: No issues found!
cd admin-next && npx tsc --noEmit   # should exit 0
```
(Per the build summary, both were clean at handover.)

## Deploy
- **Mobile:** build the release APK/AAB (from a clean path), upload to Play Console.
  Store assets are ready in [`store/`](../store/) (listing, privacy policy, terms, brand concepts).
- **Admin:** deploy `admin-next/` to Vercel (Next.js). Set the two `NEXT_PUBLIC_*` env vars
  in the Vercel project. See [`DEPLOY_GUIDE.md`](../DEPLOY_GUIDE.md).
