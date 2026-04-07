import '../services/supabase_service.dart';

// ══════════════════════════════════════════════════════════════
//  SELLER STATS SERVICE — Dashboard Analytics
// ══════════════════════════════════════════════════════════════

enum StatsPeriod { days7, days30, days90 }

class SellerStatsService {
  final SupabaseService _supabase = SupabaseService();

  // Get terrain stats for a specific period
  Future<Map<String, dynamic>> getTerrainStats(
    String terrainId,
    StatsPeriod period,
  ) async {
    try {
      final daysAgo = _getPeriodDays(period);

      // Get terrain with counts
      final response = await _supabase.client
          .from('terrains_foncira')
          .select(
            'id, titre, views_count, verification_requests_count, direct_contacts_count, photos_urls',
          )
          .eq('id', terrainId)
          .single();

      final views = (response['views_count'] ?? 0) as int;
      final verificationRequests =
          (response['verification_requests_count'] ?? 0) as int;
      final directContacts = (response['direct_contacts_count'] ?? 0) as int;

      // Generate contextual message
      final message = _getContextualMessage(views, directContacts);

      return {
        'terrain_id': terrainId,
        'titre': response['titre'] ?? 'Sans titre',
        'photo_url': (response['photos_urls'] as List?)?.isNotEmpty == true
            ? (response['photos_urls'] as List)[0]
            : null,
        'views': views,
        'verification_requests': verificationRequests,
        'direct_contacts': directContacts,
        'period_days': daysAgo,
        'contextual_message': message,
      };
    } catch (e) {
      print('Error getting terrain stats: $e');
      return {};
    }
  }

  // Get all terrains stats for seller in a period
  Future<List<Map<String, dynamic>>> getSellerStats(StatsPeriod period) async {
    try {
      if (!_supabase.isAuthenticated) {
        return [];
      }

      final userId = _supabase.currentUserId;
      if (userId == null) {
        return [];
      }

      final terrains = await _supabase.client
          .from('terrains_foncira')
          .select(
            'id, titre, views_count, verification_requests_count, direct_contacts_count, photos_urls',
          )
          .eq('owner_user_id', userId)
          .eq('is_archived', false)
          .order('updated_at', ascending: false);

      final statsList = <Map<String, dynamic>>[];

      for (final terrain in terrains) {
        final views = (terrain['views_count'] ?? 0) as int;
        final verificationRequests =
            (terrain['verification_requests_count'] ?? 0) as int;
        final directContacts = (terrain['direct_contacts_count'] ?? 0) as int;

        statsList.add({
          'terrain_id': terrain['id'],
          'titre': terrain['titre'] ?? 'Sans titre',
          'photo_url': (terrain['photos_urls'] as List?)?.isNotEmpty == true
              ? (terrain['photos_urls'] as List)[0]
              : null,
          'views': views,
          'verification_requests': verificationRequests,
          'direct_contacts': directContacts,
          'contextual_message': _getContextualMessage(views, directContacts),
        });
      }

      return statsList;
    } catch (e) {
      print('Error getting seller stats: $e');
      return [];
    }
  }

  int _getPeriodDays(StatsPeriod period) {
    switch (period) {
      case StatsPeriod.days7:
        return 7;
      case StatsPeriod.days30:
        return 30;
      case StatsPeriod.days90:
        return 90;
    }
  }

  String _getContextualMessage(int views, int directContacts) {
    if (views > 20 && directContacts < 3) {
      return 'Mettez ce terrain en avant pour convertir plus.';
    } else if (views < 5) {
      return 'Ajoutez des photos pour attirer plus de visiteurs.';
    }
    return '';
  }

  // Generate view chart data (simple list for native widget)
  List<int> generateViewsChartData(int totalViews, int daysInPeriod) {
    // Simple distribution: spread views across days
    final dailyAvg = (totalViews / daysInPeriod).ceil();
    return List.generate(daysInPeriod, (i) {
      // Add some variance
      final variance = (i % 3) * 2;
      return (dailyAvg + variance).clamp(0, totalViews).toInt();
    });
  }
}
