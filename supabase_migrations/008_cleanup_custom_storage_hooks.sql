-- =============================================================================
-- FONCIRA - Cleanup legacy custom storage hooks/policies
-- =============================================================================
-- Safe cleanup for experimental objects that can interfere with Storage API.

begin;

-- Remove custom trigger/function pair created by older local scripts.
drop trigger if exists storage_audit_trigger on storage.objects;
drop function if exists public.audit_storage_change();
drop function if exists public.cleanup_old_files();

-- Optional cleanup table created by old scripts.
drop table if exists public.storage_audit_log;

-- Remove legacy policies if they exist (non-destructive on files).
drop policy if exists "Enable public read on documents" on storage.objects;
drop policy if exists "Enable authenticated insert on documents" on storage.objects;
drop policy if exists "Enable authenticated delete on documents" on storage.objects;
drop policy if exists "Enable anon insert on documents" on storage.objects;

drop policy if exists "Allow authenticated users to upload" on storage.objects;
drop policy if exists "Allow public read access" on storage.objects;
drop policy if exists "Allow authenticated users to delete own files" on storage.objects;
drop policy if exists "Allow authenticated users to update own files" on storage.objects;
drop policy if exists "Allow all" on storage.objects;

commit;
