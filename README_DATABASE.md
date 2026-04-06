# FONCIRA Database Schema - Complete Package

## 📦 What's Included

This package contains a **complete, production-ready PostgreSQL/Supabase database schema** for transforming FONCIRA from a static app to a fully dynamic platform.

### Files Generated:

1. **`database_schema.sql`** (1000+ lignes)
   - Complete SQL script ready to paste into Supabase Editor
   - 11 tables, 70+ indexes, 15 ENUM types
   - RLS (Row Level Security) on all tables
   - Test data included (2 agents, 3 terrains, 2 clients, 1 verification)
   - Helper functions (currency conversion, timestamp triggers)

2. **`DATABASE_DOCUMENTATION.md`**
   - Complete schema documentation
   - Table descriptions with column details
   - RLS policy explanations
   - Test data breakdown
   - SQL query examples

3. **`INTEGRATION_GUIDE.md`**
   - Step-by-step Supabase setup
   - 10 code examples (SupabaseService, VerificationService, etc.)
   - Flutter integration patterns
   - RLS testing strategies
   - Deployment checklist

4. **`ERD_AND_PATTERNS.md`**
   - Entity Relationship Diagram (Mermaid)
   - Data flow diagrams
   - Query patterns (Client dashboard, Agent dashboard, etc.)
   - Access patterns by user role
   - Performance tuning notes

---

## 🚀 Quick Start (5 minutes)

### Step 1: Create Supabase Project

```bash
1. Go to https://app.supabase.com
2. Click "New project"
3. Choose region (preferrably nearest to TG: Lagos, Nigeria)
4. Create project (wait ~1 min)
```

### Step 2: Import Database Schema

```bash
1. In Supabase dashboard, go to SQL Editor
2. Click "New query"
3. Paste entire content of database_schema.sql
4. Click "Run" (should take ~30 seconds)
5. ✓ All should show green
```

### Step 3: Verify Tables

```sql
SELECT * FROM users;              -- Should see 4 test users
SELECT * FROM agents;             -- Should see 2 agents
SELECT * FROM verifications;      -- Should see 1 complete verification
SELECT * FROM payments;           -- Should see 1 payment
```

### Step 4: Configure Flutter App

```dart
// lib/services/supabase_service.dart
const String supabaseUrl = 'YOUR_PROJECT_URL_HERE';
const String supabaseAnonKey = 'YOUR_ANON_KEY_HERE';

// Get these from: Supabase Dashboard → Settings → API
```

### Step 5: Start Integration

Follow the code examples in `INTEGRATION_GUIDE.md`

---

## 📊 Database Overview

### Core Entities

```
USERS (4 test users)
├─ Clients (2)
├─ Agents (2)
└─ (Can have Admins)

TERRAINS_FONCIRA (3 test terrains)
├─ 500m² Kégué (Titre Foncier)
├─ 1000m² Tokoin (Convention)
└─ 800m² Avédji (No document)

VERIFICATIONS (1 complete flow)
└─ From Akosua Duah for Kégué terrain
    ├─ Documents uploaded
    ├─ Payment completed (150,000 FCFA)
    ├─ 4 milestones (1-3-7-10 days)
    ├─ Report with positive points & risks
    └─ Agent assigned: Kofi Mensah

AGENTS (2)
├─ Kofi Mensah (47 verifications completed)
└─ Ama Owusu (35 verifications completed)
```

### Key Statistics

| Metric             | Value                            |
| ------------------ | -------------------------------- |
| Total Tables       | 11                               |
| Indexes            | 70+                              |
| ENUM Types         | 15                               |
| RLS Policies       | ~20                              |
| Helper Functions   | 2                                |
| Test Records       | 20+                              |
| Verification Steps | 6 (réceptionnée → rapport_livre) |
| Milestone Tracking | 4 (J1, J3, J7, J10)              |

---

## 🔐 Security & RLS

The schema includes **complete Row Level Security (RLS)** policies:

### By User Role

| Role       | Can See                | Can Create               | Can Update                   |
| ---------- | ---------------------- | ------------------------ | ---------------------------- |
| **Client** | Own data only          | Verifications, Documents | Own profile, Notifications   |
| **Agent**  | Assigned verifications | Reports, Milestones      | Assigned verification status |
| **Admin**  | Everything             | Everything               | Everything                   |

### Policy Coverage

- ✓ `users` - Own profile only
- ✓ `agents` - Own record + assigned tasks
- ✓ `verifications` - Own submissions + assigned tasks
- ✓ `documents` - Related to own verification
- ✓ `payments` - Own payments
- ✓ `notifications` - Own notifications
- ✓ `terrains_foncira` - Public read, admin write

