-- =============================================================================
-- FONCIRA - Emergency repair for users + terrains_foncira
-- Target: schema "Production Database Schema (Fixed & Secured - V2)"
-- =============================================================================

begin;

-- -----------------------------------------------------------------------------
-- 1) Grants (avoid plain "permission denied for table ...")
-- -----------------------------------------------------------------------------
grant usage on schema public to anon, authenticated;

grant select, insert, update, delete on table public.users to authenticated;
grant select on table public.terrains_foncira to anon, authenticated;
grant insert, update, delete on table public.terrains_foncira to authenticated;

-- -----------------------------------------------------------------------------
-- 2) Helper functions: accept both auth_id and id linkage
-- -----------------------------------------------------------------------------
create or replace function public.app_current_user_id()
returns uuid
language sql
stable
security definer
set search_path = public
as $$
  select u.id
  from public.users u
  where (u.auth_id = auth.uid() or u.id = auth.uid())
    and u.deleted_at is null
  order by case when u.id = auth.uid() then 0 else 1 end
  limit 1;
$$;

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

create or replace function public.app_is_agent()
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
      and u.primary_role in ('agent'::user_role, 'admin'::user_role)
      and u.deleted_at is null
  );
$$;

create or replace function public.app_is_seller()
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
      and (
        u.primary_role = 'seller'::user_role
        or u.can_be_seller = true
        or u.primary_role = 'admin'::user_role
      )
      and u.deleted_at is null
  );
$$;

-- -----------------------------------------------------------------------------
-- 3) Reset only users + terrains policies (safe & deterministic)
-- -----------------------------------------------------------------------------
do $$
declare
  p record;
begin
  for p in
    select policyname
    from pg_policies
    where schemaname = 'public' and tablename = 'users'
  loop
    execute format('drop policy if exists %I on public.users', p.policyname);
  end loop;

  for p in
    select policyname
    from pg_policies
    where schemaname = 'public' and tablename = 'terrains_foncira'
  loop
    execute format('drop policy if exists %I on public.terrains_foncira', p.policyname);
  end loop;
end
$$;

create policy users_select_own_or_admin
  on public.users
  for select
  to authenticated
  using (id = public.app_current_user_id() or public.app_is_admin());

create policy users_insert_own_or_admin
  on public.users
  for insert
  to authenticated
  with check (
    auth.uid() is not null
    and (auth_id = auth.uid() or id = auth.uid() or public.app_is_admin())
  );

create policy users_update_own_or_admin
  on public.users
  for update
  to authenticated
  using (id = public.app_current_user_id() or public.app_is_admin())
  with check (id = public.app_current_user_id() or public.app_is_admin());

create policy terrains_select_published_or_owner_or_admin
  on public.terrains_foncira
  for select
  to anon, authenticated
  using (
    (status = 'publie'::listing_publication_status and deleted_at is null)
    or seller_id = public.app_current_user_id()
    or public.app_is_admin()
  );

-- Emergency mode: owner can create own listing without seller-role gating
create policy terrains_insert_owner_or_admin
  on public.terrains_foncira
  for insert
  to authenticated
  with check (
    seller_id = public.app_current_user_id()
    or public.app_is_admin()
  );

create policy terrains_update_owner_or_admin
  on public.terrains_foncira
  for update
  to authenticated
  using (seller_id = public.app_current_user_id() or public.app_is_admin())
  with check (seller_id = public.app_current_user_id() or public.app_is_admin());

create policy terrains_delete_owner_or_admin
  on public.terrains_foncira
  for delete
  to authenticated
  using (seller_id = public.app_current_user_id() or public.app_is_admin());

-- -----------------------------------------------------------------------------
-- 4) Auth sync trigger: ensure users row exists at signup
-- -----------------------------------------------------------------------------
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.users (
    id,
    auth_id,
    email,
    first_name,
    last_name,
    full_name,
    profile_photo_url
  )
  values (
    new.id,
    new.id,
    lower(new.email),
    new.raw_user_meta_data->>'first_name',
    new.raw_user_meta_data->>'last_name',
    new.raw_user_meta_data->>'full_name',
    new.raw_user_meta_data->>'avatar_url'
  )
  on conflict (id) do update
  set
    auth_id = excluded.auth_id,
    email = excluded.email,
    updated_at = now();

  return new;
exception when others then
  -- Prevent signup hard-fail on profile sync edge-cases.
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- -----------------------------------------------------------------------------
-- 5) Backfill missing public.users rows from auth.users
-- -----------------------------------------------------------------------------
insert into public.users (
  id,
  auth_id,
  email,
  first_name,
  last_name,
  full_name,
  profile_photo_url
)
select
  au.id,
  au.id,
  lower(au.email),
  au.raw_user_meta_data->>'first_name',
  au.raw_user_meta_data->>'last_name',
  au.raw_user_meta_data->>'full_name',
  au.raw_user_meta_data->>'avatar_url'
from auth.users au
where not exists (
  select 1
  from public.users u
  where u.id = au.id
     or u.auth_id = au.id
     or lower(u.email) = lower(au.email)
)
on conflict (id) do nothing;

commit;
