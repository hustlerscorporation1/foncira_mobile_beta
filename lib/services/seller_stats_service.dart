import '../services/supabase_service.dart';

enum StatsPeriod { days7, days30, days90 }

class SellerStatsService {
  final SupabaseService _supabase = SupabaseService();

  Future<String?> _resolveCurrentUserProfileId() async {
    final authUserId = _supabase.currentUserId;
    if (authUserId == null) return null;

    final profile = await _supabase.client
        .from('users')
        .select('id')
        .or('id.eq.$authUserId,auth_id.eq.$authUserId')
        .maybeSingle();

    return profile?['id']?.toString();
  }

  Future<Map<String, dynamic>> getTerrainStats(
    String terrainId,
    StatsPeriod period,
  ) async {
    try {
      final daysAgo = _getPeriodDays(period);

      final response = await _fetchTerrainById(terrainId);

      final views = _toInt(response['times_viewed'] ?? response['views_count']);
      final verificationRequests = _toInt(
        response['times_inquired'] ?? response['verification_requests_count'],
      );
      final directContacts = 0;

      final message = _getContextualMessage(views, directContacts);

      return {
        'terrain_id': terrainId,
        'titre': _terrainTitle(response),
        'photo_url': _terrainPhoto(response),
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

  Future<List<Map<String, dynamic>>> getSellerStats(StatsPeriod period) async {
    try {
      if (!_supabase.isAuthenticated) {
        return [];
      }

      final userId = await _resolveCurrentUserProfileId();
      if (userId == null) {
        return [];
      }

      final terrains = await _fetchSellerTerrains(userId);
      final statsList = <Map<String, dynamic>>[];

      for (final terrain in terrains) {
        final views = _toInt(terrain['times_viewed'] ?? terrain['views_count']);
        final inquiries = _toInt(
          terrain['times_inquired'] ?? terrain['verification_requests_count'],
        );

        statsList.add({
          'terrain_id': terrain['id'],
          'titre': _terrainTitle(terrain),
          'photo_url': _terrainPhoto(terrain),
          'views': views,
          'verification_requests': inquiries,
          'direct_contacts': 0,
          'contextual_message': _getContextualMessage(views, 0),
        });
      }

      return statsList;
    } catch (e) {
      print('Error getting seller stats: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>> _fetchTerrainById(String terrainId) async {
    final response = await _supabase.client
        .from('terrains_foncira')
        .select(
          'id, title, times_viewed, times_inquired, additional_photos, main_photo_url, seller_id, deleted_at',
        )
        .eq('id', terrainId)
        .single();
    return Map<String, dynamic>.from(response as Map);
  }

  Future<List<Map<String, dynamic>>> _fetchSellerTerrains(String userId) async {
    final response = await _supabase.client
        .from('terrains_foncira')
        .select(
          'id, title, times_viewed, times_inquired, additional_photos, main_photo_url, seller_id, deleted_at',
        )
        .eq('seller_id', userId)
        .isFilter('deleted_at', null)
        .order('updated_at', ascending: false);
    return (response as List)
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();
  }

  String _terrainTitle(Map<String, dynamic> terrain) {
    return (terrain['title'] ?? terrain['titre'] ?? 'Sans titre').toString();
  }

  String? _terrainPhoto(Map<String, dynamic> terrain) {
    final additionalPhotos = terrain['additional_photos'];
    if (additionalPhotos is List && additionalPhotos.isNotEmpty) {
      final first = additionalPhotos.first;
      if (first is String && first.isNotEmpty) return first;
      if (first is Map && first['url'] != null) {
        return first['url'].toString();
      }
    }

    final mainPhoto = terrain['main_photo_url'];
    if (mainPhoto is String && mainPhoto.isNotEmpty) {
      return mainPhoto;
    }
    return null;
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

  List<int> generateViewsChartData(int totalViews, int daysInPeriod) {
    final dailyAvg = (totalViews / daysInPeriod).ceil();
    return List.generate(daysInPeriod, (i) {
      final variance = (i % 3) * 2;
      return (dailyAvg + variance).clamp(0, totalViews).toInt();
    });
  }

  int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '0') ?? 0;
  }
}
