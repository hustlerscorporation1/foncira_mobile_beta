-- =============================================================================
-- FONCIRA - Storage upload fix for seller photos and documents
-- =============================================================================
-- This migration is idempotent and focuses only on Storage permissions.

begin;

-- Ensure required buckets exist (and remain public for getPublicUrl usage).
insert into storage.buckets (id, name, public)
values
  ('terrain_images', 'terrain_images', true),
  ('documents', 'documents', true)
on conflict (id) do update
set
  name = excluded.name,
  public = excluded.public;

-- Ensure standard roles can interact with Storage through RLS.
grant usage on schema storage to anon, authenticated;
grant select on table storage.buckets to anon, authenticated;
grant select, insert, update, delete on table storage.objects to anon, authenticated;

do $$
begin
  if not exists (
    select 1
    from pg_policies
    where schemaname = 'storage'
      and tablename = 'objects'
      and policyname = 'foncira_storage_public_read'
  ) then
    create policy foncira_storage_public_read
      on storage.objects
      for select
      to public
      using (bucket_id in ('terrain_images', 'documents'));
  end if;

  if not exists (
    select 1
    from pg_policies
    where schemaname = 'storage'
      and tablename = 'objects'
      and policyname = 'foncira_storage_documents_insert_authenticated'
  ) then
    create policy foncira_storage_documents_insert_authenticated
      on storage.objects
      for insert
      to authenticated
      with check (
        bucket_id = 'documents'
        and auth.uid() is not null
      );
  end if;

  if not exists (
    select 1
    from pg_policies
    where schemaname = 'storage'
      and tablename = 'objects'
      and policyname = 'foncira_storage_terrain_images_insert_seller_folder'
  ) then
    create policy foncira_storage_terrain_images_insert_seller_folder
      on storage.objects
      for insert
      to authenticated
      with check (
        bucket_id = 'terrain_images'
        and auth.uid() is not null
        and split_part(name, '/', 1) = 'seller_terrains'
        and split_part(name, '/', 2) = auth.uid()::text
      );
  end if;

  if not exists (
    select 1
    from pg_policies
    where schemaname = 'storage'
      and tablename = 'objects'
      and policyname = 'foncira_storage_update_own_files'
  ) then
    create policy foncira_storage_update_own_files
      on storage.objects
      for update
      to authenticated
      using (
        bucket_id in ('terrain_images', 'documents')
        and auth.uid() is not null
        and owner = auth.uid()
      )
      with check (
        bucket_id in ('terrain_images', 'documents')
        and auth.uid() is not null
        and owner = auth.uid()
      );
  end if;

  if not exists (
    select 1
    from pg_policies
    where schemaname = 'storage'
      and tablename = 'objects'
      and policyname = 'foncira_storage_delete_own_files'
  ) then
    create policy foncira_storage_delete_own_files
      on storage.objects
      for delete
      to authenticated
      using (
        bucket_id in ('terrain_images', 'documents')
        and auth.uid() is not null
        and owner = auth.uid()
      );
  end if;
end $$;

commit;
