-- v38 — Retailer codes as R001, R002, R003 … (sequential, zero-padded)
--
-- v32 made codes a plain sequence number ("1", "2"). This makes them proper short codes:
-- R + 3-digit zero-padded sequence (R001…R999, then R1000+). Both self-signup and
-- admin-created retailers get their code from the handle_new_user trigger.

-- 1) Trigger: new retailers get R + zero-padded sequential code -----------------
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'public'
AS $function$
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
    'R' || lpad(nextval('public.retailer_code_seq')::text, 3, '0')
  )
  ON CONFLICT (id) DO NOTHING;
  RETURN NEW;
EXCEPTION WHEN OTHERS THEN
  RETURN NEW;
END;
$function$;

-- 2) Backfill existing retailers to R001, R002 … in signup order ---------------
WITH ordered AS (
  SELECT id, row_number() OVER (ORDER BY created_at) AS rn
  FROM public.app_users
  WHERE role = 'retailer'
)
UPDATE public.app_users u
SET code = 'R' || lpad(o.rn::text, 3, '0')
FROM ordered o
WHERE u.id = o.id;

-- 3) Continue the sequence after the last backfilled retailer ------------------
SELECT setval(
  'public.retailer_code_seq',
  GREATEST((SELECT COUNT(*) FROM public.app_users WHERE role = 'retailer'), 1),
  (SELECT COUNT(*) FROM public.app_users WHERE role = 'retailer') > 0
);
