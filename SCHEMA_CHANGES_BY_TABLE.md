# FONCIRA v2.0 — Schema Changes Summary By Table

**Purpose**: Quick reference for developers - which columns changed in each table  
**Status**: Use with DATABASE_AUDIT_REPORT.md for detailed explanations

---

## 📌 LEGEND

| Symbol | Meaning                            |
| ------ | ---------------------------------- |
| ✅     | No changes - table OK              |
| 🔄     | Column renamed/moved               |
| ➕     | Column added                       |
| ❌     | Column removed                     |
| 🔧     | Column type changed                |
| 📝     | Constraint added                   |
| 🚀     | Index added                        |
| ⚠️     | Breaking change for app            |
| 🟢     | Non-breaking (backward compatible) |

---

## TABLE-BY-TABLE CHANGES

### TABLE: users

```
PK: id (UUID)
Role: Authentication via Supabase Auth

CHANGES:
┌─ ✅ No structural changes made
├─ 📝 first_name, last_name: Still optional (nullable OK)
├─ 📝 name: Kept for compatibility (auto-sync recommended)
├─ 📝 referral_balance: Renamed to referral_balance_fcfa (explicit currency)
│   └─ ⚠️ APP IMPACT: Check code using referral_balance
├─ ✅ deleted_at: Soft delete column (no change)
├─ ➕ updated_at: Added if missing
└─ 🚀 IN DEX: idx_users_role (new)

FLUTTER APP UPDATES NEEDED:
  // Before
  final balance = user['referral_balance'];

  // After
  final balanceFcfa = user['referral_balance_fcfa'];

MIGRATION: If referral_balance exists, it's renamed to referral_balance_fcfa
```

---

### TABLE: agents

```
PK: id (UUID)
FK: user_id → users(id) ON DELETE CASCADE

CHANGES:
┌─ 🔄 full_name → name (shortened)
│   └─ ✅ Non-breaking: Query accepts 'name'
├─ ✅ specialization: No changes
├─ ✅ is_available: No changes
├─ ✅ workload: No changes
├─ ✅ availability_start_time, availability_end_time: No changes
├─ ➕ updated_at: Added if missing
└─ 🚀 Indexes: idx_agents_specialization, idx_agents_availability (new)

FLUTTER APP UPDATES:
  // No critical changes - query still works
  // But may want to update variable names for consistency
  final agentName = agent['name']; // Not 'full_name'

MIGRATION: auto_renamed via ALTER COLUMN RENAME
```

---

### TABLE: terrains_foncira

```
PK: id (UUID)
FK: seller_id → users(id) ON DELETE RESTRICT

✅ MOST IMPORTANT TABLE - MULTIPLE CHANGES

CHANGES:
┌─ 🔄 surface → area_sqm ⚠️ BREAKING
│   ├─ Type: NUMERIC(15, 2) (units: square meters)
│   ├─ NOT NULL: Added
│   └─ APP IMPACT: MUST update Flutter code to use area_sqm
│
├─ ✅ city: Consolidated (removed duplicate 'ville')
│   └─ 📝 NOT NULL: Added (can't sell land without city)
│
├─ ✅ price_fcfa, price_usd: Kept
│   ├─ 📝 NOT NULL: Added to price_fcfa
│   ├─ 📝 CHECK: price_fcfa > 0, price_usd > 0
│   └─ ✅ No renaming
│
├─ ❌ latitude, longitude: Removed (use PostGIS instead)
│   └─ ➕ location_coordinates: POINT type (optional)
│
├─ 🔄 status: Consolidated from 'terrain_status' ENUM
│   ├─ Values: 'draft', 'publie', 'suspendu', 'vendu', 'archive'
│   └─ ✅ Backward compatible (old values still work)
│
├─ 🔄 featured_image vs main_photo_url: Clarified as 'featured_image'
│   └─ ✅ Stored in Supabase Storage
│
├─ ✅ seller_type: 'agence' | 'particulier' (no changes)
│   └─ 📝 NOT NULL: Added
│
├─ ✅ title, description: No changes
├─ ✅ price_usd: No changes
├─ ✅ document_type: No changes
│
├─ ➕ updated_at: Added if missing
│
└─ 🚀 Indexes:
   ├─ idx_terrains_seller_status (composite: seller_id, status)
   ├─ idx_terrains_deleted_at (soft delete)
   ├─ idx_terrains_title_search (full-text search)
   └─ idx_terrains_description_search (full-text search)

CRITICAL FOR FLUTTER:
  // ⚠️ MUST UPDATE ALL THESE:

  // Before
  final surfaceArea = terrain['surface'];

  // After
  final areaSquareMeters = terrain['area_sqm'];

FILES TO UPDATE:
  - lib/models/terrain_model.dart (TerrainModel.surface → area_sqm)
  - lib/components/terrain_card.dart (if using surface)
  - lib/services/terrain_service.dart (all queries)
  - lib/page/seller_dashboard.dart (stats/display)
  - lib/adapters/terrain_adapter.dart (data conversion)

SEARCH & REPLACE:
  Find: .surface
  Replace: .area_sqm
  In: lib/ directory
```

