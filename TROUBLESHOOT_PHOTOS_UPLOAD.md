# 🔧 GUIDE DÉPANNAGE: Upload Photos ne Fonctionne Pas

**Date:** 7 Avril 2026  
**Problème:** Après sélection des photos, rien ne change sur l'écran

---

## 🎯 Diagnostic Rapide

### ✅ Photos Améliorées (Vient d'être fixé!)

J'ai amélioré le code pour afficher **des messages clairs** à chaque étape:

```
1. Photo sélectionnée → "📸 Photos sélectionnées: X"
2. Upload en cours → "📤 Upload en cours..."
3. Upload réussi → "✅ X photo(s) ajoutée(s)"
4. Upload échoué → "❌ Erreur : Impossible d'uploader les photos"
                   + Instructions de dépannage
```

Les logs détaillés s'affichent aussi dans la console Flutter.

---

## 🔍 Causes Possibles (Ordre de Probabilité)

### ❌ 1: Supabase Storage n'est pas Configuré (80% de probabilité)

**Symptômes:**

- Les photos sont sélectionnées
- Message d'erreur: "Impossible d'uploader les photos"
- Console: "404 not found" ou "Permission denied"

**Solution:**

```
→ Voir: SUPABASE_STORAGE_MANUAL_CONFIG.md
→ Étapes:
  1. Créer bucket 'documents'
  2. Créer 4 policies RLS
  3. Configurer CORS
  4. Tester l'upload
```

---

### ❌ 2: Bucket Existe Mais Pas de Policies RLS (15% de probabilité)

**Symptômes:**

- Photos sélectionnées
- Message: "Permission denied" ou "Unauthorized"
- Console: "403 Forbidden"

**Solution:**

```
1. Allez à: Supabase > Storage > documents > Policies
2. Vérifiez qu'il y a 4 policies:
   ✅ Allow authenticated users to upload (INSERT)
   ✅ Allow public read access (SELECT)
   ✅ Allow authenticated users to delete own files (DELETE)
   ✅ Allow authenticated users to update own files (UPDATE)

3. Si manquantes → Les créer (voir SUPABASE_STORAGE_MANUAL_CONFIG.md)
```

---

### ❌ 3: Utilisateur Pas Connecté (3% de probabilité)

**Symptômes:**

- Message: "User not authenticated"
- Console: Erreur `currentUserId is null`

**Solution:**

```
1. Allez à: Profil
2. Connectez-vous ou créez un compte vendeur
3. Retournez à: Publier > Ajouter des photos
4. Réessayez l'upload
```

---

### ❌ 4: CORS Non Configuré (1% de probabilité)

**Symptômes:**

- Photos sélectionnées
- Message: "CORS blocked" ou "Cross-Origin Request Blocked"
- Console: "Access-Control-Allow-Origin header missing"

**Solution:**

```
1. Allez à: Supabase > Settings > API > CORS
2. Ajoutez les origines:
   - http://localhost:*
   - https://*.lovable.app
   - https://*.vercel.app
3. Cliquez: Update
4. Réessayez l'upload
```

---

## 🧪 Étapes de Dépannage (Ordre Recommandé)

### Étape 1: Vérifier Supabase Connection

```dart
// Ouvrir DevTools Flutter (F12) → Console
// Vérifier le tag [INFO] de l'app:

[INFO] Supabase initialized: https://XXXXX.supabase.co
[INFO] Current user: user-uuid-123
```

**Si absent:**

```
❌ Supabase n'est pas initialisé
→ Vérifier main.dart > Supabase.initialize()
```

---

### Étape 2: Vérifier le Bucket Existe

**Via SQL (Supabase Dashboard > SQL):**

```sql
SELECT id, name, public
FROM storage.buckets
WHERE id = 'documents';
```

**Résultat attendu:**

```
id          | name      | public
documents   | documents | true
```

**Si absent:**

```
❌ Bucket 'documents' n'existe pas
→ Créer via Supabase Storage Dashboard
   Storage > New Bucket > Name: documents > Public: ON
```

---

### Étape 3: Vérifier les Policies

**Via SQL:**

```sql
SELECT policyname, permissive, roles
FROM pg_policies
WHERE tablename = 'objects' AND schemaname = 'storage'
ORDER BY policyname;
```

**Résultat attendu:**

```
policyname                                    | permissive | roles
Allow authenticated users to delete own f...  | true       | {authenticated}
Allow authenticated users to update own f...  | true       | {authenticated}
Allow authenticated users to upload           | true       | {authenticated}
Allow public read access                      | true       | {public}
```

**Si < 4 policies:**

```
❌ Policies manquantes
→ Les créer via Supabase Dashboard
   Storage > documents > Policies > New Policy
   (Voir SUPABASE_STORAGE_MANUAL_CONFIG.md pour les détails)
```

---

### Étape 4: Tester Upload Direct

**Via Supabase Dashboard:**

```
1. Storage > documents > Upload
2. Choisir une photo
3. L'image s'affiche immédiatement?
   ✅ Bucket fonctionne
   ❌ Bucket brisé → Recréer
```

