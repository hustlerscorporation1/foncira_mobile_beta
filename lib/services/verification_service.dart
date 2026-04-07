import 'supabase_service.dart';

// ══════════════════════════════════════════════════════════════
//  FONCIRA — Verification Service
// ══════════════════════════════════════════════════════════════

class VerificationService {
  final SupabaseService _supabase = SupabaseService();

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

      final response = await _supabase.client
          .from('verifications')
          .insert({
            'user_id': _supabase.currentUserId,
            'source': 'externe',
            'status': 'receptionnee',
            'terrain_title': terrainTitle,
            'terrain_location': terrainLocation,
            'terrain_price_fcfa': priceFCFA,
            'terrain_price_usd': _supabase.convertFcfaToUsd(priceFCFA),
            'document_type': documentType,
            'sharing_link': sharingLink,
            'risk_level': _supabase.calculateRiskLevel(documentType),
            'submitted_at': DateTime.now().toIso8601String(),
            'expected_delivery_at': DateTime.now()
                .add(Duration(days: 10))
                .toIso8601String(),
          })
          .select()
          .single();

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

      final response = await _supabase.client
          .from('verifications')
          .insert({
            'user_id': _supabase.currentUserId,
            'terrain_id': terrainId,
            'source': 'foncira_marketplace',
            'status': 'receptionnee',
            'terrain_title': terrainTitle,
            'terrain_location': terrainLocation,
            'terrain_price_fcfa': priceFCFA,
            'terrain_price_usd': _supabase.convertFcfaToUsd(priceFCFA),
            'document_type': documentType,
            'sharing_link': sharingLink,
            'risk_level': _supabase.calculateRiskLevel(documentType),
            'submitted_at': DateTime.now().toIso8601String(),
            'expected_delivery_at': DateTime.now()
                .add(Duration(days: 10))
                .toIso8601String(),
          })
          .select()
          .single();

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
        {'milestone_day': 'J1', 'description': 'Vérification administrative'},
        {'milestone_day': 'J3', 'description': 'Visite terrain'},
        {'milestone_day': 'J7', 'description': 'Vérification coutumière'},
        {'milestone_day': 'J10', 'description': 'Rapport final'},
      ];

      for (final milestone in milestones) {
        await _supabase.client.from('verification_milestones').insert({
          'verification_id': verificationId,
          'milestone_day': milestone['milestone_day'],
          'description': milestone['description'],
          'status': 'en_attente',
        });
      }
    } catch (e) {
      // Fail silently - milestones are optional
    }
  }
}
