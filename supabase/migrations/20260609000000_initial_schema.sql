-- POLA Virtual Assistant — skema PostgreSQL lengkap untuk Supabase
-- Jalankan via Supabase Dashboard → SQL Editor, atau: supabase db push

-- ---------------------------------------------------------------------------
-- Extensions
-- ---------------------------------------------------------------------------
create extension if not exists "pgcrypto";
create extension if not exists "vector";

-- ---------------------------------------------------------------------------
-- Enums
-- ---------------------------------------------------------------------------
do $$ begin
  create type public.user_role as enum ('user', 'admin');
exception
  when duplicate_object then null;
end $$;

do $$ begin
  create type public.message_sender as enum ('user', 'bot');
exception
  when duplicate_object then null;
end $$;

-- ---------------------------------------------------------------------------
-- Profiles (extends auth.users)
-- ---------------------------------------------------------------------------
create table if not exists public.profiles (
  id            uuid primary key references auth.users (id) on delete cascade,
  email         text not null,
  display_name  text,
  username      text,
  avatar_url    text,
  role          public.user_role not null default 'user',
  created_at    timestamptz not null default now(),
  updated_at    timestamptz not null default now(),
  constraint profiles_email_unique unique (email)
);

create index if not exists profiles_email_idx on public.profiles (email);
create index if not exists profiles_role_idx on public.profiles (role);

-- ---------------------------------------------------------------------------
-- User settings (JSON blob per user)
-- ---------------------------------------------------------------------------
create table if not exists public.user_settings (
  user_id     uuid primary key references public.profiles (id) on delete cascade,
  settings    jsonb not null default '{}'::jsonb,
  updated_at  timestamptz not null default now()
);

-- ---------------------------------------------------------------------------
-- Conversations & messages
-- ---------------------------------------------------------------------------
create table if not exists public.conversations (
  id          uuid primary key default gen_random_uuid(),
  user_id     uuid not null references public.profiles (id) on delete cascade,
  title       text not null default 'New chat',
  is_active   boolean not null default false,
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now()
);

create index if not exists conversations_user_id_idx on public.conversations (user_id);
create index if not exists conversations_user_updated_idx on public.conversations (user_id, updated_at desc);

create table if not exists public.messages (
  id                uuid primary key default gen_random_uuid(),
  conversation_id   uuid not null references public.conversations (id) on delete cascade,
  sender            public.message_sender not null,
  text              text not null default '',
  sources           jsonb not null default '[]'::jsonb,
  attachments       jsonb not null default '[]'::jsonb,
  created_at        timestamptz not null default now()
);

create index if not exists messages_conversation_id_idx on public.messages (conversation_id);
create index if not exists messages_conversation_created_idx on public.messages (conversation_id, created_at);

-- ---------------------------------------------------------------------------
-- Knowledge base — FAQ admin
-- ---------------------------------------------------------------------------
create table if not exists public.kb_entries (
  id          uuid primary key default gen_random_uuid(),
  question    text not null,
  answer      text not null,
  is_published boolean not null default true,
  created_by  uuid references public.profiles (id) on delete set null,
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now(),
  constraint kb_entries_question_not_empty check (char_length(trim(question)) > 0),
  constraint kb_entries_answer_not_empty check (char_length(trim(answer)) > 0)
);

create index if not exists kb_entries_published_idx on public.kb_entries (is_published, updated_at desc);

-- ---------------------------------------------------------------------------
-- Knowledge base — dokumen panjang (opsional, untuk RAG / vector search)
-- ---------------------------------------------------------------------------
create table if not exists public.kb_documents (
  id            uuid primary key default gen_random_uuid(),
  title         text not null,
  content       text not null,
  source_path   text,
  is_published  boolean not null default true,
  created_by    uuid references public.profiles (id) on delete set null,
  created_at    timestamptz not null default now(),
  updated_at    timestamptz not null default now()
);

create index if not exists kb_documents_published_idx on public.kb_documents (is_published, updated_at desc);

