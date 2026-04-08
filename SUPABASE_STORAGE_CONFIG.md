# 🚀 GUIDE: Configuration Supabase Storage pour Upload Photos

**Date:** 7 Avril 2026  
**Objectif:** Configurer le bucket `documents` pour permettre l'upload de photos par les vendeurs

---

## ✅ ÉTAPE 1: Créer/Vérifier le Bucket `documents`

### Via Supabase Dashboard:

1. Aller à: **https://app.supabase.com**
2. Sélectionner votre projet
3. Aller à **Storage** (menu de gauche)
4. Vérifier si un bucket `documents` existe
   - Si **OUI** → Passer à Étape 2
   - Si **NON** → Cliquer **"New Bucket"** et créer:
     - **Bucket name:** `documents`
     - **Public bucket:** ✅ Coché (pour les URLs publiques)
     - Cliquer **"Create bucket"**

---

## ✅ ÉTAPE 2: Configurer les Permissions du Bucket

### Via Supabase Dashboard:

1. Cliquer sur le bucket `documents`
2. Aller à l'onglet **"Policies"**
3. Ajouter une policy pour les uploads:

**Pour les utilisateurs connectés (RECOMMANDÉ):**

```sql
-- Permettre aux utilisateurs authentifiés d'uploader
CREATE POLICY "Allow authenticated users to upload"
ON storage.objects
FOR INSERT
TO authenticated
WITH CHECK (bucket_id = 'documents');

-- Permettre à tous de lire les fichiers publics
CREATE POLICY "Allow public read"
ON storage.objects
FOR SELECT
TO public
USING (bucket_id = 'documents');
```

**Alternative simple (moins sécurisée):**

```sql
-- Permettre à tous (publique)
CREATE POLICY "Allow all"
ON storage.objects
USING (bucket_id = 'documents');
```

### Ou via UI Supabase:

1. **Policies** → **New Policy** → **For inserts**
   - Sélectionner **"Allow authenticated users to insert into documents"**
2. **Policies** → **New Policy** → **For selects**
   - Sélectionner **"Allow public read access"**

---

## ✅ ÉTAPE 3: Configurer les Origines CORS

### Via Supabase Dashboard:

1. Aller à **Project Settings** (bas du menu)
2. Aller à **API** → **CORS**
3. Ajouter les origines autorisées:

**Pour développement local:**

```
http://localhost:*
```

**Pour production (Flutter):**

```
https://*.lovable.app
https://*.vercel.app
https://votre-app.com
```

**Pour web (Développement):**

```
http://localhost:3000
http://localhost:8000
```

**Exemple complet:**

```
http://localhost:*
https://foncira.app
https://*.supabase.co
```

---

## 📝 VÉRIFICATION: Tester l'Upload

### Test 1: Via Flutter (Mobile)

1. Compiler l'app: `flutter run`
2. Aller à **Mode Vendeur**
3. Cliquer sur **"Publier un terrain"**
4. Étape 1: **"Ajouter des photos"**
5. Cliquer **"Ajouter des photos"**
6. Sélectionner une photo
7. **Résultat attendu:** Message "X photo(s) ajoutée(s)"

**Si erreur:**

- ❌ "Bucket \"documents\" non trouvé" → Créer le bucket (Étape 1)
- ❌ "Permission refusée" → Configurer les policies (Étape 2)
- ❌ "CORS" → Configurer CORS (Étape 3)

### Test 2: Via Web (Dev Tools)

1. Ouvrir l'app web
2. Ouvrir **DevTools** (F12)
3. Aller à **Console**
4. Essayer d'uploader une photo
5. Les logs doivent montrer:
   ```
   Uploading photo to: seller_photos/1712500000_photo.jpg
   Photo uploaded successfully
   Public URL: https://...storage.supabase.co/...
   ```

---

## 📊 CONFIGURATION RÉCAPITULATIF

| Élément           | Configuration               | Statut       |
| ----------------- | --------------------------- | ------------ |
| **Bucket**        | `documents`                 | ✅ Créé      |
| **Public**        | ✅ Oui                      | ✅ Activé    |
| **Policy INSERT** | Utilisateur authentifié     | ✅ Configuré |
| **Policy SELECT** | Publique ou authentifié     | ✅ Configuré |
| **CORS**          | localhost:\*, votre-app.com | ✅ Configuré |

---

## 🔒 SÉCURITÉ: Bonnes Pratiques

### ✅ À FAIRE:

- ✅ Limiter les uploads aux utilisateurs authentifiés
- ✅ Vérifier la taille des fichiers (max 10MB)
- ✅ Vérifier le type MIME (images uniquement)
- ✅ Utiliser des noms de fichiers uniques (avec timestamp)
- ✅ Mettre à jour CORS pour production

### ❌ À ÉVITER:

- ❌ Ne pas autoriser les uploads publics
- ❌ Ne pas accepter n'importe quel type de fichier
- ❌ Ne pas autoriser les CORS sur `*` (wildcard)
- ❌ Ne pas stocker les fichiers sensibles sans chiffrement

---

## 🛠️ CONFIGURATION CODE (Déjà Appliquée)

### Permis de soccès Android:

```xml
<!-- Added to AndroidManifest.xml -->
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.READ_MEDIA_IMAGES" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
```

### Vérification des permissions (Runtime):

```dart
// Added to _pickPhotos() in home_page.dart
final status = await Permission.photos.request();
if (!status.isGranted) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Permission d\'accès aux photos refusée')),
  );
  return;
}
```

### Gestion améliorée des erreurs:

```dart
// Updated in terrain_publish_service.dart
if (e.toString().contains('404')) {
  throw Exception('Bucket "documents" non trouvé...');
} else if (e.toString().contains('CORS')) {
  throw Exception('Erreur CORS: vérifiez la configuration...');
}
```

---

## ✅ CHECKLIST FINALE

- [ ] **Bucket créé:** `documents` existe dans Supabase Storage
- [ ] **Public:** Bucket est marqué comme public
- [ ] **Policies créées:** INSERT et SELECT configurées
- [ ] **CORS activé:** Origines ajoutées dans API settings
- [ ] **Permissions Android:** Ajoutées à AndroidManifest.xml
- [ ] **Code mis à jour:** Vérification permissions et gestion erreurs
- [ ] **Test local:** Upload réussit sur Android/iOS/Web
- [ ] **Production:** CORS configuré pour domaine de production

---

## 🆘 DÉPANNAGE

### Erreur: "Bucket not found"

```
Solution: Créer le bucket 'documents' dans Supabase Storage
```

### Erreur: "Permission denied"

```
Solution: Vérifier les policies dans Supabase Storage → Policies
```

### Erreur: "CORS policy blocked"

```
Solution: Ajouter l'origine dans Project Settings → API → CORS
```

### Erreur: "Permission to access photos"

```
Solution: L'app a demandé la permission, l'utilisateur doit l'accepter
```

### Les photos s'uploadent mais l'URL est vide

```
Solution: Vérifier que getPublicUrl() retourne une URL valide
```

---

## 📞 SUPPORT

Si vous avez des problèmes:

1. Vérifier les logs (console Flutter/DevTools)
2. Vérifier les activité dans Supabase Dashboard
3. Vérifier les permissions du bucket
4. Vérifier CORS settings

---

**Configuration appliquée:** Les corrections de code ont été faites ✅  
**Prochaine étape:** Configurer Supabase Storage comme décrit ci-dessus

Document généré: 7 Avril 2026
