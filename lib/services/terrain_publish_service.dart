import 'dart:io';
import '../models/publish_state.dart';
import '../services/supabase_service.dart';

// ══════════════════════════════════════════════════════════════
//  TERRAIN PUBLISH SERVICE — Photo Upload & Terrain Creation
// ══════════════════════════════════════════════════════════════

class TerrainPublishService {
  final SupabaseService _supabase = SupabaseService();

  // Upload photo to Supabase Storage (documents bucket)
  Future<String> uploadPhoto(File file, String fileName) async {
    try {
      final path =
          'seller_photos/${DateTime.now().millisecondsSinceEpoch}_$fileName';

      await _supabase.client.storage.from('documents').upload(path, file);

      // Get public URL
      final publicUrl = _supabase.client.storage
          .from('documents')
          .getPublicUrl(path);

      return publicUrl;
    } catch (e) {
      throw Exception('Erreur upload photo: $e');
    }
  }

  // Publish terrain to terrains_foncira table
  Future<String> publishTerrain(
    PublishState publishState, {
    bool featured = false,
  }) async {
    try {
      final currentUserId = _supabase.client.auth.currentUser?.id;
      if (currentUserId == null) {
        throw Exception('Utilisateur non connecté');
      }

      // Prepare data
      final data = publishState.toSupabaseJson();
      data['owner_user_id'] = currentUserId;
      data['is_featured'] = featured;
      if (featured) {
        data['featured_at'] = DateTime.now().toIso8601String();
      }

      // Insert terrain
      final response = await _supabase.client
          .from('terrains_foncira')
          .insert(data)
          .select();

      if (response.isEmpty) {
        throw Exception('Erreur lors de la création du terrain');
      }

      final terrainId = response[0]['id'] as String;

      // If featured, create subscription record
      if (featured) {
        await _createVendorSubscription(terrainId, currentUserId);
      }

      return terrainId;
    } catch (e) {
      throw Exception('Erreur publication: $e');
    }
  }

  // Create vendor subscription for featured listing
  Future<void> _createVendorSubscription(
    String terrainId,
    String userId,
  ) async {
    try {
      await _supabase.client.from('vendor_subscriptions').insert({
        'terrain_id': terrainId,
        'seller_user_id': userId,
        'subscription_type': 'featured',
        'price_fcfa': 15000, // 15,000 FCFA/month
        'status': 'active',
        'started_at': DateTime.now().toIso8601String(),
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Erreur création abonnement: $e');
    }
  }

  // Get upload progress for UI feedback
  Future<double> getUploadProgress(int uploadedSize, int totalSize) async {
    return uploadedSize / totalSize;
  }

  // Delete uploaded photos (for cancellation)
  Future<void> deletePhotos(List<String> photoNames) async {
    try {
      for (final name in photoNames) {
        await _supabase.client.storage.from('documents').remove([name]);
      }
    } catch (e) {
      print('Erreur suppression photos: $e');
      // Don't throw - just log
    }
  }
}
