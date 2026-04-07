import '../services/supabase_service.dart';

// ══════════════════════════════════════════════════════════════
//  FONCIRA — Terrain Seller Service (Mon Inventaire)
// ══════════════════════════════════════════════════════════════

class TerrainSellerService {
  final SupabaseService _supabase = SupabaseService();

  // Load seller's terrains from Supabase
  Future<List<Map<String, dynamic>>> getSellerTerrains() async {
    try {
      if (!_supabase.isAuthenticated) {
        return [];
      }

      final userId = _supabase.currentUserId;
      if (userId == null) {
        return [];
      }

      final response = await _supabase.client
          .from('terrains_foncira')
          .select()
          .eq('owner_user_id', userId)
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error loading seller terrains: $e');
      return [];
    }
  }

  // Get seller metrics
  Future<Map<String, int>> getSellerMetrics() async {
    try {
      if (!_supabase.isAuthenticated) {
        return {
          'views_week': 0,
          'verification_requests': 0,
          'direct_contacts': 0,
        };
      }

      final userId = _supabase.currentUserId;
      if (userId == null) {
        return {
          'views_week': 0,
          'verification_requests': 0,
          'direct_contacts': 0,
        };
      }

      // Get terrains
      final terrains = await _supabase.client
          .from('terrains_foncira')
          .select(
            'id, views_count, verification_requests_count, direct_contacts_count',
          )
          .eq('owner_user_id', userId);

      int totalViews = 0;
      int totalRequests = 0;
      int totalContacts = 0;

      for (final terrain in terrains) {
        totalViews += (terrain['views_count'] ?? 0) as int;
        totalRequests += (terrain['verification_requests_count'] ?? 0) as int;
        totalContacts += (terrain['direct_contacts_count'] ?? 0) as int;
      }

      return {
        'views_week': totalViews,
        'verification_requests': totalRequests,
        'direct_contacts': totalContacts,
      };
    } catch (e) {
      print('Error loading seller metrics: $e');
      return {
        'views_week': 0,
        'verification_requests': 0,
        'direct_contacts': 0,
      };
    }
  }

  // Update terrain status
  Future<bool> updateTerrainStatus(String terrainId, String status) async {
    try {
      await _supabase.client
          .from('terrains_foncira')
          .update({
            'status': status,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', terrainId);
      return true;
    } catch (e) {
      print('Error updating terrain status: $e');
      return false;
    }
  }

  // Feature/Highlight terrain
  Future<bool> featureTerrain(String terrainId) async {
    try {
      await _supabase.client
          .from('terrains_foncira')
          .update({
            'is_featured': true,
            'featured_at': DateTime.now().toIso8601String(),
          })
          .eq('id', terrainId);
      return true;
    } catch (e) {
      print('Error featuring terrain: $e');
      return false;
    }
  }

  // Archive terrain
  Future<bool> archiveTerrain(String terrainId) async {
    try {
      await _supabase.client
          .from('terrains_foncira')
          .update({
            'is_archived': true,
            'archived_at': DateTime.now().toIso8601String(),
          })
          .eq('id', terrainId);
      return true;
    } catch (e) {
      print('Error archiving terrain: $e');
      return false;
    }
  }

  // Mark terrain as sold
  Future<bool> markAsSold(String terrainId) async {
    try {
      await _supabase.client
          .from('terrains_foncira')
          .update({
            'status': 'sold',
            'sold_at': DateTime.now().toIso8601String(),
          })
          .eq('id', terrainId);
      return true;
    } catch (e) {
      print('Error marking terrain as sold: $e');
      return false;
    }
  }
}
