// FONCIRA - Agent Service
// Retrieves missions assigned to the currently connected agent.

import 'supabase_service.dart';

class AgentService {
  final SupabaseService _supabase = SupabaseService();

  Future<String> _resolveCurrentUserProfileId() async {
    final authUserId = _supabase.client.auth.currentUser?.id;
    if (authUserId == null) {
      throw Exception('Agent not authenticated');
    }

    final profile = await _supabase.client
        .from('users')
        .select('id')
        .or('auth_id.eq.$authUserId,id.eq.$authUserId')
        .maybeSingle();

    final profileId = profile?['id']?.toString();
    if (profileId == null || profileId.isEmpty) {
      throw Exception('Agent profile not found in users table');
    }

    return profileId;
  }

  Future<String?> _resolveCurrentAgentId() async {
    final profileId = await _resolveCurrentUserProfileId();

    final agent = await _supabase.client
        .from('agents')
        .select('id')
        .eq('user_id', profileId)
        .maybeSingle();

    final agentId = agent?['id']?.toString();
    if (agentId == null || agentId.isEmpty) return null;
    return agentId;
  }

  Map<String, dynamic> _normalizeMission(Map<String, dynamic> mission) {
    final normalized = Map<String, dynamic>.from(mission);

    final user = normalized['users'];
    if (user is Map<String, dynamic>) {
      final normalizedUser = Map<String, dynamic>.from(user);
      final phoneNumber = normalizedUser['phone_number']?.toString();
      if (phoneNumber != null && phoneNumber.isNotEmpty) {
        normalizedUser['phone'] = phoneNumber;
      } else {
        normalizedUser.putIfAbsent('phone', () => null);
      }
      normalized['users'] = normalizedUser;
    }

    final docs = normalized['verification_documents'];
    if (docs is List) {
      normalized['verification_documents'] = docs.map((doc) {
        final m = Map<String, dynamic>.from(doc as Map);

        // Keep old UI key expected by screens.
        m['document_type'] ??=
            m['document_category'] ?? m['file_type'] ?? 'Document';

        final filePath = m['file_path']?.toString();
        if (filePath != null &&
            filePath.isNotEmpty &&
            m['file_url'] == null &&
            !filePath.startsWith('http')) {
          m['file_url'] = _supabase.client.storage
              .from('documents')
              .getPublicUrl(filePath);
        }

        m['uploaded_by'] ??= m['uploaded_by_user_id'];
        return m;
      }).toList();
    }

    final milestones = normalized['verification_milestones'];
    if (milestones is List) {
      normalized['verification_milestones'] = milestones.map((ms) {
        final m = Map<String, dynamic>.from(ms as Map);
        m['completed'] = m['status'] == 'termine';
        return m;
      }).toList();
    }

    return normalized;
  }

  Future<List<Map<String, dynamic>>> getAgentMissions({int limit = 50}) async {
    try {
      final agentId = await _resolveCurrentAgentId();
      if (agentId == null) {
        // Agent role exists but no row in public.agents yet.
        return [];
      }

      final response = await _supabase.client
          .from('verifications')
          .select('''
            id,
            user_id,
            agent_id:assigned_agent_id,
            terrain_id:terrain_id_foncira,
            terrain_title,
            terrain_location,
            terrain_price_fcfa,
            terrain_price_usd,
            document_type:terrain_document_type,
            verification_status:client_status,
            risk_level:client_risk_level,
            source,
            submitted_at,
            created_at,
            updated_at,
            users!user_id (
              id,
              first_name,
              last_name,
              email,
              phone_number
            )
          ''')
          .eq('assigned_agent_id', agentId)
          .order('created_at', ascending: false)
          .limit(limit);

      return List<Map<String, dynamic>>.from(
        response,
      ).map(_normalizeMission).toList();
    } catch (e) {
      print('[AgentService] Erreur lors de la recuperation des missions: $e');
      throw Exception('Failed to fetch agent missions: $e');
    }
  }

