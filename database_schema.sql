-- ══════════════════════════════════════════════════════════════════════════════
--  FONCIRA — Complete Supabase Database Schema
--  PostgreSQL + RLS + Test Data
--  Ready to deploy
-- ══════════════════════════════════════════════════════════════════════════════

-- ──────────────────────────────────────────────────────────────────────────────
-- SECTION 1: ENUM TYPES
-- ──────────────────────────────────────────────────────────────────────────────

CREATE TYPE document_type AS ENUM (
  'titre_foncier',
  'logement',
  'convention',
  'recu_vente',
  'aucun_document',
  'ne_sais_pas'
);

CREATE TYPE terrain_status AS ENUM (
  'disponible',
  'en_cours_vente',
  'reserve',
  'verifie'
);

CREATE TYPE seller_type AS ENUM (
  'agence',
  'particulier'
);

CREATE TYPE verification_status AS ENUM (
  'receptionnee',
  'pre_analyse',
  'verification_administrative',
  'verification_terrain',
  'analyse_finale',
  'rapport_livre'
);

CREATE TYPE verification_source AS ENUM (
  'foncira_marketplace',
  'externe'
);

CREATE TYPE step_status AS ENUM (
  'en_attente',
  'en_cours',
  'termine'
);

CREATE TYPE payment_method AS ENUM (
  'mobile_money',
  'carte_bancaire'
);

CREATE TYPE payment_status AS ENUM (
  'en_attente',
  'validee',
  'echouee',
  'remboursee'
);

CREATE TYPE risk_level AS ENUM (
  'faible',
  'modere',
  'eleve'
);

CREATE TYPE post_report_decision AS ENUM (
  'acheter',
  'accompagnement',
  'pas_maintenant'
);

CREATE TYPE notification_type AS ENUM (
  'verification_update',
  'payment_confirmation',
  'report_ready',
  'systeme'
);

CREATE TYPE user_role AS ENUM (
  'client',
  'agent',
  'admin'
);

-- Table des offres / services
CREATE TYPE service_type AS ENUM (
  'verification_seule',
  'pack_verification_accompagnement',
  'accompagnement_seul',
  'mise_en_avant_vendeur'
);

CREATE TYPE marketplace_verification_status AS ENUM (
  'non_verifie',
  'verification_base_effectuee',
  'verification_complete'
);

-- ──────────────────────────────────────────────────────────────────────────────
-- SECTION 2: CORE TABLES (No Dependencies)
-- ──────────────────────────────────────────────────────────────────────────────

-- ─── USERS ────────────────────────────────────────────────────────────────────
CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  email VARCHAR(255) NOT NULL UNIQUE,
  first_name VARCHAR(100),
  last_name VARCHAR(100),
  phone_number VARCHAR(20),
  country_code VARCHAR(3) DEFAULT 'TG', -- Togolese by default
  role user_role DEFAULT 'client',
  is_active BOOLEAN DEFAULT true,
  referral_code VARCHAR(10) UNIQUE,
  referral_balance NUMERIC(15, 2) DEFAULT 0.00, -- Montant en FCFA à verser
  referral_balance_usd NUMERIC(10, 2) DEFAULT 0.00,
  profile_photo_url VARCHAR(500),

  created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  deleted_at TIMESTAMP WITH TIME ZONE
);

