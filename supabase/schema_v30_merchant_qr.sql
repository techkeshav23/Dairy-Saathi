-- MY ORDER PRO — Schema v30 (merchant QR for retailer payments)
--
-- The QR payment flow was missing the distributor's own collection QR: the app showed a
-- dummy QR and there was nowhere in the admin to set it. Add a UPI id + QR image URL to
-- store_settings. store_settings already has an authenticated-read policy, so the mobile
-- app (signed-in retailer) can read these to show the real QR at checkout.

ALTER TABLE store_settings
  ADD COLUMN IF NOT EXISTS upi_id       TEXT,
  ADD COLUMN IF NOT EXISTS qr_image_url TEXT;
