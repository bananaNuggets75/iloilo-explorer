-- SuroyIloilo community posts (anonymous, no auth required)
-- Run once in the Supabase SQL editor, after schema.sql.
--
-- Anyone with the publishable key can READ posts, INSERT a post, and bump a
-- post's helpful count through the mark_helpful() function only. Rows can't
-- be edited or deleted by clients — moderate by deleting rows in the Table
-- editor. `device_id` is an anonymous per-install id (no accounts) that makes
-- spam cleanup and future rate-limiting possible.

create table if not exists community_posts (
  id         uuid primary key default gen_random_uuid(),
  author     text not null,
  from_label text,
  topic      text,
  body       text not null,
  image_url  text,
  helpful    integer not null default 0,
  device_id  text,
  created_at timestamptz not null default now()
);

alter table community_posts enable row level security;

drop policy if exists "public read community_posts" on community_posts;
create policy "public read community_posts"
  on community_posts for select using (true);

drop policy if exists "public insert community_posts" on community_posts;
create policy "public insert community_posts"
  on community_posts for insert with check (
    char_length(author) between 1 and 40
    and char_length(body) between 1 and 1000
  );

-- Clients cannot update rows directly; the only write besides insert is this
-- controlled +1 on the helpful counter.
create or replace function mark_helpful(post_id uuid)
returns void
language sql
security definer
set search_path = public
as $$
  update community_posts set helpful = helpful + 1 where id = post_id;
$$;

grant execute on function mark_helpful(uuid) to anon, authenticated;

-- Public image bucket for post photos (5 MB cap per file).
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('community-images', 'community-images', true, 5242880,
        array['image/jpeg','image/png','image/webp'])
on conflict (id) do update
  set public = true,
      file_size_limit = excluded.file_size_limit,
      allowed_mime_types = excluded.allowed_mime_types;

drop policy if exists "public read community images" on storage.objects;
create policy "public read community images"
  on storage.objects for select using (bucket_id = 'community-images');

drop policy if exists "public upload community images" on storage.objects;
create policy "public upload community images"
  on storage.objects for insert with check (bucket_id = 'community-images');
