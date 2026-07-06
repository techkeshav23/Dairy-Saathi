-- ======================================================================================
-- MIGRATION: v19 - Image Storage Bucket
-- Creates a public bucket for product and banner images and sets up RLS policies.
-- ======================================================================================

-- 1. Create the bucket if it doesn't exist
INSERT INTO storage.buckets (id, name, public)
VALUES ('public_images', 'public_images', true)
ON CONFLICT (id) DO NOTHING;

-- 2. (RLS is already enabled on storage.objects by default)

-- 3. Policy: Allow anyone to view/read images
CREATE POLICY "Public Access" 
ON storage.objects FOR SELECT 
USING ( bucket_id = 'public_images' );

-- 4. Policy: Allow authenticated users to upload images
CREATE POLICY "Authenticated users can upload images" 
ON storage.objects FOR INSERT 
TO authenticated 
WITH CHECK ( bucket_id = 'public_images' );

-- 5. Policy: Allow authenticated users to update their images
CREATE POLICY "Authenticated users can update images" 
ON storage.objects FOR UPDATE 
TO authenticated 
USING ( bucket_id = 'public_images' );

-- 6. Policy: Allow authenticated users to delete images
CREATE POLICY "Authenticated users can delete images" 
ON storage.objects FOR DELETE 
TO authenticated 
USING ( bucket_id = 'public_images' );
