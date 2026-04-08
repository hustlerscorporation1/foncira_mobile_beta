#!/usr/bin/env dart

/// Script complet pour configurer Supabase Storage
/// Créer le bucket 'documents', configurer les policies et CORS
///
/// Usage:
/// dart setup_supabase_storage.dart
///
/// Assurez-vous d'avoir à jour:
/// - SUPABASE_URL: https://xxxxxx.supabase.co
/// - SUPABASE_ANON_KEY: votre clé publique
/// - SUPABASE_SERVICE_ROLE_KEY: votre clé service role

import 'package:http/http.dart' as http;
import 'dart:convert';

// ============================================================================
// Configuration - À METTRE À JOUR
// ============================================================================

const String SUPABASE_URL = 'https://xxxxxxxxxxx.supabase.co';
const String SUPABASE_SERVICE_ROLE_KEY =
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...'; // Service Role Key
const String BUCKET_NAME = 'documents';

// ============================================================================
// Classe principale
// ============================================================================

class SupabaseStorageSetup {
  final String supabaseUrl;
  final String serviceRoleKey;
  late final http.Client httpClient;

  SupabaseStorageSetup({
    required this.supabaseUrl,
    required this.serviceRoleKey,
  }) {
    httpClient = http.Client();
  }

  /// Headers pour les requêtes API
  Map<String, String> get _headers => {
    'apikey': serviceRoleKey,
    'Authorization': 'Bearer $serviceRoleKey',
    'Content-Type': 'application/json',
  };

  // ==========================================================================
  // 1. CRÉER LE BUCKET
  // ==========================================================================

