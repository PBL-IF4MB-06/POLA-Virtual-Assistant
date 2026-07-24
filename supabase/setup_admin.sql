-- =============================================================================
-- SETUP ADMIN POLA — jalankan di Supabase Dashboard → SQL Editor
-- =============================================================================
-- Langkah 1: Daftar akun admin di app (Login → Daftar) ATAU jalankan:
--   scripts/setup_admin.ps1
--
-- Akun admin default:
--   Email    : admin@polibatam.ac.id
--   Password : AdminPola2026!
--
-- Akun demo lokal (tanpa Supabase):
--   Email    : admin@pola.app
--   Password : admin12345
-- =============================================================================

-- 1) Konfirmasi email (skip verifikasi inbox)
update auth.users
set email_confirmed_at = coalesce(email_confirmed_at, now())
where lower(email) = lower('admin@polibatam.ac.id');

-- 2) Pastikan profil ada
insert into public.profiles (id, email, display_name, role)
select
  u.id,
  coalesce(u.email, ''),
  'Admin POLA',
  'admin'::public.user_role
from auth.users u
where lower(u.email) = lower('admin@polibatam.ac.id')
on conflict (id) do update
  set role = 'admin'::public.user_role,
      display_name = coalesce(public.profiles.display_name, 'Admin POLA');

-- 3) Pastikan user_settings ada
insert into public.user_settings (user_id)
select u.id
from auth.users u
where lower(u.email) = lower('admin@polibatam.ac.id')
on conflict (user_id) do nothing;

-- 4) Verifikasi
select
  u.email,
  u.email_confirmed_at is not null as email_confirmed,
  p.display_name,
  p.role
from auth.users u
left join public.profiles p on p.id = u.id
where lower(u.email) = lower('admin@polibatam.ac.id');

-- =============================================================================
-- Promosikan admin tambahan (ganti email):
-- update public.profiles set role = 'admin' where lower(email) = lower('nama@polibatam.ac.id');
-- =============================================================================
