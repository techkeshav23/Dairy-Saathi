import { createClient } from "@supabase/supabase-js";

// SERVER-ONLY Supabase admin client.
//
// The wholesaler admin must read EVERY retailer's data (orders, ledger, app_users).
// Those tables are protected by owner-only RLS (user_id = auth.uid()), so the browser
// anon key — which has no user session — returns zero rows. The service_role key
// BYPASSES RLS and is the correct way for a trusted server to read all rows.
//
// SECURITY: the service_role key is a full-access secret. It is read from
// SUPABASE_SERVICE_ROLE_KEY (NOT prefixed NEXT_PUBLIC_), so Next.js never inlines it
// into the browser bundle. This module must only ever be imported by Server Components
// / server code (it is imported by src/lib/supabase-data.ts, which only server pages use).
const url = process.env.NEXT_PUBLIC_SUPABASE_URL ?? "";
const serviceKey = process.env.SUPABASE_SERVICE_ROLE_KEY ?? "";

/** True only when a real service_role key is configured. */
export const hasAdminAccess = url.startsWith("https://") && serviceKey.length > 20;

/** RLS-bypassing client, or null when not configured (callers fall back to mock data). */
export const supabaseAdmin = hasAdminAccess
  ? createClient(url, serviceKey, {
      auth: { persistSession: false, autoRefreshToken: false },
    })
  : null;
