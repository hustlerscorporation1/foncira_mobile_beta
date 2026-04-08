// ============================================================================
// CONFIGURATION SUPABASE STORAGE VIA DART (Solution Réelle)
// ============================================================================
//
// ⚠️ IMPORTANT: Cette fonction vérifie juste la configuration
//               Les policies doivent être créées via l'interface Supabase
//
// Exécutez cette fonction UNE FOIS au démarrage de l'app
// (par exemple dans main.dart après l'initialisation de Supabase)

import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io' show File;

// ============================================================================
// FONCTION PRINCIPALE: Vérifier Storage Configuration
// ============================================================================

Future<void> verifyStorageConfiguration() async {
  final supabase = Supabase.instance.client;

  print('\n╔════════════════════════════════════════════════════════╗');
  print('║  🔍 Vérification Supabase Storage Configuration    🔍  ║');
  print('╚════════════════════════════════════════════════════════╝\n');

  try {
    // ✅ Étape 1: Vérifier que le bucket 'documents' existe
    print('📍 Étape 1: Vérifier le bucket "documents"...');

    final buckets = await supabase.storage.listBuckets();
    final documentsExists = buckets.any((b) => b.id == 'documents');

    if (!documentsExists) {
      print('❌ ERREUR: Le bucket "documents" n\'existe pas');
      print('   Solution: Créer le bucket dans Supabase Storage Dashboard');
      return;
    }

    final documentsBucket = buckets.firstWhere((b) => b.id == 'documents');
    print('✅ Bucket trouvé:');
    print('   - ID: ${documentsBucket.id}');
    print('   - Public: ${documentsBucket.public}');

    // ✅ Étape 2: Message sur les policies
    print('\n📍 Étape 2: Vérifier les policies RLS...');
    print('⚠️  Les policies ne peuvent pas être vérifiées via Dart');
    print('   (table storage.objects est verrouillée)');
    print('   Solution: Configurer manuellement via Supabase Dashboard');

    // ✅ Étape 3: Afficher les prochaines étapes
    print('\n📍 Étape 3: Configuration manuelle requise');
    print('\n🚀 PROCHAINES ÉTAPES (7 clics, 2 minutes):');
    print('');
    print('1️⃣  Allez à: https://app.supabase.com > Storage > documents');
    print('2️⃣  Cliquez l\'onglet "Policies"');
    print('3️⃣  Créez 4 policies:');
    print('    • INSERT: Allow authenticated users to upload');
    print('    • SELECT: Allow public read access');
    print('    • DELETE: Allow authenticated users to delete own files');
    print('    • UPDATE: Allow authenticated users to update own files');
    print('');
    print('4️⃣  Allez à: Settings > API > CORS');
    print('5️⃣  Ajoutez les origines:');
    print('    • http://localhost:*');
    print('    • https://*.lovable.app');
    print('    • https://*.vercel.app');
    print('');
    print('6️⃣  Testez l\'upload (voir testStorageUpload ci-dessous)');
    print('');
    print('7️⃣  Compilez: flutter run');

    print('\n✅ VÉRIFICATION TERMINÉE!');
    print('\n═════════════════════════════════════════════════════════\n');
  } catch (e) {
    print('❌ Erreur: $e');
    print('\n💡 Assurez-vous que:');
    print('   • Supabase est initialisé dans main.dart');
    print('   • Vous êtes connecté (auth.currentSession != null)');
    print('   • La clé API est correcte');
  }
}

// ============================================================================
// FONCTION 2: Tester l'upload (après configuration des policies)
// ============================================================================

