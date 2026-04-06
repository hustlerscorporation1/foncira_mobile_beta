# FONCIRA — Guide Intégration Supabase avec Flutter

## Guide Rapide de Deployment

### 1. Configuration Supabase

#### 1.1 Importer le Schéma

```bash
# Option 1: Via Supabase Web
1. Aller à https://app.supabase.com
2. Créer un projet (ou sélectionner existant)
3. Aller à SQL Editor → New Query
4. Coller l'intégralité de `database_schema.sql`
5. Exécuter (Run) → ✓ Tout doit réussir

# Option 2: Via SQL file
cat database_schema.sql | psql -h YOUR_DB_HOST -U YOUR_USER YOUR_DB
```

#### 1.2 Vérifier les Tables

```sql
-- Dans l'éditeur SQL Supabase, vérifier:
SELECT * FROM users;              -- 4 test users
SELECT * FROM agents;             -- 2 agents
SELECT * FROM terrains_foncira;   -- 3 terrains
SELECT * FROM verifications;      -- 1 vérification complète
```

#### 1.3 Authentification Supabase Auth

```sql
-- Les UUIDs des users DOIVENT correspondre à auth.users.id
-- Le script crée les users dans la table `users` mais vous devez
-- les créer aussi dans auth.users via Supabase Auth CLI ou API:

-- Pour chaque user test:
-- 1. Créer dans Supabase Auth (Email + Password)
-- 2. Récupérer son auth.uid()
-- 3. Mettre à jour la table users pour que id = auth.uid()
```

---

### 2. Structure des Services Dart

Créer la hiérarchie suivante dans `lib/services/`:

```
lib/services/
├── supabase_service.dart        # Client Supabase + Config
├── verification_service.dart    # CRUD vérifications
├── terrain_service.dart         # CRUD terrains marketplace
├── payment_service.dart         # Gestion paiements
├── agent_service.dart           # Infos agents
├── storage_service.dart         # Upload documents
└── notification_service.dart    # Notifications
```

---

### 3. Exemple: SupabaseService

```dart
// lib/services/supabase_service.dart

import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();

  factory SupabaseService() {
    return _instance;
  }

  SupabaseService._internal();

  late final SupabaseClient _client;

  SupabaseClient get client => _client;

  Future<void> initialize({
    required String supabaseUrl,
    required String supabaseAnonKey,
  }) async {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
    _client = Supabase.instance.client;
  }

  // Utilisateur courant
  User? get currentUser => _client.auth.currentUser;
  String? get currentUserId => currentUser?.id;

  // Véifier authentication
  bool get isAuthenticated => currentUser != null;

  // Sign out
  Future<void> signOut() async {
    await _client.auth.signOut();
  }
}
```

---

### 4. Exemple: VerificationService

```dart
// lib/services/verification_service.dart

import './supabase_service.dart';

class VerificationService {
  final _db = SupabaseService().client;

  // Créer une vérification (externe)
  Future<String> createExternalVerification({
    required String terrainTitle,
    required String terrainLocation,
    required double priceFCFA,
    required String documentType,
    String? sharingLink,
  }) async {
    final userId = SupabaseService().currentUserId;

    final response = await _db
        .from('verifications')
        .insert({
          'user_id': userId,
          'source': 'externe',
          'status': 'receptionnee',
          'terrain_title': terrainTitle,
          'terrain_location': terrainLocation,
          'terrain_price_fcfa': priceFCFA,
          'terrain_price_usd': convertFcfaToUsd(priceFCFA),
          'document_type': documentType,
          'sharing_link': sharingLink,
          'risk_level': calculateRiskFromDocType(documentType),
          'submitted_at': DateTime.now().toIso8601String(),
          'expected_delivery_at': DateTime.now()
              .add(Duration(days: 10))
              .toIso8601String(),
        })
        .select()
        .single();

    return response['id'];
  }

  // Récupérer vérifications du client
  Future<List<Verification>> getUserVerifications() async {
    final userId = SupabaseService().currentUserId;

    final response = await _db
        .from('verifications')
        .select('''
          *,
          agents (full_name, photo_url),
          verification_reports (risk_level, verdict_summary),
          verification_milestones (milestone_day, status, completed_at)
        ''')
        .eq('user_id', userId)
        .order('submitted_at', ascending: false);

    return (response as List)
        .map((v) => Verification.fromJson(v))
        .toList();
  }

  // Mettre à jour statut vérification (agent uniquement)
  Future<void> updateVerificationStatus(
    String verificationId,
    String newStatus,
  ) async {
    await _db
        .from('verifications')
        .update({
          'status': newStatus,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', verificationId);
  }

  // Ajouter un milestone terminé
  Future<void> completeMilestone({
    required String verificationId,
    required int milestoneDay,
    required String notes,
    List<String>? photos,
    Map<String, double>? coordinates,
  }) async {
    await _db
        .from('verification_milestones')
        .update({
          'status': 'termine',
          'completed_at': DateTime.now().toIso8601String(),
          'notes': notes,
          'location_photos': photos != null ? jsonEncode(photos) : null,
          'gps_coordinates': coordinates != null ? jsonEncode(coordinates) : null,
          'message_sent': true,
          'message_sent_at': DateTime.now().toIso8601String(),
        })
        .match({
          'verification_id': verificationId,
          'milestone_day': milestoneDay,
        });
  }

  // Récupérer un rapport de vérification
  Future<VerificationReport?> getVerificationReport(
    String verificationId,
  ) async {
    final response = await _db
        .from('verification_reports')
        .select('*')
        .eq('verification_id', verificationId)
        .maybeSingle();

    return response != null ? VerificationReport.fromJson(response) : null;
  }
}
```

