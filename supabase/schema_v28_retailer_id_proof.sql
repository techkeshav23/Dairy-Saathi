-- MY ORDER PRO — Schema v28 (retailer identity proof)
--
-- Retailers may not have a GST number, so signup now asks for ONE of GST / PAN / Aadhaar.
-- Store the chosen type + value; keep the existing `gst` column filled when type = 'gst'
-- so existing admin views keep working.

ALTER TABLE app_users
  ADD COLUMN IF NOT EXISTS id_type   TEXT,   -- 'gst' | 'pan' | 'aadhaar'
  ADD COLUMN IF NOT EXISTS id_number TEXT;

-- Update the signup trigger to also capture id_type / id_number from the metadata.
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
    'R' || substr(replace(NEW.id::text, '-', ''), 1, 8)
  )
  ON CONFLICT (id) DO NOTHING;
  RETURN NEW;
EXCEPTION WHEN OTHERS THEN
  RETURN NEW;
END;
$$;