  Future<Map<String, dynamic>> getMissionDetail(String verificationId) async {
    try {
      final agentId = await _resolveCurrentAgentId();
      if (agentId == null) {
        throw Exception('Agent profile not configured');
      }

      final response = await _supabase.client
          .from('verifications')
          .select('''
            id,
            user_id,
            agent_id:assigned_agent_id,
            terrain_id:terrain_id_foncira,
            terrain_title,
            terrain_location,
            terrain_price_fcfa,
            terrain_price_usd,
            document_type:terrain_document_type,
            verification_status:client_status,
            risk_level:client_risk_level,
            source,
            submitted_at,
            expected_delivery_at,
            created_at,
            updated_at,
            users!user_id (
              id,
              first_name,
              last_name,
              email,
              phone_number,
              primary_role
            ),
            verification_milestones (
              id,
              milestone_day,
              status,
              created_at,
              updated_at
            ),
            verification_documents (
              id,
              file_name,
              file_path,
              file_type,
              document_type:document_category,
              uploaded_by:uploaded_by_user_id,
              uploaded_at,
              created_at
            )
          ''')
          .eq('id', verificationId)
          .eq('assigned_agent_id', agentId)
          .single();

      return _normalizeMission(Map<String, dynamic>.from(response));
    } catch (e) {
      print('[AgentService] Erreur lors de la recuperation du detail: $e');
      throw Exception('Failed to fetch mission detail: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getMissionsByStatus(
    String status, {
    int limit = 50,
  }) async {
    try {
      final agentId = await _resolveCurrentAgentId();
      if (agentId == null) {
        return [];
      }

      final response = await _supabase.client
          .from('verifications')
          .select('''
            id,
            user_id,
            agent_id:assigned_agent_id,
            terrain_id:terrain_id_foncira,
            terrain_title,
            terrain_location,
            terrain_price_fcfa,
            document_type:terrain_document_type,
            verification_status:client_status,
            risk_level:client_risk_level,
            created_at,
            updated_at,
            users!user_id (
              id,
              first_name,
              last_name,
              email,
              phone_number
            )
          ''')
          .eq('assigned_agent_id', agentId)
          .eq('client_status', status)
          .order('created_at', ascending: false)
          .limit(limit);

      return List<Map<String, dynamic>>.from(
        response,
      ).map(_normalizeMission).toList();
    } catch (e) {
      print('[AgentService] Erreur lors de la recuperation par statut: $e');
      throw Exception('Failed to fetch missions by status: $e');
    }
  }

  Future<Map<String, dynamic>> getAgentStats() async {
    try {
      final agentId = await _resolveCurrentAgentId();
      if (agentId == null) {
        return {
          'totalMissions': 0,
          'receptionnee': 0,
          'preAnalyse': 0,
          'analyseFinal': 0,
          'rapportLivre': 0,
        };
      }

      final response = await _supabase.client
          .from('verifications')
          .select('client_status')
          .eq('assigned_agent_id', agentId);

      int totalMissions = response.length;
      int totalReceptionnee = response
          .where((v) => v['client_status'] == 'receptionnee')
          .length;
      int totalPreAnalyse = response
          .where((v) => v['client_status'] == 'pre_analyse')
          .length;
      int totalAnalyseFinal = response
          .where((v) => v['client_status'] == 'analyse_finale')
          .length;
      int totalRapportLivre = response
          .where((v) => v['client_status'] == 'rapport_livre')
          .length;

      return {
        'totalMissions': totalMissions,
        'receptionnee': totalReceptionnee,
        'preAnalyse': totalPreAnalyse,
        'analyseFinal': totalAnalyseFinal,
        'rapportLivre': totalRapportLivre,
      };
    } catch (e) {
      print('[AgentService] Erreur lors du calcul des stats: $e');
      return {
        'totalMissions': 0,
        'receptionnee': 0,
        'preAnalyse': 0,
        'analyseFinal': 0,
        'rapportLivre': 0,
      };
    }
  }

  Future<Map<String, dynamic>> getClientInfo(String userId) async {
    try {
      final response = await _supabase.client
          .from('users')
          .select(
            'id, first_name, last_name, email, phone_number, primary_role',
          )
          .eq('id', userId)
          .single();

      final client = Map<String, dynamic>.from(response);
      client['phone'] ??= client['phone_number'];
      return client;
    } catch (e) {
      print('[AgentService] Erreur lors de la recuperation du client: $e');
      throw Exception('Failed to fetch client info: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getMilestones(
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
      print('[AgentService] Erreur lors de la recuperation des milestones: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getDocuments(String verificationId) async {
    try {
      final response = await _supabase.client
          .from('verification_documents')
          .select('*')
          .eq('verification_id', verificationId)
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response).map((doc) {
        final m = Map<String, dynamic>.from(doc);
        m['document_type'] ??=
            m['document_category'] ?? m['file_type'] ?? 'Document';

        final filePath = m['file_path']?.toString();
        if (filePath != null &&
            filePath.isNotEmpty &&
            m['file_url'] == null &&
            !filePath.startsWith('http')) {
          m['file_url'] = _supabase.client.storage
              .from('documents')
              .getPublicUrl(filePath);
        }

        m['uploaded_by'] ??= m['uploaded_by_user_id'];
        return m;
      }).toList();
    } catch (e) {
      print('[AgentService] Erreur lors de la recuperation des documents: $e');
      return [];
    }
  }
}