---

### 5. Exemple: StorageService (Upload Documents)

```dart
// lib/services/storage_service.dart

class StorageService {
  final _storage = SupabaseService().client.storage;

  // Upload document
  Future<String> uploadDocument({
    required String verificationId,
    required String fileName,
    required List<int> fileBytes,
    required String fileType,
  }) async {
    final path = 'verifications/$verificationId/$fileName';

    final response = await _storage
        .from('documents')
        .uploadBinary(path, fileBytes);

    // Enregistrer dans verification_documents
    await SupabaseService().client
        .from('verification_documents')
        .insert({
          'verification_id': verificationId,
          'file_name': fileName,
          'file_path': response.path,
          'file_type': fileType,
          'uploaded_by': SupabaseService().currentUserId,
        });

    // Retourner l'URL publique
    return _storage
        .from('documents')
        .getPublicUrl(response.path);
  }

  // Lister documents d'une vérification
  Future<List<DocumentFile>> listDocuments(String verificationId) async {
    final response = await SupabaseService().client
        .from('verification_documents')
        .select('*')
        .eq('verification_id', verificationId)
        .order('created_at', ascending: false);

    return (response as List)
        .map((d) => DocumentFile.fromJson(d))
        .toList();
  }
}
```

---

### 6. Intégration dans VerificationState

```dart
// lib/models/verification_state.dart
// AVANT (Statique)
// Utiliser les données en dur...

// APRÈS (Dynamique Supabase)
class VerificationState {
  // ... champs existants ...

  // Ajouter des references Supabase
  String? databaseId;  // UUID de la vérification en DB
  String? reportId;    // UUID du rapport associé

  static Future<VerificationState> fromSupabase(String verificationId) async {
    final service = VerificationService();
    final verif = await service.getVerification(verificationId);

    return VerificationState(
      localisation: verif['terrain_location'],
      typeDocument: documentTypeFromString(verif['document_type']),
      prixFCFA: verif['terrain_price_fcfa'].toInt(),
      // ... mapper tous les champs ...
      databaseId: verif['id'],
    );
  }

  Future<void> saveToSupabase() async {
    if (databaseId == null) {
      // Créer une nouvelle vérification
      // ...
    } else {
      // Mettre à jour
      final service = VerificationService();
      await service.updateVerificationStatus(databaseId!, status.toString());
    }
  }
}
```

---

### 7. Modifier les Pages pour RLS

```dart
// lib/page/verification_tunnel_page.dart
// AVANT: Statique, aucune authenticate
// APRÈS: Vérifier auth + RLS

class _VerificationTunnelPageState extends State<VerificationTunnelPage> {
  @override
  void initState() {
    super.initState();
    _checkAuthentication();
  }

  Future<void> _checkAuthentication() async {
    if (!SupabaseService().isAuthenticated) {
      // Rediriger vers login
      Navigator.pushReplacementNamed(context, '/login');
      return;
    }
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    // Charger les données depuis Supabase
    if (widget.initialState != null) {
      // Si vérification marketplace: charger le terrain
      final terrain = await TerrainService()
          .getTerrainById(widget.initialState!.terrainId);

      setState(() {
        state = state.copyWith(
          terrainTitre: terrain['title'],
          terrainPhoto: terrain['main_photo_url'],
          terrainSurface: terrain['surface'].toString(),
        );
      });
    }
  }

  void _submitScreen1() {
    // Créer la vérification en DB
    final verificationService = VerificationService();

    verificationService.createExternalVerification(
      terrainTitle: state.terrainTitle ?? localisationController.text,
      terrainLocation: localisationController.text,
      priceFCFA: double.parse(priceController.text),
      documentType: state.typeDocument!.name,
      sharingLink: lienPartageController.text.isEmpty
          ? null
          : lienPartageController.text,
    ).then((verificationId) {
      // Uploader les documents
      for (var doc in uploadedDocuments) {
        // Upload handled separately
      }
      // Aller à l'étape suivante
      _goToStep(2);
    });
  }
}
```

