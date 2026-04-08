-- =============================================================================
-- FONCIRA - Fix 403 permission denied for table agents (agent dashboard)
-- =============================================================================

begin;

-- Ensure authenticated role can access schema and required tables.
grant usage on schema public to authenticated;

grant select on table public.agents to authenticated;
grant select on table public.verifications to authenticated;
grant select on table public.users to authenticated;
grant select on table public.verification_documents to authenticated;
grant select on table public.verification_milestones to authenticated;

-- Ensure helper functions are executable by authenticated users.
grant execute on function public.app_current_user_id() to authenticated;
grant execute on function public.app_is_admin() to authenticated;
grant execute on function public.app_is_agent() to authenticated;

-- RLS on agents: allow current agent profile (and admin) to read row.
alter table public.agents enable row level security;

drop policy if exists agents_select_self_or_admin on public.agents;
create policy agents_select_self_or_admin
  on public.agents
  for select
  to authenticated
  using (
    user_id = public.app_current_user_id()
    or public.app_is_admin()
  );

commit;