---

## 📋 Table Reference

### Essential Tables

**USERS** - Authentification + Profiles

- id, email, first_name, phone_number, country_code, role, referral_code

**VERIFICATIONS** - Main workflow tracking

- id, user_id, agent_id, source, status, risk_level
- terrain_title, terrain_location, terrain_price_fcfa
- external_location, external_seller_contact, sharing_link
- expected_delivery_at, actual_delivery_at

**VERIFICATION_MILESTONES** - J1/J3/J7/J10 progress

- id, verification_id, milestone_day, status
- started_at, completed_at, notes
- location_photos (JSONB), gps_coordinates (JSONB)

**VERIFICATION_REPORTS** - Final verdict

- id, verification_id, agent_id, risk_level
- verdict_summary, positive_points (JSONB), points_to_verify (JSONB)

**PAYMENTS** - Transaction tracking

- id, verification_id, amount_fcfa, amount_usd, payment_method, status

**VERIFICATION_DOCUMENTS** - File uploads

- id, verification_id, file_name, file_path, file_type, document_category

**NOTIFICATIONS** - User messaging

- id, recipient_id, notification_type, title, message, is_read

**AGENTS** - Verification specialists

- id, user_id, full_name, verifications_completed, average_rating, is_available

**TERRAINS_FONCIRA** - Marketplace listings

- id, title, location, ville, price_fcfa, document_type
- verification_status, seller_type, seller_name

**TESTIMONIALS** - User testimonials

- id, user_id, buyer_name, terrain_amount, testimonial_text, is_published

**REFERRAL_TRANSACTIONS** - Referral system

- id, referrer_id, referred_user_id, amount_earned_fcfa, payment_status

---

## 🔄 Complete Verification Flow

```
1. CLIENT SUBMITS VERIFICATION
   ├─ Source: External terrain OR Marketplace terrain
   ├─ Data: Location, price, document type, optional sharing link
   └─ Status: RECEPTIONNEE

2. OPTIONAL: UPLOAD DOCUMENTS
   ├─ Accepted: PDF, JPG, PNG
   ├─ Stored in: Supabase Storage
   └─ Tracked in: verification_documents table

3. CLIENT PAYS (150,000 FCFA)
   ├─ Payment method: Mobile Money or Card
   ├─ Status progression: EN_ATTENTE → VALIDEE
   └─ Recorded in: payments table

4. AGENT ASSIGNED
   ├─ Agent selected based on availability
   ├─ Status: PRE_ANALYSE
   └─ Milestones auto-created for J1, J3, J7, J10

5. AGENT COMPLETES MILESTONES
   ├─ J1: Cadastral verification - ADMINISTRATIVE VERIFICATION
   ├─ J3: Field visit - VERIFICATION TERRAIN
   ├─ J7: Customary verification - CUSTOMARY CHECK
   ├─ J10: Final analysis
   └─ Each: Photos + GPS + Notes + Proactive message

6. REPORT GENERATED
   ├─ Risk level: Faible / Modéré / Élevé
   ├─ Verdict: 1-line summary
   ├─ Positive points: What documents confirm
   ├─ Points to verify: What needs attention
   └─ Status: ANALYSE_FINALE

7. REPORT DELIVERED
   ├─ Client receives notification
   ├─ Can view full report
   ├─ Status: RAPPORT_LIVRE
   └─ Client chooses next action: ACHETER/ACCOMPAGNEMENT/PAS_MAINTENANT

8. OPTIONAL: POST-REPORT DECISION
   ├─ If ACHETER: Move to notary phase
   ├─ If ACCOMPAGNEMENT: Link to support service
   └─ If PAS_MAINTENANT: Archive, suggest alternative terrains

9. OPTIONAL: REFERRAL TRACKING
   ├─ If client = referred, credit referrer
   ├─ Amount: Configurable (e.g., 15,000 FCFA per verification)
   └─ Status tracked in: referral_transactions
```

---

## 🛠 Technology Stack

```
Backend:     PostgreSQL (via Supabase)
├─ Storage:  Supabase Storage (for documents)
├─ Auth:     Supabase Auth (email/password)
├─ Realtime: Supabase Realtime (optional)
└─ REST:     PostgREST API (auto-generated)

Frontend:    Flutter
├─ SDK:      supabase_flutter
├─ Provider: for state management
└─ Services: Custom Dart services for DB operations

Deployment: Supabase (managed PostgreSQL)
├─ Region:  Europe or Africa (choose wisely)
├─ Backup:  Hourly WAL + Daily snapshot
└─ Monitoring: Built-in dashboard
```

---

## ✅ Pre-Deployment Checklist

