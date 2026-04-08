-- ══════════════════════════════════════════════════════════════
--  FONCIRA — Migration: RLS Policies for Terrain Sellers
-- ══════════════════════════════════════════════════════════════
-- Policies for terrains_foncira to allow sellers to manage their listings

-- Enable RLS if not already enabled
ALTER TABLE terrains_foncira ENABLE ROW LEVEL SECURITY;

-- ══════════════════════════════════════════════════════════════
-- SELECT Policy: Public — Only published terrains
-- ══════════════════════════════════════════════════════════════
-- Allows anyone (including non-authenticated) to see published terrains
DROP POLICY IF EXISTS "public_can_view_published_terrains" ON terrains_foncira;

CREATE POLICY "public_can_view_published_terrains"
  ON terrains_foncira
  FOR SELECT
  USING (
    status = 'publie' 
    AND deleted_at IS NULL
  );

-- ══════════════════════════════════════════════════════════════
-- SELECT Policy: Sellers + Admins — Own drafts + all terrains
-- ══════════════════════════════════════════════════════════════
-- Sellers can see their own terrains (draft or published)
-- Admins can see all terrains (any status)
DROP POLICY IF EXISTS "sellers_admins_can_view_own_terrains" ON terrains_foncira;

CREATE POLICY "sellers_admins_can_view_own_terrains"
  ON terrains_foncira
  FOR SELECT
  USING (
    (auth.uid() = seller_id AND deleted_at IS NULL) 
    OR 
    (SELECT role FROM users WHERE id = auth.uid()) = 'admin'
  );

-- ══════════════════════════════════════════════════════════════
-- INSERT Policy: Sellers + Admins only
-- ══════════════════════════════════════════════════════════════
-- Only sellers and admins can create new terrains
DROP POLICY IF EXISTS "sellers_admins_can_create_terrains" ON terrains_foncira;

CREATE POLICY "sellers_admins_can_create_terrains"
  ON terrains_foncira
  FOR INSERT
  WITH CHECK (
    (
      SELECT role FROM users WHERE id = auth.uid()
    ) IN ('seller', 'vendor', 'admin')
    AND seller_id = auth.uid()
  );

-- ══════════════════════════════════════════════════════════════
-- UPDATE Policy: Sellers can update own terrains
-- ══════════════════════════════════════════════════════════════
-- Sellers can only update their own terrains
-- Admins can update any terrain
DROP POLICY IF EXISTS "sellers_can_update_own_terrains" ON terrains_foncira;

CREATE POLICY "sellers_can_update_own_terrains"
  ON terrains_foncira
  FOR UPDATE
  USING (
    (auth.uid() = seller_id)
    OR 
    ((SELECT role FROM users WHERE id = auth.uid()) = 'admin')
  )
  WITH CHECK (
    (auth.uid() = seller_id)
    OR 
    ((SELECT role FROM users WHERE id = auth.uid()) = 'admin')
  );

-- ══════════════════════════════════════════════════════════════
-- DELETE Policy: Admins only (soft delete via deleted_at)
-- ══════════════════════════════════════════════════════════════
-- Only admins can delete (via setting deleted_at)
DROP POLICY IF EXISTS "admins_can_delete_terrains" ON terrains_foncira;

CREATE POLICY "admins_can_delete_terrains"
  ON terrains_foncira
  FOR DELETE
  USING (
    (SELECT role FROM users WHERE id = auth.uid()) = 'admin'
  );

-- ══════════════════════════════════════════════════════════════
-- Ensure users table is properly configured
-- ══════════════════════════════════════════════════════════════
ALTER TABLE users ENABLE ROW LEVEL SECURITY;

-- Drop existing general policy if it exists to avoid conflicts
DROP POLICY IF EXISTS "users_can_view_public_info" ON users;

-- Allow users to view public info about other users
CREATE POLICY "users_can_view_public_info"
  ON users
  FOR SELECT
  USING (true);

-- Allow users to view and update their own data
DROP POLICY IF EXISTS "users_can_manage_own_data" ON users;

CREATE POLICY "users_can_manage_own_data"
  ON users
  FOR ALL
  USING (auth.uid() = id)
  WITH CHECK (auth.uid() = id);

-- Admins can view and update all user data
DROP POLICY IF EXISTS "admins_can_manage_all_users" ON users;

CREATE POLICY "admins_can_manage_all_users"
  ON users
  FOR ALL
  USING ((SELECT role FROM users WHERE id = auth.uid()) = 'admin')
  WITH CHECK ((SELECT role FROM users WHERE id = auth.uid()) = 'admin');
