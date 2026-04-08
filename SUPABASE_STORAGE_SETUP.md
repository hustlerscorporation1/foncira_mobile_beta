# 🪣 Configuration Supabase Storage - Guide Complet

## **Étape 1: Accéder à Supabase Studio**

1. Ouvre: https://app.supabase.com
2. Clique sur ton projet: **Agnigbangna**
3. Va à la section **Storage** (icône dossier à gauche)

---

## **Étape 2: Créer le bucket "documents"**

### Option A: Via l'interface (RECOMMANDÉ - 2 clics!)

1. Clique sur **"+ New Bucket"**
2. Nom: **`documents`**
3. Sélectionne **"Public"** ✅
4. Clique **"Create Bucket"**

### Option B: C'est fait! ✅ Si le bucket existe déjà

---

## **Étape 3: Configurer les Policies (RLS)**

1. Clique sur le bucket **"documents"**
2. Va à l'onglet **"Policies"**
3. Ajoute ces 4 policies (clique **"New Policy" > "For SELECT" / "INSERT", etc.**)

### Policy 1: Public Read

```sql
-- Allow anyone to read
CREATE POLICY "Enable public read"
ON storage.objects
FOR SELECT USING (bucket_id = 'documents');
```

### Policy 2: Authenticated Upload

```sql
-- Allow authenticated users to upload
CREATE POLICY "Enable authenticated upload"
ON storage.objects
FOR INSERT WITH CHECK (
  bucket_id = 'documents'
  AND auth.role() = 'authenticated'
);
```

### Policy 3: Authenticated Delete

```sql
-- Allow authenticated users to delete their own uploads
CREATE POLICY "Enable authenticated delete"
ON storage.objects
FOR DELETE USING (
  bucket_id = 'documents'
  AND auth.role() = 'authenticated'
);
```

### Policy 4: Anon Upload (Optionnel)

```sql
-- Allow anonymous users to upload
CREATE POLICY "Enable anon upload"
ON storage.objects
FOR INSERT WITH CHECK (
  bucket_id = 'documents'
  AND auth.role() = 'anon'
);
```

---

## **Étape 4: Configurer le CORS (Crucial!)**

1. Va à **Settings > Storage** (en bas à gauche)
2. Scroll jusqu'à **"CORS allowed origins"**
3. Ajoute ces origines (une par ligne):

```
http://localhost:3000
http://localhost:5173
http://10.0.2.2:5173
http://localhost:8080
*
```

4. Clique **"Save"**

---

## **Étape 5: Vérifier les permissions du bucket**

Clique sur **"documents"** et vérifie:

- ✅ Public: **ON** (allumé)
- ✅ File size limit: **50 MB** (minimum)
- ✅ Allowed MIME types:
  - `image/jpeg`
  - `image/png`
  - `image/gif`
  - `image/webp`

---

## **C'est fait! 🎉**

Les vendeurs peuvent maintenant uploader des photos de terrain sans erreur!

**Test rapide:**

1. Lance l'app Flutter
2. Va à "Publication Terrain"
3. Sélectionne des photos
4. Clique "Uploader"
5. Les photos devraient s'uploader correctement ✅

---

## **Si ça ne marche pas encore:**

### Problème: "Bucket not found"

- Vérifie que le bucket s'appelle exactement **"documents"** (minuscules)
- Confirme qu'il est **Public** ✅

### Problème: "Permission denied"

- Vérifie les policies RLS dans Settings > Storage > Policies
- Assure-toi que SELECT est accessible publiquement

### Problème: "CORS error"

- Vérifie Settings > Storage > CORS
- Ajoute les origines listées ci-dessus

### Problème: Uploads lents

- Vérifie la limite de taille du bucket (minimum 50MB)

---

## **Dashboard Supabase**

Après configuration, tu peux voir:

- 📊 Storage > Buckets > documents
- 📈 Nombre de fichiers uploadés
- 💾 Espace utilisé