---

### TABLE: services

```
PK: id (UUID)
Special: service_type is UNIQUE (only one row per service type)

CHANGES:
┌─ ✅ service_type: ENUM (no changes)
├─ ✅ price_fcfa, price_usd: No changes
├─ ✅ is_active: No changes
├─ ➕ created_at: Added
├─ ➕ updated_at: Added
└─ 🚀 No new indexes

FLUTTER APP:
  ✅ No breaking changes
  Query pattern still works:
    services.where((s) => s['is_active'] == true)
```

---

### TABLE: verifications

```
PK: id (UUID)
FK: user_id, agent_id, terrain_id_foncira

CHANGES:
┌─ 🔄 terrain_id_foncira → terrain_id ⚠️ Naming consistency
│   └─ ✅ Still references terrains_foncira(id)
│
├─ ✅ verification_status: Renamed to verification_workflow_status (clarity)
│   ├─ Values: receptionnee, pre_analyse, verification_administrative, etc.
│   └─ ✅ Backward compatible
│
├─ ✅ source: verification_source ENUM
├─ ✅ risk_level: risk_level ENUM
├─ ✅ agent_id: NOT NULL ✅ Confirmed
│
├─ ❌ duplicate price columns removed
│   └─ Keep: terrain_price_fcfa, terrain_price_usd (snapshot from terrain)
│
├─ ✅ payment_status: payment_status ENUM
├─ ✅ updated_at: Already present
│
└─ 🚀 Indexes:
   ├─ idx_verifications_status_agent
   └─ idx_verifications_created_at

FLUTTER APP:
  ✅ Check code using terrain_id_foncira → update to terrain_id

MIGRATE DATA:
  No data migration needed (column references corrected in migration)
```

---

### TABLE: verification_documents

```
PK: id (UUID)
FK: verification_id → verifications(id) ON DELETE CASCADE

CHANGES:
┌─ ✅ verification_id, file_url, document_type: No changes
├─ ✅ uploaded_by: References users(id)
├─ ✅ created_at: Present ✅
├─ ➕ updated_at: Added if missing
└─ 🚀 No new indexes (considered soft-delete candidate)

FLUTTER APP:
  ✅ No breaking changes
```

---

### TABLE: verification_reports

```
PK: id (UUID)
Special: UNIQUE(verification_id) - only 1 report per verification

CHANGES:
✅ Added in audit (was in migration 001, now in main schema)
├─ ✅ verification_id: Links to verification
├─ ✅ agent_id: Who created the report
├─ ✅ risk_level: risk_level ENUM
├─ ✅ verdict: TEXT (agent's decision)
├─ ✅ positive_points: JSONB TEXT[] (array)
├─ ✅ points_to_verify: JSONB TEXT[] (array)
├─ ✅ alternative_terrains: JSONB array (for high-risk cases)
├─ ✅ created_at, updated_at: Present
└─ 🚀 No indexes (usually queried directly by verification_id)

FLUTTER APP:
  ✅ No breaking changes
  Already implemented in admin_verification_detail.dart
```

