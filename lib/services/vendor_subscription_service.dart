import '../services/supabase_service.dart';

// ══════════════════════════════════════════════════════════════
//  VENDOR SUBSCRIPTION SERVICE — Featured Listing Management
// ══════════════════════════════════════════════════════════════

class VendorSubscriptionService {
  final SupabaseService _supabase = SupabaseService();

  static const int subscriptionPriceFCFA = 15000; // 15,000 FCFA/month
  static const int subscriptionPriceUSD = 23; // ≈ $23

  // Get all seller's terrains with subscription status
  Future<List<Map<String, dynamic>>> getTerrainSubscriptions() async {
    try {
      if (!_supabase.isAuthenticated) {
        return [];
      }

      final userId = _supabase.currentUserId;
      if (userId == null) {
        return [];
      }

      // Get terrains
      final terrains = await _supabase.client
          .from('terrains_foncira')
          .select('id, titre, photos_urls, is_featured')
          .eq('owner_user_id', userId)
          .eq('is_archived', false)
          .order('created_at', ascending: false);

      final subscriptionsList = <Map<String, dynamic>>[];

      for (final terrain in terrains) {
        final terrainId = terrain['id'] as String;

        // Get subscription status
        final subscriptionData = await _getSubscriptionStatus(terrainId);

        subscriptionsList.add({
          'terrain_id': terrainId,
          'titre': terrain['titre'] ?? 'Sans titre',
          'photo_url': (terrain['photos_urls'] as List?)?.isNotEmpty == true
              ? (terrain['photos_urls'] as List)[0]
              : null,
          'is_featured': terrain['is_featured'] ?? false,
          'subscription_status': subscriptionData['status'] ?? 'inactive',
          'subscription_expires_at': subscriptionData['expires_at'],
          'can_activate': subscriptionData['can_activate'] ?? true,
        });
      }

      return subscriptionsList;
    } catch (e) {
      print('Error getting subscriptions: $e');
      return [];
    }
  }

  // Get subscription status for a single terrain
  Future<Map<String, dynamic>> _getSubscriptionStatus(String terrainId) async {
    try {
      final response = await _supabase.client
          .from('vendor_subscriptions')
          .select('id, status, expires_at')
          .eq('terrain_id', terrainId)
          .eq('subscription_type', 'featured')
          .order('created_at', ascending: false)
          .limit(1);

      if (response.isEmpty) {
        return {'status': 'inactive', 'expires_at': null, 'can_activate': true};
      }

      final subscription = response[0];
      final expiresAt = DateTime.parse(subscription['expires_at'] as String);
      final isActive =
          subscription['status'] == 'active' &&
          expiresAt.isAfter(DateTime.now());

      return {
        'status': isActive ? 'active' : 'inactive',
        'expires_at': subscription['expires_at'],
        'can_activate': !isActive,
      };
    } catch (e) {
      print('Error getting subscription status: $e');
      return {'status': 'inactive', 'expires_at': null, 'can_activate': true};
    }
  }

  // Create or renew subscription
  Future<bool> createOrRenewSubscription(String terrainId) async {
    try {
      if (!_supabase.isAuthenticated) {
        return false;
      }

      final userId = _supabase.currentUserId;
      if (userId == null) {
        return false;
      }

      final now = DateTime.now();
      final expiresAt = now.add(const Duration(days: 30));

      // Check if subscription exists
      final existing = await _supabase.client
          .from('vendor_subscriptions')
          .select('id')
          .eq('terrain_id', terrainId)
          .eq('subscription_type', 'featured')
          .limit(1);

      if (existing.isNotEmpty) {
        // Update existing
        await _supabase.client
            .from('vendor_subscriptions')
            .update({
              'status': 'active',
              'expires_at': expiresAt.toIso8601String(),
              'updated_at': now.toIso8601String(),
            })
            .eq('id', existing[0]['id']);
      } else {
        // Create new
        await _supabase.client.from('vendor_subscriptions').insert({
          'terrain_id': terrainId,
          'seller_user_id': userId,
          'subscription_type': 'featured',
          'price_fcfa': subscriptionPriceFCFA,
          'status': 'active',
          'started_at': now.toIso8601String(),
          'expires_at': expiresAt.toIso8601String(),
          'created_at': now.toIso8601String(),
          'updated_at': now.toIso8601String(),
        });
      }

      // Update terrain is_featured flag
      await _supabase.client
          .from('terrains_foncira')
          .update({'is_featured': true, 'featured_at': now.toIso8601String()})
          .eq('id', terrainId);

      return true;
    } catch (e) {
      print('Error creating subscription: $e');
      return false;
    }
  }

  // Cancel subscription (set to inactive)
  Future<bool> cancelSubscription(String terrainId) async {
    try {
      await _supabase.client
          .from('vendor_subscriptions')
          .update({
            'status': 'inactive',
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('terrain_id', terrainId)
          .eq('subscription_type', 'featured');

      // Update terrain is_featured flag
      await _supabase.client
          .from('terrains_foncira')
          .update({'is_featured': false})
          .eq('id', terrainId);

      return true;
    } catch (e) {
      print('Error cancelling subscription: $e');
      return false;
    }
  }
}
