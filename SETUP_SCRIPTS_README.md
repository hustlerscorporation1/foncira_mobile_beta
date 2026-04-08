# 🚀 Configuration Complète Supabase Storage - Upload Photos

**Date:** 7 Avril 2026  
**Projet:** Agnigbangna  
**Objectif:** Configuration complète pour permettre aux vendeurs d'uploader des photos de terrains

---

## 📋 Guide Rapide (3 étapes)

### ✅ Étape 1: Créer le Bucket

```bash
# Exécutez le script PowerShell (Windows)
.\setup_supabase_storage.ps1 `
  -SupabaseUrl "https://xxxxx.supabase.co" `
  -ServiceRoleKey "eyJhbGc..."
```

### ✅ Étape 2: Configurer les Policies (Permissions)

1. Allez à: `https://app.supabase.com/project/???/sql`
2. Cliquez **"New Query"**
3. Collez le contenu de `setup_storage_policies.sql`
4. Cliquez **"RUN"**

### ✅ Étape 3: Configurer CORS

1. Allez à: `https://app.supabase.com/project/???/settings/api`
2. Cherchez **"CORS allow-listed origins"**
3. Ajoutez les origines:
   ```
   http://localhost:*
   https://foncira.app
   https://*.lovable.app
   https://*.vercel.app
   ```
4. Cliquez **"Update"**

---

## 📚 Scripts Disponibles

### 1. **setup_supabase_storage.ps1** (PowerShell - Windows) ⭐ RECOMMANDÉ

```powershell
# Syntaxe simple:
.\setup_supabase_storage.ps1

# Avec paramètres:
.\setup_supabase_storage.ps1 `
  -SupabaseUrl "https://xxxxx.supabase.co" `
  -ServiceRoleKey "eyJhbGc..." `
  -BucketName "documents"
```

**Avantages:**

- ✅ Automatise la création du bucket
- ✅ Belles couleurs et formatage
- ✅ Vérification complète
- ✅ Instructions étape par étape
- ✅ Fonctonne nativement sur Windows

**Fonctionnalités:**

- Crée le bucket 'documents'
- Vérifie les paramètres
- Récupère les infos du bucket
- Affiche les étapes suivantes

---

### 2. **setup_supabase_storage.dart** (Dart complet)

```bash
# Installation des dépendances:
dart pub add http

# Exécution:
dart setup_supabase_storage.dart
```

**Avantages:**

- ✅ Peut être intégré dans votre app Flutter
- ✅ Logique complète en Dart
- ✅ Gestion d'erreurs améliorée
- ✅ Vérification finale du bucket

**Fonctionnalités:**

- Crée le bucket
- Crée les policies
- Configure CORS
- Vérifie tout est correcte

**Limitation:**

- ⚠️ Les APIs CORS et policies peuvent échouer (limitation Supabase)
- 💡 Solution: Faire les étapes 2 et 3 manuellement

---

### 3. **setup_storage_policies.sql** (SQL pur) ⭐ RECOMMANDÉ POUR POLICIES

```sql
-- Copier le contenu du fichier
-- Aller à: Supabase Dashboard > SQL Editor
-- Coller et exécuter
```

**Contenu:**

- ✅ Crée les policies RLS complètes
- ✅ Crée les triggers pour audit logging
- ✅ Configure la sécurité
- ✅ Inclut des vérifications

**Policies créées:**

1. `Allow authenticated users to upload` (INSERT)
2. `Allow public read access` (SELECT)
3. `Allow authenticated users to delete own files` (DELETE)
4. `Allow authenticated users to update own files` (UPDATE)

---

### 4. **setup_cors.js** (Node.js)

```bash
# Installation:
npm install

