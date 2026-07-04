/// MY ORDER PRO — Supabase config.
/// Paste your project's URL + anon key below (Supabase dashboard -> Project Settings -> API).
/// Until both are filled with real values, [useSupabase] stays false and the app
/// uses MockRepository so it still runs.
class SupabaseConfig {
  SupabaseConfig._();

  // MY ORDER PRO — live Supabase project (set 2026-07-01).
  // anonKey holds the new-style *publishable* key (sb_publishable_...) — the
  // browser/mobile-safe client key that replaces the legacy anon key. RLS gates access.
  static const String url = 'https://hkvbietffnfuecxwwsni.supabase.co';
  static const String anonKey = 'sb_publishable_nMrL5854TRy2rSbBLk7WUQ_EKlkiEF9';

  /// True only when both values look real (not the placeholders).
  static bool get isConfigured =>
      url.startsWith('https://') && !anonKey.startsWith('PASTE_');

  /// Master switch: use Supabase when configured, else Mock.
  static bool get useSupabase => isConfigured;
}
