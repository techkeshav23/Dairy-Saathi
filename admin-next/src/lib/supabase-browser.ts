import { createBrowserClient } from "@supabase/ssr";

// Browser-side Supabase client for auth (login / logout / current user).
// Uses the public anon key; sessions are stored in cookies so the middleware
// and server can read them too.
export function createClient() {
  return createBrowserClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
  );
}
