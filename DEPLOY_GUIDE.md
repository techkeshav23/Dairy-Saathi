# DEPLOY_GUIDE

Welcome to the deployment documentation for **MY ORDER PRO**, a B2B wholesale ordering platform. This guide provides step-by-step instructions to configure, build, and deploy the complete stack.

## 1. Overview & Architecture

MY ORDER PRO consists of three primary components:
1. **Mobile App (Flutter):** The storefront where retailers browse products, view GST-inclusive pricing (₹), and place wholesale orders.
2. **Admin Panel (Next.js 16):** A web dashboard for distributors to manage inventory, process orders, and track payments.
3. **Backend (Supabase):** The unified PostgreSQL database, authentication, and API layer.

### Architecture Diagram

```text
+-----------------------+          +------------------------+          +-----------------------+
|     Retailer App      |          |    Supabase Backend    |          |      Admin Panel      |
|       (Flutter)       | =======> |  (PostgreSQL + Auth)   | <======= |     (Next.js 16)      |
|   iOS / Android APK   |   REST   |   RLS / Storage / DB   |   REST   |   Vercel Deployment   |
+-----------------------+          +------------------------+          +-----------------------+
                                               |
                                               v
                                   +------------------------+
                                   |   SMS Gateway (MSG91)  |
                                   |     OTP Auth / DLT     |
                                   +------------------------+
```

---

## 2. Prerequisites

Ensure your development environment meets the following requirements before proceeding:

*   **Flutter SDK:** `v3.19.0` or higher (verify with `flutter --version`).
*   **Node.js:** `v18.x` or higher (verify with `node -v`).
*   **Git:** Installed and configured.
*   **Accounts Required:**
    *   [Supabase](https://supabase.com/) (Database & Auth)
    *   [Vercel](https://vercel.com/) (Admin Panel Hosting)
    *   [MSG91](https://msg91.com/) or Twilio (SMS OTP)

---

## 3. Backend Setup (Supabase)

1. Log in to [Supabase](https://supabase.com) and click **New Project**.
2. Name the project `my-order-pro-backend`, select your region (e.g., `South Asia (Mumbai)` for lowest latency in India), and set a strong database password.
3. Once the project is provisioned, navigate to the **SQL Editor** in the left sidebar.
4. Click **New Query**, paste the contents of your `supabase/schema.sql` file, and click **Run**. This will create your tables (products, orders, users), GST configurations, and Row Level Security (RLS) policies.
5. Navigate to **Project Settings -> API**.
6. Copy the **Project URL** and the **anon `public` API Key**. You will need these for both the Flutter app and the Next.js admin panel.

---

## 4. Mobile App Deployment (Flutter)

The mobile app is used by retailers to place orders.

### Local Setup & Debugging

1. Navigate to the Flutter project root:
   ```bash
   cd my-order-pro-app
   ```
2. Fetch dependencies:
   ```bash
   flutter pub get
   ```
3. Configure Supabase credentials. Open `lib/data/supabase_config.dart` and paste your keys:
   ```dart
   class SupabaseConfig {
     static const String supabaseUrl = 'YOUR_SUPABASE_URL';
     static const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';
   }
   ```
4. Run the app on a connected device or emulator:
   ```bash
   flutter run
   ```

### Building for Production (Android)

To generate a release APK for distribution to retailers:

```bash
flutter build apk --release
```
*The generated APK will be located at:*
`build/app/outputs/flutter-apk/app-release.apk`

**Note for Google Play Store:** If you are publishing to the Play Store, you must build an App Bundle (`flutter build appbundle`) and sign it using a Java Keystore (`key.jks`). Update your `android/app/build.gradle` with your signing configurations before building.

---

## 5. Admin Panel Deployment (Next.js 16)

The admin panel is used by your internal team to manage the B2B catalog and fulfill orders.

### Local Setup

1. Navigate to the admin directory:
   ```bash
   cd admin-next
   ```
2. Set up environment variables:
   ```bash
   cp .env.local.example .env.local
   ```
3. Edit `.env.local` and add your Supabase credentials:
   ```env
   NEXT_PUBLIC_SUPABASE_URL=your_supabase_url_here
   NEXT_PUBLIC_SUPABASE_ANON_KEY=your_supabase_anon_key_here
   ```
4. Install dependencies and start the development server:
   ```bash
   npm install
   npm run dev
   ```
   *Access the admin panel at `http://localhost:3000`.*

### Production Deployment (Vercel)

1. Push your `admin-next` code to a GitHub repository.
2. Log in to [Vercel](https://vercel.com) and click **Add New -> Project**.
3. Import your GitHub repository. Ensure the Framework Preset is set to **Next.js**.
4. In the **Environment Variables** section, add:
   *   `NEXT_PUBLIC_SUPABASE_URL`
   *   `NEXT_PUBLIC_SUPABASE_ANON_KEY`
5. Click **Deploy**. Vercel will automatically run `npm run build` and publish your admin panel.

---

## 6. Phone OTP Authentication

B2B retailers log in using their mobile numbers.

1. Go to your Supabase Dashboard -> **Authentication** -> **Providers**.
2. Enable **Phone**.
3. **SMS Provider Setup:**
   *   **MSG91 (Recommended for India):** Select MSG91. You will need your Auth Key and Sender ID. *Crucial:* Ensure your SMS templates are DLT-approved via the TRAI portal (e.g., "Your MY ORDER PRO login OTP is {#var#}. Do not share this with anyone.").
   *   **Twilio:** Alternatively, select Twilio and input your Account SID, Auth Token, and Message Service SID.
4. Save the configuration. Supabase will now handle OTP generation and verification.

---

## 7. Going Live Checklist

Before onboarding your first retailer, verify the following:

- [ ] **Branding:** Replace the default Flutter app icon and splash screen. Use `flutter_launcher_icons` and `flutter_native_splash` packages.
- [ ] **Real Data:** Clear dummy data. Upload real product catalogs via the Admin Panel. Ensure prices are correctly formatted in ₹ and GST slabs (5%, 12%, 18%, 28%) are accurately assigned.
- [ ] **RLS Review:** Double-check Supabase Row Level Security policies. Retailers should only be able to `SELECT` their own orders and `READ` active products.
- [ ] **Device Testing:** Test the release APK on a physical Android device to ensure smooth performance and correct UI scaling.
- [ ] **Backups:** Enable Point-in-Time Recovery (PITR) or daily logical backups in Supabase Project Settings -> Database -> Backups.

---

## 8. Troubleshooting

### Flutter / Mobile App
*   **Issue:** `CocoaPods not installed or not in valid state` (iOS).
    *   **Fix:** Run `cd ios && pod install --repo-update`.
*   **Issue:** Build fails with Gradle errors.
    *   **Fix:** Run `flutter clean && flutter pub get`, then rebuild. Ensure your Java version matches the Gradle requirement (Java 17 is recommended).

### Next.js Admin Panel
*   **Issue:** Build fails on Vercel with ESLint/Type errors.
    *   **Fix:** Run `npm run build` locally to catch errors. Fix TypeScript interfaces matching your Supabase schema.
*   **Issue:** Stale data appearing on the dashboard.
    *   **Fix:** Next.js 16 aggressively caches fetches. Ensure you are using `revalidate` tags or `export const dynamic = 'force-dynamic'` on real-time order pages.

### Supabase Backend
*   **Issue:** App fetches return empty lists `[]` despite data existing.
    *   **Fix:** This is almost always an RLS (Row Level Security) issue. Ensure your `SELECT` policies allow authenticated users to read the table.
*   **Issue:** OTP SMS not arriving.
    *   **Fix:** Check Supabase Auth logs. If using MSG91, verify that your DLT template exactly matches the payload Supabase is sending, and that your MSG91 wallet has sufficient ₹ balance.

---
*Powered by CodeBlimp*