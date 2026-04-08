# FONCIRA — Terrain Sellers: RLS Policies & Service Implementation

## 📋 Vue d'ensemble

Ce document couvre:

1. **RLS Policies complètes** pour vendeurs/sellers
2. **TerrainSellerService** — Service Dart complet
3. **Déploiement** de la migration SQL

---

## 🔐 RLS Policies Implémentées

### Migration: `002_add_sellers_rls_policies.sql`

#### 1. **SELECT Policy: Public** (`public_can_view_published_terrains`)

```sql
-- Condition: status = 'publie' AND deleted_at IS NULL
-- Qui peut: Tout le monde (unauthenticated + authenticated)
-- Use case: Affichage marketplace public
```

#### 2. **SELECT Policy: Sellers & Admins** (`sellers_admins_can_view_own_terrains`)

```sql
-- Condition:
--   (auth.uid() = seller_id AND deleted_at IS NULL) OR
--   (user.role = 'admin')
-- Qui peut: Vendeurs voient leurs terrains + Admins voient tous
-- Use case: Dashboard vendeur + Admin moderation
```

#### 3. **INSERT Policy: Sellers & Admins** (`sellers_admins_can_create_terrains`)

```sql
-- Condition:
--   user.role IN ('seller', 'vendor', 'admin') AND
--   seller_id = auth.uid()
-- Qui peut: Créer terrains (seller_id = current user)
-- Use case: Soumission de terrain par vendeur
```

#### 4. **UPDATE Policy: Owners & Admins** (`sellers_can_update_own_terrains`)

```sql
-- Qui peut: Vendeurs modifient propres terrains + Admins modifient tous
-- Use case: Modification lors du brouillon
```

#### 5. **DELETE Policy: Admins Only** (`admins_can_delete_terrains`)

```sql
-- Qui peut: Admins uniquement (soft delete via deleted_at)
-- Use case: Suppression (moderation)
```

---

## 📱 TerrainSellerService — API Complète

### Singleton Pattern

```dart
final service = TerrainSellerService();
```

### Méthodes Principales

#### 1. **Créer un terrain (Brouillon)**

```dart
final result = await service.createTerrain(
  title: 'Terrain à Lomé',
  priceFcfa: 15000000,
  priceUsd: 22900,
  areaSqm: 500,
  city: 'Lomé',
  documentType: 'titre', // 'titre', 'cession', 'permission'
  description: 'Beau terrain résidentiel',
  sellerNotes: 'Bien pourvu',
  imageFile: selectedImageFile,
);
// Retourne: Map avec les données du terrain créé (status='draft')
```

#### 2. **Modifier un terrain**

```dart
final updated = await service.updateTerrain(
  terrainId: terrainId,
  title: 'Nouveau titre',
  priceFcfa: 15500000,
  imageFile: newImageFile, // Optionnel
);
```

#### 3. **Publier un terrain (draft → publie)**

```dart
final published = await service.publishTerrain(terrainId);
// Mise à jour: status='publie', published_at=now()
```

#### 4. **Dépublier un terrain (publie → draft)**

```dart
final draft = await service.unpublishTerrain(terrainId);
```

#### 5. **Récupérer les terrains du vendeur**

```dart
// Tous les terrains (avec filtre optionnel)
final terrains = await service.getSellerTerrains(
  status: 'publie', // Optionnel: 'draft', 'publie', etc.
  limit: 20,
  offset: 0,
);

// Terrains publiés uniquement
final published = await service.getSellerPublishedTerrains();
```

#### 6. **Récupérer les statistiques**

```dart
final stats = await service.getSellerStats();
// Retourne: {
//   'drafts': 5,
//   'published': 12,
//   'under_verification': 3
// }
```

#### 7. **Archiver un terrain (soft delete)**

```dart
await service.archiveTerrain(terrainId);
// Mise à jour: deleted_at=now()
```

#### 8. **Récupérer les vérifications d'un terrain**

```dart
final verifications = await service.getTerrainVerifications(terrainId);
// Retourne: List de vérifications avec agent info
```

#### 9. **Sélectionner une image**

```dart
final imageFile = await service.pickImageFromGallery();
// Retourne: File ou null
```

---

## 🚀 Déploiement

### Étape 1: Exécuter la Migration SQL

Dans **Supabase SQL Editor**:

1. Aller à: Dashboard Supabase → SQL Editor
2. Créer une nouvelle query
3. Copier-coller le contenu de `supabase_migrations/002_add_sellers_rls_policies.sql`
4. Exécuter (`Run`)

**Résultat attendu**: "Aucune erreur" ✓

### Étape 2: Vérifier les Policies