- [ ] SQL script imported successfully
- [ ] All 11 tables created
- [ ] Test data visible in tables
- [ ] RLS enabled on all tables
- [ ] Supabase Auth configured
- [ ] Flutter dependencies added (supabase_flutter)
- [ ] Config.dart updated with correct credentials
- [ ] SupabaseService created
- [ ] VerificationService created
- [ ] Pages updated to load from Supabase
- [ ] RLS tested with different user roles
- [ ] Storage bucket created for documents
- [ ] CORS configured if needed
- [ ] Backup strategy enabled
- [ ] Monitoring alerts set up
- [ ] Team members given access
- [ ] Data export/import procedures documented

---

## 📈 Expected Scale

### Year 1 Projections

```
Verifications:        10,000+
Devices:              5,000+
Agents:               50+
Terrains listed:      500+
Total documents:      50,000+
Transactions:         10,000+M FCFA
```

### Database Growth (Year 1)

```
Data size: ~500 MB
You'll stay in Supabase free tier first year
Then move to: Pro ($25/month) → Enterprise
```

---

## 🔧 Maintenance

### Regular Tasks

```
Daily:   Monitor error logs, backup status
Weekly:  Review RLS policies, check query performance
Monthly: Analyze growth trends, plan scaling
Yearly:  Full audit, security review, archive old data
```

### Common Commands

```sql
-- Monitor table sizes
SELECT schemaname, tablename, pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename))
FROM pg_tables
WHERE schemaname='public'
ORDER BY pg_total_relation_size(schemaname||'.'||tablename) DESC;

-- Check RLS policies
SELECT * FROM pg_policies;

-- Analyze query performance
EXPLAIN ANALYZE SELECT * FROM verifications WHERE user_id = 'UUID';
```

---

## 📞 Support & Troubleshooting

### Common Issues

**"RLS policy violation"**
→ Check that auth.uid() matches user ID in table

**"Column does not exist"**
→ Check case sensitivity (PostgreSQL is strict)

**"JWT invalid"**
→ Verify Supabase credentials in Flutter config

**"Foreign key constraint failed"**
→ Ensure parent record exists before inserting

See `INTEGRATION_GUIDE.md` → Troubleshooting section for more.

---

## 📚 Documentation Map

```
├─ database_schema.sql           ← Copy into Supabase
├─ DATABASE_DOCUMENTATION.md    ← Read first
├─ INTEGRATION_GUIDE.md         ← Follow for Flutter integration
├─ ERD_AND_PATTERNS.md          ← Understand relationships
└─ README.md (this file)        ← You are here
```

---

## 🎯 Next Steps

1. **Immediate (Today)**
   - [ ] Import `database_schema.sql`
   - [ ] Verify tables were created
   - [ ] Read `DATABASE_DOCUMENTATION.md`

2. **This Week**
   - [ ] Set up Supabase project completely
   - [ ] Configure Flutter with credentials
   - [ ] Create `SupabaseService.dart`

3. **Next Week**
   - [ ] Create `VerificationService.dart`
   - [ ] Update verification_tunnel_page.dart to use Supabase
   - [ ] Test RLS with different users

4. **Following Week**
   - [ ] Create remaining services (Payment, Storage, etc.)
   - [ ] Update all pages for dynamic data
   - [ ] Full integration testing

---

## 📄 Files Summary

| File                      | Lines | Purpose                       |
| ------------------------- | ----- | ----------------------------- |
| database_schema.sql       | 1000+ | SQL script - copy to Supabase |
| DATABASE_DOCUMENTATION.md | 500+  | Schema reference              |
| INTEGRATION_GUIDE.md      | 400+  | Flutter integration examples  |
| ERD_AND_PATTERNS.md       | 350+  | Relationships & queries       |
| README.md                 | 350+  | This file                     |

**Total:** ~3000 lines of documentation + schema

---

## 🚦 Status

✅ **Complete & Production-Ready**

- Category: Database Architecture
- Version: 1.0
- Generated: April 2026
- Tested: Yes (schemas validates, RLS tested, test data included)
- Status: Ready to deploy

---

## 📄 License & Usage

This schema and documentation are part of the FONCIRA project.
Feel free to:

- ✓ Modify table structures
- ✓ Add columns as needed
- ✓ Extend ERDs
- ✓ Customize RLS policies

Just ensure:

- ✓ Backup before major changes
- ✓ Test RLS thoroughly
- ✓ Document modifications
- ✓ Keep audit trail

---

**Thank you for using FONCIRA!**

For questions or updates to the schema, refer to `DATABASE_DOCUMENTATION.md` or the Supabase documentation.

Happy shipping! 🚀
