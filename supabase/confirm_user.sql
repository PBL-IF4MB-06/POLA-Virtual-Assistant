-- =============================================================================
-- Perbaikan akun yang tidak bisa login (jalankan di Supabase → SQL Editor)
-- Ganti 'email-anda@polibatam.ac.id' dengan email Anda
-- =============================================================================

-- 1) Konfirmasi email (confirmed_at otomatis terisi dari kolom ini)
update auth.users
set email_confirmed_at = now()
where lower(email) = lower('email-anda@polibatam.ac.id');

-- 2) Buat profil jika belum ada (trigger mungkin belum jalan saat daftar pertama)
insert into public.profiles (id, email, display_name, role)
select
  u.id,
  coalesce(u.email, ''),
  split_part(coalesce(u.email, ''), '@', 1),
  'user'::public.user_role
from auth.users u
where lower(u.email) = lower('email-anda@polibatam.ac.id')
  and not exists (
    select 1 from public.profiles p where p.id = u.id
  );

insert into public.user_settings (user_id)
select u.id
from auth.users u
where lower(u.email) = lower('email-anda@polibatam.ac.id')
  and not exists (
    select 1 from public.user_settings s where s.user_id = u.id
  )
on conflict (user_id) do nothing;

-- 3) Cek status akun
select
  u.id,
  u.email,
  u.email_confirmed_at,
  u.confirmed_at,
  u.created_at,
  p.role as profile_role
from auth.users u
left join public.profiles p on p.id = u.id
where lower(u.email) = lower('email-anda@polibatam.ac.id');

-- =============================================================================
-- Reset password (jika lupa password setelah banyak percobaan daftar)
-- Dashboard → Authentication → Users → pilih user → Send password recovery
-- atau set password baru di panel user tersebut
-- =============================================================================