---

### TABLE: verification_milestones

```
PK: id (UUID)
FK: verification_id → verifications(id)

CHANGES:
┌─ 📝 milestone_day: Added CHECK constraint (1, 3, 7, 10 ONLY)
├─ ✅ milestone_day: 1, 3, 7, or 10 (no changes to values)
├─ ✅ photos: JSONB array
├─ ✅ gps_coordinates: POINT or JSON
├─ ✅ completed: BOOLEAN
├─ ✅ created_at, updated_at: Present
└─ 🚀 No new indexes

FLUTTER APP:
  ✅ No breaking changes
```

---

### TABLE: payments

```
PK: id (UUID)
FK: verification_id, user_id, service_id

CHANGES:
┌─ ✅ amount_fcfa, amount_usd: No changes (immutable)
├─ ✅ payment_method: payment_method ENUM
├─ ✅ payment_status: payment_status ENUM
├─ ❌ service_id + service_type: REMOVED redundancy
│   └─ Always query services table for type via join
├─ ✅ created_at: Present
├─ ✅ updated_at: Present
│
└─ 🚀 Indexes:
   ├─ idx_payments_created_at
   └─ idx_payments_status

FLUTTER APP:
  🔧 Code using payments.service_type may break
  Solution: Use service_id to join services table

  Before:
    Map service = payments[i];
    String type = service['service_type'];

  After:
    Map payment = payments[i];
    Map service = await getService(payment['service_id']);
    String type = service['service_type'];
```

---

### TABLE: notifications

```
PK: id (UUID)
FK: recipient_id → users(id)

CHANGES:
┌─ ✅ notification_type: notification_type ENUM
├─ ✅ recipient_id: Foreign key to users
├─ ✅ verification_id: Optional FK (nullable)
├─ ✅ created_at: Present
│
└─ 🚀 Indexes:
   ├─ idx_notifications_created_at
   └─ idx_notifications_recipient_created

FLUTTER APP:
  ✅ No breaking changes
```

---

### TABLE: vendor_subscriptions (marketplace subscriptions)

```
PK: id (UUID)
FK: user_id, terrain_id (references terrains_foncira)

CHANGES:
┌─ ✅ subscription_status: VARCHAR/ENUM (no changes)
├─ ✅ subscription_start_date, end_date: Present
├─ ✅ renewal_at: TIMESTAMP
├─ ➕ updated_at: Added
│
└─ 🚀 No new indexes

FLUTTER APP:
  ✅ No breaking changes
```

---

### TABLE: vendor_stats

```
No PK (dashboard aggregation table)
Periodically refreshed

CHANGES:
┌─ ✅ user_id (owner), total_subscriptions, active_subscriptions: No changes
├─ 📝 CHECK: total_subscriptions >= 0
├─ ✅ avg_rating: NUMERIC(3,2), no changes
├─ ✅ updated_at: Present
│
└─ 🚀 No new indexes (small table, scanned infrequently)

FLUTTER APP:
  ✅ No breaking changes
```

---

### TABLE: testimonials (user reviews)

```
PK: id (UUID)
FK: user_id → users(id)

CHANGES:
┌─ ✅ author_name: Kept for denormalization (snapshot)
│   └─ ⚠️ Won't auto-sync if user name changes
├─ 📝 rating: Added CHECK (0 ≤ rating ≤ 5)
├─ ✅ content: TEXT
├─ ✅ is_published: BOOLEAN
├─ ✅ created_at: Present
├─ ➕ updated_at: Added
│
└─ 🚀 Indexes (optional):
   └─ idx_testimonials_is_published

FLUTTER APP:
  ✅ No breaking changes
```

