-- =============================================================================
-- FONCIRA - Fix app_config permission denied (42501)
-- =============================================================================

begin;

-- Keep RLS as protection layer
alter table public.app_config enable row level security;

-- Ensure admin check works for both linkage styles (id/auth_id)
create or replace function public.app_is_admin()
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1
    from public.users u
    where (u.auth_id = auth.uid() or u.id = auth.uid())
      and u.primary_role = 'admin'::public.user_role
      and u.deleted_at is null
  );
$$;

-- Grant table privileges to authenticated role.
-- Non-admin users remain blocked by RLS policy.
grant select, insert, update, delete on table public.app_config to authenticated;

-- Ensure a single deterministic admin-only policy exists.
drop policy if exists app_config_admin_only on public.app_config;
create policy app_config_admin_only
  on public.app_config
  for all
  to authenticated
  using (public.app_is_admin())
  with check (public.app_is_admin());

commit;
