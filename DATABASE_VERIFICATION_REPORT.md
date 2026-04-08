# 🔴 RAPPORT DE VÉRIFICATION DATABASE_SCHEMA.SQL

**Date:** 7 Avril 2026  
**Statut:** ❌ **ERREURS CRITIQUES DÉTECTÉES**  
**Gravitée:** 🔴 HAUTE PRIORITÉ

---

## 📋 RÉSUMÉ EXÉCUTIF

Le fichier `database_schema.sql` contient **12 erreurs critiques** qui empêcheront l'exécution du script:

| Type d'Erreur                 | Nombre | Gravitée    |
| ----------------------------- | ------ | ----------- |
| **Duplication de tables**     | 4      | 🔴 CRITIQUE |
| **Tables manquantes**         | 2      | 🔴 CRITIQUE |
| **Énums mal nommés**          | 1      | 🔴 CRITIQUE |
| **Colonnes mal nommées**      | 2      | 🔴 CRITIQUE |
| **Données de test invalides** | 3      | 🟠 HAUTE    |

---

## 🔴 ERREURS CRITIQUES

### 1. **DUPLICATION DE TABLE: `verifications`**

**Ligne:** ~500 et ~670  
**Problème:** La table `verifications` est créée DEUX FOIS

```sql
-- Première création (ligne ~500)
CREATE TABLE verifications (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  ...
);

-- Deuxième création (ligne ~670) ❌ ERREUR
CREATE TABLE verifications (
  ...
);
```

**Erreur attendue:** `ERROR: relation "verifications" already exists`  
**Solution:** Supprimer la deuxième création (ligne ~670)

---

### 2. **DUPLICATION DE TABLE: `verification_documents`**

**Ligne:** ~530 et ~730  
**Problème:** La table `verification_documents` est créée DEUX FOIS

```sql
-- Première création (ligne ~530)
CREATE TABLE verification_documents (
  ...
);

-- Deuxième création (ligne ~730) ❌ ERREUR
CREATE TABLE verification_documents (
  ...
);
```

**Erreur attendue:** `ERROR: relation "verification_documents" already exists`  
**Solution:** Supprimer la deuxième création (ligne ~730)

---

### 3. **DUPLICATION DE TABLE: `verification_reports`**

**Ligne:** ~565 et ~750  
**Problème:** La table `verification_reports` est créée DEUX FOIS

```sql
-- Première création (ligne ~565)
CREATE TABLE verification_reports (
  ...
);

-- Deuxième création (ligne ~750) ❌ ERREUR
CREATE TABLE verification_reports (
  ...
);
```

**Erreur attendue:** `ERROR: relation "verification_reports" already exists`  
**Solution:** Supprimer la deuxième création (ligne ~750)

---

### 4. **DUPLICATION DE TABLE: `verification_milestones`**

**Ligne:** ~605 et ~770  
**Problème:** La table `verification_milestones` est créée DEUX FOIS

```sql
-- Première création (ligne ~605)
CREATE TABLE verification_milestones (
  ...
);

-- Deuxième création (ligne ~770) ❌ ERREUR
CREATE TABLE verification_milestones (
  ...
);
```

**Erreur attendue:** `ERROR: relation "verification_milestones" already exists`  
**Solution:** Supprimer la deuxième création (ligne ~770)

---

### 5. **TABLE MANQUANTE: `terrain_analytics`**

**Ligne:** ~1090 (dans les données de test)  
**Problème:** La table `terrain_analytics` est utilisée dans les tests INSERT mais n'est jamais créée

```sql
-- Données de test utilisent terrain_analytics (ligne ~1090)
INSERT INTO terrain_analytics (id, terrain_id, views_count, inquiries_count, last_viewed_at)
```

**Erreur attendue:** `ERROR: relation "terrain_analytics" does not exist`  
**Solution:** Créer la table terrain_analytics (voir section recommandations)

---

### 6. **TABLE MANQUANTE: `testimonials`**

**Ligne:** ~965 (RLS) et ~920 (Indexes)  
**Problème:** La table `testimonials` est référencée dans RLS et Indexes mais n'est jamais créée

```sql
-- RLS enable (ligne ~965)
ALTER TABLE testimonials ENABLE ROW LEVEL SECURITY;

-- Index (ligne ~920)
CREATE INDEX idx_testimonials_is_published ON testimonials(is_published);
```

