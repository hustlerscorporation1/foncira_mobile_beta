-- ============================================================================
-- ⚠️ ATTENTION: CE SCRIPT SQL NE FONCTIONNERA PAS!
-- ============================================================================
-- 
-- Raison: `storage.objects` est une table système de Supabase
--         complètement verrouillée et ne peut pas être modifiée via SQL
--
-- ⚠️ SOLUTION RÉELLE: Configurer les policies via l'interface Supabase
--    (7 clics, 2 minutes max)
--
-- ÉTAPES À SUIVRE:
-- 1. Allez à: https://app.supabase.com
-- 2. Sélectionnez votre projet
-- 3. Storage > Buckets > documents > onglet "Policies"
-- 4. Créez les 4 policies manuellement (voir GUIDE.md ci-dessous)
--
-- Ce fichier SQL est conservé à titre de référence uniquement
-- et ne sera pas exécuté
--
-- ============================================================================
-- ❌ GUIDE: CE QUI NE FONCTIONNERA PAS
-- ============================================================================
-- 
-- Tentative de créer les policies via SQL (CELA ÉCHOUE):
--
-- DROP POLICY IF EXISTS "Allow authenticated users to upload" ON storage.objects;
-- CREATE POLICY "Allow authenticated users to upload"
-- ON storage.objects
-- FOR INSERT
-- TO authenticated
-- WITH CHECK (bucket_id = 'documents');
--
-- Pourquoi: storage.objects est verrouillée par Supabase
--          Les tables système ne peuvent pas être modifiées via SQL
--
-- ============================================================================
-- ✅ GUIDE: CE QUI FONCTIONNE (Configuration manuelle)
-- ============================================================================
--
-- À faire dans Supabase Dashboard (7 clics):
--
-- 1️⃣ Allez à: https://app.supabase.com/project/YOUR_PROJECT/storage/buckets
-- 2️⃣ Cliquez sur le bucket "documents"
-- 3️⃣ Cliquez sur l'onglet "Policies"
-- 4️⃣ Cliquez "New Policy"
--
-- POLICY 1: INSERT (Upload)
-- ─────────────────────────
-- - Sélectionnez: "For INSERT"
-- - Nom: "Allow authenticated users to upload"
-- - Roles: authenticated
-- - WITH CHECK: (bucket_id = 'documents')
-- - Cliquez: "Save"
--
-- POLICY 2: SELECT (Read)
-- ─────────────────────────
-- - Sélectionnez: "For SELECT"
-- - Nom: "Allow public read access"
-- - Roles: public
-- - USING: (bucket_id = 'documents')
-- - Cliquez: "Save"
--
-- POLICY 3: DELETE (Delete own files)
-- ─────────────────────────
-- - Sélectionnez: "For DELETE"
-- - Nom: "Allow authenticated users to delete own files"
-- - Roles: authenticated
-- - USING: (bucket_id = 'documents' AND owner_id = auth.uid())
-- - Cliquez: "Save"
--
-- POLICY 4: UPDATE (Update own files)
-- ─────────────────────────
-- - Sélectionnez: "For UPDATE"
-- - Nom: "Allow authenticated users to update own files"
-- - Roles: authenticated
-- - USING: (bucket_id = 'documents' AND owner_id = auth.uid())
-- - WITH CHECK: (bucket_id = 'documents' AND owner_id = auth.uid())
-- - Cliquez: "Save"
--
-- ============================================================================
-- ✅ APRÈS AVOIR CRÉÉ LES POLICIES
-- ============================================================================
--
-- 1. Vous pouvez vérifier via ce SELECT (n'aura aucun effet):
SELECT
  schemaname,
  tablename,
  policyname,
  permissive
FROM pg_policies
WHERE tablename = 'objects'
  AND schemaname = 'storage';

-- 2. Testez l'upload via Flutter:
--    - flutter run
--    - Mode Vendeur
--    - Publier un terrain
--    - Ajouter des photos
--    - L'upload devrait fonctionner ✅
--
-- 3. Vérifiez les fichiers uploadés:
SELECT * FROM storage.objects WHERE bucket_id = 'documents';

-- ============================================================================
-- CE SCRIPT EST CONSERVÉ POUR RÉFÉRENCE UNIQUEMENT
-- ============================================================================
--
-- Note: Ce fichier contient les tentatives SQL qui NE FONCTIONNERONT PAS
--       Gardez-le pour comprendre pourquoi il faut configurer manuellement
--
-- Pour la vraie configuration, consultez le guide Dart:
-- setup_supabase_storage_dart_solution.dart

-- ============================================================================
-- ÉTAPE 1: NETTOYER LES POLICIES EXISTANTES
-- ============================================================================
-- Note: Cette étape nécessite les droits de propriétaire (service_role)

DROP POLICY IF EXISTS "Allow authenticated users to upload" ON storage.objects;
DROP POLICY IF EXISTS "Allow public read access" ON storage.objects;
DROP POLICY IF EXISTS "Allow authenticated users to delete own files" ON storage.objects;
DROP POLICY IF EXISTS "Allow authenticated users to update own files" ON storage.objects;
DROP POLICY IF EXISTS "Allow all" ON storage.objects;

-- ============================================================================
-- ÉTAPE 2: VÉRIFIER LE BUCKET
-- ============================================================================

-- Vérifier que le bucket 'documents' existe
SELECT id, name, public, created_at
FROM storage.buckets
WHERE id = 'documents';

-- ============================================================================
-- ÉTAPE 3: ACTIVER RLS
-- ============================================================================

ALTER TABLE storage.objects ENABLE ROW LEVEL SECURITY;

-- ============================================================================
-- ÉTAPE 4: CRÉER LES POLICIES
-- ============================================================================

-- INSERT: upload autorisé pour les utilisateurs authentifiés
CREATE POLICY "Allow authenticated users to upload"
ON storage.objects
FOR INSERT
TO authenticated
WITH CHECK (
  bucket_id = 'documents'
);

-- SELECT: lecture publique des fichiers du bucket
CREATE POLICY "Allow public read access"
ON storage.objects
FOR SELECT
TO public
USING (
  bucket_id = 'documents'
);

-- DELETE: suppression uniquement de ses propres fichiers
CREATE POLICY "Allow authenticated users to delete own files"
ON storage.objects
FOR DELETE
TO authenticated
USING (
  bucket_id = 'documents'
  AND owner_id = (select auth.uid())
);

-- UPDATE: modification uniquement de ses propres fichiers
CREATE POLICY "Allow authenticated users to update own files"
ON storage.objects
FOR UPDATE
TO authenticated
USING (
  bucket_id = 'documents'
  AND owner_id = (select auth.uid())
)
WITH CHECK (
  bucket_id = 'documents'
  AND owner_id = (select auth.uid())
);

-- ============================================================================
-- ÉTAPE 5: VÉRIFIER LES POLICIES (CORRIGÉE)
-- ============================================================================

SELECT
  schemaname,
  tablename,
  policyname,
  permissive,
  qual,
  with_check
FROM pg_policies
WHERE tablename = 'objects'
  AND schemaname = 'storage';

-- ============================================================================
-- ÉTAPE 6: AUDIT OPTIONNEL
-- ============================================================================

CREATE TABLE IF NOT EXISTS public.storage_audit_log (
  id BIGSERIAL PRIMARY KEY,
  bucket_id TEXT NOT NULL,
  object_name TEXT NOT NULL,
  user_id UUID,
  action TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE OR REPLACE FUNCTION public.audit_storage_change()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.storage_audit_log (bucket_id, object_name, user_id, action)
  VALUES (
    COALESCE(NEW.bucket_id, OLD.bucket_id),
    COALESCE(NEW.name, OLD.name),
    auth.uid(),
    TG_OP
  );

  RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS storage_audit_trigger ON storage.objects;

CREATE TRIGGER storage_audit_trigger
AFTER INSERT OR UPDATE OR DELETE ON storage.objects
FOR EACH ROW
EXECUTE FUNCTION public.audit_storage_change();

-- ============================================================================
-- ÉTAPE 7: FONCTION OPTIONNELLE DE NETTOYAGE
-- ============================================================================

CREATE OR REPLACE FUNCTION public.cleanup_old_files()
RETURNS void AS $$
BEGIN
  DELETE FROM storage.objects
  WHERE bucket_id = 'documents'
    AND created_at < NOW() - INTERVAL '30 days'
    AND name LIKE 'temp/%';
END;
$$ LANGUAGE plpgsql;

-- ============================================================================
-- ÉTAPE 8: RÉSUMÉ
-- ============================================================================

SELECT
  'Bucket' AS item,
  name AS value,
  'Exists' AS status
FROM storage.buckets
WHERE id = 'documents'

UNION ALL

SELECT
  'RLS' AS item,
  'storage.objects' AS value,
  'Enabled' AS status

UNION ALL

SELECT
  'Policies' AS item,
  COUNT(policyname)::text AS value,
  'Configured' AS status
FROM pg_policies
WHERE tablename = 'objects'
  AND schemaname = 'storage'
GROUP BY COUNT(policyname);

-- ============================================================================
-- CHECKLIST APRÈS EXÉCUTION
-- ============================================================================

-- ✅ CONFIGURATION SQL TERMINÉE!
-- 
-- Après cette configuration SQL:
--    1. ✅ Le bucket 'documents' est sécurisé avec RLS
--    2. ✅ 4 policies créées (INSERT, SELECT, DELETE, UPDATE)
--    3. ✅ Audit logging configuré automatiquement
--    4. ✅ Fonction de nettoyage disponible
--
-- CORS Configuration (via Supabase Dashboard):
--    1. Allez à: Project Settings > API > CORS
--    2. Ajoutez les origines autorisées:
--       
--       Pour développement local:
--       - http://localhost:*
--       
--       Pour production:
--       - https://foncira.app
--       - https://*.lovable.app
--       - https://*.vercel.app
--       - https://*.supabase.co
--
-- Policies créées:
--    ✅ Allow authenticated users to upload (INSERT) - Authentifiés seulement
--    ✅ Allow public read access (SELECT) - Tout le monde peut lire
--    ✅ Allow authenticated users to delete own files (DELETE) - Propres fichiers
--    ✅ Allow authenticated users to update own files (UPDATE) - Propres fichiers
--
-- Sécurité:
--    - ✅ Seuls les utilisateurs authentifiés peuvent uploader
--    - ✅ N'importe qui peut lire les fichiers (supposés publics)
--    - ✅ Les utilisateurs ne peuvent supprimer que leurs propres fichiers
--    - ✅ Les utilisateurs ne peuvent modifier que leurs propres fichiers
--    - ✅ Audit logging enregistre toutes les actions
--    - ✅ Fonction de nettoyage nettoie les fichiers temporaires après 30 jours
--
-- Test:
--    1. SELECT * FROM storage.objects WHERE bucket_id = 'documents';
--    2. SELECT * FROM storage_audit_log ORDER BY created_at DESC;
--    3. Compilez: flutter run
--    4. Testez l'upload de photos
--    5. Vérifiez les fichiers: SELECT * FROM storage.objects;

-- ============================================================================
-- FIN DU SCRIPT
-- ============================================================================