Future<bool> testStorageUpload(File file) async {
  final supabase = Supabase.instance.client;

  print('\n╔════════════════════════════════════════════════════════╗');
  print('║  🧪 Test Upload Supabase Storage                  🧪  ║');
  print('╚════════════════════════════════════════════════════════╝\n');

  try {
    final fileName = 'test/${DateTime.now().millisecondsSinceEpoch}_test.jpg';

    print('📤 Tentative d\'upload...');
    print('   Fichier: $fileName');

    // Essayer d'uploader
    await supabase.storage.from('documents').upload(fileName, file);

    print('✅ Upload réussi!');

    // Récupérer l'URL publique
    final publicUrl = supabase.storage.from('documents').getPublicUrl(fileName);

    print('🔗 URL publique: $publicUrl');

    // Liste les fichiers dans le dossier test/
    final files = await supabase.storage.from('documents').list(path: 'test');
    print('\n📁 Fichiers dans test/:');
    for (final file in files) {
      print('   • ${file.name} (${file.metadata?['size'] ?? '?'} bytes)');
    }

    // Supprimer le fichier de test
    print('\n🗑️  Suppression du fichier de test...');
    await supabase.storage.from('documents').remove([fileName]);
    print('✅ Fichier supprimé');

    print('\n═════════════════════════════════════════════════════════');
    print('✅ TEST RÉUSSI: Storage configuré correctement!');
    print('═════════════════════════════════════════════════════════\n');

    return true;
  } catch (e) {
    print('\n❌ ERREUR: $e');
    print('\n💡 Débogage:');
    print('   • Vérifiez que le bucket "documents" existe');
    print('   • Vérifiez que les policies sont créées');
    print('   • Vérifiez que CORS est configuré');
    print('   • Vérifiez que vous êtes authentifié\n');
    return false;
  }
}

// ============================================================================
// INTÉGRATION DANS MAIN.DART
// ============================================================================

/*

Example main.dart:

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Importer ce fichier
// import 'setup_supabase_storage_manual.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialiser Supabase
  await Supabase.initialize(
    url: 'https://xxxx.supabase.co',
    anonKey: 'eyJhbGc...',
  );

  // Vérifier Storage configuration
  await verifyStorageConfiguration();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Agnigbangna',
      home: Scaffold(
        appBar: AppBar(title: const Text('Storage Test')),
        body: Center(
          child: ElevatedButton(
            onPressed: () => testStorageUpload(testFile),
            child: const Text('Tester Upload'),
          ),
        ),
      ),
    );
  }
}

*/

// ============================================================================
// DEBUG: Afficher les logs détaillés
// ============================================================================

/*

Pour voir tous les logs, activez le mode debug:

```dart
// Dans main.dart:
Supabase.instance.client.functions.setAuthHeader = true;
```

Puis regardez la console:

```
✅ Bucket trouvé
❌ ERREUR: Permission denied (policies manquantes)
✅ Upload réussi (après configuration des policies)
```

*/

// ============================================================================
// STATUT CONFIGURATION
// ============================================================================

/*

AVANT: ❌ ❌ ❌
- ❌ SQL ne fonctionne pas (table verrouillée)
- ❌ API ne fonctionne pas (table verrouillée)
- ❌ Dart ne peut pas créer les policies

MAINTENANT: ✅ ⏳ ⏳
- ✅ Vérification storage fonctionne
- ⏳ Policies: Configuration manuelle requis (7 clics)
- ⏳ CORS: Configuration manuelle requise (quelques origines)

APRÈS CONFIGURATION: ✅ ✅ ✅
- ✅ Upload fonctionne
- ✅ Photos stockées
- ✅ URLs publiques

*/

// ============================================================================
// SOLUTION FINALE
// ============================================================================

/*

⚠️ VERDICT FINAL:

❌ Ce qui NE fonctionne PAS:
   - SQL direct
   - API Supabase REST
   - Clé service_role (limitations)

✅ Ce qui FONCTIONNE:
   - Interface Supabase Dashboard (7 clics, 2 min)
   - Cette fonction Dart pour vérifier
   - Tests post-configuration

📍 FLOW:

1. Exécuter verifyStorageConfiguration() au démarrage
2. Configurer les 4 policies manuellement (2 min)
3. Configurer CORS (1 min)
4. Exécuter testStorageUpload() pour vérifier
5. Compiler flutter run et tester l'upload réel

TEMPS TOTAL: ~5 minutes

*/
