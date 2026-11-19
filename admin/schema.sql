-- QzzCity Digital admin database
-- Run once in the dedicated QzzCityDigital Supabase project.
-- Create your administrator account in Authentication > Users first.
-- Replace YOUR_ADMIN_EMAIL below with that exact email before running.
-- Never put a service_role key in browser code.

create extension if not exists pgcrypto;

create table if not exists public.admin_users (
  user_id uuid primary key references auth.users(id) on delete cascade
);

create or replace function public.is_qzzcity_admin()
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1 from public.admin_users
    where user_id = (select auth.uid())
  );
$$;

revoke all on function public.is_qzzcity_admin() from public;
grant execute on function public.is_qzzcity_admin() to authenticated;

create table if not exists public.services (
 id uuid primary key default gen_random_uuid(), name text not null, description text default '', category text default '', created_at timestamptz default now()
);
create table if not exists public.pricing (
 id uuid primary key default gen_random_uuid(), name text not null, price text not null, description text default '', features jsonb default '[]'::jsonb, active boolean default true, created_at timestamptz default now()
);
create table if not exists public.portfolio (
 id uuid primary key default gen_random_uuid(), title text not null, category text default '', description text default '', url text default '', image_url text default '', created_at timestamptz default now()
);
create table if not exists public.testimonials (
 id uuid primary key default gen_random_uuid(), customer_name text not null, business_name text default '', quote text not null, active boolean default false, created_at timestamptz default now()
);
create table if not exists public.enquiries (
 id uuid primary key default gen_random_uuid(), name text not null, email text default '', phone text default '', message text not null, created_at timestamptz default now()
);
create table if not exists public.site_settings (
 id uuid primary key default gen_random_uuid(), business_name text default 'QzzCity Digital', whatsapp text default '+27715382395', email text default '', announcement text default '', about text default '', created_at timestamptz default now()
);

alter table public.admin_users enable row level security;
alter table public.services enable row level security;
alter table public.pricing enable row level security;
alter table public.portfolio enable row level security;
alter table public.testimonials enable row level security;
alter table public.enquiries enable row level security;
alter table public.site_settings enable row level security;

create policy "Admins can read admin list" on public.admin_users
for select to authenticated using (user_id = (select auth.uid()) or public.is_qzzcity_admin());

create policy "Public can read services" on public.services for select to anon, authenticated using (true);
create policy "Public can read active pricing" on public.pricing for select to anon, authenticated using (active = true);
create policy "Public can read portfolio" on public.portfolio for select to anon, authenticated using (true);
create policy "Public can read published testimonials" on public.testimonials for select to anon, authenticated using (active = true);
create policy "Public can read site settings" on public.site_settings for select to anon, authenticated using (true);

create policy "Admins manage services" on public.services for all to authenticated using (public.is_qzzcity_admin()) with check (public.is_qzzcity_admin());
create policy "Admins manage pricing" on public.pricing for all to authenticated using (public.is_qzzcity_admin()) with check (public.is_qzzcity_admin());
create policy "Admins manage portfolio" on public.portfolio for all to authenticated using (public.is_qzzcity_admin()) with check (public.is_qzzcity_admin());
create policy "Admins manage testimonials" on public.testimonials for all to authenticated using (public.is_qzzcity_admin()) with check (public.is_qzzcity_admin());
create policy "Admins manage settings" on public.site_settings for all to authenticated using (public.is_qzzcity_admin()) with check (public.is_qzzcity_admin());
create policy "Admins read enquiries" on public.enquiries for select to authenticated using (public.is_qzzcity_admin());
create policy "Public submit enquiries" on public.enquiries for insert to anon, authenticated with check (true);
create policy "Admins delete enquiries" on public.enquiries for delete to authenticated using (public.is_qzzcity_admin());

grant select on public.services, public.pricing, public.portfolio, public.testimonials, public.site_settings to anon, authenticated;
grant all on public.admin_users, public.services, public.pricing, public.portfolio, public.testimonials, public.site_settings to authenticated;
grant insert on public.enquiries to anon, authenticated;
grant select, delete on public.enquiries to authenticated;

-- Add only your own account as the administrator.
insert into public.admin_users (user_id)
select id from auth.users where email = 'YOUR_ADMIN_EMAIL'
on conflict (user_id) do nothing;