1. Aller à: **Table Editor** → `terrains_foncira`
2. Onglet **Security** → Vérifier les 5 policies
3. Chaque policy doit avoir ✓ actif (vert)

### Étape 3: Tester le Service

```dart
// Dans un widget/page
try {
  final service = TerrainSellerService();

  // Créer un terrain test
  final terrain = await service.createTerrain(
    title: 'Test Terrain',
    priceFcfa: 10000000,
    priceUsd: 15000,
    areaSqm: 400,
    city: 'Lomé',
    documentType: 'titre',
  );

  print('Terrain créé: ${terrain?['id']}');

} catch (e) {
  print('Erreur: $e');
}
```

---

## 📊 Flux Vendeur Typique

```
1. Vendeur se connecte → auth.uid() = seller_id
   ↓
2. Vendeur crée terrain → INSERT (RLS: seller_id = auth.uid()) ✓
   ↓
   Status = 'draft' (invisible public)
   ↓
3. Vendeur modifie terrain → UPDATE (RLS: auth.uid() = seller_id) ✓
   ↓
4. Vendeur publie → UPDATE status='publie'
   ↓
   Maintenant visible public (RLS: status='publie') ✓
   ↓
5. Public voit terrain → SELECT (RLS: status='publie') ✓
```

---

## 🔒 Sécurité

### ✅ Garanties RLS

| Action        | Vendeur Propre | Vendeur Autre | Admin | Public |
| ------------- | -------------- | ------------- | ----- | ------ |
| SELECT draft  | ✓              | ✗             | ✓     | ✗      |
| SELECT publie | ✓              | ✓             | ✓     | ✓      |
| INSERT        | ✓\*            | ✗             | ✓     | ✗      |
| UPDATE propre | ✓\*            | ✗             | ✓     | ✗      |
| DELETE        | ✗              | ✗             | ✓     | ✗      |

\*si seller_id = auth.uid()

### Pas de Risque D'Injection

Supabase gère:

- ✅ Paramétrage des requêtes
- ✅ Validation JWT
- ✅ user.id immuable (from auth token)

---

## 🐛 Troubleshooting

### Error: "new row violates row-level security policy"

**Cause**: `seller_id != auth.uid()`
**Solution**: Vérifier que `seller_id` est défini à `auth.uid()` lors de INSERT

### Error: "relation 'terrains_foncira' does not exist"

**Cause**: Table n'existe pas encore
**Solution**: Vérifier que `terrains_foncira` est créée dans le schéma

### Policy ne s'applique pas

**Cause**: RLS n'est pas activée sur la table
**Solution**: Vérifier `ALTER TABLE terrains_foncira ENABLE ROW LEVEL SECURITY;` a été exécutée

### Admin ne voit pas les terrains

**Cause**: Policy admin_read utilise `(SELECT role FROM users WHERE id = auth.uid())`
**Solution**: Vérifier que l'admin est connecté et que sa `role` = 'admin' dans la table `users`

---

## 📝 Colonnes Requises

**Table `terrains_foncira`** doit avoir:

- ✅ `id` (UUID PRIMARY KEY)
- ✅ `seller_id` (UUID REFERENCES users(id))
- ✅ `status` (VARCHAR: draft, publie, suspendu, vendu, archive)
- ✅ `deleted_at` (TIMESTAMP NULL)
- ✅ `title`, `price_fcfa`, `price_usd`, `area_sqm`, `city`, `document_type`
- ✅ `description`, `seller_notes`, `featured_image`
- ✅ `verification_status`
- ✅ `created_at`, `updated_at`, `published_at`

---

## 🎯 Cas d'Usage

### Vendeur crée et publie

```dart
// 1. Créer brouillon
final terrain = await service.createTerrain(...);
// Status = 'draft', invisible public

// 2. Modifier si nécessaire
await service.updateTerrain(terrainId, ...);

// 3. Publier
await service.publishTerrain(terrainId);
// Status = 'publie', visible public ✓
```

### Admin modère

```dart
// Admin voit tous les terrains
final all = await supabase
    .from('terrains_foncira')
    .select('*'); // RLS: admin_read policy ✓

// Admin peut changer status
await supabase
    .from('terrains_foncira')
    .update({'status': 'suspendu'})
    .eq('id', terrainId); // RLS: admin_update policy ✓
```

### Public navigue marketplace

```dart
// Voir uniquement terrains publiés
final published = await supabase
    .from('terrains_foncira')
    .select('*') // RLS: public_can_view_published_terrains ✓
    .eq('status', 'publie');
```

---

## 📞 Support

Pour questions:

- Supabase RLS: https://supabase.com/docs/guides/auth/row-level-security
- TerrainSellerService API: Voir commentaires dans le code
- Migrations: https://supabase.com/docs/guides/cli/local-development
