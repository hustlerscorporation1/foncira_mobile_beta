# ⚠️ Configuration Supabase Storage - Solution Réelle

**Date:** 7 Avril 2026  
**Important:** Les scripts SQL ne fonctionnent PAS - voici la vraie solution

---

## 🚨 Le Problème

La table `storage.objects` est **complètement verrouillée** par Supabase et ne peut pas être modifiée:

- ❌ Pas via SQL
- ❌ Pas via API REST
- ❌ Pas via Dart

**Seule solution:** Configurer les policies via l'**interface Supabase** ✅

---

## ✅ Solution: Configuration Manuelle (7 clics, 2 minutes)

### Étape 1: Aller au Dashboard

```
https://app.supabase.com/project/YOUR_PROJECT_ID/storage/buckets
```

Remplacez `YOUR_PROJECT_ID` par votre ID Supabase

---

### Étape 2: Cliquer sur le Bucket "documents"

![Screenshot: Cliquez sur documents]

- Storage > Buckets > **documents**

---

### Étape 3: Aller à l'onglet "Policies"

En haut du bucket, voir les onglets:

- Info
- **Policies** ← Cliquer ici
- Objects

---

### Étape 4: Créer les 4 Policies

#### 🔹 POLICY 1: INSERT (Permettre l'upload)

1. Cliquez **"New Policy"**
2. Sélectionnez **"For INSERT"**
3. Remplissez:
   ```
   Policy Name: Allow authenticated users to upload
   Roles: authenticated
   WITH CHECK: (bucket_id = 'documents')
   ```
4. Cliquez **"Save"**

---

#### 🔹 POLICY 2: SELECT (Permettre la lecture)

1. Cliquez **"New Policy"**
2. Sélectionnez **"For SELECT"**
3. Remplissez:
   ```
   Policy Name: Allow public read access
   Roles: public
   USING: (bucket_id = 'documents')
   ```
4. Cliquez **"Save"**

---

#### 🔹 POLICY 3: DELETE (Permettre la suppression)

1. Cliquez **"New Policy"**
2. Sélectionnez **"For DELETE"**
3. Remplissez:
   ```
   Policy Name: Allow authenticated users to delete own files
   Roles: authenticated
   USING: (bucket_id = 'documents' AND owner_id = auth.uid())
   ```
4. Cliquez **"Save"**

---

#### 🔹 POLICY 4: UPDATE (Permettre la modification)

1. Cliquez **"New Policy"**
2. Sélectionnez **"For UPDATE"**
3. Remplissez:
   ```
   Policy Name: Allow authenticated users to update own files
   Roles: authenticated
   USING: (bucket_id = 'documents' AND owner_id = auth.uid())
   WITH CHECK: (bucket_id = 'documents' AND owner_id = auth.uid())
   ```
4. Cliquez **"Save"**

---

## 🌐 Étape 5: Configurer CORS

1. Allez à: **Settings** (en bas du menu) > **API**
2. Cherchez: **"CORS allow-listed origins"**
3. Ajoutez les origines:
   ```
   http://localhost:*
   https://foncira.app
   https://*.lovable.app
   https://*.vercel.app
   ```
4. Cliquez **"Update"**

---

## 🧪 Étape 6: Tester

### Test 1: Vérifier les policies

```sql
SELECT policyname, permissive
FROM pg_policies
WHERE tablename = 'objects'
  AND schemaname = 'storage';
```

**Résultat attendu:** 4 policies créées ✅

### Test 2: Compiler et tester l'app

```bash
flutter run
```

1. **Mode Vendeur**
2. **Publier un terrain**
3. **Ajouter des photos**
4. **Sélectionner une photo**

**Résultat attendu:** Photo ajoutée avec succès ✅

### Test 3: Vérifier les fichiers

```sql
SELECT name, size, created_at
FROM storage.objects
WHERE bucket_id = 'documents'
ORDER BY created_at DESC;
```

**Résultat attendu:** Fichiers uploadés ✅

---

## 📋 Checklist Final

| Étape                        | Statut |
| ---------------------------- | ------ |
| Bucket 'documents' créé      | ✅     |
| Policy INSERT créée          | ⏳     |
| Policy SELECT créée          | ⏳     |
| Policy DELETE créée          | ⏳     |
| Policy UPDATE créée          | ⏳     |
| CORS configuré               | ⏳     |
| Permissions Android ajoutées | ✅     |
| Runtime permission check     | ✅     |
| Error handling amélioré      | ✅     |
| App compilée                 | ⏳     |
| Photo uploadée               | ⏳     |

---

## 🆘 Dépannage

### Erreur: "Bucket not found"

```
❌ Bucket 'documents' n'existe pas
✅ Solution: Créer le bucket dans Storage
```

### Erreur: "Permission denied"

```
❌ Policy INSERT n'existe pas
✅ Solution: Créer Policy INSERT (voir étape 4.1)
```

### Erreur: "CORS blocked"

```
❌ Origines CORS pas configurées
✅ Solution: Ajouter origines dans Settings > API > CORS
```

### L'upload fonctionne mais l'URL est vide

```
❌ Policy SELECT pas créée
✅ Solution: Créer Policy SELECT (voir étape 4.2)
```

---

## 📚 Fichiers Associés

| Fichier                             | Description                                 | Statut          |
| ----------------------------------- | ------------------------------------------- | --------------- |
| `setup_storage_policies.sql`        | ❌ Ne fonctionne pas (référence uniquement) | Deprecated      |
| `setup_supabase_storage.ps1`        | PowerShell pour créer le bucket             | ✅ Utiliser     |
| `setup_supabase_storage.dart`       | Dart pour tester l'upload                   | ✅ Utiliser     |
| `SUPABASE_STORAGE_CONFIG.md`        | Configuration ancienne                      | ⚠️ À ignorer    |
| `SUPABASE_STORAGE_MANUAL_CONFIG.md` | **CETTE PAGE** - Vraie solution             | ✅ **À SUIVRE** |

---

## 🎯 Résumé

**Avant:**

```
SQL → ❌ Impossible (table verrouillée)
API → ❌ Impossible (table verrouillée)
Dart → ❌ Impossible (table verrouillée)
```

**Maintenant:**

```
Interface Supabase → ✅ Fonctionne (7 clics)
```

**Temps:** 2-3 minutes max ⏱️

---

## 📞 Configuration Complète (Résumé)

### ✅ Ce qui a été fait:

- ✅ Database schema créée et corrigée
- ✅ Permissions Android déclarées
- ✅ Runtime permission check ajouté
- ✅ Error handling amélioré
- ✅ Bucket 'documents' créé

### ⏳ À faire maintenant (manuel):

- ⏳ Créer 4 policies via Supabase Dashboard (2 min)
- ⏳ Configurer CORS (1 min)
- ⏳ Tester l'upload (1 min)

**Total: 4 minutes** ⏱️

---

_Document généré: 7 Avril 2026_  
_Version: 2.0 (Corrigée)_  
_Status: ✅ SOLUTION FINALE_