-- ─── AGENTS ───────────────────────────────────────────────────────────────────
CREATE TABLE agents (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL UNIQUE REFERENCES users(id) ON DELETE CASCADE,
  full_name VARCHAR(100) NOT NULL,
  photo_url VARCHAR(500),
  specialization VARCHAR(100),
  verifications_completed INTEGER DEFAULT 0,
  average_rating NUMERIC(3, 2),
  is_available BOOLEAN DEFAULT true,
  current_workload INTEGER DEFAULT 0,
  max_concurrent_verifications INTEGER DEFAULT 5,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- ─── TESTIMONIALS ─────────────────────────────────────────────────────────────
CREATE TABLE testimonials (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  buyer_name VARCHAR(100) NOT NULL,
  country_code VARCHAR(3),
  terrain_amount NUMERIC(15, 2) NOT NULL, -- Prix du terrain en FCFA
  risk_avoided VARCHAR(50), -- 'faible', 'modere', 'eleve'
  testimonial_text TEXT NOT NULL,
  is_published BOOLEAN DEFAULT false,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- ─── TERRAINS FONCIRA (Marketplace) ────────────────────────────────────────────
CREATE TABLE terrains_foncira (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title VARCHAR(255) NOT NULL,
  location VARCHAR(255) NOT NULL,
  quartier VARCHAR(100),
  zone VARCHAR(100),
  ville VARCHAR(100),
  price_fcfa NUMERIC(15, 2) NOT NULL,
  price_usd NUMERIC(10, 2) NOT NULL,
  surface NUMERIC(10, 2) NOT NULL, -- en m²
  is_constructible BOOLEAN DEFAULT true,
  vue VARCHAR(100),
  is_viabilise BOOLEAN DEFAULT false,
  description TEXT,
  document_type document_type DEFAULT 'aucun_document',
  terrain_status terrain_status DEFAULT 'disponible',
  seller_type seller_type NOT NULL,
  seller_name VARCHAR(100) NOT NULL,
  seller_phone VARCHAR(20),
  seller_agency_name VARCHAR(100),
  verification_status marketplace_verification_status DEFAULT 'non_verifie',
  latitude NUMERIC(10, 8),
  longitude NUMERIC(11, 8),
  main_photo_url VARCHAR(500),
  additional_photos JSONB, -- Array de URLs
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  deleted_at TIMESTAMP WITH TIME ZONE
);


CREATE TABLE services (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  service_type service_type NOT NULL UNIQUE,
  label VARCHAR(100) NOT NULL,
  price_fcfa NUMERIC(15,2) NOT NULL,
  price_usd NUMERIC(10,2) NOT NULL,
  variable_cost_fcfa NUMERIC(15,2) NOT NULL,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- Table mise en avant vendeurs (abonnements)
CREATE TABLE vendor_subscriptions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  terrain_id UUID REFERENCES terrains_foncira(id) ON DELETE CASCADE,
  status VARCHAR(20) DEFAULT 'actif',
  price_fcfa NUMERIC(15,2) DEFAULT 15000,
  started_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  expires_at TIMESTAMP WITH TIME ZONE,
  renewed_at TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- ──────────────────────────────────────────────────────────────────────────────
-- SECTION 3: VERIFICATION TABLES
-- ──────────────────────────────────────────────────────────────────────────────

-- ─── VERIFICATIONS ────────────────────────────────────────────────────────────
CREATE TABLE verifications (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  terrain_id_foncira UUID REFERENCES terrains_foncira(id) ON DELETE SET NULL,
  source verification_source NOT NULL,
  status verification_status DEFAULT 'receptionnee',
  risk_level risk_level DEFAULT 'faible',
  
  -- Terrain data (for display)
  terrain_title VARCHAR(255) NOT NULL,
  terrain_location VARCHAR(255) NOT NULL,
  terrain_price_fcfa NUMERIC(15, 2),
  terrain_price_usd NUMERIC(10, 2),
  
  -- External terrain data (if source = 'externe')
  external_location VARCHAR(255),
  external_seller_contact VARCHAR(100),
  external_price_fcfa NUMERIC(15, 2),
  external_price_usd NUMERIC(10, 2),
  external_description TEXT,
  external_source VARCHAR(100), -- 'réseaux sociaux', 'bouche-à-oreille', etc.
  
  -- Additional data
  sharing_link VARCHAR(500), -- Lien de partage Facebook/WhatsApp
  document_type document_type,
  
  -- Agent assignment
  agent_id UUID REFERENCES agents(id) ON DELETE SET NULL,
  
  -- Timeline
  submitted_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  expected_delivery_at TIMESTAMP WITH TIME ZONE,
  actual_delivery_at TIMESTAMP WITH TIME ZONE,
  
  -- Post-report decision
  post_report_decision post_report_decision,
  decision_made_at TIMESTAMP WITH TIME ZONE,
  
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- ─── VERIFICATION DOCUMENTS ───────────────────────────────────────────────────
CREATE TABLE verification_documents (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  verification_id UUID NOT NULL REFERENCES verifications(id) ON DELETE CASCADE,
  file_name VARCHAR(255) NOT NULL,
  file_path VARCHAR(500) NOT NULL, -- Chemin Supabase Storage
  file_type VARCHAR(10) NOT NULL, -- 'PDF', 'JPG', 'PNG'
  file_size_bytes INTEGER,
  document_category VARCHAR(50), -- 'titre', 'convention', 'recu', 'photo', 'autre'
  uploaded_by UUID REFERENCES users(id) ON DELETE SET NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- ─── VERIFICATION REPORTS ─────────────────────────────────────────────────────
CREATE TABLE verification_reports (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  verification_id UUID NOT NULL UNIQUE REFERENCES verifications(id) ON DELETE CASCADE,
  agent_id UUID NOT NULL REFERENCES agents(id) ON DELETE RESTRICT,
  risk_level risk_level NOT NULL,
  verdict_summary VARCHAR(255) NOT NULL, -- Une phrase de résumé
  positive_points JSONB, -- Array de points positifs identifiés
  points_to_verify JSONB, -- Array de points à vérifier
  alternative_terrains JSONB, -- Array de terrains alternatifs proposés
  full_report_text TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- ─── VERIFICATION MILESTONES J1/J3/J7/J10 ─────────────────────────────────────
CREATE TABLE verification_milestones (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  verification_id UUID NOT NULL REFERENCES verifications(id) ON DELETE CASCADE,
  milestone_day INTEGER NOT NULL, -- 1, 3, 7, 10
  milestone_name VARCHAR(100) NOT NULL, -- 'Vérification cadastrale', etc.
  status step_status DEFAULT 'en_attente',
  started_at TIMESTAMP WITH TIME ZONE,
  completed_at TIMESTAMP WITH TIME ZONE,
  notes TEXT,
  
  -- Milestone-specific data
  location_photos JSONB, -- Array d'URLs de photos horodatées
  gps_coordinates JSONB, -- {latitude, longitude}
  
  -- Proactive message
  message_sent BOOLEAN DEFAULT false,
  message_content TEXT,
  message_sent_at TIMESTAMP WITH TIME ZONE,
  
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- ─── SECTION 3.5 : EXTENSIONS DES TABLES EXISTANTES ──────────────────────────


-- ──────────────────────────────────────────────────────────────────────────────
-- SECTION 4: PAYMENTS & TRANSACTIONS
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
-- SECTION 5: NOTIFICATIONS & MESSAGING
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
-- SECTION 6: INDEXES FOR PERFORMANCE
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
CREATE INDEX idx_verifications_agent_id ON verifications(agent_id);
CREATE INDEX idx_verifications_terrain_id ON verifications(terrain_id_foncira);
CREATE INDEX idx_verifications_status ON verifications(status);
CREATE INDEX idx_verifications_risk_level ON verifications(risk_level);
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

-- ──────────────────────────────────────────────────────────────────────────────
-- SECTION 7: ROW LEVEL SECURITY (RLS)
-- ──────────────────────────────────────────────────────────────────────────────

-- Enable RLS on all tables
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE agents ENABLE ROW LEVEL SECURITY;
ALTER TABLE terrains_foncira ENABLE ROW LEVEL SECURITY;
ALTER TABLE verifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE verification_documents ENABLE ROW LEVEL SECURITY;
ALTER TABLE verification_reports ENABLE ROW LEVEL SECURITY;
ALTER TABLE verification_milestones ENABLE ROW LEVEL SECURITY;
ALTER TABLE payments ENABLE ROW LEVEL SECURITY;
ALTER TABLE referral_transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE testimonials ENABLE ROW LEVEL SECURITY;

-- ─── USERS RLS ─────────────────────────────────────────────────────────────────
-- Users see only their own profile (or admins see all)
CREATE POLICY users_select_own ON users
  FOR SELECT USING (
    auth.uid()::text = id::text 
    OR (SELECT role FROM users WHERE id = auth.uid()::uuid) = 'admin'::user_role
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
    OR auth.uid()::text = (SELECT user_id::text FROM agents WHERE id = agent_id)
    OR (SELECT role FROM users WHERE id = auth.uid()::uuid) = 'admin'::user_role
  );

CREATE POLICY verifications_insert_own ON verifications
  FOR INSERT WITH CHECK (auth.uid()::text = user_id::text);

CREATE POLICY verifications_update_own ON verifications
  FOR UPDATE USING (
    auth.uid()::text = user_id::text 
    OR auth.uid()::text = (SELECT user_id::text FROM agents WHERE id = agent_id)
    OR (SELECT role FROM users WHERE id = auth.uid()::uuid) = 'admin'::user_role
  );

-- ─── VERIFICATION DOCUMENTS RLS ────────────────────────────────────────────────
-- Users see documents from their own verifications (or assigned agents, or admins)
CREATE POLICY verification_documents_select ON verification_documents
  FOR SELECT USING (
    (SELECT user_id::text FROM verifications WHERE id = verification_id) = auth.uid()::text
    OR auth.uid()::text = (SELECT user_id::text FROM agents WHERE id = (SELECT agent_id FROM verifications WHERE id = verification_id))
    OR (SELECT role FROM users WHERE id = auth.uid()::uuid) = 'admin'::user_role
  );

-- ─── PAYMENTS RLS ──────────────────────────────────────────────────────────────
-- Users see only their own payments (or admins)
CREATE POLICY payments_select_own ON payments
  FOR SELECT USING (
    auth.uid()::text = user_id::text
    OR (SELECT role FROM users WHERE id = auth.uid()::uuid) = 'admin'::user_role
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

-- ──────────────────────────────────────────────────────────────────────────────
-- SECTION 8: TEST DATA (Togolese Context)
-- ──────────────────────────────────────────────────────────────────────────────

-- ─── TEST USERS ────────────────────────────────────────────────────────────────
INSERT INTO users (id, email, first_name, last_name, phone_number, country_code, role, referral_code)
VALUES
  ('550e8400-e29b-41d4-a716-446655440001'::uuid, 'kofi@example.tg', 'Kofi', 'Mensah', '+22890123456', 'TG', 'agent', 'KOFI123'),
  ('550e8400-e29b-41d4-a716-446655440002'::uuid, 'ama@example.tg', 'Ama', 'Owusu', '+22890234567', 'TG', 'agent', 'AMA456'),
  ('550e8400-e29b-41d4-a716-446655440010'::uuid, 'akosua@example.tg', 'Akosua', 'Duah', '+22891234567', 'TG', 'client', 'AKOS999'),
  ('550e8400-e29b-41d4-a716-446655440011'::uuid, 'kwame@example.tg', 'Kwame', 'Boateng', '+22892345678', 'TG', 'client', 'KWAM888');

-- ─── TEST AGENTS ──────────────────────────────────────────────────────────────
INSERT INTO agents (id, user_id, full_name, photo_url, specialization, verifications_completed, average_rating, is_available)
VALUES
  ('550e8400-e29b-41d4-a716-446655440101'::uuid, '550e8400-e29b-41d4-a716-446655440001'::uuid, 'Kofi Mensah', 'assets/agent_kofi.jpg', 'Vérification cadastrale', 47, 4.8, true),
  ('550e8400-e29b-41d4-a716-446655440102'::uuid, '550e8400-e29b-41d4-a716-446655440002'::uuid, 'Ama Owusu', 'assets/agent_ama.jpg', 'Vérification coutumière', 35, 4.6, true);

-- ─── TEST TERRAINS FONCIRA ────────────────────────────────────────────────────
INSERT INTO terrains_foncira (
  id, title, location, quartier, zone, ville, price_fcfa, price_usd, surface,
  is_constructible, is_viabilise, document_type, terrain_status,
  seller_type, seller_name, seller_phone, verification_status
)
VALUES
  (
    '550e8400-e29b-41d4-a716-446655440201'::uuid,
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
    NULL
  ),
  (
    '550e8400-e29b-41d4-a716-446655440202'::uuid,
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
    'agence'::seller_type,
    'Agence Immotogo',
    '+22890000222',
    NULL
  ),
  (
    '550e8400-e29b-41d4-a716-446655440203'::uuid,
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
    NULL
  );

-- ─── TEST VERIFICATIONS ───────────────────────────────────────────────────────
INSERT INTO verifications (
  id, user_id, terrain_id_foncira, source, status, risk_level,
  terrain_title, terrain_location, terrain_price_fcfa, terrain_price_usd,
  document_type, agent_id, expected_delivery_at, submitted_at
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
    '550e8400-e29b-41d4-a716-446655440401'::uuid,
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
    'termine'::step_status,
    now() - interval '10 days',
    now() - interval '10 days',
    'Demande enregistrée. Documents conformes.'
  ),
  (
    '550e8400-e29b-41d4-a716-446655440502'::uuid,
    '550e8400-e29b-41d4-a716-446655440301'::uuid,
    3,
    'Visite terrain',
    'termine'::step_status,
    now() - interval '8 days',
    now() - interval '7 days',
    'Terrain visité. Bornes conformes au plan cadastral.'
  ),
  (
    '550e8400-e29b-41d4-a716-446655440503'::uuid,
    '550e8400-e29b-41d4-a716-446655440301'::uuid,
    7,
    'Vérification coutumière',
    'termine'::step_status,
    now() - interval '5 days',
    now() - interval '3 days',
    'Statut auprès des autorités locales confirmé. Pas de litige.'
  ),
  (
    '550e8400-e29b-41d4-a716-446655440504'::uuid,
    '550e8400-e29b-41d4-a716-446655440301'::uuid,
    10,
    'Rapport final',
    'en_attente'::step_status,
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
-- SECTION 9: VIEWS FOR COMMON QUERIES
-- ──────────────────────────────────────────────────────────────────────────────

CREATE VIEW verification_with_agent_details AS
SELECT
  v.id,
  v.user_id,
  v.terrain_title,
  v.terrain_location,
  v.status,
  v.risk_level,
  v.submitted_at,
  v.expected_delivery_at,
  a.full_name AS agent_name,
  a.photo_url AS agent_photo,
  u.email AS client_email,
  u.first_name AS client_first_name
FROM verifications v
LEFT JOIN agents a ON v.agent_id = a.id
LEFT JOIN users u ON v.user_id = u.id;

CREATE VIEW user_verification_summary AS
SELECT
  u.id,
  u.first_name,
  u.email,
  COUNT(v.id) AS total_verifications,
  COUNT(CASE WHEN v.status = 'rapport_livre'::verification_status THEN 1 END) AS completed_verifications,
  AVG(CASE WHEN v.risk_level = 'faible'::risk_level THEN 1 WHEN v.risk_level = 'modere'::risk_level THEN 2 WHEN v.risk_level = 'eleve'::risk_level THEN 3 END) AS average_risk_score
FROM users u
LEFT JOIN verifications v ON u.id = v.user_id
GROUP BY u.id, u.first_name, u.email;

CREATE VIEW agent_workload_summary AS
SELECT
  a.id,
  a.full_name,
  COUNT(v.id) AS total_assigned,
  COUNT(CASE WHEN v.status != 'rapport_livre'::verification_status THEN 1 END) AS in_progress,
  a.verifications_completed,
  a.average_rating
FROM agents a
LEFT JOIN verifications v ON a.id = v.agent_id
GROUP BY a.id, a.full_name, a.verifications_completed, a.average_rating;

-- ──────────────────────────────────────────────────────────────────────────────
-- SECTION 10: HELPER FUNCTIONS
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
-- SECTION 11: COMMENTS (Documentation)
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
