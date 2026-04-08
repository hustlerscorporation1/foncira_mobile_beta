# 🔍 DIAGNOSTIC: Upload des Photos - État Actuel

**Date:** 7 Avril 2026  
**Statut:** ⚠️ **PROBLÈMES DÉTECTÉS**

---

## 📋 RÉSUMÉ

L'upload de photos est **partiellement possible**, mais il y a **3 problèmes critiques** qui l'empêchent de fonctionner correctement:

| Problème                           | Contexte            | Gravitée    | Statut          |
| ---------------------------------- | ------------------- | ----------- | --------------- |
| **Permissions Android manquantes** | AndroidManifest.xml | 🔴 CRITIQUE | ❌ À corriger   |
| **Bucket Supabase non configuré**  | Storage             | 🔴 CRITIQUE | ❌ À vérifier   |
| **Permissions CORS non définies**  | Supabase            | 🔴 CRITIQUE | ❌ À configurer |

---

## 🔴 PROBLÈME 1: Permissions Android Manquantes

### Situation actuelle:

Le fichier `android/app/src/main/AndroidManifest.xml` ne contient **PAS** les permissions d'accès aux photos.

### Conséquence:

- ❌ Sur **Android 6.0+**: Crash à l'appel de `ImagePicker.pickMultiImage()`
- ❌ Sur **Android 13+**: Besoin de `READ_MEDIA_IMAGES` (pas de `READ_EXTERNAL_STORAGE`)

### Permissions requises:

```xml
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.READ_MEDIA_IMAGES" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
```

**Solution:** Ajouter les permissions dans AndroidManifest.xml

---

## 🔴 PROBLÈME 2: Bucket Supabase 'documents' Non Configuré

### Situation actuelle:

Le code utilise:

```dart
await _supabase.client.storage.from('documents').upload(path, file);
```

### Problème:

- ❌ Le bucket `documents` doit exister dans Supabase Storage
- ❌ Si le bucket n'existe pas → `ERROR: Bucket not found`
- ❌ Les buckets nécessitent une configuration RLS (Row Level Security)

### Solution:

1. Aller à Supabase Dashboard → Storage
2. Créer un bucket `documents` (si absent)
3. Configurer les permissions d'accès:
   ```
   Public or Authenticated users can upload files
   ```

---

## 🔴 PROBLÈME 3: CORS Non Configuré

### Situation actuelle:

Le bucket Supabase n'a pas d'origines CORS autorisées pour les uploads depuis Flutter/Web.

### Problème:

- ❌ Erreur: `CORS policy: No 'Access-Control-Allow-Origin' header`
- ❌ Les uploads échouent depuis le navigateur/mobile

### Configuration CORS requise:

Pour le bucket `documents`, ajouter les origines:

```
http://localhost:*
https://*.lovable.app
https://*.vercel.app
https://votre-domaine.com
```

---

## ✅ CODE ACTUEL (Fonctional Structure)

### 1. ImagePicker (Dart) ✅

```dart
final picker = ImagePicker();
final pickedFiles = await picker.pickMultiImage();
```

**État:** ✅ Fonctionne SAUF si les permissions manquent

### 2. Upload vers Supabase (Dart) ✅

```dart
await _supabase.client.storage
    .from('documents')
    .upload(path, file);
```

**État:** ✅ Fonctionne SI le bucket existe et CORS est configuré

### 3. Gestion des photos (PublishState) ✅

```dart
final newUrls = <String>[];
for (final file in filesToUpload) {
  final uploadedUrl = await _publishService.uploadPhoto(
    File(file.path),
    file.name,
  );
  newUrls.add(uploadedUrl);
}
```

**État:** ✅ Logique correcte

---

## 🛠️ ÉTAPES POUR CORRIGER

### Étape 1: Ajouter les Permissions Android (Dart code)

**Lieu:** `android/app/src/main/AndroidManifest.xml`

Ajouter AVANT la balise `</manifest>`:

```xml
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.READ_MEDIA_IMAGES" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
```

### Étape 2: Demander les Permissions au Runtime (Dart code)

**Amélioration du `_pickPhotos()` dans `home_page.dart`:**

Ajouter avant `picker.pickMultiImage()`:

```dart
final status = await Permission.photos.request();
if (!status.isGranted) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Permission photos refusée')),
  );
  return;
}
```

### Étape 3: Configurer Supabase Storage

Dans Supabase Dashboard:

1. Aller à **Storage**
2. Vérifier/Créer un bucket nommé `documents`
3. Configurer les permissions:
   - Public: Oui (pour les uploads)
   - Authentifié: Oui

### Étape 4: Configurer CORS Supabase

Dans Supabase Dashboard → Storage → Settings:

```
CORS Origins:
- http://localhost:*
- https://*.lovable.app
- https://*.vercel.app
```

---

## 📊 MATRICE DE FONCTIONNALITÉ

| Plateforme  | ImagePicker                 | Upload               | Photos | Statut             |
| ----------- | --------------------------- | -------------------- | ------ | ------------------ |
| **Android** | ⚠️ Permissions manquantes   | ❌ Bucket non config | ❌     | ❌ Non-fonctionnel |
| **iOS**     | ✅ Info.plist OK (probable) | ❌ Bucket non config | ❌     | ⚠️ Partiellement   |
| **Web**     | ✅ Fonctionne               | ❌ CORS manquant     | ❌     | ⚠️ Partiellement   |

---

## 🔧 SOLUTION COMPLÈTE À APPLIQUER

### A. Corriger les Permissions Android

- [x] Ajouter les permissions dans AndroidManifest.xml
- [x] Ajouter la vérification des permissions au runtime dans `_pickPhotos()`

### B. Configurer Supabase

- [ ] Créer/Vérifier le bucket `documents`
- [ ] Configurer les permissions du bucket
- [ ] Ajouter les origines CORS

### C. Tester l'Upload

- [ ] Tester sur Android
- [ ] Tester sur iOS
- [ ] Tester sur Web

---

## 💡 RECOMMANDATIONS

1. **Priorité 1:** Ajouter les permissions Android (critique)
2. **Priorité 2:** Configurer Supabase Storage
3. **Priorité 3:** Améliorer la gestion des erreurs upload

---

**Prochaine étape:** Appliquer la solution complète?
