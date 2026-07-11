-- MY ORDER PRO — Schema v33 (buyer account type: retailer vs firm)
--
-- Buyers are of two types: 'retailer' (small shop) or 'firm' (bigger GST-registered
-- business). Both order the same way (same pricing/credit/catalog) — only the signup
-- fields and labels differ. We store the chosen type; the trigger captures it from signup
-- metadata. (This is separate from `role`, which stays retailer/distributor.)

ALTER TABLE app_users
  ADD COLUMN IF NOT EXISTS account_type TEXT NOT NULL DEFAULT 'retailer';

CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  INSERT INTO public.app_users (
    id, email, phone, business_name, owner_name, shop_name, name,
    gst, id_type, id_number, area, status, role, account_type, created_by, code
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
    COALESCE(NEW.raw_user_meta_data->>'account_type', 'retailer'),
    COALESCE(NEW.raw_user_meta_data->>'created_by', 'self'),
    nextval('public.retailer_code_seq')::text
  )
  ON CONFLICT (id) DO NOTHING;
  RETURN NEW;
EXCEPTION WHEN OTHERS THEN
  RETURN NEW;
END;
$$;
