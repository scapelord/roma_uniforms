-- 1. ENUMS (The F1 Flags) --
CREATE TYPE user_role AS ENUM ('client', 'admin');
CREATE TYPE stock_status AS ENUM ('in_stock', 'limited', 'out_of_stock', 'sold_out');
CREATE TYPE order_status AS ENUM ('pending', 'processing', 'in_transit', 'delivered', 'cancelled', 'returned');

-- 2. PROFILES (Extending Auth) --
CREATE TABLE public.profiles (
  id UUID REFERENCES auth.users(id) PRIMARY KEY,
  full_name TEXT,
  phone_number TEXT,
  role user_role DEFAULT 'client',
  avatar_url TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now())
);

-- 3. PRODUCTS (The Catalogue) --
CREATE TABLE public.products (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  name TEXT NOT NULL,
  description TEXT,
  category TEXT NOT NULL, -- 'Tunic', 'Scrub', 'Labcoat'
  price DECIMAL(10,2) NOT NULL,
  sale_price DECIMAL(10,2), -- For offers
  images TEXT[], -- Array of image URLs
  stock_level INTEGER DEFAULT 0,
  status stock_status DEFAULT 'in_stock',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now())
);

-- 4. DELIVERY ZONES (The Circuit Map) --
CREATE TABLE public.delivery_zones (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  region_name TEXT NOT NULL, -- e.g., 'Nairobi CBD', 'Upcountry'
  base_cost DECIMAL(10,2) NOT NULL,
  is_door_delivery BOOLEAN DEFAULT FALSE
);

-- 5. ORDERS (The Lap Times) --
CREATE TABLE public.orders (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES public.profiles(id),
  status order_status DEFAULT 'pending',
  total_amount DECIMAL(10,2) NOT NULL,
  delivery_cost DECIMAL(10,2) NOT NULL,
  delivery_address TEXT,
  delivery_zone_id UUID REFERENCES public.delivery_zones(id),
  payment_reference TEXT, -- M-Pesa Code
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now())
);

-- 6. ORDER ITEMS (Pit Crew Details) --
CREATE TABLE public.order_items (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  order_id UUID REFERENCES public.orders(id) ON DELETE CASCADE,
  product_id UUID REFERENCES public.products(id),
  quantity INTEGER DEFAULT 1,
  unit_price DECIMAL(10,2) NOT NULL -- Price at moment of purchase
);

-- 7. SECURITY (Row Level Security) --
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE products ENABLE ROW LEVEL SECURITY;
ALTER TABLE orders ENABLE ROW LEVEL SECURITY;

-- Policy: Everyone can read products, only Admins can edit
CREATE POLICY "Public Read Products" ON products FOR SELECT USING (true);
CREATE POLICY "Admins Manage Products" ON products FOR ALL 
USING (auth.uid() IN (SELECT id FROM profiles WHERE role = 'admin'));

-- Policy: Users see their own orders, Admins see all
CREATE POLICY "Users View Own Orders" ON orders FOR SELECT 
USING (auth.uid() = user_id);
CREATE POLICY "Admins View All Orders" ON orders FOR SELECT 
USING (auth.uid() IN (SELECT id FROM profiles WHERE role = 'admin'));

-- 8. AUTO-PROFILE TRIGGER --
-- Automatically creates a profile entry when a user signs up
create function public.handle_new_user()
returns trigger as $$
begin
  insert into public.profiles (id, full_name, role)
  values (new.id, new.raw_user_meta_data->>'full_name', 'client');
  return new;
end;
$$ language plpgsql security definer;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();
