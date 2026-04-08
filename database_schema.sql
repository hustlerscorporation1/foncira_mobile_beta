-- ══════════════════════════════════════════════════════════════════════════════
--  FONCIRA — Complete Production Database Schema
--  PostgreSQL + Supabase RLS + Audit Trail + Complete Platform
--  Covers: Client, Seller, Agent, Admin, Marketplace, Verification, Payments
--  Ready for immediate deployment
-- ══════════════════════════════════════════════════════════════════════════════

-- ──────────────────────────────────────────────────────────────────────────────
-- SECTION 1: ENUM TYPES (Complete Domain Model)
-- ──────────────────────────────────────────────────────────────────────────────

-- Document types declared by seller
CREATE TYPE document_type AS ENUM (
  'titre_foncier',
  'logement',
  'convention',
  'recu_vente',
  'aucun_document',
  'ne_sais_pas'
);

-- Terrain marketplace listing status
CREATE TYPE terrain_status AS ENUM (
  'disponible',
  'en_cours_vente',
  'reserve',
  'verifie',
  'suspendu',
  'archivee'
);

-- Seller type on marketplace
CREATE TYPE seller_type AS ENUM (
  'agence_immobiliere',
  'particulier',
  'promoteur'
);

-- Main verification tunnel states (client-facing)
CREATE TYPE verification_status AS ENUM (
  'receptionnee',
  'pre_analyse',
  'verification_administrative',
  'verification_terrain',
  'analyse_finale',
  'rapport_livre',
  'rapport_rejete'
);

-- Where verification originated
CREATE TYPE verification_source AS ENUM (
  'foncira_marketplace',
  'externe'
);

-- Internal milestone/step status (not client-facing)
CREATE TYPE mission_step_status AS ENUM (
  'en_attente',
  'en_cours',
  'termine',
  'reporte',
  'echec'
);

-- Risk level assessment
CREATE TYPE risk_level AS ENUM (
  'faible',
  'modere',
  'eleve',
  'critique'
);

-- Client decision after report
CREATE TYPE post_report_decision AS ENUM (
  'acheter',
  'accompagnement',
  'pas_maintenant',
  'renegocier'
);

-- Notification types for users
CREATE TYPE notification_type AS ENUM (
  'verification_update',
  'payment_confirmation',
  'report_ready',
  'agent_assigned',
  'milestone_completed',
  'action_required',
  'systeme'
);

-- Platform user roles (not just 'client', 'agent', 'admin')
CREATE TYPE user_role AS ENUM (
  'client',
  'seller',
  'agent',
  'admin',
  'support',
  'auditor'
);

-- Service offerings catalog
CREATE TYPE service_type AS ENUM (
  'verification_seule',
  'pack_verification_accompagnement',
  'accompagnement_seul',
  'mise_en_avant_vendeur',
  'audit_externe'
);

-- Marketplace verification status (linked to internal verification)
CREATE TYPE marketplace_verification_status AS ENUM (
  'non_verifie',
  'verification_base_effectuee',
  'verification_complete',
  'risque_identifie'
);

-- Payment status in payment flow
CREATE TYPE payment_status AS ENUM (
  'en_attente',
  'validee',
  'echouee',
  'remboursee',
  'en_litige'
);

-- Payment method
CREATE TYPE payment_method AS ENUM (
  'mobile_money',
  'carte_bancaire',
  'transfert_bancaire',
  'crypto'
);

-- Source types for terrain data collection
CREATE TYPE collection_source_type AS ENUM (
  'chef_coutumier',
  'vendeur',
  'voisin',
  'geometre',
  'autorite_locale',
  'autre'
);

-- File/attachment types
CREATE TYPE file_type AS ENUM (
  'document_pdf',
  'photo_jpeg',
  'photo_png',
  'audio_mp3',
  'audio_wav',
  'video_mp4',
  'spreadsheet_xlsx',
  'autre'
);

-- Notification delivery status
CREATE TYPE notification_delivery_status AS ENUM (
  'en_attente',
  'envoye',
  'lu',
  'rejete'
);

-- Admin action types (audit trail)
CREATE TYPE admin_action_type AS ENUM (
  'agent_assignation',
  'verification_validation',
  'report_approval',
  'user_modification',
  'payment_validation',
  'risk_override',
  'account_suspension',
  'autre'
);


-- ──────────────────────────────────────────────────────────────────────────────
-- SECTION 2: CORE AUTHENTICATION & PLATFORM USERS
-- ──────────────────────────────────────────────────────────────────────────────

-- ─── USERS (Linked to Supabase auth.users) ─────────────────────────────────────
CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  auth_id UUID UNIQUE, -- Links to auth.users(id) if using Supabase Auth
  email VARCHAR(255) NOT NULL UNIQUE,
  phone_number VARCHAR(20),
  country_code VARCHAR(3) DEFAULT 'TG',
  
  -- Core user data
  first_name VARCHAR(100),
  last_name VARCHAR(100),
  full_name VARCHAR(200),
  profile_photo_url VARCHAR(500),
  bio TEXT,
  
  -- Multi-role support
  primary_role user_role NOT NULL DEFAULT 'client',
  can_be_seller BOOLEAN DEFAULT false,
  can_be_agent BOOLEAN DEFAULT false,
  can_be_admin BOOLEAN DEFAULT false,
  
  -- Account status
  is_active BOOLEAN DEFAULT true,
  is_email_verified BOOLEAN DEFAULT false,
  is_phone_verified BOOLEAN DEFAULT false,
  account_status VARCHAR(50) DEFAULT 'active', -- 'active', 'suspended', 'deleted'
  
  -- Referral system
  referral_code VARCHAR(10) UNIQUE,
  referred_by_user_id UUID REFERENCES users(id) ON DELETE SET NULL,
  referral_balance_fcfa NUMERIC(15, 2) DEFAULT 0.00,
  referral_balance_usd NUMERIC(10, 2) DEFAULT 0.00,
  
  -- Timestamps
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  last_login_at TIMESTAMP WITH TIME ZONE,
  deleted_at TIMESTAMP WITH TIME ZONE
);

