import 'supabase_service.dart';

// ══════════════════════════════════════════════════════════════
//  FONCIRA — Verification Service
// ══════════════════════════════════════════════════════════════

class VerificationService {
  final SupabaseService _supabase = SupabaseService();

  String _normalizeDocumentType(String raw) {
    final value = raw.toLowerCase();

    if (value.contains('aucun')) return 'aucun_document';
    if (value.contains('ne sais pas') || value.contains('sais_pas')) {
      return 'ne_sais_pas';
    }
    if (value.contains('titre')) return 'titre_foncier';
    if (value.contains('logement')) return 'logement';
    if (value.contains('convention')) return 'convention';
    if (value.contains('reçu') || value.contains('recu')) return 'recu_vente';

    return 'ne_sais_pas';
  }

  String _calculateRiskFromNormalizedDocument(String normalizedDocumentType) {
    switch (normalizedDocumentType) {
      case 'titre_foncier':
      case 'logement':
        return 'faible';
      case 'convention':
      case 'recu_vente':
        return 'modere';
      case 'aucun_document':
      case 'ne_sais_pas':
      default:
        return 'eleve';
    }
  }

  bool _isMissingColumnError(Object error, List<String> columnNames) {
    final text = error.toString();
    return text.contains('PGRST204') &&
        columnNames.any((name) => text.contains("'$name'"));
  }

  Future<Map<String, dynamic>> _insertVerificationCompat({
    required bool isMarketplace,
    required String terrainTitle,
    required String terrainLocation,
    required double priceFCFA,
    required String documentType,
    String? sharingLink,
    String? terrainId,
  }) async {
    final now = DateTime.now();
    final normalizedDocumentType = _normalizeDocumentType(documentType);
    final riskLevel = _calculateRiskFromNormalizedDocument(
      normalizedDocumentType,
    );

    // Newer schema variant (client_status + terrain_document_type + terrain_id_foncira)
    final modernPayload = {
      'user_id': _supabase.currentUserId,
      'source': isMarketplace ? 'foncira_marketplace' : 'externe',
      'client_status': 'receptionnee',
      'terrain_title': terrainTitle,
      'terrain_location': terrainLocation,
      'terrain_price_fcfa': priceFCFA,
      'terrain_document_type': normalizedDocumentType,
      'sharing_link': sharingLink,
      'client_risk_level': riskLevel,
      'submitted_at': now.toIso8601String(),
      'expected_delivery_at': now.add(Duration(days: 10)).toIso8601String(),
      if (isMarketplace) 'terrain_id_foncira': terrainId,
    };

    try {
      return await _supabase.client
          .from('verifications')
          .insert(modernPayload)
          .select()
          .single();
    } catch (modernError) {
      final shouldTryLegacy = _isMissingColumnError(modernError, [
        'terrain_document_type',
        'client_status',
        'terrain_id_foncira',
      ]);

      if (!shouldTryLegacy) {
        rethrow;
      }

      // Legacy schema variant (status + document_type + terrain_id)
      final legacyPayload = {
        'user_id': _supabase.currentUserId,
        'source': isMarketplace ? 'foncira_marketplace' : 'externe',
        'status': 'receptionnee',
        'client_status': 'receptionnee',
        'terrain_title': terrainTitle,
        'terrain_location': terrainLocation,
        'terrain_price_fcfa': priceFCFA,
        'document_type': normalizedDocumentType,
        'sharing_link': sharingLink,
        'risk_level': riskLevel,
        'submitted_at': now.toIso8601String(),
        'expected_delivery_at': now.add(Duration(days: 10)).toIso8601String(),
        if (isMarketplace) 'terrain_id': terrainId,
      };

      return await _supabase.client
          .from('verifications')
          .insert(legacyPayload)
          .select()
          .single();
    }
  }

  // ── Create verification from external terrain ───────────────
  Future<String?> createExternalVerification({
    required String terrainTitle,
    required String terrainLocation,
    required double priceFCFA,
    required String documentType,
    String? sharingLink,
  }) async {
    try {
      if (_supabase.currentUserId == null) {
        throw Exception('User not authenticated');
      }

      final response = await _insertVerificationCompat(
        isMarketplace: false,
        terrainTitle: terrainTitle,
        terrainLocation: terrainLocation,
        priceFCFA: priceFCFA,
        documentType: documentType,
        sharingLink: sharingLink,
      );

      // Keep tracking UX consistent between marketplace and external flow.
      await _createInitialMilestones(response['id']);

      return response['id'];
    } catch (e) {
      throw Exception('Failed to create verification: $e');
    }
  }

  // ── Create verification from marketplace ───────────────────
  Future<String?> createMarketplaceVerification({
    required String terrainId,
    required String terrainTitle,
    required String terrainLocation,
    required double priceFCFA,
    required String documentType,
    String? sharingLink,
  }) async {
    try {
      if (_supabase.currentUserId == null) {
        throw Exception('User not authenticated');
      }

      final response = await _insertVerificationCompat(
        isMarketplace: true,
        terrainId: terrainId,
        terrainTitle: terrainTitle,
        terrainLocation: terrainLocation,
        priceFCFA: priceFCFA,
        documentType: documentType,
        sharingLink: sharingLink,
      );

      // Auto-create milestones for J1, J3, J7, J10
      await _createInitialMilestones(response['id']);

      return response['id'];
    } catch (e) {
      throw Exception('Failed to create marketplace verification: $e');
    }
  }