---

### TABLE: terrain_inquiries (buyer-seller communication)

```
PK: id (UUID)
FK: terrain_id, buyer_id, seller_id

CHANGES:
✅ No structural changes
├─ ✅ message_count, last_message_at: Present
├─ ✅ created_at, updated_at: Present
│
└─ 🚀 No new indexes

FLUTTER APP:
  ✅ No breaking changes
```

---

### TABLE: terrains_inquiry_messages

```
PK: id (UUID)
FK: inquiry_id, sender_id

CHANGES:
✅ No structural changes (conversation threads)
├─ ✅ message_content: TEXT
├─ ✅ created_at: Present
│
└─ 🚀 No new indexes (queried by inquiry_id)

FLUTTER APP:
  ✅ No breaking changes
```

---

### TABLE: referral_transactions

```
PK: id (UUID)
FK: referrer_id, referred_user_id, verification_id

CHANGES:
┌─ 📝 ON DELETE RESTRICT: Blocks deletion (ensures audit trail)
│   └─ ⚠️ Can't delete users with referral history
├─ ✅ amount_fcfa, amount_usd: No changes
├─ ✅ status: referral_status ENUM
├─ ✅ created_at: Present
│
└─ 🚀 Indexes:
   └─ idx_referral_transactions_referrer_id

FLUTTER APP:
  ✅ No breaking changes
```

---

### TABLE: feedbacks (customer satisfaction)

```
PK: id (UUID)
FK: user_id, verification_id

CHANGES:
┌─ 🔧 satisfaction: VARCHAR → satisfaction_type ENUM ⚠️ TYPE CHANGE
│   ├─ Values: 'yes', 'maybe', 'no'
│   └─ ✅ Backward compatible (old VARCHAR values migrated)
│
├─ ✅ feedback_text: TEXT
├─ ✅ created_at: Present
├─ ✅ updated_at: Present
│
└─ 🚀 No new indexes

FLUTTER APP:
  ✅ No breaking changes
  // Code treats it as string/"text already, so enum is transparent
```

---

### TABLE: accompaniments (notaire partnerships)

```
PK: id (UUID)
FK: verification_id → verifications(id)

CHANGES:
┌─ 📝 verification_id: NULLABLE → NOT NULL ⚠️ CONSTRAINT CHANGE
│   └─ All accompaniments MUST have a verification
│
├─ ✅ notaire_name, phone: Present
├─ ✅ status: VARCHAR
├─ ✅ updated_at: Added
│
└─ 🚀 No new indexes

FLUTTER APP:
  ✅ No breaking changes (accompaniments always linked to verifications anyway)
```

---

### TABLE: terrain_analytics (statistical tracking)

```
No PK (time-series data)
Aggregated via verification lifecycle

CHANGES:
✅ No structural changes
├─ ✅ terrain_id, view_count, inquiry_count: Present
├─ ✅ created_at, updated_at: Present
│
└─ 🚀 No new indexes (small table)

FLUTTER APP:
  ✅ No breaking changes
```

---

### TABLE: app_config (NEW - dynamic settings)

```
PK: key (VARCHAR) - single-column primary key
Usage: Key-value store for runtime configuration

ADDED IN v2:
├─ ✅ key: VARCHAR(100) PRIMARY KEY
├─ ✅ value: TEXT
├─ ✅ created_at, updated_at: TIMESTAMP
│
└─ 🚀 No indexes (small lookup table)

USED FOR:
├─ kFcfaToUsd: Exchange rate (655.957)
├─ Statistics: terrains_verified, disputes_avoided, amount_protected
└─ Custom settings: Configurable without code changes

FLUTTER APP:
  ✅ Already implemented in admin_settings_tab_v2.dart
  fetch: SELECT * FROM app_config;
  update: UPDATE app_config SET value = $1 WHERE key = $2;
```

---

## 🔴 TABLES WITH NO CHANGES