# Exécution:
node setup_cors.js
```

**Avantages:**

- ✅ Interface utilisateur claire
- ✅ Récupère la config actuelle
- ✅ Ajoute les origines CORS
- ✅ Instructions manuelles si échec

**Fonctionnalités:**

- Récupère les origines actuelles
- Ajoute les nouvelles origines
- Affiche les instructions manuelles
- Gère les erreurs gracieusement

---

## 🎯 Flux Recommandé

### **Option 1: Automatisé (Recommandé pour Dev)**

```
1. Modifier les paramètres dans setup_supabase_storage.ps1
   ↓
2. Exécuter: .\setup_supabase_storage.ps1
   ├─ ✅ Crée le bucket
   ├─ ✅ Vérifie le bucket
   └─ 📝 Affiche les étapes suivantes
   ↓
3. Exécuter le SQL (policies) via Supabase Dashboard
   ├─ Aller à: SQL > New Query
   ├─ Copier setup_storage_policies.sql
   └─ ✅ Cliquer RUN
   ↓
4. Configurer CORS manuellement
   ├─ Aller à: Settings > API > CORS
   └─ ✅ Ajouter les origines
   ↓
5. Compiler et tester
   └─ flutter run
```

### **Option 2: Entièrement Automatisé (Dart)**

```
1. Modifier SUPABASE_URL et SUPABASE_SERVICE_ROLE_KEY
   ↓
2. Exécuter: dart setup_supabase_storage.dart
   ├─ ✅ Crée le bucket
   ├─ ✅ Crée les policies
   ├─ ✅ Configure CORS
   └─ ✅ Vérifie tout
   ↓
3. Compiler et tester
   └─ flutter run
```

### **Option 3: Entièrement Manuelle**

```
1. Supabase Dashboard > Storage > New Bucket
   └─ Créer 'documents'
   ↓
2. Supabase Dashboard > SQL > New Query
   └─ Exécuter setup_storage_policies.sql
   ↓
3. Supabase Dashboard > Settings > API > CORS
   └─ Ajouter les origines
   ↓
4. Compiler et tester
   └─ flutter run
```

---

## 🔍 Vérification

### Vérifier que le bucket existe

```bash
# Via PowerShell:
curl -H "apikey: YOUR_KEY" `
     "https://xxxxx.supabase.co/storage/v1/bucket/documents"

# Via SQL:
SELECT * FROM storage.buckets WHERE name = 'documents';
```

### Vérifier les policies

```sql
-- Via SQL:
SELECT policyname, permissive, roles
FROM pg_policies
WHERE tablename = 'objects';
```

### Vérifier CORS

```bash
# Via PowerShell:
curl -H "Origin: http://localhost:3000" `
     "https://xxxxx.supabase.co/storage/v1/bucket/documents"
```

---

## 📝 Trouvez vos Clés API

1. Allez à: https://app.supabase.com
2. Sélectionnez votre projet
3. **Settings** (en bas du menu) > **API**
4. Vous verrez:
   ```
   Project URL: https://xxxxx.supabase.co
   anon public: eyJhbGc...
   service_role (secret): eyJhbGc...
   ```
5. **Copiez:**
   - `Project URL` → `SUPABASE_URL`
   - `service_role (secret)` → `SUPABASE_SERVICE_ROLE_KEY`

---

## ⚠️ Points Importants

### 🔒 Sécurité

- ✅ Seuls les utilisateurs **authentifiés** peuvent uploader
- ✅ N'importe qui peut **lire** les fichiers (supposés publics)
- ✅ Les utilisateurs ne peuvent **supprimer** que leurs fichiers
- ✅ Service Role Key: **MAINTENIR SECRET** (ne pas committer!)

### 🚨 Erreurs Courantes

| Erreur                   | Cause                      | Solution                            |
| ------------------------ | -------------------------- | ----------------------------------- |
| "Bucket not found (404)" | Bucket n'existe pas        | Créer le bucket                     |
| "Permission denied"      | Policies non configurées   | Exécuter setup_storage_policies.sql |
| "CORS error"             | Origines CORS non ajoutées | Configurer CORS dans Settings       |
| "Unauthorized"           | Clé API incorrecte         | Vérifier SERVICE_ROLE_KEY           |

### 📱 Permissions Mobile

**Android** (déjà configuré):

```xml
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.READ_MEDIA_IMAGES" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
```

**iOS** (à vérifier - nécessite Info.plist):

```xml
<key>NSPhotoLibraryUsageDescription</key>
<string>Agni permet d'ajouter des photos à vos terrains</string>
```

---

## 🧪 Test Après Configuration

### Test 1: Vérifier le bucket existe

```sql
SELECT id, name, public FROM storage.buckets WHERE name = 'documents';
```

**Résultat attendu:** Une ligne avec `documents`

### Test 2: Vérifier les policies

```sql
SELECT policyname FROM pg_policies WHERE tablename = 'objects';
```

**Résultat attendu:** 4 policies (upload, read, delete, update)

### Test 3: Uploader via l'app

1. `flutter run`
2. Mode Vendeur
3. **Publier un terrain**
4. Étape 1: **Ajouter des photos**
5. Sélectionner une photo
6. **Résultat:** ✅ Photo ajoutée

### Test 4: Vérifier dans Supabase

```sql
SELECT name, size, created_at
FROM storage.objects
WHERE bucket_id = 'documents'
ORDER BY created_at DESC;
```

---

## 📞 Dépannage

### Les scripts ne fonctionnent pas

**PowerShell:**

```powershell
# Vérifier que les paramètres sont corrects:
$SupabaseUrl = "https://xxxxx.supabase.co"
$ServiceRoleKey = "eyJhbGc..."