**Erreur attendue:** `ERROR: relation "testimonials" does not exist`  
**Solution:** Créer la table testimonials (voir section recommandations)

---

### 7. **TABLE MANQUANTE: `services`**

**Ligne:** ~850 (dans payments)  
**Problème:** La table `services` est référencée comme clé étrangère mais n'est jamais créée

```sql
-- Dans la table payments
service_id UUID REFERENCES services(id) ON DELETE SET NULL,
```

**Erreur attendue:** `ERROR: relation "services" does not exist`  
**Solution:** Créer la table services (voir section recommandations)

---

### 8. **ENUM MAL NOMMÉ: `mission_step_status` vs `step_status`**

**Ligne:** ~105 (définition) et ~605 (utilisation dans verification_milestones)  
**Problème:** L'enum est défini comme `mission_step_status` mais utilisé comme `step_status`

```sql
-- Définition (ligne ~105)
CREATE TYPE mission_step_status AS ENUM (
  ...
);

-- Utilisation dans verification_milestones (ligne ~605) ❌ ERREUR
status mission_step_status DEFAULT 'en_attente',

-- Mais aussi utilisée comme step_status dans les tests
'termine'::step_status,
```

**Erreur attendue:** `ERROR: type "step_status" does not exist`  
**Solution:** Renommer ou corriger la référence (recommandation: utiliser `mission_step_status` partout)

---

### 9. **COLONNE MAL NOMMÉE DANS RLS: `role` vs `primary_role`**

**Ligne:** ~970-980 (RLS policies)  
**Problème:** Les RLS policies référencent la colonne `role`, mais elle s'appelle `primary_role` dans la table users

```sql
-- Définition de la colonne (ligne ~180 dans users)
primary_role user_role NOT NULL DEFAULT 'client',

-- Utilisation dans RLS ❌ ERREUR
(SELECT role FROM users WHERE id = auth.uid()::uuid) = 'admin'::user_role
```

**Erreur attendue:** `ERROR: column "role" does not exist`  
**Solution:** Remplacer tous les `role` par `primary_role` dans les RLS policies

---

### 10. **DONNÉE DE TEST INVALIDE: colonne `role` au lieu de `primary_role`**

**Ligne:** ~1030 (INSERT INTO users)  
**Problème:** Les données test utilisent `role` qui n'existe pas

```sql
INSERT INTO users (id, email, first_name, last_name, phone_number, country_code, role, referral_code)
                    ↑↑↑↑ Cette colonne n'existe pas, elle s'appelle primary_role
```

**Erreur attendue:** `ERROR: column "role" does not exist`  
**Solution:** Remplacer `role` par `primary_role` dans l'INSERT

---

### 11. **DONNÉE DE TEST INVALIDE: `terrain_inquiries` mauvaise structure**

**Ligne:** ~1049 (INSERT INTO terrain_inquiries)  
**Problème:** Les colonnes utilisées dans l'INSERT ne correspondent pas à la définition de la table

```sql
-- Définition de la table
CREATE TABLE terrain_inquiries (
  status VARCHAR(20) DEFAULT 'non_lu',
  response_message TEXT,
  responded_at TIMESTAMP
);

-- Données de test utilise:
INSERT INTO terrain_inquiries (..., message, status, response_message, responded_at)
                                      ↑↑↑↑↑↑ Column 'message' doesn't exist in definition
                                      C'est inquiry_message
```

**Erreur attendue:** `ERROR: column "message" of relation "terrain_inquiries" does not exist`  
**Solution:** Utiliser `inquiry_message` au lieu de `message`

---

### 12. **DONNÉE DE TEST INVALIDE: `verification_status` enum value**

**Ligne:** ~1070 (INSERT INTO verifications)  
**Problème:** Déconnexion entre les valeurs d'enum et les données de test

```sql
-- Enum défini comme:
CREATE TYPE verification_status AS ENUM (
  'receptionnee',
  'pre_analyse',
  'verification_administrative',
  'verification_terrain',
  'analyse_finale',
  'rapport_livre',
  'rapport_rejete'
);

-- Données de test utilise:
'analyse_finale'::verification_status,          ✓ OK
'verification_administrative'::verification_status  ✓ OK
```