-- ---------------------------------------------------------------------------
-- Knowledge chunks + embeddings (pgvector, opsional)
-- ---------------------------------------------------------------------------
create table if not exists public.kb_chunks (
  id            uuid primary key default gen_random_uuid(),
  document_id   uuid references public.kb_documents (id) on delete cascade,
  entry_id      uuid references public.kb_entries (id) on delete cascade,
  chunk_index   int not null default 0,
  content       text not null,
  embedding     vector(384),
  created_at    timestamptz not null default now(),
  constraint kb_chunks_source_check check (
    (document_id is not null and entry_id is null)
    or (document_id is null and entry_id is not null)
  )
);

create index if not exists kb_chunks_document_idx on public.kb_chunks (document_id);
create index if not exists kb_chunks_entry_idx on public.kb_chunks (entry_id);

-- ---------------------------------------------------------------------------
-- updated_at trigger
-- ---------------------------------------------------------------------------
create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists profiles_set_updated_at on public.profiles;
create trigger profiles_set_updated_at
  before update on public.profiles
  for each row execute function public.set_updated_at();

drop trigger if exists user_settings_set_updated_at on public.user_settings;
create trigger user_settings_set_updated_at
  before update on public.user_settings
  for each row execute function public.set_updated_at();

drop trigger if exists conversations_set_updated_at on public.conversations;
create trigger conversations_set_updated_at
  before update on public.conversations
  for each row execute function public.set_updated_at();

drop trigger if exists kb_entries_set_updated_at on public.kb_entries;
create trigger kb_entries_set_updated_at
  before update on public.kb_entries
  for each row execute function public.set_updated_at();

drop trigger if exists kb_documents_set_updated_at on public.kb_documents;
create trigger kb_documents_set_updated_at
  before update on public.kb_documents
  for each row execute function public.set_updated_at();

-- ---------------------------------------------------------------------------
-- Auto-create profile + settings on signup
-- ---------------------------------------------------------------------------
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  dn text;
begin
  dn := coalesce(
    new.raw_user_meta_data->>'full_name',
    new.raw_user_meta_data->>'name',
    split_part(coalesce(new.email, ''), '@', 1)
  );

  insert into public.profiles (id, email, display_name)
  values (new.id, coalesce(new.email, ''), dn)
  on conflict (id) do update
    set email = excluded.email,
        display_name = coalesce(public.profiles.display_name, excluded.display_name);

  insert into public.user_settings (user_id)
  values (new.id)
  on conflict (user_id) do nothing;

  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- ---------------------------------------------------------------------------
-- Helper: cek admin
-- ---------------------------------------------------------------------------
create or replace function public.is_admin(uid uuid default auth.uid())
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1 from public.profiles p
    where p.id = uid and p.role = 'admin'
  );
$$;

-- ---------------------------------------------------------------------------
-- Row Level Security
-- ---------------------------------------------------------------------------
alter table public.profiles enable row level security;
alter table public.user_settings enable row level security;
alter table public.conversations enable row level security;
alter table public.messages enable row level security;
alter table public.kb_entries enable row level security;
alter table public.kb_documents enable row level security;
alter table public.kb_chunks enable row level security;

-- profiles
drop policy if exists "profiles_select_own_or_admin" on public.profiles;
create policy "profiles_select_own_or_admin"
  on public.profiles for select
  using (auth.uid() = id or public.is_admin());

drop policy if exists "profiles_update_own" on public.profiles;
create policy "profiles_update_own"
  on public.profiles for update
  using (auth.uid() = id)
  with check (auth.uid() = id);

drop policy if exists "profiles_admin_update_role" on public.profiles;
create policy "profiles_admin_update_role"
  on public.profiles for update
  using (public.is_admin())
  with check (public.is_admin());

-- user_settings
drop policy if exists "user_settings_select_own" on public.user_settings;
create policy "user_settings_select_own"
  on public.user_settings for select
  using (auth.uid() = user_id);

drop policy if exists "user_settings_upsert_own" on public.user_settings;
create policy "user_settings_upsert_own"
  on public.user_settings for all
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

-- conversations
drop policy if exists "conversations_select_own" on public.conversations;
create policy "conversations_select_own"
  on public.conversations for select
  using (auth.uid() = user_id);