---

### 8. Tests EAU des Requêtes du RLS

```dart
// Tests RLS: Vérifier que les clients ne voient que leurs vérifications

void main() {
  group('RLS Verifications', () {
    test('Client sees only own verifications', () async {
      // Client 1 login
      // Récupérer ses vérifications
      // Assert: only their IDs

      // Client 2 login
      // Récupérer ses vérifications
      // Assert: only their IDs

      // NOT client 1's verifications
    });

    test('Agent sees assigned verifications', () async {
      // Agent login
      // Récupérer vérifications
      // Assert: only those with agent_id = their ID
    });

    test('Admin sees all', () async {
      // Admin login
      // Récupérer vérifications
      // Assert: all
    });
  });
}
```

---

### 9. Variables d'Environnement

```bash
# lib/services/config.dart
const String supabaseUrl = 'https://YOUR_PROJECT.supabase.co';
const String supabaseAnonKey = 'YOUR_ANON_KEY';

// Ou mieux: utiliser des variables d'environnement
// .env (ne pas commit)
SUPABASE_URL=https://...
SUPABASE_ANON_KEY=...

// Charger via flutter_dotenv
import 'package:flutter_dotenv/flutter_dotenv.dart';
const String supabaseUrl = DotEnv().env['SUPABASE_URL'] ?? '';
```

---

### 10. Checklist de Déploiement

- [ ] Schéma SQL importé et tables créées
- [ ] Test data visible dans Supabase
- [ ] RLS activé et testé
- [ ] Auth Supabase configuré
- [ ] Services SupabaseService, VerificationService, StorageService créés
- [ ] Pages mises à jour pour charger depuis Supabase
- [ ] RLS testé avec différents rôles utilisateur
- [ ] Webhooks optionnels pour notifications push
- [ ] CORS configuré si API externe
- [ ] Backup quotidien activé
- [ ] Monitoring et alertes configurés

---

## Commandes SQL Utiles (Debugging)

```sql
-- Vérifier les records d'une vérification
SELECT * FROM verifications WHERE id = '550e8400-e29b-41d4-a716-446655440301';

-- Voir les milestones d'une vérification
SELECT * FROM verification_milestones
WHERE verification_id = '550e8400-e29b-41d4-a716-446655440301'
ORDER BY milestone_day ASC;

-- Voir les documents uploadés
SELECT * FROM verification_documents
WHERE verification_id = '550e8400-e29b-41d4-a716-446655440301';

-- Vérifier les paiements validés
SELECT * FROM payments WHERE status = 'validee' ORDER BY paid_at DESC;

-- Vérifier la charge de travail d'un agent
SELECT COUNT(*) as current_workload
FROM verifications
WHERE agent_id = '550e8400-e29b-41d4-a716-446655440101'
  AND status != 'rapport_livre';

-- Voir les notifications non lues
SELECT * FROM notifications
WHERE is_read = false AND recipient_id = 'YOUR_USER_ID'
ORDER BY created_at DESC;

-- Test RLS: Simuler un client différent
-- (Utiliser Supabase Auth token du client dans les requêtes)
```

---

## Troubleshooting

### Problème: "JWT invalid or expired"

**Solution:** Vérifier que l'auth.uid() du user correspond à id dans la table users

### Problème: "RLS policy violation"

**Solution:** Vérifier les politiques RLS et que le user a les permissions requises

### Problème: "Relation not found"

**Solution:** Vérifier que la table a bien été créée (SELECT \* FROM information_schema.tables)

### Problème: "Column does not exist"

**Solution:** Vérifier la casse des colonnes (PostgreSQL est case-sensitive)

---

## Références

- [Supabase Flutter Docs](https://supabase.com/docs/reference/flutter/introduction)
- [PostgREST API](https://postgrest.org/)
- [Row Level Security](https://supabase.com/docs/guides/auth/row-level-security)
- [Supabase Storage](https://supabase.com/docs/guides/storage)

---

**Document généré:** Avril 2026  
**Prêt à intégrer**
