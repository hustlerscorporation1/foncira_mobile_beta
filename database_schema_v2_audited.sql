-- ══════════════════════════════════════════════════════════════════════════════
--  FONCIRA — Complete Supabase Database Schema (AUDITED & CORRECTED)
--  PostgreSQL 14+ + RLS + Test Data
--  Prepared: April 2026
-- ══════════════════════════════════════════════════════════════════════════════
--
--  AUDIT NOTES:
--  - Harmonized column naming (surface -> area_sqm, location standardized)
--  - Removed duplicate status columns (terrain_status enum + status VARCHAR)
--  - Fixed foreign key relationships
--  - Optimized RLS policies
--  - Added missing timestamps
--  - Standardized UUID handling
--  - Fixed ON DELETE cascade issues
--  - Removed orphaned columns where appropriate
--  - Added seller_id standard column
--  - Unified user name handling
--

-- ══════════════════════════════════════════════════════════════════════════════
-- SECTION 1: ENUM TYPES
-- ══════════════════════════════════════════════════════════════════════════════

-- User roles
CREATE TYPE user_role AS ENUM (
  'client',
  'agent',
  'vendor',
  'admin'
);

-- Document types (for verification)
CREATE TYPE verification_document_type AS ENUM (
  'titre_foncier',
  'cession',
  'permission',
  'convention',
  'recu_vente',
  'aucun_document',
  'ne_sais_pas'
);

-- Terrain marketplace status (publication)
CREATE TYPE terrain_status AS ENUM (
  'draft',
  'publie',
  'suspendu',
  'vendu',
  'archive'
);

-- Seller type (marketplace)
CREATE TYPE seller_type AS ENUM (
  'agence',
  'particulier'
);

-- Marketplace verification level
CREATE TYPE marketplace_verification_status AS ENUM (
  'non_verifie',
  'verification_base_effectuee',
  'verification_complete'
);

-- Verification workflow status
CREATE TYPE verification_workflow_status AS ENUM (
  'receptionnee',
  'pre_analyse',
  'verification_administrative',
  'verification_terrain',
  'analyse_finale',
  'rapport_livre'
);

-- Verification source
CREATE TYPE verification_source AS ENUM (
  'foncira_marketplace',
  'externe'
);

-- Risk levels
CREATE TYPE risk_level AS ENUM (
  'faible',
  'modere',
  'eleve'
);

-- Step/Milestone status
CREATE TYPE step_status AS ENUM (
  'en_attente',
  'en_cours',
  'termine'
);

-- Payments
CREATE TYPE payment_method AS ENUM (
  'mobile_money',
  'carte_bancaire',
  'virement_bancaire'
);

CREATE TYPE payment_status AS ENUM (
  'en_attente',
  'validee',
  'echouee',
  'remboursee'
);

-- Post-report decisions
CREATE TYPE post_report_decision AS ENUM (
  'acheter',
  'accompagnement',
  'pas_maintenant'
);

-- Notifications
CREATE TYPE notification_type AS ENUM (
  'verification_update',
  'payment_confirmation',
  'report_delivered',
  'inquiry_received',
  'inquiry_responded',
  'system'
);

-- Services
CREATE TYPE service_type AS ENUM (
  'verification_seule',
  'pack_verification_accompagnement',
  'accompagnement_seul',
  'mise_en_avant_vendeur'
);

-- ══════════════════════════════════════════════════════════════════════════════
-- SECTION 2: CORE TABLES (No Dependencies)
-- ══════════════════════════════════════════════════════════════════════════════

-- ─── USERS ────────────────────────────────────────────────────────────────────
CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  email VARCHAR(255) NOT NULL UNIQUE,
  name VARCHAR(200),
  first_name VARCHAR(100),
  last_name VARCHAR(100),
  phone VARCHAR(20),
  country VARCHAR(3) DEFAULT 'TG',
  role user_role DEFAULT 'client',
  is_active BOOLEAN DEFAULT true,
  is_available BOOLEAN DEFAULT true,
  
  -- Referral
  referral_code VARCHAR(10) UNIQUE,
  referral_balance_fcfa NUMERIC(15, 2) DEFAULT 0.00,
  referral_balance_usd NUMERIC(10, 2) DEFAULT 0.00,
  
  -- Profile
  profile_photo_url VARCHAR(500),
  whatsapp VARCHAR(20),
  
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  deleted_at TIMESTAMP WITH TIME ZONE
);

CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_role ON users(role);
CREATE INDEX idx_users_referral_code ON users(referral_code);
CREATE INDEX idx_users_created_at ON users(created_at);

-- ─── AGENTS ───────────────────────────────────────────────────────────────────
CREATE TABLE agents (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL UNIQUE REFERENCES users(id) ON DELETE CASCADE,
  name VARCHAR(150) NOT NULL,
  photo_url VARCHAR(500),
  specialization VARCHAR(100),
  verifications_completed INTEGER DEFAULT 0,
  average_rating NUMERIC(3, 2) DEFAULT 0,
  is_available BOOLEAN DEFAULT true,
  current_workload INTEGER DEFAULT 0,
  max_concurrent_verifications INTEGER DEFAULT 5,
  
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

CREATE INDEX idx_agents_user_id ON agents(user_id);
CREATE INDEX idx_agents_is_available ON agents(is_available);
CREATE INDEX idx_agents_specialization ON agents(specialization);

-- ─── SERVICES ─────────────────────────────────────────────────────────────────
CREATE TABLE services (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  service_type service_type NOT NULL UNIQUE,
  label VARCHAR(150) NOT NULL,
  price_fcfa NUMERIC(15, 2) NOT NULL,
  price_usd NUMERIC(10, 2) NOT NULL,
  variable_cost_fcfa NUMERIC(15, 2) DEFAULT 0,
  is_active BOOLEAN DEFAULT true,
  
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

CREATE INDEX idx_services_is_active ON services(is_active);

-- ─── APP CONFIG (Global Settings) ─────────────────────────────────────────────
CREATE TABLE app_config (
  key VARCHAR(100) PRIMARY KEY,
  value TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- ─── TESTIMONIALS ─────────────────────────────────────────────────────────────
CREATE TABLE testimonials (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  author_name VARCHAR(150) NOT NULL,
  author_location VARCHAR(100),
  rating NUMERIC(2, 1) DEFAULT 5,
  content TEXT NOT NULL,
  is_published BOOLEAN DEFAULT false,
  
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

CREATE INDEX idx_testimonials_is_published ON testimonials(is_published);
CREATE INDEX idx_testimonials_user_id ON testimonials(user_id);
CREATE INDEX idx_testimonials_created_at ON testimonials(created_at);

-- ══════════════════════════════════════════════════════════════════════════════
-- SECTION 3: MARKETPLACE (TERRAINS)
-- ══════════════════════════════════════════════════════════════════════════════

-- ─── TERRAINS FONCIRA ─────────────────────────────────────────────────────────
CREATE TABLE terrains_foncira (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  seller_id UUID NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
  
  -- Basic info
  title VARCHAR(255) NOT NULL,
  description TEXT,
  seller_notes TEXT,
  
  -- Location (hierarchical)
  city VARCHAR(100) NOT NULL,
  quartier VARCHAR(100),
  zone VARCHAR(100),
  location_coordinates POINT, -- PostGIS: (latitude, longitude)
  
  -- Property specs
  area_sqm NUMERIC(10, 2) NOT NULL,
  is_constructible BOOLEAN DEFAULT true,
  is_viabilise BOOLEAN DEFAULT false,
  vue VARCHAR(100),
  
  -- Pricing
  price_fcfa NUMERIC(15, 2) NOT NULL,
  price_usd NUMERIC(10, 2) NOT NULL,
  
  -- Document & verification
  document_type verification_document_type DEFAULT 'aucun_document',
  marketplace_verification_status marketplace_verification_status DEFAULT 'non_verifie',
  
  -- Seller info
  seller_type seller_type NOT NULL,
  seller_name VARCHAR(150),
  seller_phone VARCHAR(20),
  seller_agency_name VARCHAR(150),
  
  -- Publishing
  status terrain_status DEFAULT 'draft',
  published_at TIMESTAMP WITH TIME ZONE,
  
  -- Media
  featured_image VARCHAR(500),
  additional_photos JSONB,
  
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  deleted_at TIMESTAMP WITH TIME ZONE
);

CREATE INDEX idx_terrains_seller_id ON terrains_foncira(seller_id);
CREATE INDEX idx_terrains_city ON terrains_foncira(city);
CREATE INDEX idx_terrains_status ON terrains_foncira(status);
CREATE INDEX idx_terrains_verification_status ON terrains_foncira(marketplace_verification_status);
CREATE INDEX idx_terrains_document_type ON terrains_foncira(document_type);
CREATE INDEX idx_terrains_price_fcfa ON terrains_foncira(price_fcfa);
CREATE INDEX idx_terrains_created_at ON terrains_foncira(created_at);

-- ─── VENDOR STATS ─────────────────────────────────────────────────────────────
CREATE TABLE vendor_stats (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL UNIQUE REFERENCES users(id) ON DELETE CASCADE,
  total_terrains INTEGER DEFAULT 0,
  total_sales INTEGER DEFAULT 0,
  revenue_fcfa NUMERIC(15, 2) DEFAULT 0,
  views_this_month INTEGER DEFAULT 0,
  conversion_rate NUMERIC(5, 2) DEFAULT 0,
  average_time_to_sale INTERVAL,
  
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

CREATE INDEX idx_vendor_stats_user_id ON vendor_stats(user_id);

-- ─── TERRAIN ANALYTICS ────────────────────────────────────────────────────────
CREATE TABLE terrain_analytics (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  terrain_id UUID NOT NULL UNIQUE REFERENCES terrains_foncira(id) ON DELETE CASCADE,
  views_count INTEGER DEFAULT 0,
  inquiries_count INTEGER DEFAULT 0,
  last_viewed_at TIMESTAMP WITH TIME ZONE,
  
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

CREATE INDEX idx_terrain_analytics_terrain_id ON terrain_analytics(terrain_id);
CREATE INDEX idx_terrain_analytics_views_count ON terrain_analytics(views_count);

-- ─── TERRAIN INQUIRIES (Buyer-Seller Communication) ───────────────────────────
CREATE TABLE terrain_inquiries (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  terrain_id UUID NOT NULL REFERENCES terrains_foncira(id) ON DELETE CASCADE,
  buyer_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  message TEXT NOT NULL,
  status VARCHAR(20) DEFAULT 'non_lu',
  response_message TEXT,
  responded_at TIMESTAMP WITH TIME ZONE,
  
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

CREATE INDEX idx_terrain_inquiries_terrain_id ON terrain_inquiries(terrain_id);
CREATE INDEX idx_terrain_inquiries_buyer_id ON terrain_inquiries(buyer_id);
CREATE INDEX idx_terrain_inquiries_status ON terrain_inquiries(status);

-- ─── VENDOR SUBSCRIPTIONS (Featured Listings) ──────────────────────────────────
CREATE TABLE vendor_subscriptions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  terrain_id UUID NOT NULL REFERENCES terrains_foncira(id) ON DELETE CASCADE,
  subscription_type VARCHAR(50) DEFAULT 'basic',
  status VARCHAR(20) DEFAULT 'active',
  price_fcfa NUMERIC(15, 2) DEFAULT 15000,
  started_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  expires_at TIMESTAMP WITH TIME ZONE,
  renewed_at TIMESTAMP WITH TIME ZONE,
  
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

CREATE INDEX idx_vendor_subscriptions_user_id ON vendor_subscriptions(user_id);
CREATE INDEX idx_vendor_subscriptions_status ON vendor_subscriptions(status);

-- ══════════════════════════════════════════════════════════════════════════════
-- SECTION 4: VERIFICATIONS
-- ══════════════════════════════════════════════════════════════════════════════

-- ─── VERIFICATIONS ────────────────────────────────────────────────────────────
CREATE TABLE verifications (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  terrain_id UUID REFERENCES terrains_foncira(id) ON DELETE SET NULL,
  
  -- Source
  source verification_source NOT NULL,
  
  -- Status & risk
  status verification_workflow_status DEFAULT 'receptionnee',
  risk_level risk_level DEFAULT 'faible',
  
  -- Terrain reference data
  client_name VARCHAR(255),
  terrain_location VARCHAR(255),
  terrain_price_fcfa NUMERIC(15, 2),
  terrain_price_usd NUMERIC(10, 2),
  document_type verification_document_type,
  
  -- External terrain data (if source='externe')
  external_location VARCHAR(255),
  external_seller_contact VARCHAR(150),
  external_price_fcfa NUMERIC(15, 2),
  external_price_usd NUMERIC(10, 2),
  external_description TEXT,
  external_source VARCHAR(100),
  
  -- Assignment
  agent_id UUID REFERENCES agents(id) ON DELETE SET NULL,
  
  -- Timeline
  submitted_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  expected_delivery_at TIMESTAMP WITH TIME ZONE,
  actual_delivery_at TIMESTAMP WITH TIME ZONE,
  
  -- Post-report
  post_report_decision post_report_decision,
  decision_made_at TIMESTAMP WITH TIME ZONE,
  
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

CREATE INDEX idx_verifications_user_id ON verifications(user_id);
CREATE INDEX idx_verifications_agent_id ON verifications(agent_id);
CREATE INDEX idx_verifications_terrain_id ON verifications(terrain_id);
CREATE INDEX idx_verifications_status ON verifications(status);
CREATE INDEX idx_verifications_risk_level ON verifications(risk_level);
CREATE INDEX idx_verifications_source ON verifications(source);
CREATE INDEX idx_verifications_submitted_at ON verifications(submitted_at);

-- ─── VERIFICATION DOCUMENTS ───────────────────────────────────────────────────
CREATE TABLE verification_documents (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  verification_id UUID NOT NULL REFERENCES verifications(id) ON DELETE CASCADE,
  file_name VARCHAR(255) NOT NULL,
  file_path VARCHAR(500) NOT NULL,
  file_type VARCHAR(10),
  file_size_bytes INTEGER,
  document_category VARCHAR(50),
  uploaded_by UUID REFERENCES users(id) ON DELETE SET NULL,
  
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

CREATE INDEX idx_verification_documents_verification_id ON verification_documents(verification_id);
CREATE INDEX idx_verification_documents_file_type ON verification_documents(file_type);

-- ─── VERIFICATION REPORTS ─────────────────────────────────────────────────────
CREATE TABLE verification_reports (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  verification_id UUID NOT NULL UNIQUE REFERENCES verifications(id) ON DELETE CASCADE,
  agent_id UUID NOT NULL REFERENCES agents(id) ON DELETE RESTRICT,
  risk_level risk_level NOT NULL,
  verdict TEXT NOT NULL,
  positive_points JSONB,
  points_to_verify JSONB,
  alternative_terrains JSONB,
  full_report_text TEXT,
  
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

CREATE INDEX idx_verification_reports_verification_id ON verification_reports(verification_id);
CREATE INDEX idx_verification_reports_agent_id ON verification_reports(agent_id);

-- ─── VERIFICATION MILESTONES ──────────────────────────────────────────────────
CREATE TABLE verification_milestones (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  verification_id UUID NOT NULL REFERENCES verifications(id) ON DELETE CASCADE,
  milestone_day INTEGER NOT NULL CHECK (milestone_day IN (1, 3, 7, 10)),
  milestone_name VARCHAR(150) NOT NULL,
  status step_status DEFAULT 'en_attente',
  started_at TIMESTAMP WITH TIME ZONE,
  completed_at TIMESTAMP WITH TIME ZONE,
  notes TEXT,
  location_photos JSONB,
  gps_coordinates JSONB,
  message_sent BOOLEAN DEFAULT false,
  message_content TEXT,
  message_sent_at TIMESTAMP WITH TIME ZONE,
  
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  
  UNIQUE(verification_id, milestone_day)
);

CREATE INDEX idx_verification_milestones_verification_id ON verification_milestones(verification_id);
CREATE INDEX idx_verification_milestones_milestone_day ON verification_milestones(milestone_day);

-- ══════════════════════════════════════════════════════════════════════════════
-- SECTION 5: PAYMENTS & TRANSACTIONS
-- ══════════════════════════════════════════════════════════════════════════════

-- ─── PAYMENTS ──────────────────────────────────────────────────────────────────
CREATE TABLE payments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  verification_id UUID NOT NULL REFERENCES verifications(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
  amount_fcfa NUMERIC(15, 2) NOT NULL,
  amount_usd NUMERIC(10, 2) NOT NULL,
  payment_method payment_method NOT NULL,
  status payment_status DEFAULT 'en_attente',
  transaction_reference VARCHAR(100),
  provider_response JSONB,
  service_id UUID REFERENCES services(id) ON DELETE SET NULL,
  paid_at TIMESTAMP WITH TIME ZONE,
  
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

CREATE INDEX idx_payments_verification_id ON payments(verification_id);
CREATE INDEX idx_payments_user_id ON payments(user_id);
CREATE INDEX idx_payments_status ON payments(status);
CREATE INDEX idx_payments_created_at ON payments(created_at);

-- ─── REFERRAL TRANSACTIONS ────────────────────────────────────────────────────
CREATE TABLE referral_transactions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  referrer_id UUID NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
  referred_user_id UUID NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
  verification_id UUID NOT NULL REFERENCES verifications(id) ON DELETE CASCADE,
  amount_earned_fcfa NUMERIC(15, 2) NOT NULL,
  amount_earned_usd NUMERIC(10, 2) NOT NULL,
  payment_status payment_status DEFAULT 'en_attente',
  paid_at TIMESTAMP WITH TIME ZONE,
  
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

CREATE INDEX idx_referral_transactions_referrer_id ON referral_transactions(referrer_id);
CREATE INDEX idx_referral_transactions_referred_user_id ON referral_transactions(referred_user_id);

-- ─── ACCOMPAGNEMENTS (Optional Support Service) ────────────────────────────────
CREATE TABLE accompagnements (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  verification_id UUID REFERENCES verifications(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  agent_id UUID REFERENCES agents(id) ON DELETE SET NULL,
  status VARCHAR(50) DEFAULT 'en_cours',
  notaire_partenaire VARCHAR(150),
  notes TEXT,
  started_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  completed_at TIMESTAMP WITH TIME ZONE,
  
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

CREATE INDEX idx_accompagnements_user_id ON accompagnements(user_id);
CREATE INDEX idx_accompagnements_verification_id ON accompagnements(verification_id);

-- ─── FEEDBACKS ────────────────────────────────────────────────────────────────
CREATE TABLE feedbacks (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  verification_id UUID NOT NULL REFERENCES verifications(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  satisfaction VARCHAR(10) NOT NULL,
  comment TEXT,
  rating NUMERIC(2, 1),
  
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

CREATE INDEX idx_feedbacks_verification_id ON feedbacks(verification_id);

-- ══════════════════════════════════════════════════════════════════════════════
-- SECTION 6: NOTIFICATIONS
-- ══════════════════════════════════════════════════════════════════════════════

-- ─── NOTIFICATIONS ────────────────────────────────────────────────────────────
CREATE TABLE notifications (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  notification_type notification_type NOT NULL,
  title VARCHAR(255) NOT NULL,
  message TEXT NOT NULL,
  related_verification_id UUID REFERENCES verifications(id) ON DELETE SET NULL,
  is_read BOOLEAN DEFAULT false,
  read_at TIMESTAMP WITH TIME ZONE,
  action_url VARCHAR(500),
  
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

CREATE INDEX idx_notifications_user_id ON notifications(user_id);
CREATE INDEX idx_notifications_is_read ON notifications(is_read);
CREATE INDEX idx_notifications_created_at ON notifications(created_at);

-- ══════════════════════════════════════════════════════════════════════════════
-- SECTION 7: ROW LEVEL SECURITY (RLS)
-- ══════════════════════════════════════════════════════════════════════════════

-- Enable RLS on all tables
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE agents ENABLE ROW LEVEL SECURITY;
ALTER TABLE services ENABLE ROW LEVEL SECURITY;
ALTER TABLE app_config ENABLE ROW LEVEL SECURITY;
ALTER TABLE testimonials ENABLE ROW LEVEL SECURITY;
ALTER TABLE terrains_foncira ENABLE ROW LEVEL SECURITY;
ALTER TABLE vendor_stats ENABLE ROW LEVEL SECURITY;
ALTER TABLE terrain_analytics ENABLE ROW LEVEL SECURITY;
ALTER TABLE terrain_inquiries ENABLE ROW LEVEL SECURITY;
ALTER TABLE vendor_subscriptions ENABLE ROW LEVEL SECURITY;
ALTER TABLE verifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE verification_documents ENABLE ROW LEVEL SECURITY;
ALTER TABLE verification_reports ENABLE ROW LEVEL SECURITY;
ALTER TABLE verification_milestones ENABLE ROW LEVEL SECURITY;
ALTER TABLE payments ENABLE ROW LEVEL SECURITY;
ALTER TABLE referral_transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE accompagnements ENABLE ROW LEVEL SECURITY;
ALTER TABLE feedbacks ENABLE ROW LEVEL SECURITY;
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;

-- ─── USERS RLS ─────────────────────────────────────────────────────────────────
-- Users can view all (public info), update own
CREATE POLICY users_select_all ON users
  FOR SELECT USING (true);

CREATE POLICY users_update_own ON users
  FOR UPDATE USING (auth.uid() = id)
  WITH CHECK (auth.uid() = id);

CREATE POLICY users_insert_own ON users
  FOR INSERT WITH CHECK (auth.uid() = id);

-- ─── AGENTS RLS ────────────────────────────────────────────────────────────────
-- All users can view agents
CREATE POLICY agents_select_all ON agents
  FOR SELECT USING (true);

-- Agents update own data, admins update all
CREATE POLICY agents_update_own_or_admin ON agents
  FOR UPDATE USING (
    auth.uid() = user_id 
    OR (SELECT role FROM users WHERE id = auth.uid()) = 'admin'
  )
  WITH CHECK (
    auth.uid() = user_id 
    OR (SELECT role FROM users WHERE id = auth.uid()) = 'admin'
  );

-- ─── SERVICES RLS ──────────────────────────────────────────────────────────────
-- All users can view services
CREATE POLICY services_select_all ON services
  FOR SELECT USING (true);

-- ─── APP_CONFIG RLS ────────────────────────────────────────────────────────────
-- All users can read, only admins can write
CREATE POLICY app_config_select_all ON app_config
  FOR SELECT USING (true);

CREATE POLICY app_config_write_admin_only ON app_config
  FOR ALL USING ((SELECT role FROM users WHERE id = auth.uid()) = 'admin')
  WITH CHECK ((SELECT role FROM users WHERE id = auth.uid()) = 'admin');

-- ─── TESTIMONIALS RLS ──────────────────────────────────────────────────────────
-- Anyone can view published, users can manage own
CREATE POLICY testimonials_select_published ON testimonials
  FOR SELECT USING (is_published = true OR auth.uid() = user_id);

CREATE POLICY testimonials_manage_own ON testimonials
  FOR ALL USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- ─── TERRAINS RLS ─────────────────────────────────────────────────────────────
-- Public see published, sellers see own, admins see all
CREATE POLICY terrains_select_public ON terrains_foncira
  FOR SELECT USING (
    status = 'publie'
    OR auth.uid() = seller_id
    OR (SELECT role FROM users WHERE id = auth.uid()) = 'admin'
  );

CREATE POLICY terrains_insert_vendors ON terrains_foncira
  FOR INSERT WITH CHECK (
    (SELECT role FROM users WHERE id = auth.uid()) IN ('vendor', 'admin')
    AND auth.uid() = seller_id
  );

CREATE POLICY terrains_update_own ON terrains_foncira
  FOR UPDATE USING (
    auth.uid() = seller_id 
    OR (SELECT role FROM users WHERE id = auth.uid()) = 'admin'
  )
  WITH CHECK (
    auth.uid() = seller_id 
    OR (SELECT role FROM users WHERE id = auth.uid()) = 'admin'
  );

-- ─── VERIFICATIONS RLS ─────────────────────────────────────────────────────────
-- Users see own, agents see assigned, admins see all
CREATE POLICY verifications_select_own ON verifications
  FOR SELECT USING (
    auth.uid() = user_id
    OR auth.uid() = (SELECT user_id FROM agents WHERE id = agent_id)
    OR (SELECT role FROM users WHERE id = auth.uid()) = 'admin'
  );

CREATE POLICY verifications_insert_own ON verifications
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY verifications_update_own ON verifications
  FOR UPDATE USING (
    auth.uid() = user_id
    OR auth.uid() = (SELECT user_id FROM agents WHERE id = agent_id)
    OR (SELECT role FROM users WHERE id = auth.uid()) = 'admin'
  )
  WITH CHECK (
    auth.uuid() = user_id
    OR auth.uid() = (SELECT user_id FROM agents WHERE id = agent_id)
    OR (SELECT role FROM users WHERE id = auth.uid()) = 'admin'
  );

-- ─── VERIFICATION DOCUMENTS RLS ────────────────────────────────────────────────
-- Same as verifications
CREATE POLICY verification_documents_select ON verification_documents
  FOR SELECT USING (
    (SELECT user_id FROM verifications WHERE id = verification_id) = auth.uid()
    OR auth.uid() = (SELECT user_id FROM agents WHERE id = (SELECT agent_id FROM verifications WHERE id = verification_id))
    OR (SELECT role FROM users WHERE id = auth.uid()) = 'admin'
  );

-- ─── PAYMENTS RLS ──────────────────────────────────────────────────────────────
-- Users see own, admins see all
CREATE POLICY payments_select_own ON payments
  FOR SELECT USING (
    auth.uid() = user_id
    OR (SELECT role FROM users WHERE id = auth.uid()) = 'admin'
  );

-- ─── NOTIFICATIONS RLS ─────────────────────────────────────────────────────────
-- Users see own only
CREATE POLICY notifications_select_own ON notifications
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY notifications_update_own ON notifications
  FOR UPDATE USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- ─── TERRAIN INQUIRIES RLS ────────────────────────────────────────────────────
-- Buyers see own, sellers see inquiries on their terrains, admins see all
CREATE POLICY terrain_inquiries_select ON terrain_inquiries
  FOR SELECT USING (
    auth.uid() = buyer_id
    OR auth.uid() = (SELECT seller_id FROM terrains_foncira WHERE id = terrain_id)
    OR (SELECT role FROM users WHERE id = auth.uid()) = 'admin'
  );

CREATE POLICY terrain_inquiries_insert_buyer ON terrain_inquiries
  FOR INSERT WITH CHECK (auth.uid() = buyer_id);

CREATE POLICY terrain_inquiries_update_seller ON terrain_inquiries
  FOR UPDATE USING (
    auth.uid() = (SELECT seller_id FROM terrains_foncira WHERE id = terrain_id)
  )
  WITH CHECK (
    auth.uid() = (SELECT seller_id FROM terrains_foncira WHERE id = terrain_id)
  );

-- ══════════════════════════════════════════════════════════════════════════════
-- SECTION 8: TEST DATA
-- ══════════════════════════════════════════════════════════════════════════════

-- ─── TEST USERS ────────────────────────────────────────────────────────────────
INSERT INTO users (
  id, email, name, first_name, last_name, phone, country, role, referral_code
) VALUES
  ('550e8400-e29b-41d4-a716-446655440001'::uuid, 'kofi@example.tg', 'Kofi Mensah', 'Kofi', 'Mensah', '+22890123456', 'TG', 'agent'::user_role, 'KOFI123'),
  ('550e8400-e29b-41d4-a716-446655440002'::uuid, 'ama@example.tg', 'Ama Owusu', 'Ama', 'Owusu', '+22890234567', 'TG', 'agent'::user_role, 'AMA456'),
  ('550e8400-e29b-41d4-a716-446655440010'::uuid, 'akosua@example.tg', 'Akosua Duah', 'Akosua', 'Duah', '+22891234567', 'TG', 'client'::user_role, 'AKOS999'),
  ('550e8400-e29b-41d4-a716-446655440011'::uuid, 'kwame@example.tg', 'Kwame Boateng', 'Kwame', 'Boateng', '+22892345678', 'TG', 'client'::user_role, 'KWAM888'),
  ('550e8400-e29b-41d4-a716-446655440012'::uuid, 'agbelamou@example.tg', 'M. Agbélamou', 'M.', 'Agbélamou', '+22890000111', 'TG', 'vendor'::user_role, 'AGBE555'),
  ('550e8400-e29b-41d4-a716-446655440014'::uuid, 'mensah@example.tg', 'Yao Mensah', 'Yao', 'Mensah', '+22890000333', 'TG', 'vendor'::user_role, 'YAO777');

-- ─── TEST AGENTS ──────────────────────────────────────────────────────────────
INSERT INTO agents (id, user_id, name, specialization, is_available, average_rating) VALUES
  ('550e8400-e29b-41d4-a716-446655440101'::uuid, '550e8400-e29b-41d4-a716-446655440001'::uuid, 'Kofi Mensah', 'Vérification cadastrale', true, 4.8),
  ('550e8400-e29b-41d4-a716-446655440102'::uuid, '550e8400-e29b-41d4-a716-446655440002'::uuid, 'Ama Owusu', 'Vérification coutumière', true, 4.6);

-- ─── TEST SERVICES ────────────────────────────────────────────────────────────
INSERT INTO services (id, service_type, label, price_fcfa, price_usd, is_active) VALUES
  ('550e8400-e29b-41d4-a716-446655440301'::uuid, 'verification_seule'::service_type, 'Vérification seule', 150000, 259, true),
  ('550e8400-e29b-41d4-a716-446655440302'::uuid, 'pack_verification_accompagnement'::service_type, 'Pack complet', 350000, 603, true),
  ('550e8400-e29b-41d4-a716-446655440303'::uuid, 'accompagnement_seul'::service_type, 'Accompagnement seul', 200000, 344, true);

-- ─── TEST TERRAINS ────────────────────────────────────────────────────────────
INSERT INTO terrains_foncira (
  id, seller_id, title, city, area_sqm, price_fcfa, price_usd,
  document_type, marketplace_verification_status, seller_type,
  seller_name, seller_phone, status, published_at
) VALUES
  ('550e8400-e29b-41d4-a716-446655440201'::uuid, '550e8400-e29b-41d4-a716-446655440012'::uuid, 
   'Terrain résidentiel 500m² à Kégué', 'Lomé', 500, 15000000, 22908,
   'titre_foncier'::verification_document_type, 'verification_base_effectuee'::marketplace_verification_status,
   'particulier'::seller_type, 'M. Agbélamou', '+22890000111', 'publie'::terrain_status, now());

-- ─── TEST VERIFICATIONS ───────────────────────────────────────────────────────
INSERT INTO verifications (
  id, user_id, terrain_id, source, status, risk_level,
  client_name, terrain_location, terrain_price_fcfa, terrain_price_usd,
  document_type, agent_id, submitted_at, expected_delivery_at
) VALUES
  ('550e8400-e29b-41d4-a716-446655440401'::uuid, '550e8400-e29b-41d4-a716-446655440010'::uuid,
   '550e8400-e29b-41d4-a716-446655440201'::uuid, 'foncira_marketplace'::verification_source,
   'rapport_livre'::verification_workflow_status, 'faible'::risk_level,
   'Akosua Duah', 'Kégué, Lomé', 15000000, 22908,
   'titre_foncier'::verification_document_type, '550e8400-e29b-41d4-a716-446655440101'::uuid,
   now() - INTERVAL '10 days', now() + INTERVAL '10 days');

-- End of schema file