---

### Étape 5: Tester Upload via l'App

```
1. flutter run
2. Mode Vendeur
3. Publier un terrain > Ajouter des photos
4. Sélectionner 1-2 photos
5. Vérifier les logs:

   ✅ "✅ Photo uploadée" → OK!
   ❌ "❌ Erreur upload photo" → Voir erreur détaillée
```

---

## 🐛 Lire les Erreurs de la Console

Ouvrez **DevTools** (F12) et cherchez des logs comme:

### ✅ Success

```
📸 Photos sélectionnées: 2
⏳ Upload photo: image1.jpg
✅ Photo uploadée: image1.jpg
⏳ Upload photo: image2.jpg
✅ Photo uploadée: image2.jpg
✅ Total: 2 photos ajoutées, 0 échouées
```

### ❌ Failure - Bucket Missing

```
📸 Photos sélectionnées: 2
⏳ Upload photo: image1.jpg
❌ Erreur upload photo image1.jpg: 404 - documents bucket not found
🚨 Aucune photo n'a pu être uploadée
```

**Correction:**

```
→ Créer bucket 'documents' dans Supabase Storage
→ (Voir SUPABASE_STORAGE_MANUAL_CONFIG.md)
```

### ❌ Failure - Permission Denied

```
📸 Photos sélectionnées: 2
⏳ Upload photo: image1.jpg
❌ Erreur upload photo image1.jpg: 403 - Permission denied
🚨 Aucune photo n'a pu être uploadée
```

**Correction:**

```
→ Créer les 4 policies RLS
→ (Voir SUPABASE_STORAGE_MANUAL_CONFIG.md - Étape 4)
```

### ❌ Failure - CORS Error

```
❌ Erreur upload photo image1.jpg: CORS policy blocked...
```

**Correction:**

```
→ Ajouter origines CORS
→ Settings > API > CORS allow-listed origins
```

---

## ✅ Checklist Complet de Configuration

```
□ Bucket 'documents' créé
  Vérifier: Supabase > Storage > documents

□ 4 Policies RLS créées
  Vérifier: SELECT policyname... (voir Étape 3)

□ CORS configuré
  Vérifier: Settings > API > CORS
  Doit contenir: http://localhost:*

□ Utilisateur connecté
  Vérifier: Page > Profil > Connecté?

□ Flutter app compilée
  Commande: flutter run
```

---

## 🚀 Test Complet (Du Début)

### Scénario D'Essai:

```
1. Allez à: Mode Vendeur
2. Cliquez: Publier un terrain
3. Étape 1: Ajouter des photos
4. Cliquez: "Ajouter des photos"
5. Sélectionnez: 3-5 photos du téléphone
6. Attendez: ~10 secondes
7. Résultat attendu:
   ✅ Photos apparaissent dans la grille
   ✅ Compteur: "3/3-8 photos"
   ✅ Bouton d'ajout encore visible
8. Cliquez: Suivant
9. Remplissez: Titre, localisation, superficie, prix
10. Cliquez: Suivant
11. Recherchez sur Supabase:
    SELECT * FROM storage.objects WHERE bucket_id = 'documents';
    → Les fichiers doivent être là!
```

---

## 📞 Si Rien ne Marche

1. **Compiler en mode debug:**

   ```bash
   flutter run -v  # Mode verbeux
   ```

2. **Vérifier les logs complets:**

   ```
   Ouvrir DevTools > Console
   Chercher les messages avec 📸 ⏳ ✅ ❌
   ```

3. **Vérifier Supabase Status:**

   ```
   https://status.supabase.com
   (Supabase down? Réessayer plus tard)
   ```

4. **Vérifier Internet:**

   ```bash
   ping google.com  # Est-ce connecté?
   ```

5. **Vérifier les Clés API:**
   ```
   Supabase > Settings > API
   Copier: Project URL et Anon Key
   Vérifier dans: lib/services/config.dart ou main.dart
   ```

---

## 📊 Status Configurations

| Configuration                | Statut | Action           |
| ---------------------------- | ------ | ---------------- |
| **Bucket**                   | ⏳     | Créer si absent  |
| **Policies INSERT**          | ⏳     | Créer si absent  |
| **Policies SELECT**          | ⏳     | Créer si absent  |
| **Policies DELETE**          | ⏳     | Créer si absent  |
| **Policies UPDATE**          | ⏳     | Créer si absent  |
| **CORS**                     | ⏳     | Ajouter origines |
| **Permissions Android**      | ✅     | Déclarées        |
| **Runtime Permission Check** | ✅     | Implémenté       |
| **Upload Service**           | ✅     | Complet          |
| **Error Messages**           | ✅     | Amélioré         |

---

## 🎯 Prochaine Étape

→ Si configuration Supabase complètement faite: **Tester l'upload**

→ Sinon: **Suivre SUPABASE_STORAGE_MANUAL_CONFIG.md**

---

_Guide généré: 7 Avril 2026_  
_Version: 1.0_  
_Status: ✅ Prêt à utiliser_
