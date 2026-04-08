-- =============================================================================
-- FONCIRA - HOTFIX: users + terrains_foncira permissions/RLS stabilization
-- Safe to re-run (idempotent)
-- =============================================================================

BEGIN;

-- -----------------------------------------------------------------------------
-- 1) Base grants required by PostgREST
-- -----------------------------------------------------------------------------
GRANT USAGE ON SCHEMA public TO anon, authenticated;

GRANT SELECT ON TABLE public.terrains_foncira TO anon, authenticated;
GRANT INSERT, UPDATE, DELETE ON TABLE public.terrains_foncira TO authenticated;

GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE public.users TO authenticated;

-- -----------------------------------------------------------------------------
-- 2) Enable RLS (kept ON)
-- -----------------------------------------------------------------------------
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.terrains_foncira ENABLE ROW LEVEL SECURITY;

-- -----------------------------------------------------------------------------
-- 3) Helper function for admin checks (avoids copy/paste)
-- -----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.is_current_user_admin()
RETURNS BOOLEAN
LANGUAGE SQL
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT EXISTS (
    SELECT 1
    FROM public.users u
    WHERE (u.id = auth.uid() OR u.auth_id = auth.uid())
      AND u.primary_role = 'admin'::user_role
      AND u.deleted_at IS NULL
  );
$$;

REVOKE ALL ON FUNCTION public.is_current_user_admin() FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.is_current_user_admin() TO anon, authenticated;

CREATE OR REPLACE FUNCTION public.current_user_profile_id()
RETURNS UUID
LANGUAGE SQL
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT u.id
  FROM public.users u
  WHERE u.id = auth.uid() OR u.auth_id = auth.uid()
  ORDER BY CASE WHEN u.id = auth.uid() THEN 0 ELSE 1 END
  LIMIT 1;
$$;

REVOKE ALL ON FUNCTION public.current_user_profile_id() FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.current_user_profile_id() TO anon, authenticated;

-- -----------------------------------------------------------------------------
-- 4) Reset users policies to consistent state
-- -----------------------------------------------------------------------------
DROP POLICY IF EXISTS users_select_own ON public.users;
DROP POLICY IF EXISTS users_update_own ON public.users;
DROP POLICY IF EXISTS users_insert_own ON public.users;
DROP POLICY IF EXISTS users_delete_own ON public.users;
DROP POLICY IF EXISTS users_can_view_public_info ON public.users;
DROP POLICY IF EXISTS users_can_manage_own_data ON public.users;
DROP POLICY IF EXISTS admins_can_manage_all_users ON public.users;
DROP POLICY IF EXISTS users_select_self_or_admin ON public.users;
DROP POLICY IF EXISTS users_insert_self ON public.users;
DROP POLICY IF EXISTS users_update_self_or_admin ON public.users;
DROP POLICY IF EXISTS users_delete_admin_only ON public.users;

CREATE POLICY users_select_self_or_admin
  ON public.users
  FOR SELECT
  TO authenticated
  USING (
    id = public.current_user_profile_id()
    OR public.is_current_user_admin()
  );

CREATE POLICY users_insert_self
  ON public.users
  FOR INSERT
  TO authenticated
  WITH CHECK (
    id = auth.uid()
    AND auth_id = auth.uid()
  );

CREATE POLICY users_update_self_or_admin
  ON public.users
  FOR UPDATE
  TO authenticated
  USING (
    id = public.current_user_profile_id()
    OR public.is_current_user_admin()
  )
  WITH CHECK (
    id = public.current_user_profile_id()
    OR public.is_current_user_admin()
  );

CREATE POLICY users_delete_admin_only
  ON public.users
  FOR DELETE
  TO authenticated
  USING (public.is_current_user_admin());

-- -----------------------------------------------------------------------------
-- 5) Reset terrains_foncira policies to consistent state
-- -----------------------------------------------------------------------------
DROP POLICY IF EXISTS terrains_select_all ON public.terrains_foncira;
DROP POLICY IF EXISTS public_can_view_published_terrains ON public.terrains_foncira;
DROP POLICY IF EXISTS sellers_admins_can_view_own_terrains ON public.terrains_foncira;
DROP POLICY IF EXISTS sellers_admins_can_create_terrains ON public.terrains_foncira;
DROP POLICY IF EXISTS sellers_can_update_own_terrains ON public.terrains_foncira;
DROP POLICY IF EXISTS admins_can_delete_terrains ON public.terrains_foncira;
DROP POLICY IF EXISTS terrains_select_public_or_owner_or_admin ON public.terrains_foncira;
DROP POLICY IF EXISTS terrains_insert_owner ON public.terrains_foncira;
DROP POLICY IF EXISTS terrains_update_owner_or_admin ON public.terrains_foncira;
DROP POLICY IF EXISTS terrains_delete_admin_only ON public.terrains_foncira;

CREATE POLICY terrains_select_public_or_owner_or_admin
  ON public.terrains_foncira
  FOR SELECT
  TO anon, authenticated
  USING (
    deleted_at IS NULL
    AND (
      status = 'publie'
      OR seller_id = public.current_user_profile_id()
      OR public.is_current_user_admin()
    )
  );

CREATE POLICY terrains_insert_owner
  ON public.terrains_foncira
  FOR INSERT
  TO authenticated
  WITH CHECK (
    seller_id = public.current_user_profile_id()
    AND deleted_at IS NULL
  );

CREATE POLICY terrains_update_owner_or_admin
  ON public.terrains_foncira
  FOR UPDATE
  TO authenticated
  USING (
    seller_id = public.current_user_profile_id()
    OR public.is_current_user_admin()
  )
  WITH CHECK (
    seller_id = public.current_user_profile_id()
    OR public.is_current_user_admin()
  );

CREATE POLICY terrains_delete_admin_only
  ON public.terrains_foncira
  FOR DELETE
  TO authenticated
  USING (public.is_current_user_admin());

COMMIT;

-- Quick smoke checks (run manually if needed):
-- SELECT auth.uid();
-- SELECT * FROM public.users WHERE id = auth.uid() OR auth_id = auth.uid();
-- SELECT count(*) FROM public.terrains_foncira;
