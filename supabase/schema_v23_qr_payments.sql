-- MY ORDER PRO — Schema Update for QR Payments
-- Adds payment tracking columns to orders and updates the place_order RPC.

-- 1. Add payment tracking columns to the orders table
ALTER TABLE orders 
ADD COLUMN IF NOT EXISTS payment_mode TEXT,
ADD COLUMN IF NOT EXISTS payment_screenshot TEXT,
ADD COLUMN IF NOT EXISTS payment_status TEXT DEFAULT 'pending';

-- 2. Create the payment_screenshots bucket
INSERT INTO storage.buckets (id, name, public) 
VALUES ('payment_screenshots', 'payment_screenshots', true)
ON CONFLICT (id) DO NOTHING;

-- Allow authenticated users to upload screenshots
CREATE POLICY "Allow authenticated uploads to payment_screenshots" 
ON storage.objects FOR INSERT 
TO authenticated 
WITH CHECK (bucket_id = 'payment_screenshots');

-- Allow public read access to screenshots (so Admin Panel can easily display them)
CREATE POLICY "Allow public read from payment_screenshots" 
ON storage.objects FOR SELECT 
USING (bucket_id = 'payment_screenshots');

-- 3. Update the place_order function to accept payment_mode and payment_screenshot
CREATE OR REPLACE FUNCTION place_order(
  total NUMERIC, 
  items JSONB,
  payment_mode TEXT DEFAULT 'cod',
  payment_screenshot TEXT DEFAULT NULL
)
RETURNS UUID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_uid      UUID := auth.uid();
  v_order_id UUID;
  v_item     JSONB;
BEGIN
  IF v_uid IS NULL THEN
    RAISE EXCEPTION 'not authenticated';
  END IF;

  -- Ensure the profile row exists
  INSERT INTO app_users (id, phone)
  SELECT v_uid, COALESCE(u.phone, v_uid::text)
  FROM auth.users u
  WHERE u.id = v_uid
  ON CONFLICT (id) DO NOTHING;

  -- Set status based on payment_mode
  -- If QR, it goes to 'pending_verification' status to wait for admin approval
  -- Or we can leave status as 'placed' and use payment_status = 'pending'.
  -- We'll use status='placed' and payment_status='pending' for QR.
  
  INSERT INTO orders (user_id, status, total, payment_mode, payment_screenshot, payment_status)
  VALUES (
    v_uid, 
    'placed', 
    total, 
    payment_mode, 
    payment_screenshot,
    CASE WHEN payment_mode = 'qr' THEN 'pending' ELSE 'verified' END
  )
  RETURNING id INTO v_order_id;

  FOR v_item IN SELECT jsonb_array_elements(items)
  LOOP
    INSERT INTO order_items (order_id, product_id, qty, unit_price)
    VALUES (
      v_order_id,
      v_item->>'product_id',
      COALESCE((v_item->>'qty')::INT, 1),
      COALESCE((v_item->>'unit_price')::NUMERIC, 0)
    );
  END LOOP;

  RETURN v_order_id;
END;
$$;
GRANT EXECUTE ON FUNCTION place_order(NUMERIC, JSONB, TEXT, TEXT) TO authenticated;
