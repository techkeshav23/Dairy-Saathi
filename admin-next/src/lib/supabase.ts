import { createClient } from "@supabase/supabase-js";

// MY ORDER PRO admin — Supabase client.
// Set these in admin-next/.env.local (see .env.local.example):
//   NEXT_PUBLIC_SUPABASE_URL, NEXT_PUBLIC_SUPABASE_ANON_KEY
const url = process.env.NEXT_PUBLIC_SUPABASE_URL ?? "";
const anonKey = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY ?? "";

/** True only when both env vars are present (real values). */
export const isSupabaseConfigured =
  url.startsWith("https://") && anonKey.length > 20;

/** Use Supabase when configured; otherwise the pages fall back to mock data.ts. */
export const useSupabase = isSupabaseConfigured;

export const supabase = isSupabaseConfigured
  ? createClient(url, anonKey)
  : null;
