-- ══════════════════════════════════════════════════════════════════════════════
-- Supabase Storage Configuration - SQL Script
-- 
-- Instructions:
-- 1. Va à: https://app.supabase.com > Agnigbangna > SQL Editor
-- 2. Crée une nouvelle query
-- 3. Copie-colle ce contenu entier
-- 4. Clique "Run"
-- 5. Attend que tout soit "Success" ✅
-- ══════════════════════════════════════════════════════════════════════════════

-- ─────────────────────────────────────────────────────────────────────────────
-- STEP 1: Créer les policies RLS pour le bucket "documents"
-- ─────────────────────────────────────────────────────────────────────────────

-- Policy 1: Lecture publique
CREATE POLICY "Enable public read on documents"
ON storage.objects
FOR SELECT
USING (bucket_id = 'documents');

-- Policy 2: Upload pour utilisateurs authentifiés
CREATE POLICY "Enable authenticated insert on documents"
ON storage.objects
FOR INSERT
WITH CHECK (
  bucket_id = 'documents' 
  AND auth.role() = 'authenticated'
);

-- Policy 3: Suppression pour utilisateurs authentifiés
CREATE POLICY "Enable authenticated delete on documents"
ON storage.objects
FOR DELETE
USING (
  bucket_id = 'documents' 
  AND auth.role() = 'authenticated'
);

-- Policy 4: Upload pour utilisateurs anonymes (optionnel)
CREATE POLICY "Enable anon insert on documents"
ON storage.objects
FOR INSERT
WITH CHECK (
  bucket_id = 'documents' 
  AND auth.role() = 'anon'
);

-- ─────────────────────────────────────────────────────────────────────────────
-- STEP 2: Vérifier les policies créées
-- ─────────────────────────────────────────────────────────────────────────────

-- Affiche tous les policies du bucket "documents"
SELECT 
  name,
  definition,
  action,
  created_at
FROM pg_policies
WHERE schemaname = 'storage' 
  AND tablename = 'objects'
ORDER BY created_at DESC;

-- ─────────────────────────────────────────────────────────────────────────────
-- STEP 3: Vérifier les métadonnées du bucket
-- ─────────────────────────────────────────────────────────────────────────────

-- Affiche les détails du bucket
SELECT 
  id,
  name,
  owner,
  public,
  created_at,
  updated_at
FROM storage.buckets
WHERE name = 'documents';

-- ─────────────────────────────────────────────────────────────────────────────
-- NOTES IMPORTANTES
-- ─────────────────────────────────────────────────────────────────────────────
-- 
-- Si tu vois des erreurs comme:
-- - "policy xyz already exists" → C'est OK! Les policies existent déjà
-- - "bucket not found" → Crée le bucket manuellement via l'interface Supabase
-- 
-- Après exécution, va à Storage > documents et vérifie:
-- ✅ Public: ON (allumé)
-- ✅ Policies: 4 policies actives
-- ✅ CORS: Configuré dans Settings > Storage
-- 
-- ─────────────────────────────────────────────────────────────────────────────
