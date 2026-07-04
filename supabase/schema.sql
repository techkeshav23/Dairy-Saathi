-- Create tables

CREATE TABLE categories (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    icon_code INT,
    color_hex TEXT,
    item_count INT DEFAULT 0
);

CREATE TABLE products (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    brand TEXT,
    category_id TEXT REFERENCES categories(id) ON DELETE SET NULL,
    image_url TEXT,
    unit TEXT,
    mrp NUMERIC(10, 2) NOT NULL DEFAULT 0,
    moq INT NOT NULL DEFAULT 1,
    stock INT NOT NULL DEFAULT 0,
    is_popular BOOLEAN NOT NULL DEFAULT FALSE,
    is_featured BOOLEAN NOT NULL DEFAULT FALSE,
    description TEXT
);

CREATE TABLE price_slabs (
    id BIGSERIAL PRIMARY KEY,
    product_id TEXT NOT NULL REFERENCES products(id) ON DELETE CASCADE,
    min_qty INT NOT NULL DEFAULT 1,
    price_per_unit NUMERIC(10, 2) NOT NULL
);

CREATE TABLE banners (
    id TEXT PRIMARY KEY,
    image_url TEXT NOT NULL,
    title TEXT,
    action_url TEXT
);

CREATE TABLE app_users (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    phone TEXT UNIQUE NOT NULL,
    name TEXT,
    shop_name TEXT,
    gst TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE orders (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES app_users(id) ON DELETE CASCADE,
    status TEXT NOT NULL DEFAULT 'placed',
    total NUMERIC(12, 2) NOT NULL DEFAULT 0,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE order_items (
    id BIGSERIAL PRIMARY KEY,
    order_id UUID NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
    product_id TEXT NOT NULL REFERENCES products(id) ON DELETE RESTRICT,
    qty INT NOT NULL DEFAULT 1,
    unit_price NUMERIC(10, 2) NOT NULL
);

CREATE TABLE ledger_entries (
    id BIGSERIAL PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES app_users(id) ON DELETE CASCADE,
    type TEXT NOT NULL,
    amount NUMERIC(12, 2) NOT NULL,
    note TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Create indexes

CREATE INDEX idx_products_category_id ON products(category_id);
CREATE INDEX idx_price_slabs_product_id ON price_slabs(product_id);
CREATE INDEX idx_orders_user_id ON orders(user_id);
CREATE INDEX idx_order_items_order_id ON order_items(order_id);
CREATE INDEX idx_order_items_product_id ON order_items(product_id);
CREATE INDEX idx_ledger_entries_user_id ON ledger_entries(user_id);

-- Enable Row Level Security (RLS)

ALTER TABLE categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE products ENABLE ROW LEVEL SECURITY;
ALTER TABLE price_slabs ENABLE ROW LEVEL SECURITY;
ALTER TABLE banners ENABLE ROW LEVEL SECURITY;
ALTER TABLE app_users ENABLE ROW LEVEL SECURITY;
ALTER TABLE orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE order_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE ledger_entries ENABLE ROW LEVEL SECURITY;

-- Create RLS Policies

-- Categories
CREATE POLICY "Allow authenticated read access on categories" 
ON categories FOR SELECT TO authenticated USING (true);

CREATE POLICY "Allow service role full access on categories" 
ON categories FOR ALL TO service_role USING (true) WITH CHECK (true);

-- Products
CREATE POLICY "Allow authenticated read access on products" 
ON products FOR SELECT TO authenticated USING (true);

CREATE POLICY "Allow service role full access on products" 
ON products FOR ALL TO service_role USING (true) WITH CHECK (true);

-- Price Slabs
CREATE POLICY "Allow authenticated read access on price_slabs" 
ON price_slabs FOR SELECT TO authenticated USING (true);

CREATE POLICY "Allow service role full access on price_slabs" 
ON price_slabs FOR ALL TO service_role USING (true) WITH CHECK (true);

-- Banners
CREATE POLICY "Allow authenticated read access on banners" 
ON banners FOR SELECT TO authenticated USING (true);

CREATE POLICY "Allow service role full access on banners" 
ON banners FOR ALL TO service_role USING (true) WITH CHECK (true);

-- App Users
CREATE POLICY "Allow authenticated read access on app_users" 
ON app_users FOR SELECT TO authenticated USING (auth.uid() = id);

CREATE POLICY "Allow service role full access on app_users" 
ON app_users FOR ALL TO service_role USING (true) WITH CHECK (true);

-- Orders
CREATE POLICY "Allow authenticated read access on orders" 
ON orders FOR SELECT TO authenticated USING (auth.uid() = user_id);

CREATE POLICY "Allow service role full access on orders" 
ON orders FOR ALL TO service_role USING (true) WITH CHECK (true);

-- Order Items
CREATE POLICY "Allow authenticated read access on order_items" 
ON order_items FOR SELECT TO authenticated USING (
    EXISTS (
        SELECT 1 FROM orders 
        WHERE orders.id = order_items.order_id 
        AND orders.user_id = auth.uid()
    )
);

CREATE POLICY "Allow service role full access on order_items" 
ON order_items FOR ALL TO service_role USING (true) WITH CHECK (true);

-- Ledger Entries
CREATE POLICY "Allow authenticated read access on ledger_entries" 
ON ledger_entries FOR SELECT TO authenticated USING (auth.uid() = user_id);

CREATE POLICY "Allow service role full access on ledger_entries" 
ON ledger_entries FOR ALL TO service_role USING (true) WITH CHECK (true);