# Puis exécuter:
.\setup_supabase_storage.ps1 -SupabaseUrl $SupabaseUrl -ServiceRoleKey $ServiceRoleKey
```

**Dart:**

```dart
// Mettre à jour au début du fichier:
const String SUPABASE_URL = 'https://xxxxx.supabase.co';
const String SUPABASE_SERVICE_ROLE_KEY = 'eyJhbGc...';

// Exécuter:
dart setup_supabase_storage.dart
```

**Node.js:**

```javascript
// Mettre à jour au début:
const SUPABASE_URL = 'https://xxxxx.supabase.co';
const SUPABASE_SERVICE_ROLE_KEY = 'eyJhbGc...';

// Exécuter:
node setup_cors.js
```

### Les uploads échouent après configuration

1. **Vérifier les permissions:**

   ```bash
   flutter run -v  # Affiche les logs détaillés
   ```

2. **Vérifier le bucket dans Supabase Dashboard:**
   - Storage > documents > doit être **Public** ✅

3. **Vérifier les policies:**
   - Storage > documents > Policies > doit avoir 4 policies ✅

4. **Vérifier CORS:**
   - Settings > API > CORS > doit avoir les origines ✅

---

## 📊 Statut Configuration

Use this checklist to track your progress:

| Élément        | Statut | Fichier                    |
| -------------- | ------ | -------------------------- |
| Bucket créé    | ⏳     | setup_supabase_storage.ps1 |
| Policies RLS   | ⏳     | setup_storage_policies.sql |
| CORS configuré | ⏳     | setup_cors.js              |
| App compilée   | ⏳     | `flutter run`              |
| Photo uploadée | ⏳     | **Test manuel**            |

---

## 🎯 Résumé

Vous avez 3 scripts automatisés pour configurer Supabase Storage:

1. **setup_supabase_storage.ps1** ⭐ Crée le bucket (Windows)
2. **setup_storage_policies.sql** ⭐ Configure les permissions (SQL)
3. **setup_cors.js** ou **setup_supabase_storage.ps1** pour CORS

**Temps estimé:** 5-10 minutes pour tout configurer

**Après:** Les vendeurs peuvent uploader des photos! 🎉

---

**Questions?** Vérifiez:

- Avez-vous les bonnes clés API?
- Les origines CORS sont-elles ajoutées?
- Les policies SQL ont-elles été exécutées?
- La permission Android est-elle acceptée sur le téléphone?

---

_Document généré: 7 Avril 2026_
_Version: 1.0_
