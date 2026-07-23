-- Izinkan pengguna baru membuat baris profil sendiri jika trigger belum jalan.
drop policy if exists "profiles_insert_own" on public.profiles;
create policy "profiles_insert_own"
  on public.profiles for insert
  with check (auth.uid() = id);