-- ─── USER PREFERENCES ──────────────────────────────────────────────────────────
CREATE TABLE user_preferences (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL UNIQUE REFERENCES users(id) ON DELETE CASCADE,
  
  -- Notification preferences
  email_notifications BOOLEAN DEFAULT true,
  sms_notifications BOOLEAN DEFAULT true,
  push_notifications BOOLEAN DEFAULT true,
  
  -- UI preferences
  preferred_language VARCHAR(5) DEFAULT 'fr',
  theme VARCHAR(20) DEFAULT 'dark',
  
  -- Privacy
  profile_visibility VARCHAR(20) DEFAULT 'private', -- 'private', 'public', 'sellers_only'
  
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- ──────────────────────────────────────────────────────────────────────────────
-- SECTION 3: AGENTS & INTERNAL TEAM
-- ──────────────────────────────────────────────────────────────────────────────

-- ─── AGENTS (Field verification team) ──────────────────────────────────────────
CREATE TABLE agents (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL UNIQUE REFERENCES users(id) ON DELETE CASCADE,
  
  -- Agent profile
  full_name VARCHAR(100) NOT NULL,
  agent_code VARCHAR(20) UNIQUE,
  photo_url VARCHAR(500),
  specializations TEXT[], -- Array of specialization areas
  
  -- Capabilities
  can_collect_data BOOLEAN DEFAULT true,
  can_validate_internally BOOLEAN DEFAULT false,
  can_approve_reports BOOLEAN DEFAULT false,
  
  -- Performance metrics
  verifications_completed INTEGER DEFAULT 0,
  average_rating NUMERIC(3, 2),
  reliability_score NUMERIC(5, 2) DEFAULT 100.00, -- 0-100
  
  -- Workload management
  is_available BOOLEAN DEFAULT true,
  current_mission_count INTEGER DEFAULT 0,
  max_concurrent_missions INTEGER DEFAULT 10,
  max_daily_collections INTEGER DEFAULT 5,
  
  -- Service area if applicable
  service_areas VARCHAR(100)[], -- Cities/regions agent covers
  
  -- Timestamps
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  deactivated_at TIMESTAMP WITH TIME ZONE
);

-- ─── ADMIN USERS ──────────────────────────────────────────────────────────────
CREATE TABLE admin_users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL UNIQUE REFERENCES users(id) ON DELETE CASCADE,
  
  admin_level VARCHAR(50) NOT NULL, -- 'support', 'analyst', 'lead', 'super_admin'
  department VARCHAR(100),
  
  -- Permissions
  can_assign_agents BOOLEAN DEFAULT false,
  can_approve_reports BOOLEAN DEFAULT false,
  can_validate_internally BOOLEAN DEFAULT false,
  can_suspend_users BOOLEAN DEFAULT false,
  can_manage_admins BOOLEAN DEFAULT false,
  can_manage_payments BOOLEAN DEFAULT false,
  
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- ─── APP CONFIG (Admin-editable dashboard settings/stats) ──────────────────────
CREATE TABLE app_config (
  key VARCHAR(100) PRIMARY KEY,
  value TEXT NOT NULL,
  description TEXT,
  updated_by_admin_id UUID REFERENCES admin_users(id) ON DELETE SET NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- ─── AUDIT LOG (Admin traceability) ─────────────────────────────────────────────
CREATE TABLE audit_log (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  admin_user_id UUID REFERENCES admin_users(id) ON DELETE SET NULL,
  actor_user_id UUID REFERENCES users(id) ON DELETE SET NULL,
  action_type admin_action_type NOT NULL,
  target_table VARCHAR(100),
  target_id UUID,
  previous_data JSONB,
  new_data JSONB,
  reason TEXT,
  ip_address INET,
  user_agent TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- ──────────────────────────────────────────────────────────────────────────────
-- SECTION 4: MARKETPLACE & SELLER MODE
-- ──────────────────────────────────────────────────────────────────────────────

-- ─── SELLER PROFILES ──────────────────────────────────────────────────────────
CREATE TABLE seller_profiles (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL UNIQUE REFERENCES users(id) ON DELETE CASCADE,
  
  -- Business info
  seller_type seller_type NOT NULL,
  business_name VARCHAR(255),
  business_registration_number VARCHAR(100),
  
  -- Media
  logo_url VARCHAR(500),
  cover_photo_url VARCHAR(500),
  
  -- Verification status
  is_verified BOOLEAN DEFAULT false,
  verification_documents_submitted BOOLEAN DEFAULT false,
  
  -- Performance
  total_listings INTEGER DEFAULT 0,
  total_sales INTEGER DEFAULT 0,
  response_time_hours NUMERIC(10, 2),
  average_seller_rating NUMERIC(3, 2),
  
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- ─── TERRAINS MARKETPLACE (Listings) ───────────────────────────────────────────
CREATE TABLE terrains_foncira (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  seller_id UUID NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
  
  -- Core listing data
  title VARCHAR(255) NOT NULL,
  description TEXT,
  
  -- Location hierarchy
  location VARCHAR(255) NOT NULL,
  quartier VARCHAR(100),
  zone VARCHAR(100),
  ville VARCHAR(100),
  latitude NUMERIC(10, 8),
  longitude NUMERIC(11, 8),
  
  -- Property details
  surface NUMERIC(10, 2) NOT NULL, -- in m²
  price_fcfa NUMERIC(15, 2) NOT NULL,
  price_usd NUMERIC(10, 2) NOT NULL,
  
  -- Property characteristics
  is_constructible BOOLEAN DEFAULT true,
  is_viabilise BOOLEAN DEFAULT false,
  vue VARCHAR(100),
  
  -- Documentation
  document_type document_type DEFAULT 'aucun_document',
  
  -- Marketplace status
  terrain_status terrain_status DEFAULT 'disponible',
  verification_status marketplace_verification_status DEFAULT 'non_verifie',
  
  -- Publishing
  status VARCHAR(20) DEFAULT 'draft', -- 'draft', 'publie', 'suspendu', 'vendu', 'archive'
  published_at TIMESTAMP WITH TIME ZONE,
  published_until TIMESTAMP WITH TIME ZONE, -- Premium listing expiry
  
  -- Media
  main_photo_url VARCHAR(500),
  additional_photos JSONB, -- Array of {url, uploaded_at, caption}
  
  -- Seller override fields (if agent enters data)
  seller_name VARCHAR(100),
  seller_phone VARCHAR(20),
  seller_type seller_type,
  seller_agency_name VARCHAR(100),
  
  -- Admin notes
  admin_notes TEXT,
  seller_notes TEXT,
  flagged_as JSONB, -- {reason, reported_by, reported_at}
  
  -- Internal tracking
  times_viewed INTEGER DEFAULT 0,
  times_inquired INTEGER DEFAULT 0,
  
  -- Timestamps
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  deleted_at TIMESTAMP WITH TIME ZONE
);

-- ─── TERRAIN PHOTOS (Separate for scalability) ────────────────────────────────
CREATE TABLE terrain_photos (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  terrain_id UUID NOT NULL REFERENCES terrains_foncira(id) ON DELETE CASCADE,
  
  photo_url VARCHAR(500) NOT NULL,
  caption VARCHAR(255),
  display_order INTEGER DEFAULT 0,
  
  -- Optional metadata
  taken_at TIMESTAMP WITH TIME ZONE,
  taken_by_agent_id UUID REFERENCES agents(id) ON DELETE SET NULL,
  gps_latitude NUMERIC(10, 8),
  gps_longitude NUMERIC(11, 8),
  
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- ─── TERRAIN INQUIRIES (Buyer → Seller) ───────────────────────────────────────
CREATE TABLE terrain_inquiries (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  terrain_id UUID NOT NULL REFERENCES terrains_foncira(id) ON DELETE CASCADE,
  buyer_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  
  inquiry_message TEXT NOT NULL,
  status VARCHAR(20) DEFAULT 'non_lu', -- 'non_lu', 'lu', 'repondu'
  
  seller_response TEXT,
  response_at TIMESTAMP WITH TIME ZONE,
  
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- ─── VENDOR STATS & ANALYTICS ──────────────────────────────────────────────────
CREATE TABLE vendor_stats (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL UNIQUE REFERENCES users(id) ON DELETE CASCADE,
  
  -- Aggregates
  total_listings INTEGER DEFAULT 0,
  active_listings INTEGER DEFAULT 0,
  total_sales INTEGER DEFAULT 0,
  revenue_fcfa NUMERIC(15, 2) DEFAULT 0,
  revenue_usd NUMERIC(10, 2) DEFAULT 0,
  
  -- Metrics
  views_this_month INTEGER DEFAULT 0,
  inquiries_this_month INTEGER DEFAULT 0,
  conversion_rate NUMERIC(5, 2) DEFAULT 0,
  average_time_to_sale INTERVAL,
  response_time_hours NUMERIC(10, 2),
  
  -- Ratings
  average_rating NUMERIC(3, 2),
  total_reviews INTEGER DEFAULT 0,
  
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- ─── VENDOR SUBSCRIPTIONS (Premium features) ──────────────────────────────────
CREATE TABLE vendor_subscriptions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  terrain_id UUID REFERENCES terrains_foncira(id) ON DELETE CASCADE,
  
  subscription_type VARCHAR(50), -- 'highlighted', 'featured', 'premium'
  price_fcfa NUMERIC(15, 2),
  
  status VARCHAR(20) DEFAULT 'active',
  started_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  expires_at TIMESTAMP WITH TIME ZONE,
  
  auto_renew BOOLEAN DEFAULT false,
  renewed_at TIMESTAMP WITH TIME ZONE,
  
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- ──────────────────────────────────────────────────────────────────────────────
-- SECTION 5: VERIFICATION TUNNEL (Main Client Flow)
-- ──────────────────────────────────────────────────────────────────────────────

-- ─── VERIFICATIONS (Main tunnel entity) ────────────────────────────────────────
CREATE TABLE verifications (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  terrain_id_foncira UUID REFERENCES terrains_foncira(id) ON DELETE SET NULL,
  
  -- Source & origin
  source verification_source NOT NULL DEFAULT 'externe',
  external_source_description VARCHAR(255), -- 'Facebook', 'WhatsApp', etc
  sharing_link VARCHAR(500),
  
  -- Client-visible status
  client_status verification_status DEFAULT 'receptionnee',
  client_risk_level risk_level DEFAULT 'faible',
  
  -- Terrain data captured at submission
  terrain_title VARCHAR(255) NOT NULL,
  terrain_location VARCHAR(255) NOT NULL,
  terrain_price_fcfa NUMERIC(15, 2),
  terrain_price_usd NUMERIC(10, 2),
  terrain_document_type document_type,
  
  -- External terrain data (for non-marketplace verifications)
  external_location VARCHAR(255),
  external_seller_contact VARCHAR(100),
  external_price_fcfa NUMERIC(15, 2),
  external_price_usd NUMERIC(10, 2),
  external_description TEXT,
  
  -- Agent assignment
  assigned_agent_id UUID REFERENCES agents(id) ON DELETE SET NULL,
  
  -- Timeline
  submitted_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  expected_delivery_at TIMESTAMP WITH TIME ZONE,
  actual_delivery_at TIMESTAMP WITH TIME ZONE,
  
  -- Client decision post-report
  client_post_decision post_report_decision,
  decision_made_at TIMESTAMP WITH TIME ZONE,
  
  -- Service info
  service_type service_type,
  
  -- Timestamps
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- ─── VERIFICATION INTERNAL PROCESS (Hidden from client) ──────────────────────
CREATE TABLE verification_internal_process (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  verification_id UUID NOT NULL UNIQUE REFERENCES verifications(id) ON DELETE CASCADE,
  
  -- Internal assessment
  internal_risk_level risk_level DEFAULT 'faible',
  internal_status VARCHAR(100) DEFAULT 'en_attente',
  
  -- Pre-analysis phase
  pre_analysis_notes TEXT,
  pre_analysis_completed_at TIMESTAMP WITH TIME ZONE,
  pre_analysis_by_admin_id UUID REFERENCES admin_users(id) ON DELETE SET NULL,
  
  -- Administrative verification phase
  admin_check_notes TEXT,
  admin_check_completed_at TIMESTAMP WITH TIME ZONE,
  admin_check_by_admin_id UUID REFERENCES admin_users(id) ON DELETE SET NULL,
  
  -- Field collection phase (agent)
  field_work_started_at TIMESTAMP WITH TIME ZONE,
  field_work_completed_at TIMESTAMP WITH TIME ZONE,
  
  -- Internal validation phase
  internal_validation_notes TEXT,
  internal_validation_completed_at TIMESTAMP WITH TIME ZONE,
  internal_validation_by_admin_id UUID REFERENCES admin_users(id) ON DELETE SET NULL,
  
  -- Final analysis phase
  final_analysis_notes TEXT,
  final_analysis_completed_at TIMESTAMP WITH TIME ZONE,
  final_analysis_by_admin_id UUID REFERENCES admin_users(id) ON DELETE SET NULL,
  
  -- Risk flags identified internally
  risk_flags JSONB, -- Array of {flag, severity, notes}
  risk_override BOOLEAN DEFAULT false,
  risk_override_reason TEXT,
  risk_override_by_admin_id UUID REFERENCES admin_users(id) ON DELETE SET NULL,
  
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- ─── VERIFICATION DOCUMENTS ───────────────────────────────────────────────────
CREATE TABLE verification_documents (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  verification_id UUID NOT NULL REFERENCES verifications(id) ON DELETE CASCADE,
  
  file_name VARCHAR(255) NOT NULL,
  file_path VARCHAR(500) NOT NULL,
  file_type file_type NOT NULL,
  file_size_bytes INTEGER,
  
  document_category VARCHAR(50), -- 'titre', 'convention', 'recu', 'photo', 'autre'
  
  uploaded_by_user_id UUID REFERENCES users(id) ON DELETE SET NULL,
  uploaded_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  
  -- Optional: expiry for sensitive docs
  expires_at TIMESTAMP WITH TIME ZONE,
  
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- ─── VERIFICATION REPORTS (Final deliverable to client) ──────────────────────
CREATE TABLE verification_reports (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  verification_id UUID NOT NULL UNIQUE REFERENCES verifications(id) ON DELETE CASCADE,
  
  -- Analysis
  agent_id UUID REFERENCES agents(id) ON DELETE SET NULL,
  reviewed_by_admin_id UUID REFERENCES admin_users(id) ON DELETE SET NULL,
  
  -- Main findings
  risk_level risk_level NOT NULL,
  verdict_summary VARCHAR(500) NOT NULL, -- 1-2 sentence summary
  executive_summary TEXT, -- Longer summary for client
  
  -- Detailed findings
  positive_points JSONB, -- Array of identified strengths
  points_to_verify JSONB, -- Array of items requiring attention
  risks_identified JSONB, -- Array of identified risks {risk, severity, recommendation}
  alternative_terrains JSONB, -- Array of similar terrains as alternatives
  
  -- Full report
  full_report_text TEXT,
  
  -- Recommendations
  recommendations TEXT,
  next_steps TEXT,
  
  -- Validation
  is_approved BOOLEAN DEFAULT false,
  approved_at TIMESTAMP WITH TIME ZONE,
  approved_by_admin_id UUID REFERENCES admin_users(id) ON DELETE SET NULL,
  
  -- Timeline
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  delivered_at TIMESTAMP WITH TIME ZONE
);

-- ─── VERIFICATION MILESTONES (J1/J3/J7/J10 tracking) ────────────────────────
CREATE TABLE verification_milestones (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  verification_id UUID NOT NULL REFERENCES verifications(id) ON DELETE CASCADE,
  
  milestone_day INTEGER NOT NULL, -- 1, 3, 7, 10
  milestone_name VARCHAR(100) NOT NULL,
  milestone_description TEXT,
  
  status mission_step_status DEFAULT 'en_attente',
  
  started_at TIMESTAMP WITH TIME ZONE,
  completed_at TIMESTAMP WITH TIME ZONE,
  
  -- Milestone data
  location_photos JSONB, -- Array of photo URLs
  gps_coordinates JSONB, -- {latitude, longitude}
  notes TEXT,
  
  -- Proactive notifications
  client_notification_sent BOOLEAN DEFAULT false,
  client_notification_sent_at TIMESTAMP WITH TIME ZONE,
  client_notification_message TEXT,
  
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);



-- ─── MISSING TABLES ──────────────────────────────────────────────────────────

-- Terrain analytics table
CREATE TABLE terrain_analytics (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  terrain_id UUID NOT NULL UNIQUE REFERENCES terrains_foncira(id) ON DELETE CASCADE,
  views_count INTEGER DEFAULT 0,
  inquiries_count INTEGER DEFAULT 0,
  last_viewed_at TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- Testimonials table
CREATE TABLE testimonials (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  verification_id UUID REFERENCES verifications(id) ON DELETE SET NULL,
  rating INTEGER CHECK (rating >= 1 AND rating <= 5),
  title VARCHAR(255),
  content TEXT NOT NULL,
  is_published BOOLEAN DEFAULT false,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- Services table
CREATE TABLE services (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name VARCHAR(255) NOT NULL,
  description TEXT,
  price_fcfa NUMERIC(15, 2) NOT NULL,
  price_usd NUMERIC(10, 2) NOT NULL,
  service_type service_type,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);


-- ──────────────────────────────────────────────────────────────────────────────
-- SECTION 6: PAYMENTS & TRANSACTIONS
-- ──────────────────────────────────────────────────────────────────────────────

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
  provider_response JSONB, -- Réponse du fournisseur de paiement
  paid_at TIMESTAMP WITH TIME ZONE,
  service_type service_type,
  service_id UUID REFERENCES services(id) ON DELETE SET NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);


CREATE TABLE accompagnements (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  verification_id UUID REFERENCES verifications(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES users(id),
  agent_id UUID REFERENCES agents(id),
  status VARCHAR(50) DEFAULT 'en_cours',
  notaire_partenaire VARCHAR(100),
  notes TEXT,
  started_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  completed_at TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

CREATE TABLE feedbacks (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  verification_id UUID NOT NULL REFERENCES verifications(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES users(id),
  satisfaction VARCHAR(10) NOT NULL, -- 'yes', 'maybe', 'no'
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);


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

-- ──────────────────────────────────────────────────────────────────────────────
-- SECTION 7: NOTIFICATIONS & MESSAGING
-- ──────────────────────────────────────────────────────────────────────────────

-- ─── NOTIFICATIONS ────────────────────────────────────────────────────────────
CREATE TABLE notifications (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  recipient_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  notification_type notification_type NOT NULL,
  title VARCHAR(255) NOT NULL,
  message TEXT NOT NULL,
  related_verification_id UUID REFERENCES verifications(id) ON DELETE SET NULL,
  is_read BOOLEAN DEFAULT false,
  read_at TIMESTAMP WITH TIME ZONE,
  action_url VARCHAR(500),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- ──────────────────────────────────────────────────────────────────────────────
-- SECTION 8: INDEXES FOR PERFORMANCE
-- ──────────────────────────────────────────────────────────────────────────────

CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_referral_code ON users(referral_code);
CREATE INDEX idx_users_created_at ON users(created_at);

CREATE INDEX idx_agents_user_id ON agents(user_id);
CREATE INDEX idx_agents_is_available ON agents(is_available);

CREATE INDEX idx_terrains_ville ON terrains_foncira(ville);
CREATE INDEX idx_terrains_document_type ON terrains_foncira(document_type);
CREATE INDEX idx_terrains_terrain_status ON terrains_foncira(terrain_status);
CREATE INDEX idx_terrains_verification_status ON terrains_foncira(verification_status);
CREATE INDEX idx_terrains_created_at ON terrains_foncira(created_at);
CREATE INDEX idx_terrains_price_fcfa ON terrains_foncira(price_fcfa);
CREATE INDEX idx_terrains_surface ON terrains_foncira(surface);

CREATE INDEX idx_verifications_user_id ON verifications(user_id);
CREATE INDEX idx_verifications_agent_id ON verifications(assigned_agent_id);
CREATE INDEX idx_verifications_terrain_id ON verifications(terrain_id_foncira);
CREATE INDEX idx_verifications_status ON verifications(client_status);
CREATE INDEX idx_verifications_risk_level ON verifications(client_risk_level);
CREATE INDEX idx_verifications_source ON verifications(source);
CREATE INDEX idx_verifications_submitted_at ON verifications(submitted_at);
CREATE INDEX idx_verifications_created_at ON verifications(created_at);

CREATE INDEX idx_verification_documents_verification_id ON verification_documents(verification_id);
CREATE INDEX idx_verification_documents_file_type ON verification_documents(file_type);

CREATE INDEX idx_verification_reports_verification_id ON verification_reports(verification_id);
CREATE INDEX idx_verification_reports_agent_id ON verification_reports(agent_id);
CREATE INDEX idx_verification_reports_risk_level ON verification_reports(risk_level);

CREATE INDEX idx_verification_milestones_verification_id ON verification_milestones(verification_id);
CREATE INDEX idx_verification_milestones_milestone_day ON verification_milestones(milestone_day);
CREATE INDEX idx_verification_milestones_status ON verification_milestones(status);

CREATE INDEX idx_payments_verification_id ON payments(verification_id);
CREATE INDEX idx_payments_user_id ON payments(user_id);
CREATE INDEX idx_payments_status ON payments(status);
CREATE INDEX idx_payments_created_at ON payments(created_at);

CREATE INDEX idx_referral_transactions_referrer_id ON referral_transactions(referrer_id);
CREATE INDEX idx_referral_transactions_referred_user_id ON referral_transactions(referred_user_id);

CREATE INDEX idx_notifications_recipient_id ON notifications(recipient_id);
CREATE INDEX idx_notifications_is_read ON notifications(is_read);
CREATE INDEX idx_notifications_verification_id ON notifications(related_verification_id);
CREATE INDEX idx_notifications_created_at ON notifications(created_at);

CREATE INDEX idx_testimonials_is_published ON testimonials(is_published);
CREATE INDEX idx_testimonials_created_at ON testimonials(created_at);

-- Indexes for seller dashboard tables
CREATE INDEX idx_terrains_seller_id ON terrains_foncira(seller_id);
CREATE INDEX idx_terrains_status ON terrains_foncira(status);
CREATE INDEX idx_terrains_published_at ON terrains_foncira(published_at);

CREATE INDEX idx_vendor_stats_user_id ON vendor_stats(user_id);
CREATE INDEX idx_vendor_stats_updated_at ON vendor_stats(updated_at);

CREATE INDEX idx_app_config_updated_at ON app_config(updated_at);

CREATE INDEX idx_audit_log_admin_user_id ON audit_log(admin_user_id);
CREATE INDEX idx_audit_log_actor_user_id ON audit_log(actor_user_id);
CREATE INDEX idx_audit_log_action_type ON audit_log(action_type);
CREATE INDEX idx_audit_log_created_at ON audit_log(created_at);

CREATE INDEX idx_terrain_analytics_terrain_id ON terrain_analytics(terrain_id);
CREATE INDEX idx_terrain_analytics_views_count ON terrain_analytics(views_count);

CREATE INDEX idx_terrain_inquiries_terrain_id ON terrain_inquiries(terrain_id);
CREATE INDEX idx_terrain_inquiries_buyer_id ON terrain_inquiries(buyer_id);
CREATE INDEX idx_terrain_inquiries_status ON terrain_inquiries(status);
CREATE INDEX idx_terrain_inquiries_created_at ON terrain_inquiries(created_at);

-- ──────────────────────────────────────────────────────────────────────────────
-- SECTION 9: ROW LEVEL SECURITY (RLS)
-- ──────────────────────────────────────────────────────────────────────────────

-- Enable RLS on all tables
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE agents ENABLE ROW LEVEL SECURITY;
ALTER TABLE admin_users ENABLE ROW LEVEL SECURITY;
ALTER TABLE terrains_foncira ENABLE ROW LEVEL SECURITY;
ALTER TABLE verifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE verification_documents ENABLE ROW LEVEL SECURITY;
ALTER TABLE verification_reports ENABLE ROW LEVEL SECURITY;
ALTER TABLE verification_milestones ENABLE ROW LEVEL SECURITY;
ALTER TABLE payments ENABLE ROW LEVEL SECURITY;
ALTER TABLE referral_transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE testimonials ENABLE ROW LEVEL SECURITY;
ALTER TABLE vendor_stats ENABLE ROW LEVEL SECURITY;
ALTER TABLE terrain_analytics ENABLE ROW LEVEL SECURITY;
ALTER TABLE terrain_inquiries ENABLE ROW LEVEL SECURITY;
ALTER TABLE vendor_subscriptions ENABLE ROW LEVEL SECURITY;
ALTER TABLE services ENABLE ROW LEVEL SECURITY;
ALTER TABLE app_config ENABLE ROW LEVEL SECURITY;
ALTER TABLE audit_log ENABLE ROW LEVEL SECURITY;

-- ─── ADMIN USERS RLS ───────────────────────────────────────────────────────────
-- Only admins can read/write admin users table
CREATE POLICY admin_users_select_admin_only ON admin_users
  FOR SELECT USING (
    EXISTS (
      SELECT 1
      FROM users u
      WHERE (u.id::text = auth.uid()::text OR u.auth_id = auth.uid())
        AND u.primary_role = 'admin'::user_role
    )
  );

CREATE POLICY admin_users_insert_admin_only ON admin_users
  FOR INSERT WITH CHECK (
    EXISTS (
      SELECT 1
      FROM users u
      WHERE (u.id::text = auth.uid()::text OR u.auth_id = auth.uid())
        AND u.primary_role = 'admin'::user_role
    )
  );

CREATE POLICY admin_users_update_admin_only ON admin_users
  FOR UPDATE USING (
    EXISTS (
      SELECT 1
      FROM users u
      WHERE (u.id::text = auth.uid()::text OR u.auth_id = auth.uid())
        AND u.primary_role = 'admin'::user_role
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1
      FROM users u
      WHERE (u.id::text = auth.uid()::text OR u.auth_id = auth.uid())
        AND u.primary_role = 'admin'::user_role
    )
  );

CREATE POLICY admin_users_delete_admin_only ON admin_users
  FOR DELETE USING (
    EXISTS (
      SELECT 1
      FROM users u
      WHERE (u.id::text = auth.uid()::text OR u.auth_id = auth.uid())
        AND u.primary_role = 'admin'::user_role
    )
  );

-- ─── APP CONFIG RLS ────────────────────────────────────────────────────────────
-- Admin-only config table for dashboard parameters and social-proof counters
CREATE POLICY app_config_select_admin_only ON app_config
  FOR SELECT USING (
    EXISTS (
      SELECT 1
      FROM users u
      WHERE (u.id::text = auth.uid()::text OR u.auth_id = auth.uid())
        AND u.primary_role = 'admin'::user_role
    )
  );

CREATE POLICY app_config_insert_admin_only ON app_config
  FOR INSERT WITH CHECK (
    EXISTS (
      SELECT 1
      FROM users u
      WHERE (u.id::text = auth.uid()::text OR u.auth_id = auth.uid())
        AND u.primary_role = 'admin'::user_role
    )
  );

CREATE POLICY app_config_update_admin_only ON app_config
  FOR UPDATE USING (
    EXISTS (
      SELECT 1
      FROM users u
      WHERE (u.id::text = auth.uid()::text OR u.auth_id = auth.uid())
        AND u.primary_role = 'admin'::user_role
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1
      FROM users u
      WHERE (u.id::text = auth.uid()::text OR u.auth_id = auth.uid())
        AND u.primary_role = 'admin'::user_role
    )
  );

CREATE POLICY app_config_delete_admin_only ON app_config
  FOR DELETE USING (
    EXISTS (
      SELECT 1
      FROM users u
      WHERE (u.id::text = auth.uid()::text OR u.auth_id = auth.uid())
        AND u.primary_role = 'admin'::user_role
    )
  );

-- ─── AUDIT LOG RLS ─────────────────────────────────────────────────────────────
-- Audit logs are readable by admins only and append-only
CREATE POLICY audit_log_select_admin_only ON audit_log
  FOR SELECT USING (
    EXISTS (
      SELECT 1
      FROM users u
      WHERE (u.id::text = auth.uid()::text OR u.auth_id = auth.uid())
        AND u.primary_role = 'admin'::user_role
    )
  );

CREATE POLICY audit_log_insert_admin_only ON audit_log
  FOR INSERT WITH CHECK (
    EXISTS (
      SELECT 1
      FROM users u
      WHERE (u.id::text = auth.uid()::text OR u.auth_id = auth.uid())
        AND u.primary_role = 'admin'::user_role
    )
  );

-- ─── USERS RLS ─────────────────────────────────────────────────────────────────
-- Users see only their own profile (or admins see all)
CREATE POLICY users_select_own ON users
  FOR SELECT USING (
    auth.uid()::text = id::text 
    OR (SELECT primary_role FROM users WHERE id = auth.uid()::uuid) = 'admin'::user_role
  );

CREATE POLICY users_update_own ON users
  FOR UPDATE USING (auth.uid()::text = id::text)
  WITH CHECK (auth.uid()::text = id::text);

-- ─── AGENTS RLS ────────────────────────────────────────────────────────────────
-- All users can view agents, agents see only their own record
CREATE POLICY agents_select_all ON agents
  FOR SELECT USING (true);

CREATE POLICY agents_update_own ON agents
  FOR UPDATE USING (auth.uid()::text = user_id::text)
  WITH CHECK (auth.uid()::text = user_id::text);

-- ─── TERRAINS RLS ──────────────────────────────────────────────────────────────
-- All users can view published terrains
CREATE POLICY terrains_select_all ON terrains_foncira
  FOR SELECT USING (true);

-- ─── VERIFICATIONS RLS ─────────────────────────────────────────────────────────
-- Users see only their own verifications (or agents assigned to them, or admins)
CREATE POLICY verifications_select_own ON verifications
  FOR SELECT USING (
    auth.uid()::text = user_id::text 
    OR auth.uid()::text = (SELECT user_id::text FROM agents WHERE id = assigned_agent_id)
    OR (SELECT primary_role FROM users WHERE id = auth.uid()::uuid) = 'admin'::user_role
  );

CREATE POLICY verifications_insert_own ON verifications
  FOR INSERT WITH CHECK (auth.uid()::text = user_id::text);

CREATE POLICY verifications_update_own ON verifications
  FOR UPDATE USING (
    auth.uid()::text = user_id::text 
    OR auth.uid()::text = (SELECT user_id::text FROM agents WHERE id = assigned_agent_id)
    OR (SELECT primary_role FROM users WHERE id = auth.uid()::uuid) = 'admin'::user_role
  );

-- ─── VERIFICATION DOCUMENTS RLS ────────────────────────────────────────────────
-- Users see documents from their own verifications (or assigned agents, or admins)
CREATE POLICY verification_documents_select ON verification_documents
  FOR SELECT USING (
    (SELECT user_id::text FROM verifications WHERE id = verification_id) = auth.uid()::text
    OR auth.uid()::text = (SELECT user_id::text FROM agents WHERE id = (SELECT assigned_agent_id FROM verifications WHERE id = verification_id))
    OR (SELECT primary_role FROM users WHERE id = auth.uid()::uuid) = 'admin'::user_role
  );

-- ─── PAYMENTS RLS ──────────────────────────────────────────────────────────────
-- Users see only their own payments (or admins)
CREATE POLICY payments_select_own ON payments
  FOR SELECT USING (
    auth.uid()::text = user_id::text
    OR (SELECT primary_role FROM users WHERE id = auth.uid()::uuid) = 'admin'::user_role
  );

-- ─── NOTIFICATIONS RLS ─────────────────────────────────────────────────────────
-- Users see only their own notifications
CREATE POLICY notifications_select_own ON notifications
  FOR SELECT USING (auth.uid()::text = recipient_id::text);

CREATE POLICY notifications_update_own ON notifications
  FOR UPDATE USING (auth.uid()::text = recipient_id::text)
  WITH CHECK (auth.uid()::text = recipient_id::text);

-- ─── TESTIMONIALS RLS ──────────────────────────────────────────────────────────
-- All users can view published testimonials, users can update/delete their own
CREATE POLICY testimonials_select_published ON testimonials
  FOR SELECT USING (is_published = true OR auth.uid()::text = user_id::text);

CREATE POLICY testimonials_update_own ON testimonials
  FOR UPDATE USING (auth.uid()::text = user_id::text)
  WITH CHECK (auth.uid()::text = user_id::text);

-- ─── VENDOR STATS RLS ──────────────────────────────────────────────────────────
-- Sellers see only their own stats
CREATE POLICY vendor_stats_select_own ON vendor_stats
  FOR SELECT USING (auth.uid()::text = user_id::text OR (SELECT primary_role FROM users WHERE id = auth.uid()::uuid) = 'admin'::user_role);

-- ─── TERRAIN ANALYTICS RLS ────────────────────────────────────────────────────
-- Sellers see analytics for their published terrains
CREATE POLICY terrain_analytics_select_own ON terrain_analytics
  FOR SELECT USING (
    (SELECT seller_id::text FROM terrains_foncira WHERE id = terrain_id) = auth.uid()::text
    OR (SELECT primary_role FROM users WHERE id = auth.uid()::uuid) = 'admin'::user_role
  );

-- ─── TERRAIN INQUIRIES RLS ────────────────────────────────────────────────────
-- Buyers can view their own inquiries, sellers can view inquiries about their terrains
CREATE POLICY terrain_inquiries_select_own ON terrain_inquiries
  FOR SELECT USING (
    auth.uid()::text = buyer_id::text
    OR auth.uid()::text = (SELECT seller_id::text FROM terrains_foncira WHERE id = terrain_id)
    OR (SELECT primary_role FROM users WHERE id = auth.uid()::uuid) = 'admin'::user_role
  );

-- Buyers can insert inquiries
CREATE POLICY terrain_inquiries_insert ON terrain_inquiries
  FOR INSERT WITH CHECK (auth.uid()::text = buyer_id::text);

-- Sellers can update inquiries (mark as read, respond)
CREATE POLICY terrain_inquiries_update ON terrain_inquiries
  FOR UPDATE USING (
    auth.uid()::text = (SELECT seller_id::text FROM terrains_foncira WHERE id = terrain_id)
  )
  WITH CHECK (auth.uid()::text = (SELECT seller_id::text FROM terrains_foncira WHERE id = terrain_id));

-- ──────────────────────────────────────────────────────────────────────────────
-- SECTION 10: TEST DATA (Togolese Context)
-- ──────────────────────────────────────────────────────────────────────────────

-- ─── TEST USERS ────────────────────────────────────────────────────────────────
INSERT INTO users (id, email, first_name, last_name, phone_number, country_code, primary_role, referral_code)
VALUES
  ('550e8400-e29b-41d4-a716-446655440001'::uuid, 'kofi@example.tg', 'Kofi', 'Mensah', '+22890123456', 'TG', 'agent'::user_role, 'KOFI123'),
  ('550e8400-e29b-41d4-a716-446655440002'::uuid, 'ama@example.tg', 'Ama', 'Owusu', '+22890234567', 'TG', 'agent'::user_role, 'AMA456'),
  ('550e8400-e29b-41d4-a716-446655440010'::uuid, 'akosua@example.tg', 'Akosua', 'Duah', '+22891234567', 'TG', 'client'::user_role, 'AKOS999'),
  ('550e8400-e29b-41d4-a716-446655440011'::uuid, 'kwame@example.tg', 'Kwame', 'Boateng', '+22892345678', 'TG', 'client'::user_role, 'KWAM888'),
  ('550e8400-e29b-41d4-a716-446655440012'::uuid, 'agbelamou@example.tg', 'M. Agbélamou', 'Agbelamou', '+22890000111', 'TG', 'client'::user_role, 'AGBE555'),
  ('550e8400-e29b-41d4-a716-446655440013'::uuid, 'immotogo@example.tg', 'Agence', 'Immotogo', '+22890000222', 'TG', 'client'::user_role, 'IMMO666'),
  ('550e8400-e29b-41d4-a716-446655440014'::uuid, 'mensah@example.tg', 'Yao', 'Mensah', '+22890000333', 'TG', 'client'::user_role, 'YAO777');

-- ─── TEST AGENTS ──────────────────────────────────────────────────────────────

-- --- TEST APP CONFIG (Admin settings dashboard) -------------------------------
INSERT INTO app_config (key, value, description)
VALUES
  ('fcfa_to_usd_rate', '655.957', 'Taux de conversion FCFA -> USD'),
  ('stat_terrains_verified', '1250', 'Nombre de terrains verifies affiche'),
  ('stat_disputes_avoided', '420', 'Nombre de litiges evites affiche'),
  ('stat_amount_protected_usd', '3200000', 'Montant protege en USD affiche');
INSERT INTO agents (id, user_id, full_name, photo_url, specializations, verifications_completed, average_rating, is_available)
VALUES
  ('550e8400-e29b-41d4-a716-446655440101'::uuid, '550e8400-e29b-41d4-a716-446655440001'::uuid, 'Kofi Mensah', 'assets/agent_kofi.jpg', ARRAY['Vérification cadastrale']::text[], 47, 4.8, true),
  ('550e8400-e29b-41d4-a716-446655440102'::uuid, '550e8400-e29b-41d4-a716-446655440002'::uuid, 'Ama Owusu', 'assets/agent_ama.jpg', ARRAY['Vérification coutumière']::text[], 35, 4.6, true);

-- ─── TEST TERRAINS FONCIRA ────────────────────────────────────────────────────
INSERT INTO terrains_foncira (
  id, seller_id, title, location, quartier, zone, ville, price_fcfa, price_usd, surface,
  is_constructible, is_viabilise, document_type, terrain_status,
  seller_type, seller_name, seller_phone, verification_status, status, published_at
)
VALUES
  (
    '550e8400-e29b-41d4-a716-446655440201'::uuid,
    '550e8400-e29b-41d4-a716-446655440012'::uuid,
    'Terrain résidentiel 500m² à Kégué',
    'Derrière le marché de Bè, Lomé',
    'Kégué',
    'Bè',
    'Lomé',
    15000000,
    22908,
    500,
    true,
    true,
    'titre_foncier'::document_type,
    'disponible'::terrain_status,
    'particulier'::seller_type,
    'M. Agbélamou',
    '+22890000111',
    'verification_base_effectuee'::marketplace_verification_status,
    'publie',
    now()
  ),
  (
    '550e8400-e29b-41d4-a716-446655440202'::uuid,
    '550e8400-e29b-41d4-a716-446655440013'::uuid,
    'Terrain commercial 1000m² Tokoin',
    'Tokoin Wuiti, près du CEG',
    'Tokoin',
    'Tokoin',
    'Lomé',
    18000000,
    27490,
    1000,
    true,
    true,
    'convention'::document_type,
    'disponible'::terrain_status,
    'agence_immobiliere'::seller_type,
    'Agence Immotogo',
    '+22890000222',
    'verification_base_effectuee'::marketplace_verification_status,
    'publie',
    now()
  ),
  (
    '550e8400-e29b-41d4-a716-446655440203'::uuid,
    '550e8400-e29b-41d4-a716-446655440014'::uuid,
    'Terrain résidentiel 800m² Avédji',
    'Rue Nationale, Avédji, Lomé',
    'Avédji',
    'Avédji',
    'Lomé',
    22000000,
    33586,
    800,
    true,
    false,
    'aucun_document'::document_type,
    'reserve'::terrain_status,
    'particulier'::seller_type,
    'Monsieur Akomo',
    '+22890000333',
    'non_verifie'::marketplace_verification_status,
    'publie',
    now()
  );

-- ─── TEST VENDOR STATS ────────────────────────────────────────────────────────
INSERT INTO vendor_stats (id, user_id, total_listings, total_sales, revenue_fcfa, views_this_month, conversion_rate, average_time_to_sale)
VALUES
  ('550e8400-e29b-41d4-a716-446655440401'::uuid, '550e8400-e29b-41d4-a716-446655440012'::uuid, 1, 0, 0, 45, 0.00, NULL),
  ('550e8400-e29b-41d4-a716-446655440402'::uuid, '550e8400-e29b-41d4-a716-446655440013'::uuid, 1, 2, 3000000, 120, 5.50, INTERVAL '30 days'),
  ('550e8400-e29b-41d4-a716-446655440403'::uuid, '550e8400-e29b-41d4-a716-446655440014'::uuid, 1, 0, 0, 30, 0.00, NULL);

-- ─── TEST TERRAIN ANALYTICS ──────────────────────────────────────────────────
INSERT INTO terrain_analytics (id, terrain_id, views_count, inquiries_count, last_viewed_at)
VALUES
  ('550e8400-e29b-41d4-a716-446655440501'::uuid, '550e8400-e29b-41d4-a716-446655440201'::uuid, 45, 3, now() - INTERVAL '2 hours'),
  ('550e8400-e29b-41d4-a716-446655440502'::uuid, '550e8400-e29b-41d4-a716-446655440202'::uuid, 120, 8, now() - INTERVAL '1 hour'),
  ('550e8400-e29b-41d4-a716-446655440503'::uuid, '550e8400-e29b-41d4-a716-446655440203'::uuid, 30, 1, now() - INTERVAL '5 days');

-- ─── TEST TERRAIN INQUIRIES ──────────────────────────────────────────────────
INSERT INTO terrain_inquiries (id, terrain_id, buyer_id, inquiry_message, status, seller_response, response_at)
VALUES
  (
    '550e8400-e29b-41d4-a716-446655440601'::uuid,
    '550e8400-e29b-41d4-a716-446655440201'::uuid,
    '550e8400-e29b-41d4-a716-446655440010'::uuid,
    'Bonjour, est-ce que ce terrain est encore disponible? Je suis intéressé par un achat.',
    'repondu',
    'Oui, le terrain est toujours disponible. Contactez-moi au numéro indiqué pour discuter les détails.',
    now() - INTERVAL '1 day'
  ),
  (
    '550e8400-e29b-41d4-a716-446655440602'::uuid,
    '550e8400-e29b-41d4-a716-446655440202'::uuid,
    '550e8400-e29b-41d4-a716-446655440011'::uuid,
    'Quel est le prix minimum accepté pour ce terrain?',
    'lu',
    NULL,
    NULL
  );

-- ─── TEST VERIFICATIONS ───────────────────────────────────────────────────────
INSERT INTO verifications (
  id, user_id, terrain_id_foncira, source, client_status, client_risk_level,
  terrain_title, terrain_location, terrain_price_fcfa, terrain_price_usd,
  terrain_document_type, assigned_agent_id, expected_delivery_at, submitted_at
)
VALUES
  (
    '550e8400-e29b-41d4-a716-446655440301'::uuid,
    '550e8400-e29b-41d4-a716-446655440010'::uuid,
    '550e8400-e29b-41d4-a716-446655440201'::uuid,
    'foncira_marketplace'::verification_source,
    'analyse_finale'::verification_status,
    'faible'::risk_level,
    'Terrain résidentiel 500m² à Kégué',
    'Derrière le marché de Bè, Lomé',
    15000000,
    22908,
    'titre_foncier'::document_type,
    '550e8400-e29b-41d4-a716-446655440101'::uuid,
    now() + interval '10 days',
    now() - interval '10 days'
  ),
  (
    '550e8400-e29b-41d4-a716-446655440302'::uuid,
    '550e8400-e29b-41d4-a716-446655440011'::uuid,
    NULL,
    'externe'::verification_source,
    'verification_administrative'::verification_status,
    'modere'::risk_level,
    'Terrain trouvé sur Facebook',
    'Tokoin Wuiti, près du CEG',
    18000000,
    27490,
    'convention'::document_type,
    '550e8400-e29b-41d4-a716-446655440102'::uuid,
    now() + interval '5 days',
    now() - interval '5 days'
  );

-- ─── TEST PAYMENTS ────────────────────────────────────────────────────────────
INSERT INTO payments (
  id, verification_id, user_id, amount_fcfa, amount_usd,
  payment_method, status, transaction_reference, paid_at
)
VALUES
  (
    '550e8400-e29b-41d4-a716-446655440704'::uuid,
    '550e8400-e29b-41d4-a716-446655440301'::uuid,
    '550e8400-e29b-41d4-a716-446655440010'::uuid,
    150000,
    259,
    'mobile_money'::payment_method,
    'validee'::payment_status,
    'MTN-20240104-0001',
    now() - interval '10 days'
  );

-- ─── TEST VERIFICATION MILESTONES ─────────────────────────────────────────────
INSERT INTO verification_milestones (
  id, verification_id, milestone_day, milestone_name, status,
  started_at, completed_at, notes
)
VALUES
  (
    '550e8400-e29b-41d4-a716-446655440501'::uuid,
    '550e8400-e29b-41d4-a716-446655440301'::uuid,
    1,
    'Vérification cadastrale',
    'termine'::mission_step_status,
    now() - interval '10 days',
    now() - interval '10 days',
    'Demande enregistrée. Documents conformes.'
  ),
  (
    '550e8400-e29b-41d4-a716-446655440502'::uuid,
    '550e8400-e29b-41d4-a716-446655440301'::uuid,
    3,
    'Visite terrain',
    'termine'::mission_step_status,
    now() - interval '8 days',
    now() - interval '7 days',
    'Terrain visité. Bornes conformes au plan cadastral.'
  ),
  (
    '550e8400-e29b-41d4-a716-446655440503'::uuid,
    '550e8400-e29b-41d4-a716-446655440301'::uuid,
    7,
    'Vérification coutumière',
    'termine'::mission_step_status,
    now() - interval '5 days',
    now() - interval '3 days',
    'Statut auprès des autorités locales confirmé. Pas de litige.'
  ),
  (
    '550e8400-e29b-41d4-a716-446655440504'::uuid,
    '550e8400-e29b-41d4-a716-446655440301'::uuid,
    10,
    'Rapport final',
    'en_attente'::mission_step_status,
    now() - interval '2 days',
    NULL,
    'Dernière étape: compilation du rapport.'
  );

-- ─── TEST VERIFICATION REPORTS ────────────────────────────────────────────────
INSERT INTO verification_reports (
  id, verification_id, agent_id, risk_level,
  verdict_summary, positive_points, points_to_verify
)
VALUES
  (
    '550e8400-e29b-41d4-a716-446655440601'::uuid,
    '550e8400-e29b-41d4-a716-446655440301'::uuid,
    '550e8400-e29b-41d4-a716-446655440101'::uuid,
    'faible'::risk_level,
    'Terrain conforme, titre foncier valide, sans litiges connus.',
    '["Un titre foncier est présent — le document le plus solide au Togo.", "Bornes cadastrales conformes au plan officiel.", "Pas de litige auprès des autorités coutumières."]'::jsonb,
    '["Vérification bancaire recommandée avant signature du contrat."]'::jsonb
  );

-- ─── TEST NOTIFICATIONS ───────────────────────────────────────────────────────
INSERT INTO notifications (
  id, recipient_id, notification_type, title, message,
  related_verification_id, is_read, created_at
)
VALUES
  (
    '550e8400-e29b-41d4-a716-446655440701'::uuid,
    '550e8400-e29b-41d4-a716-446655440010'::uuid,
    'verification_update'::notification_type,
    'Visite terrain effectuée',
    'Notre agent Kofi Mensah a visité le terrain et confirmé sa conformité',
    '550e8400-e29b-41d4-a716-446655440301'::uuid,
    true,
    now() - interval '7 days'
  );

-- ──────────────────────────────────────────────────────────────────────────────
-- SECTION 11: VIEWS FOR COMMON QUERIES
-- ──────────────────────────────────────────────────────────────────────────────

CREATE VIEW verification_with_agent_details AS
SELECT
  v.id,
  v.user_id,
  v.terrain_title,
  v.terrain_location,
  v.client_status AS status,
  v.client_risk_level AS risk_level,
  v.submitted_at,
  v.expected_delivery_at,
  a.full_name AS agent_name,
  a.photo_url AS agent_photo,
  u.email AS client_email,
  u.first_name AS client_first_name
FROM verifications v
LEFT JOIN agents a ON v.assigned_agent_id = a.id
LEFT JOIN users u ON v.user_id = u.id;

CREATE VIEW user_verification_summary AS
SELECT
  u.id,
  u.first_name,
  u.email,
  COUNT(v.id) AS total_verifications,
  COUNT(CASE WHEN v.client_status = 'rapport_livre'::verification_status THEN 1 END) AS completed_verifications,
  AVG(CASE WHEN v.client_risk_level = 'faible'::risk_level THEN 1 WHEN v.client_risk_level = 'modere'::risk_level THEN 2 WHEN v.client_risk_level = 'eleve'::risk_level THEN 3 END) AS average_risk_score
FROM users u
LEFT JOIN verifications v ON u.id = v.user_id
GROUP BY u.id, u.first_name, u.email;

CREATE VIEW agent_workload_summary AS
SELECT
  a.id,
  a.full_name,
  COUNT(v.id) AS total_assigned,
  COUNT(CASE WHEN v.client_status != 'rapport_livre'::verification_status THEN 1 END) AS in_progress,
  a.verifications_completed,
  a.average_rating
FROM agents a
LEFT JOIN verifications v ON a.id = v.assigned_agent_id
GROUP BY a.id, a.full_name, a.verifications_completed, a.average_rating;

-- ──────────────────────────────────────────────────────────────────────────────
-- SECTION 12: HELPER FUNCTIONS
-- ──────────────────────────────────────────────────────────────────────────────

-- Function to convert FCFA to USD at current rate
CREATE OR REPLACE FUNCTION convert_fcfa_to_usd(fcfa_amount NUMERIC)
RETURNS NUMERIC AS $$
BEGIN
  RETURN ROUND(fcfa_amount / 570, 2);
END;
$$ LANGUAGE plpgsql IMMUTABLE;

-- Function to auto-update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Triggers for updated_at
CREATE TRIGGER users_update_updated_at BEFORE UPDATE ON users
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER agents_update_updated_at BEFORE UPDATE ON agents
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER terrains_foncira_update_updated_at BEFORE UPDATE ON terrains_foncira
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER verifications_update_updated_at BEFORE UPDATE ON verifications
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER verification_reports_update_updated_at BEFORE UPDATE ON verification_reports
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER verification_milestones_update_updated_at BEFORE UPDATE ON verification_milestones
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER payments_update_updated_at BEFORE UPDATE ON payments
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER testimonials_update_updated_at BEFORE UPDATE ON testimonials
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- ──────────────────────────────────────────────────────────────────────────────
-- SECTION 13: COMMENTS (Documentation)
-- ──────────────────────────────────────────────────────────────────────────────

COMMENT ON TABLE users IS 'Utilisateurs FONCIRA - clients et agents';
COMMENT ON TABLE agents IS 'Agents vérificateurs avec leurs statistiques';
COMMENT ON TABLE terrains_foncira IS 'Terrains du marketplace FONCIRA';
COMMENT ON TABLE verifications IS 'Demandes de vérification - tunnel complet';
COMMENT ON TABLE verification_documents IS 'Documents uploadés par les clients';
COMMENT ON TABLE verification_reports IS 'Rapports finals des vérifications';
COMMENT ON TABLE verification_milestones IS 'Jalons de suivi J1/J3/J7/J10';
COMMENT ON TABLE payments IS 'Paiements des vérifications';
COMMENT ON TABLE referral_transactions IS 'Transactions de parrainage';
COMMENT ON TABLE notifications IS 'Notifications utilisateurs';
COMMENT ON TABLE testimonials IS 'Témoignages des clients';

-- End of schema

