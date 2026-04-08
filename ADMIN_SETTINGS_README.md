# FONCIRA — Configuration des Paramètres Administrateur

## 📋 Vue d'ensemble

Ce document couvre:

1. **Onglet 5 - Paramètres** avec gestion des services, taux de change, statistiques
2. **Gestion des rapports** depuis le détail de la vérification
3. **Création d'agents** via Supabase Edge Function

---

## 🔧 Configuration Required

### 1. Créer la table `app_config`

Exécutez la migration SQL dans Supabase SQL Editor:

```bash
supabase_migrations/001_create_app_config.sql
```

Cela crée:

- Table `app_config` (key/value store pour config globale)
- Table `verification_reports` (rapports de vérification)

---

### 2. Déployer l'Edge Function `create-agent`

L'Edge Function crée les agents via Supabase Auth avec la `service_role_key` (ne jamais exposer côté Flutter).

#### Étapes:

1. **Installer Supabase CLI** (si pas déjà fait):

   ```bash
   npm install -g supabase
   ```

2. **Se connecter à Supabase**:

   ```bash
   supabase login
   ```

3. **Déployer la fonction**:

   ```bash
   cd supabase/functions/create-agent
   supabase functions deploy create-agent
   ```

4. **Vérifier le déploiement**:
   - Aller au dashboard Supabase → Edge Functions
   - Vérifier que `create-agent` est listée

---

## 📱 Fonctionnalités Implémentées

### Admin Detail Page — Gestion des Rapports

**Condition**: `status == 'analyse_finale'` et pas de rapport existant

**Formulaire de rapport**:

- ✅ Sélecteur de risque (3 pills): Faible / Modéré / Élevé
- ✅ Verdict (max 255 caractères)
- ✅ Points positifs (multi-lignes, chaque ligne = 1 item)
- ✅ Points à vérifier (même structure)
- ✅ Terrains alternatifs (si risque élevé, jusqu'à 3)

**Valeurs par défaut**:

- `risk_level`: Stocker comme `'faible'`, `'modere'`, `'eleve'`
- `positive_points`, `points_to_verify`: TEXT[] (array en Postgres)
- `alternative_terrains`: JSONB (chaque item: `{name: "Terrain 1"}`)

**Actions à la validation**:

1. INSERT dans `verification_reports`
2. UPDATE `verifications`:
   - `status` = `'rapport_livre'`
   - `risk_level` = valeur du rapport
   - `actual_delivery_at` = `now()`
3. INSERT dans `notifications`:
   - `title`: "Rapport disponible"
   - `message`: "Votre rapport de vérification est disponible."
   - `type`: "report_delivered"

---

### Onglet 5 — Paramètres

#### Section 1: Offres de Service

**Source**: Table `services` (label, price_fcfa, price_usd, is_active)

**Actions admin**:

- Modifier label
- Modifier price_fcfa
- Modifier price_usd
- Toggle is_active
- Bouton "Enregistrer" pour chaque service (pas de save global)

**Propagation**: Les prix changent immédiatement dans tout le tunnel client

---

#### Section 2: Taux de Conversion

**Stockage**: Table `app_config` avec `key='fcfa_to_usd_rate'`

**Défaut**: `655.957`

**Actions**:

- Afficher taux actuel
- Champ éditable pour modifier
- Bouton "Enregistrer"

**Utilisation côté client**: L'app lit ce taux depuis Supabase au démarrage

---

#### Section 3: Statistiques Globales (Preuve Sociale)

**Stockage**: Table `app_config` avec 3 clés:

- `stat_terrains_verified`
- `stat_disputes_avoided`
- `stat_amount_protected_usd`

**Affichage**: Sur la home client (compteurs bleus)

**Actions admin**:

- Éditer les 3 valeurs
- Bouton global "Enregistrer tout"

---

#### Section 4: Gestion des Agents

**Formulaire de création**:

- Email (obligatoire)
- Prénom (obligatoire)
- Spécialisation (optionnel)

**Processus**:

1. Admin clique "Créer un agent"
2. Dialog avec formulaire s'ouvre
3. À la soumission:
   - Appel à Edge Function `/create-agent`
   - Edge Function crée utilisateur Auth (via service_role)
   - Insère dans `users` avec `role='agent'`
   - Insère dans `agents` avec valeurs par défaut
   - Retour à l'admin avec succès/erreur

---

## 🗄️ Schéma SQL Ajoutés

### Table `app_config`

```sql
CREATE TABLE app_config (
  key VARCHAR PRIMARY KEY,
  value TEXT NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

**Valeurs par défaut à insérer**:

```sql
INSERT INTO app_config (key, value) VALUES
  ('fcfa_to_usd_rate', '655.957'),
  ('stat_terrains_verified', '0'),
  ('stat_disputes_avoided', '0'),
  ('stat_amount_protected_usd', '0');
```

### Table `verification_reports`

```sql
CREATE TABLE verification_reports (
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
```

---

## 🔐 Sécurité

### Edge Function — `create-agent`

**Jamais exposer `SUPABASE_SERVICE_ROLE_KEY` côté Flutter** ❌

✅ **Approche sécurisée**:

- Edge Function hébergée sur Supabase (côté serveur)
- Utilise `service_role_key` en secret d'environnement
- Flutter appelle la fonction via HTTP (authentifié avec JWT)
- Valider JWT côté serveur pour vérifier que l'appelant est admin

---

## 📝 Fichiers Créés/Modifiés

### Fichiers Créés:

- ✅ `lib/page/admin/admin_settings_tab_v2.dart` — Onglet paramètres complet
- ✅ `supabase_migrations/001_create_app_config.sql` — Migration
- ✅ `supabase_functions/create-agent/index.ts` — Edge Function

### Fichiers Modifiés:

- ✅ `lib/page/admin/admin_verification_detail.dart` — Ajout section rapport
- ✅ `lib/page/admin/admin_dashboard.dart` — Import de admin_settings_tab_v2

---

## 🚀 Déploiement Pas à Pas

1. **Exécuter la migration SQL**:

   ```sql
   -- Dans Supabase SQL Editor
   -- Copier-coller le contenu de supabase_migrations/001_create_app_config.sql
   ```

2. **Déployer l'Edge Function**:

   ```bash
   supabase functions deploy create-agent
   ```

3. **Tester admin_settings_tab**:
   - Accéder au dashboard admin → Paramètres
   - Vérifier les 4 sections chargent correctement

4. **Tester gestion des rapports**:
   - Créer une vérification avec `status='analyse_finale'`
   - Aller au détail → Voir bouton "Saisir le rapport"
   - Remplir et valider

---

## 🐛 Troubleshooting

### Edge Function non trouvée

```
Error: 404 - Function not found
```

**Solution**: Vérifier que la fonction est déployée:

```bash
supabase functions list
```

### Service role key exposée

**JAMAIS** faire:

```dart
// ❌ MAUVAIS
final client = SupabaseClient(projectUrl, serviceRoleKey);
```

**TOUJOURS** utiliser:

```dart
// ✅ BON
await supabase.functions.invoke('create-agent', body: {...});
```

### Taux de conversion ne se met pas à jour

- Vérifier que `app_config` a une ligne avec `key='fcfa_to_usd_rate'`
- Vérifier l'UPDATE dans le DialogBuilder

---

## 📞 Support

Pour des questions sur:

- **Edge Functions**: Docs Supabase → Functions
- **RLS**: Docs Supabase → RLS
- **Flutter/Supabase**: Package supabase_flutter