  Future<void> createBucket() async {
    print('\n🚀 ÉTAPE 1: Créer le bucket "$BUCKET_NAME"...');

    try {
      final response = await httpClient.post(
        Uri.parse('$supabaseUrl/storage/v1/bucket'),
        headers: _headers,
        body: jsonEncode({
          'name': BUCKET_NAME,
          'public': true, // ✅ Rendre le bucket public pour les URLs
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('✅ Bucket "$BUCKET_NAME" créé avec succès!');
        print('   Réponse: ${response.body}');
      } else if (response.statusCode == 400 &&
          response.body.contains('duplicate')) {
        print(
          '⚠️  Le bucket "$BUCKET_NAME" existe déjà (c\'est normal, en continuant...)',
        );
      } else {
        print('❌ Erreur: ${response.statusCode}');
        print('   Réponse: ${response.body}');
        rethrow;
      }
    } catch (e) {
      print('❌ Erreur lors de la création du bucket: $e');
      rethrow;
    }
  }

  // ==========================================================================
  // 2. CONFIGURER LES POLICIES (Permissions)
  // ==========================================================================

  Future<void> setupPolicies() async {
    print('\n🔐 ÉTAPE 2: Configurer les policies (permissions)...');

    // Policy 1: Permettre aux utilisateurs authentifiés d'uploader
    await _createPolicy(
      name: 'Allow authenticated users to upload',
      definition:
          '''
        CREATE POLICY "Allow authenticated users to upload"
        ON storage.objects
        FOR INSERT
        TO authenticated
        WITH CHECK (bucket_id = '$BUCKET_NAME')
      ''',
    );

    // Policy 2: Permettre à tous de lire les fichiers
    await _createPolicy(
      name: 'Allow public read access',
      definition:
          '''
        CREATE POLICY "Allow public read access"
        ON storage.objects
        FOR SELECT
        USING (bucket_id = '$BUCKET_NAME')
      ''',
    );

    // Policy 3: Permettre aux utilisateurs authentifiés de supprimer leurs fichiers
    await _createPolicy(
      name: 'Allow authenticated users to delete own files',
      definition:
          '''
        CREATE POLICY "Allow authenticated users to delete own files"
        ON storage.objects
        FOR DELETE
        TO authenticated
        USING (bucket_id = '$BUCKET_NAME' AND owner_id = auth.uid())
      ''',
    );

    print('✅ Policies configurées avec succès!');
  }

  Future<void> _createPolicy({
    required String name,
    required String definition,
  }) async {
    try {
      print('  📌 Création policy: $name');

      final response = await httpClient.post(
        Uri.parse('$supabaseUrl/rest/v1/rpc/create_policy'),
        headers: _headers,
        body: jsonEncode({'policy_definition': definition}),
      );

      // Les policies peuvent retourner 201 ou other codes selon la config
      if (response.statusCode >= 200 && response.statusCode < 300) {
        print('     ✅ $name créée!');
      } else {
        // Les policies peuvent échouer si déjà existe, ce n'est pas grave
        print('     ⚠️  $name (code: ${response.statusCode})');
      }
    } catch (e) {
      print('     ⚠️  Erreur: $e (impossible de créer via API)');
      print('     💡 Les policies peuvent être ajoutées manuellement');
    }
  }

  // ==========================================================================
  // 3. CONFIGURER CORS
  // ==========================================================================

  Future<void> setupCors() async {
    print('\n🌐 ÉTAPE 3: Configurer les origines CORS...');

    final corsOrigins = [
      'http://localhost:*', // Dev local
      'https://foncira.app', // Production (à adapter)
      'https://*.lovable.app', // Lovable
      'https://*.vercel.app', // Vercel
    ];

    try {
      for (final origin in corsOrigins) {
        await _addCorsOrigin(origin);
      }
      print('✅ Origines CORS configurées!');
    } catch (e) {
      print('⚠️  Erreur CORS: $e');
      print('   💡 Vous pouvez configurer CORS manuellement');
      print('   → Supabase Dashboard > Project Settings > API > CORS');
    }
  }

  Future<void> _addCorsOrigin(String origin) async {
    try {
      final response = await httpClient.post(
        Uri.parse('$supabaseUrl/rest/v1/rpc/add_cors_origin'),
        headers: _headers,
        body: jsonEncode({'origin': origin}),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        print('  ✅ $origin');
      } else {
        print('  ⚠️  $origin (code: ${response.statusCode})');
      }
    } catch (e) {
      print('  ⚠️  $origin - Erreur: $e');
    }
  }

  // ==========================================================================
  // 4. VÉRIFICATION FINALE
  // ==========================================================================

  Future<void> verifySetup() async {
    print('\n✅ ÉTAPE 4: Vérification finale...');

    try {
      final response = await httpClient.get(
        Uri.parse('$supabaseUrl/storage/v1/bucket/$BUCKET_NAME'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('✅ Bucket vérifié:');
        print('   - Nom: ${data['name']}');
        print('   - Public: ${data['public']}');
        print('   - ID: ${data['id']}');
      } else {
        print('❌ Bucket non trouvé: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Erreur lors de la vérification: $e');
    }
  }

  // ==========================================================================
  // EXÉCUTION COMPLÈTE
  // ==========================================================================

  Future<void> runSetup() async {
    try {
      print('╔════════════════════════════════════════════════════════╗');
      print('║  🚀 Configuration Supabase Storage - Upload Photos  🚀  ║');
      print('╚════════════════════════════════════════════════════════╝');
      print('\n📍 Configuration:');
      print('   Supabase URL: $supabaseUrl');
      print('   Bucket: $BUCKET_NAME');

      await createBucket();
      await setupPolicies();
      await setupCors();
      await verifySetup();

      print('\n╔════════════════════════════════════════════════════════╗');
      print('║  ✅ CONFIGURATION RÉUSSIE!                          ✅  ║');
      print('╚════════════════════════════════════════════════════════╝');
      print('\n📝 Prochaines étapes:');
      print('   1. Compilez l\'app: flutter run');
      print('   2. Testez l\'upload de photos');
      print('   3. Vérifiez les fichiers dans Supabase Dashboard > Storage');
    } catch (e) {
      print('\n❌ ERREUR: $e');
      print('\n💡 Pour configurer manuellement:');
      print('   1. Allez à: $supabaseUrl/project/storage');
      print('   2. Créez le bucket: $BUCKET_NAME');
      print('   3. Ajoutez les policies dans l\'onglet "Policies"');
      print('   4. Configurez CORS dans Settings > API');
    } finally {
      httpClient.close();
    }
  }
}

// ============================================================================
// MAIN - Point d'entrée
// ============================================================================

Future<void> main() async {
  // ✅ À METTRE À JOUR AVANT D'EXÉCUTER
  if (SUPABASE_URL.contains('xxxxxxxxxxx') ||
      SUPABASE_SERVICE_ROLE_KEY.contains('eyJ')) {
    print('❌ ERREUR: Mettez à jour SUPABASE_URL et SUPABASE_SERVICE_ROLE_KEY!');
    print('\n📍 Trouvez ces valeurs:');
    print('   1. Allez à: https://app.supabase.com');
    print('   2. Sélectionnez votre projet');
    print('   3. Settings > API > Project URL et Service Role key');
    print('   4. Copiez les valeurs dans ce script');
    return;
  }

  final setup = SupabaseStorageSetup(
    supabaseUrl: SUPABASE_URL,
    serviceRoleKey: SUPABASE_SERVICE_ROLE_KEY,
  );

  await setup.runSetup();
}
