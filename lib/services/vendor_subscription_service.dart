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

  // ══════════════════════════════════════════════════════════════
  // CREDITS SYSTEM — Boost Terrains with Credits
  // ══════════════════════════════════════════════════════════════

  /// Get current credits for a subscription
  Future<int> getCreditsRemaining(String subscriptionId) async {
    try {
      final response = await _supabase.client
          .from('vendor_subscriptions')
          .select('credits_remaining')
          .eq('id', subscriptionId)
          .single();

      return response['credits_remaining'] as int? ?? 0;
    } catch (e) {
      print('Error getting credits: $e');
      return 0;
    }
  }

  /// Purchase credits (10 credits per subscription = 15,000 FCFA)
  /// Returns the new subscription record with updated credits
  Future<Map<String, dynamic>?> purchaseCredits(
    String subscriptionId,
    int creditsToPurchase,
  ) async {
    try {
      if (!_supabase.isAuthenticated) {
        return null;
      }

      final userId = _supabase.currentUserId;
      if (userId == null) {
        return null;
      }

      // Get current subscription
      final subscription = await _supabase.client
          .from('vendor_subscriptions')
          .select('*')
          .eq('id', subscriptionId)
          .single();

      if (subscription['user_id'] != userId) {
        throw Exception(
          'Unauthorized: This subscription does not belong to you',
        );
      }

      // Calculate price: 1,500 FCFA per credit (15,000 FCFA / 10 credits)
      final totalPrice = creditsToPurchase * 1500;

      // Update credits
      final currentCredits = subscription['credits_remaining'] as int? ?? 0;
      final newCredits = currentCredits + creditsToPurchase;

      final updated = await _supabase.client
          .from('vendor_subscriptions')
          .update({
            'credits_remaining': newCredits,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', subscriptionId)
          .select();

      return updated.isNotEmpty ? (updated[0] as Map<String, dynamic>) : null;
    } catch (e) {
      print('Error purchasing credits: $e');
      return null;
    }
  }

  /// Use one credit to boost a terrain for 1 day
  Future<bool> useCredit(String subscriptionId, String terrainId) async {
    try {
      if (!_supabase.isAuthenticated) {
        return false;
      }

      final userId = _supabase.currentUserId;
      if (userId == null) {
        return false;
      }

      // Get subscription
      final subscription = await _supabase.client
          .from('vendor_subscriptions')
          .select('credits_remaining')
          .eq('id', subscriptionId)
          .single();

      final creditsRemaining = subscription['credits_remaining'] as int? ?? 0;

      if (creditsRemaining <= 0) {
        throw Exception(
          'Insufficient credits. You need at least 1 credit to boost.',
        );
      }

      // Consume credit
      await _supabase.client
          .from('vendor_subscriptions')
          .update({
            'credits_remaining': creditsRemaining - 1,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', subscriptionId);

      // Mark terrain as boosted with expiry timestamp
      final boostExpiresAt = DateTime.now().add(const Duration(days: 1));
      await _supabase.client
          .from('terrains_foncira')
          .update({
            'is_featured': true,
            'featured_at': DateTime.now().toIso8601String(),
            'boost_expires_at': boostExpiresAt.toIso8601String(),
          })
          .eq('id', terrainId)
          .eq('seller_id', userId);

      return true;
    } catch (e) {
      print('Error using credit: $e');
      return false;
    }
  }

  /// Get initial credits for new subscription (10 credits = 15,000 FCFA package)
  static const int initialCredits = 10;

  /// Create subscription with initial credits
  Future<bool> createOrRenewSubscriptionWithCredits(String terrainId) async {
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
          .select('id, credits_remaining')
          .eq('terrain_id', terrainId)
          .eq('subscription_type', 'featured')
          .limit(1);

      if (existing.isNotEmpty) {
        // Update existing - add 10 more credits
        final currentCredits = existing[0]['credits_remaining'] as int? ?? 0;
        await _supabase.client
            .from('vendor_subscriptions')
            .update({
              'status': 'active',
              'expires_at': expiresAt.toIso8601String(),
              'credits_remaining': currentCredits + initialCredits,
              'updated_at': now.toIso8601String(),
            })
            .eq('id', existing[0]['id']);
      } else {
        // Create new with initial 10 credits
        await _supabase.client.from('vendor_subscriptions').insert({
          'terrain_id': terrainId,
          'user_id': userId,
          'subscription_type': 'featured',
          'price_fcfa': subscriptionPriceFCFA,
          'status': 'active',
          'credits_remaining': initialCredits,
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
      print('Error creating subscription with credits: $e');
      return false;
    }
  }
}
