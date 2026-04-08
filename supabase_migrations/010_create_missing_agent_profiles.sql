-- =============================================================================
-- FONCIRA - Create missing rows in public.agents for agent users
-- =============================================================================

begin;

insert into public.agents (
  user_id,
  full_name,
  agent_code,
  specializations,
  service_areas
)
select
  u.id as user_id,
  trim(
    coalesce(nullif(u.full_name, ''), '')
    || case
      when coalesce(nullif(u.full_name, ''), '') = '' then ''
      else ' '
    end
    || coalesce(nullif(u.first_name, ''), '')
    || case
      when coalesce(nullif(u.last_name, ''), '') = '' then ''
      else ' ' || u.last_name
    end
  ) as full_name_raw,
  'AGT-' || upper(substring(replace(u.id::text, '-', '') from 1 for 8)) as agent_code,
  '{}'::text[] as specializations,
  '{}'::varchar(100)[] as service_areas
from public.users u
left join public.agents a on a.user_id = u.id
where a.id is null
  and u.deleted_at is null
  and (u.primary_role = 'agent'::public.user_role or u.can_be_agent = true);

-- Guarantee non-empty full_name for any newly created rows.
update public.agents a
set full_name = coalesce(nullif(a.full_name, ''), 'Agent Foncira')
where a.full_name is null or a.full_name = '';

commit;
