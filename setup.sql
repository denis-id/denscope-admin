-- =============================================
-- MIGRASI (jika tabel admin_users sudah ada)
-- Jalankan perintah berikut di Supabase SQL Editor
-- untuk mengizinkan role 'user' dari Denscope Register:
-- =============================================
ALTER TABLE admin_users DROP CONSTRAINT IF EXISTS admin_users_role_check;
ALTER TABLE admin_users ADD CONSTRAINT admin_users_role_check 
  CHECK (role IN ('admin','author','user'));
-- =============================================
-- DENSCOPE ADMIN - Database Setup
-- Jalankan di Supabase SQL Editor
-- =============================================

-- 1. ARTICLES
create table if not exists admin_articles (
  id uuid default gen_random_uuid() primary key,
  title text,
  slug text unique,
  summary text,
  content text,
  thumbnail text,
  category text,
  author text,
  tags text[] default '{}',
  status text default 'draft' check (status in ('draft','published','scheduled')),
  views integer default 0,
  likes integer default 0,
  meta_title text,
  meta_description text,
  focus_keyword text,
  og_image text,
  scheduled_at timestamptz,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

-- 2. CATEGORIES
create table if not exists admin_categories (
  id uuid default gen_random_uuid() primary key,
  name text not null unique,
  slug text unique,
  description text,
  color text default '#6c63ff',
  created_at timestamptz default now()
);

-- 3. TAGS
create table if not exists admin_tags (
  id uuid default gen_random_uuid() primary key,
  name text not null unique,
  slug text unique,
  created_at timestamptz default now()
);

-- 4. ADMIN USERS (authors + registered users)
create table if not exists admin_users (
  id uuid default gen_random_uuid() primary key,
  name text not null,
  email text not null unique,
  password text,
  role text default 'author' check (role in ('admin','author','user')),
  avatar text,
  bio text,
  created_at timestamptz default now()
);

-- Jika tabel sudah ada, jalankan ALTER ini untuk menambah 'user' ke constraint:
-- ALTER TABLE admin_users DROP CONSTRAINT IF EXISTS admin_users_role_check;
-- ALTER TABLE admin_users ADD CONSTRAINT admin_users_role_check CHECK (role IN ('admin','author','user'));

-- 5. MEDIA
create table if not exists admin_media (
  id uuid default gen_random_uuid() primary key,
  name text,
  url text,
  size integer,
  type text,
  created_at timestamptz default now()
);

-- 6. COMMENTS (tambah kolom approved jika belum ada)
alter table comments add column if not exists approved boolean default false;

-- =============================================
-- ROW LEVEL SECURITY
-- =============================================
alter table admin_articles enable row level security;
alter table admin_categories enable row level security;
alter table admin_tags enable row level security;
alter table admin_users enable row level security;
alter table admin_media enable row level security;

-- Allow all (admin dashboard pakai anon key, auth dihandle manual)
create policy "Allow all admin_articles" on admin_articles for all using (true) with check (true);
create policy "Allow all admin_categories" on admin_categories for all using (true) with check (true);
create policy "Allow all admin_tags" on admin_tags for all using (true) with check (true);
create policy "Allow all admin_users" on admin_users for all using (true) with check (true);
create policy "Allow all admin_media" on admin_media for all using (true) with check (true);

-- =============================================
-- SEED DATA - Kategori default
-- =============================================
insert into admin_categories (name, slug, description, color) values
  ('Teknologi', 'teknologi', 'Artikel seputar teknologi terkini', '#6c63ff'),
  ('Bisnis', 'bisnis', 'Dunia bisnis dan ekonomi', '#38bdf8'),
  ('Lifestyle', 'lifestyle', 'Gaya hidup modern', '#22c55e'),
  ('Nasional', 'nasional', 'Berita dalam negeri', '#f59e0b'),
  ('Internasional', 'internasional', 'Berita mancanegara', '#ef4444'),
  ('Film', 'film', 'Review dan info film', '#a78bfa'),
  ('Novel', 'novel', 'Cerita dan fiksi', '#34d399'),
  ('Health', 'health', 'Kesehatan dan kebugaran', '#fb923c'),
  ('Otomotif', 'otomotif', 'Dunia otomotif', '#60a5fa')
on conflict (name) do nothing;

-- Seed tags default
insert into admin_tags (name, slug) values
  ('teknologi', 'teknologi'), ('AI', 'ai'), ('SEO', 'seo'),
  ('bisnis', 'bisnis'), ('lifestyle', 'lifestyle'), ('review', 'review'),
  ('tutorial', 'tutorial'), ('tips', 'tips'), ('berita', 'berita')
on conflict (name) do nothing;