drop policy if exists "conversations_insert_own" on public.conversations;
create policy "conversations_insert_own"
  on public.conversations for insert
  with check (auth.uid() = user_id);

drop policy if exists "conversations_update_own" on public.conversations;
create policy "conversations_update_own"
  on public.conversations for update
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

drop policy if exists "conversations_delete_own" on public.conversations;
create policy "conversations_delete_own"
  on public.conversations for delete
  using (auth.uid() = user_id);

-- messages (via conversation ownership)
drop policy if exists "messages_select_own" on public.messages;
create policy "messages_select_own"
  on public.messages for select
  using (
    exists (
      select 1 from public.conversations c
      where c.id = conversation_id and c.user_id = auth.uid()
    )
  );

drop policy if exists "messages_insert_own" on public.messages;
create policy "messages_insert_own"
  on public.messages for insert
  with check (
    exists (
      select 1 from public.conversations c
      where c.id = conversation_id and c.user_id = auth.uid()
    )
  );

drop policy if exists "messages_update_own" on public.messages;
create policy "messages_update_own"
  on public.messages for update
  using (
    exists (
      select 1 from public.conversations c
      where c.id = conversation_id and c.user_id = auth.uid()
    )
  );

drop policy if exists "messages_delete_own" on public.messages;
create policy "messages_delete_own"
  on public.messages for delete
  using (
    exists (
      select 1 from public.conversations c
      where c.id = conversation_id and c.user_id = auth.uid()
    )
  );

-- kb_entries: FAQ published bisa dibaca siapa saja (termasuk tamu), tulis admin saja
drop policy if exists "kb_entries_select_published" on public.kb_entries;
create policy "kb_entries_select_published"
  on public.kb_entries for select
  using (is_published = true or public.is_admin());

drop policy if exists "kb_entries_admin_write" on public.kb_entries;
create policy "kb_entries_admin_write"
  on public.kb_entries for all
  using (public.is_admin())
  with check (public.is_admin());

-- kb_documents
drop policy if exists "kb_documents_select_published" on public.kb_documents;
create policy "kb_documents_select_published"
  on public.kb_documents for select
  using (
    auth.uid() is not null
    and (is_published = true or public.is_admin())
  );

drop policy if exists "kb_documents_admin_write" on public.kb_documents;
create policy "kb_documents_admin_write"
  on public.kb_documents for all
  using (public.is_admin())
  with check (public.is_admin());

-- kb_chunks: baca semua user login
drop policy if exists "kb_chunks_select_auth" on public.kb_chunks;
create policy "kb_chunks_select_auth"
  on public.kb_chunks for select
  using (auth.uid() is not null);

drop policy if exists "kb_chunks_admin_write" on public.kb_chunks;
create policy "kb_chunks_admin_write"
  on public.kb_chunks for all
  using (public.is_admin())
  with check (public.is_admin());

-- ---------------------------------------------------------------------------
-- RPC: set active conversation (hanya satu aktif per user)
-- ---------------------------------------------------------------------------
create or replace function public.set_active_conversation(convo_id uuid)
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  if auth.uid() is null then
    raise exception 'Not authenticated';
  end if;

  update public.conversations
  set is_active = false
  where user_id = auth.uid();

  update public.conversations
  set is_active = true
  where id = convo_id and user_id = auth.uid();
end;
$$;

grant execute on function public.set_active_conversation(uuid) to authenticated;

-- ---------------------------------------------------------------------------
-- RPC: grant admin by email (admin only)
-- ---------------------------------------------------------------------------
create or replace function public.grant_admin_by_email(target_email text)
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  if not public.is_admin() then
    raise exception 'Admin only';
  end if;

  update public.profiles
  set role = 'admin'
  where lower(email) = lower(trim(target_email));
end;
$$;

grant execute on function public.grant_admin_by_email(text) to authenticated;

create or replace function public.revoke_admin_by_email(target_email text)
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  if not public.is_admin() then
    raise exception 'Admin only';
  end if;

  update public.profiles
  set role = 'user'
  where lower(email) = lower(trim(target_email))
    and id <> auth.uid();
end;
$$;

grant execute on function public.revoke_admin_by_email(text) to authenticated;