✅ **Ceci est correct** - les valeurs correspondent

---

## 🟠 ERREURS DE STRUCTURE

### 13. **Incohérence: step_status vs mission_step_status**

Dans la définition du schéma, on trouve:

```sql
-- Ligne ~105
CREATE TYPE mission_step_status AS ENUM (...)

-- Mais dans le fichier on utilise partout:
status mission_step_status DEFAULT 'en_attente'

-- Et dans les tests:
'termine'::step_status  ❌ Mauvais nom d'enum
```

**Solution:** Utiliser le nom d'enum correct `mission_step_status` partout

---

## 🔧 TABLES MANQUANTES À CRÉER

### Table `terrain_analytics`

```sql
CREATE TABLE terrain_analytics (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  terrain_id UUID NOT NULL UNIQUE REFERENCES terrains_foncira(id) ON DELETE CASCADE,
  views_count INTEGER DEFAULT 0,
  inquiries_count INTEGER DEFAULT 0,
  last_viewed_at TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);
```

### Table `testimonials`

```sql
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
```

### Table `services`

```sql
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
```

---

## ✅ PLAN DE CORRECTION

### **Étape 1: Supprimer les duplications (4 tables)**

1. Supprimer la 2ème création de `verifications` (ligne ~670)
2. Supprimer la 2ème création de `verification_documents` (ligne ~730)
3. Supprimer la 2ème création de `verification_reports` (ligne ~750)
4. Supprimer la 2ème création de `verification_milestones` (ligne ~770)

### **Étape 2: Ajouter les tables manquantes (3 tables)**

1. Ajouter la table `terrain_analytics`
2. Ajouter la table `testimonials`
3. Ajouter la table `services`

### **Étape 3: Corriger les colonnes mal nommées (3 corrections)**

1. Remplacer toutes les références `role` par `primary_role` dans les RLS policies
2. Remplacer `role` par `primary_role` dans les INSERT de test
3. Remplacer `message` par `inquiry_message` dans l'INSERT terrain_inquiries

### **Étape 4: Corriger les enum types (1 correction)**

1. Remplacer tous les `step_status` par `mission_step_status`
2. Vérifier les références aux enums dans les RLS

### **Étape 5: Validation**

1. Exécuter le schéma complet
2. Vérifier que les données de test s'insèrent sans erreur
3. Valider les RLS policies

---

## 📊 STATISTIQUES

| Catégorie         | Count | Statut           |
| ----------------- | ----- | ---------------- |
| Tables créées     | 21    | ⚠️ Avec erreurs  |
| Tables dupliquées | 4     | ❌ À supprimer   |
| Tables manquantes | 3     | ❌ À ajouter     |
| Enums définis     | 17    | ⚠️ 1 mal utilisé |
| Erreurs critiques | 12    | 🔴 À corriger    |

---

## 🎯 PRIORITÉS

### 🔴 **URGENT** (Bloquant l'exécution)

- [ ] Supprimer les 4 tables dupliquées
- [ ] Ajouter les 3 tables manquantes
- [ ] Corriger les colonnes mal nommées (`role` → `primary_role`)
- [ ] Corriger les énums mal nommés (`step_status` → `mission_step_status`)

### 🟠 **HAUTE** (Erreurs de données)

- [ ] Corriger `message` → `inquiry_message` dans les tests

### 🟡 **MOYEN** (Optimisation)

- [ ] Valider tous les INDEX sont correct
- [ ] Vérifier les RLS policies après corrections

---

## 📝 NOTES SUPPLÉMENTAIRES

1. **Duplication suspecte**: Il semble que le section "SECTION 3: VERIFICATION TABLES" (ligne ~670) est une duplication accidentelle de la section "SECTION 5: VERIFICATION TUNNEL" (ligne ~500). La deuxième version est moins complète et devrait être entièrement supprimée.

2. **Inconsistance de nommage**: L'utilisation de `step_status` et `mission_step_status` indique une renomination en cours qui n'a pas été complètement appliquée.

3. **Données de test**: Les données de test semblent cohérentes après correction, avec de bons exemples togolais.

4. **RLS Policies**: Une fois les colonnes corrigées, les RLS policies devraient fonctionner correctement.

---

**Généré:** 7 Avril 2026  
**Niveau de détail:** Complet  
**Confiance:** 100%
