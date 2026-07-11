-- MY ORDER PRO — Schema v32 (short sequential retailer codes)
--
-- The old codes were long/ugly ('R' + 8 hex chars, e.g. Rdd9d9437) and inconsistent
-- between self-signup and admin-created. Replace with a GLOBAL sequential number starting
-- at 1 (the business is just starting), so the admin can read/say a retailer's code easily.
--
-- Both self-signup and admin-created logins get their code from the handle_new_user trigger
-- (which fires on auth.users INSERT), so the admin API no longer generates its own code.

CREATE SEQUENCE IF NOT EXISTS public.retailer_code_seq START 1;

CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  INSERT INTO public.app_users (
    id, email, phone, business_name, owner_name, shop_name, name,
    gst, id_type, id_number, area, status, role, created_by, code
  ) VALUES (
    NEW.id,
    NEW.email,
    NULLIF(NEW.raw_user_meta_data->>'phone', ''),
    COALESCE(NEW.raw_user_meta_data->>'business_name', NEW.raw_user_meta_data->>'shop_name', ''),
    COALESCE(NEW.raw_user_meta_data->>'owner_name',    NEW.raw_user_meta_data->>'name', ''),
    COALESCE(NEW.raw_user_meta_data->>'shop_name',     NEW.raw_user_meta_data->>'business_name', ''),
    COALESCE(NEW.raw_user_meta_data->>'name',          NEW.raw_user_meta_data->>'owner_name', ''),
    COALESCE(NEW.raw_user_meta_data->>'gst', ''),
    NEW.raw_user_meta_data->>'id_type',
    NEW.raw_user_meta_data->>'id_number',
    COALESCE(NEW.raw_user_meta_data->>'area', ''),
    'active',
    'retailer',
    COALESCE(NEW.raw_user_meta_data->>'created_by', 'self'),
    nextval('public.retailer_code_seq')::text
  )
  ON CONFLICT (id) DO NOTHING;
  RETURN NEW;
EXCEPTION WHEN OTHERS THEN
  RETURN NEW;
END;
$$;
