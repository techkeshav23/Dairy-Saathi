-- MY ORDER PRO — Schema v27 (reliable retailer profile creation)
--
-- Bug: when Supabase "Confirm email" is ON, signUp() returns no session, so the mobile
-- client returned early BEFORE writing the app_users profile row. Result: an auth.users
-- row exists but no app_users profile → the retailer never shows in the admin panel.
--
-- Fix: create the app_users profile SERVER-SIDE via an AFTER INSERT trigger on auth.users,
-- reading the signup metadata. Runs regardless of email-confirmation state or session, so
-- every new signup (and every admin-created login) gets a profile. Defensive: never blocks
-- signup even if the profile insert fails.

CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  INSERT INTO public.app_users (
    id, email, phone, business_name, owner_name, shop_name, name,
    gst, area, status, role, created_by, code
  ) VALUES (
    NEW.id,
    NEW.email,
    NULLIF(NEW.raw_user_meta_data->>'phone', ''),
    COALESCE(NEW.raw_user_meta_data->>'business_name', NEW.raw_user_meta_data->>'shop_name', ''),
    COALESCE(NEW.raw_user_meta_data->>'owner_name',    NEW.raw_user_meta_data->>'name', ''),
    COALESCE(NEW.raw_user_meta_data->>'shop_name',     NEW.raw_user_meta_data->>'business_name', ''),
    COALESCE(NEW.raw_user_meta_data->>'name',          NEW.raw_user_meta_data->>'owner_name', ''),
    COALESCE(NEW.raw_user_meta_data->>'gst', ''),
    COALESCE(NEW.raw_user_meta_data->>'area', ''),
    'active',
    'retailer',
    COALESCE(NEW.raw_user_meta_data->>'created_by', 'self'),
    'R' || substr(replace(NEW.id::text, '-', ''), 1, 8)
  )
  ON CONFLICT (id) DO NOTHING;
  RETURN NEW;
EXCEPTION WHEN OTHERS THEN
  -- Never block auth signup if the profile insert has an issue.
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- One-time backfill: give every existing auth user that has no profile a row, so the
-- retailers who signed up before this fix now appear in the admin. admin@admin.com becomes
-- the distributor (also fills the "0 distributors" gap so mobile catalog management works).
INSERT INTO public.app_users (
  id, email, role, status, created_by, business_name, owner_name, shop_name, name, code
)
SELECT
  u.id, u.email,
  CASE WHEN u.email = 'admin@admin.com' THEN 'distributor' ELSE 'retailer' END,
  'active',
  CASE WHEN u.email = 'admin@admin.com' THEN 'system' ELSE 'self' END,
  COALESCE(u.raw_user_meta_data->>'business_name', u.raw_user_meta_data->>'shop_name', ''),
  COALESCE(u.raw_user_meta_data->>'owner_name',    u.raw_user_meta_data->>'name', ''),
  COALESCE(u.raw_user_meta_data->>'shop_name',     u.raw_user_meta_data->>'business_name', ''),
  COALESCE(u.raw_user_meta_data->>'name',          u.raw_user_meta_data->>'owner_name', ''),
  'R' || substr(replace(u.id::text, '-', ''), 1, 8)
FROM auth.users u
LEFT JOIN public.app_users a ON a.id = u.id
WHERE a.id IS NULL
ON CONFLICT (id) DO NOTHING;