```
✅ SCHEMA VERIFIED - NO CHANGES NEEDED:
├─ auth.users (Supabase managed)
├─ steps (verification step definitions)
├─ user_roles_descriptions (documentation)
└─ [Any other system tables]

These tables are:
├─ ✅ Existing in v1 schema
├─ ✅ Used by the application as-is
└─ ✅ No structural changes made in v2
```

---

## 🎯 SUMMARY: CHANGES BY IMPACT

### ⚠️ BREAKING CHANGES (App Code Must Update)

```
1. terrains_foncira.surface → area_sqm (column rename)
   → MUST update Flutter code
   → Search: .surface, Replace: .area_sqm

2. verifications.terrain_id_foncira → terrain_id (FK name)
   → May need code update if explicitly referenced

3. payments: service_type removed (denormalization fix)
   → Must join services table to get service_type

4. accompaniments.verification_id: NULLABLE → NOT NULL
   → App already enforces this, so likely no code impact
```

### 🟡 CAUTION (Keep in mind)

```
1. users.referral_balance → referral_balance_fcfa
   → Column renamed for clarity (currency explicit)

2. agents.full_name → name
   → Column renamed (still works, but var names should update)

3. verifications.verification_status → verification_workflow_status
   → Enum name changed (backward compatible)

4. testimonials.author_name denormalization
   → Won't auto-sync with user name changes
   → Consider trigger for sync
```

### 🟢 BACKWARD COMPATIBLE (No app code changes)

```
✅ All other changes
✅ New timestamps, indexes, constraints
✅ Service table additions (app_config)
✅ Enum value additions (old values still valid)
✅ New RLS policies (stricter security)
✅ PostGIS location_coordinates (optional)
```

---

## 📋 CHECKLIST FOR FLUTTER DEVELOPERS

After migration deployed, update Flutter app:

- [ ] **Update terrains_foncira model**
  - [ ] Rename property `surface` → `areaSquareMeters` or `areaSqm`
  - [ ] Update all queries/filters using `.surface`
  - [ ] Update UI displays showing surface area

- [ ] **Update verifications model** (low priority)
  - [ ] Optional: Rename `terrainIdFoncira` → `terrainId`
  - [ ] Update any explicit FK references

- [ ] **Update payment queries**
  - [ ] If using `payment['service_type']`, join services table
  - [ ] Verify service data still accessible

- [ ] **Test all critical flows**
  - [ ] Login (all 4 roles: client, vendor, agent, admin)
  - [ ] Admin dashboard (all 5 tabs)
  - [ ] Marketplace terrain display
  - [ ] Seller dashboard
  - [ ] Verification workflow
  - [ ] Payment tracking
  - [ ] No "column not found" errors

- [ ] **Test RLS policies**
  - [ ] Vendor sees only own terrains
  - [ ] Agent sees assigned verifications
  - [ ] Client sees public terrains
  - [ ] Admin sees everything

- [ ] **Performance check**
  - [ ] No slow queries (watch Supabase dashboard)
  - [ ] Search indexes working
  - [ ] Full-text search functional

- [ ] **Clear app cache**
  - [ ] Force reload after updating code
  - [ ] Clear Supabase cache if any
  - [ ] Re-authenticate in dev/test

---

## 🔗 RELATED DOCUMENTS

| Document                              | Purpose                           |
| ------------------------------------- | --------------------------------- |
| **database_schema_v2_audited.sql**    | Complete corrected schema         |
| **DATABASE_AUDIT_REPORT.md**          | Full audit with 12 manual actions |
| **003_schema_v1_to_v2_migration.sql** | Step-by-step migration script     |
| **DEPLOYMENT_QUICK_START.md**         | How to deploy                     |

---

**Status**: Schema v2.0 ready for deployment  
**Flutter App Impact Summary**: 3-4 breaking changes (surface/terrain_id/service_type/accompaniments)  
**Estimated Update Time**: 30-60 minutes  
**Testing Time**: 1-2 hours (all roles + flows)
