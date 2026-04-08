-- ══════════════════════════════════════════════════════════════
--  FONCIRA — Migration: Create app_config Table
-- ══════════════════════════════════════════════════════════════
-- Execute this in Supabase SQL Editor to create the app_config table

CREATE TABLE IF NOT EXISTS app_config (
  key VARCHAR PRIMARY KEY,
  value TEXT NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Add RLS policy (optional, for security)
ALTER TABLE app_config ENABLE ROW LEVEL SECURITY;

-- Allow admins to read and write
CREATE POLICY "admins_can_manage_config"
  ON app_config
  FOR ALL
  USING (auth.jwt() ->> 'role' = 'admin')
  WITH CHECK (auth.jwt() ->> 'role' = 'admin');

-- Insert default values
INSERT INTO app_config (key, value) VALUES
  ('fcfa_to_usd_rate', '655.957'),
  ('stat_terrains_verified', '0'),
  ('stat_disputes_avoided', '0'),
  ('stat_amount_protected_usd', '0')
ON CONFLICT (key) DO NOTHING;

-- Create verification_reports table if not exists
CREATE TABLE IF NOT EXISTS verification_reports (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  verification_id UUID NOT NULL REFERENCES verifications(id),
  risk_level VARCHAR NOT NULL CHECK (risk_level IN ('faible', 'modere', 'eleve')),
  verdict TEXT NOT NULL,
  positive_points TEXT[] NOT NULL,
  points_to_verify TEXT[] NOT NULL,
  alternative_terrains JSONB,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  UNIQUE(verification_id)
);

-- Add indexes
CREATE INDEX idx_verification_reports_verification_id 
  ON verification_reports(verification_id);

-- Add RLS
ALTER TABLE verification_reports ENABLE ROW LEVEL SECURITY;

CREATE POLICY "admins_can_view_reports"
  ON verification_reports
  FOR SELECT
  USING (auth.jwt() ->> 'role' = 'admin');

CREATE POLICY "admins_can_create_reports"
  ON verification_reports
  FOR INSERT
  WITH CHECK (auth.jwt() ->> 'role' = 'admin');