  // ── Get user verifications ─────────────────────────────────
  Future<List<Map<String, dynamic>>> getUserVerifications() async {
    try {
      if (_supabase.currentUserId == null) {
        throw Exception('User not authenticated');
      }

      final response = await _supabase.client
          .from('verifications')
          .select('''
            *,
            agents(id, full_name, average_rating),
            verification_reports(id, risk_level, verdict_summary),
            verification_milestones(id, milestone_day, status)
          ''')
          .eq('user_id', _supabase.currentUserId!)
          .order('submitted_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Failed to get verifications: $e');
    }
  }

  // ── Get single verification ────────────────────────────────
  Future<Map<String, dynamic>?> getVerification(String verificationId) async {
    try {
      final response = await _supabase.client
          .from('verifications')
          .select('''
            *,
            agents(id, full_name, average_rating),
            verification_reports(*),
            verification_documents(*),
            verification_milestones(*),
            payments(*)
          ''')
          .eq('id', verificationId)
          .single();

      return response;
    } catch (e) {
      return null;
    }
  }

  // ── Update verification status ─────────────────────────────
  Future<bool> updateVerificationStatus(
    String verificationId,
    String newStatus,
  ) async {
    try {
      await _supabase.client
          .from('verifications')
          .update({'status': newStatus})
          .eq('id', verificationId);
      return true;
    } catch (e) {
      throw Exception('Failed to update verification status: $e');
    }
  }

  // ── Complete milestone ────────────────────────────────────
  Future<bool> completeMilestone(
    String milestoneId, {
    String? notes,
    Map<String, dynamic>? locationPhotos,
    Map<String, dynamic>? gpsCoordinates,
  }) async {
    try {
      await _supabase.client
          .from('verification_milestones')
          .update({
            'status': 'termine',
            'completed_at': DateTime.now().toIso8601String(),
            if (notes != null) 'notes': notes,
            if (locationPhotos != null) 'location_photos': locationPhotos,
            if (gpsCoordinates != null) 'gps_coordinates': gpsCoordinates,
            'message_sent': true,
          })
          .eq('id', milestoneId);
      return true;
    } catch (e) {
      throw Exception('Failed to complete milestone: $e');
    }
  }

  // ── Get milestones for verification ──────────────────────
  Future<List<Map<String, dynamic>>> getVerificationMilestones(
    String verificationId,
  ) async {
    try {
      final response = await _supabase.client
          .from('verification_milestones')
          .select('*')
          .eq('verification_id', verificationId)
          .order('milestone_day', ascending: true);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Failed to get milestones: $e');
    }
  }

  // ── Create verification report ────────────────────────────
  Future<String?> createVerificationReport({
    required String verificationId,
    required String agentId,
    required String riskLevel,
    required String verdictSummary,
    required List<String> positivePoints,
    required List<String> pointsToVerify,
  }) async {
    try {
      final response = await _supabase.client
          .from('verification_reports')
          .insert({
            'verification_id': verificationId,
            'agent_id': agentId,
            'risk_level': riskLevel,
            'verdict_summary': verdictSummary,
            'positive_points': positivePoints,
            'points_to_verify': pointsToVerify,
          })
          .select()
          .single();

      // Update verification status to rapport_livre
      await updateVerificationStatus(verificationId, 'rapport_livre');

      return response['id'];
    } catch (e) {
      throw Exception('Failed to create report: $e');
    }
  }

  // ── Private helper: Create initial milestones ──────────────
  Future<void> _createInitialMilestones(String verificationId) async {
    try {
      final milestones = [
        {'day': 1, 'label': 'J1', 'description': 'Demande validée'},
        {'day': 3, 'label': 'J3', 'description': 'Vérification administrative'},
        {'day': 5, 'label': 'J5', 'description': 'Vérification coutumière'},
        {
          'day': 7,
          'label': 'J7',
          'description': 'Vérification du voisinage & Géomètre',
        },
        {
          'day': 10,
          'label': 'J10',
          'description': 'Décision du juriste & Rapport final',
        },
      ];

      for (final milestone in milestones) {
        try {
          await _supabase.client.from('verification_milestones').insert({
            'verification_id': verificationId,
            'milestone_day': milestone['day'],
            'milestone_name': milestone['label'],
            'milestone_description': milestone['description'],
            'status': 'en_attente',
          });
        } catch (_) {
          await _supabase.client.from('verification_milestones').insert({
            'verification_id': verificationId,
            'milestone_day': milestone['label'],
            'description': milestone['description'],
            'status': 'en_attente',
          });
        }
      }
    } catch (e) {
      // Fail silently - milestones are optional
    }
  }
}
