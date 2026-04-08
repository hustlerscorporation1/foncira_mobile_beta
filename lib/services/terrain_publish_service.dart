import 'dart:io';
import '../models/publish_state.dart';
import '../services/supabase_service.dart';

class TerrainPublishService {
  final SupabaseService _supabase = SupabaseService();

  static const String _primaryPhotoBucket = 'terrain_images';
  static const String _legacyPhotoBucket = 'documents';

  Future<String> _resolveCurrentUserProfileId() async {
    final authUserId = _supabase.client.auth.currentUser?.id;
    if (authUserId == null) {
      throw Exception('Utilisateur non connecte');
    }

    final profile = await _supabase.client
        .from('users')
        .select('id')
        .or('id.eq.$authUserId,auth_id.eq.$authUserId')
        .maybeSingle();

    final profileId = profile?['id']?.toString();
    if (profileId == null || profileId.isEmpty) {
      throw Exception(
        'Profil utilisateur introuvable. Reconnectez-vous puis reessayez.',
      );
    }

    return profileId;
  }

  // Upload terrain photos to Supabase Storage.
  Future<String> uploadPhoto(File file, String fileName) async {
    try {
      if (!file.existsSync()) {
        throw Exception('Fichier non trouve: ${file.path}');
      }

      final currentUserId = _supabase.client.auth.currentUser?.id;
      if (currentUserId == null) {
        throw Exception('Utilisateur non connecte');
      }

      final safeFileName = fileName.replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_');
      final path =
          'seller_terrains/$currentUserId/${DateTime.now().millisecondsSinceEpoch}_$safeFileName';

      final triedBuckets = <String>{};
      final uploadErrors = <String>[];

      for (final bucket in <String>[_primaryPhotoBucket, _legacyPhotoBucket]) {
        if (triedBuckets.contains(bucket)) continue;
        triedBuckets.add(bucket);

        try {
          print('Uploading photo to: $bucket/$path');
          await _supabase.client.storage.from(bucket).upload(path, file);
          final publicUrl = _supabase.client.storage
              .from(bucket)
              .getPublicUrl(path);
          print('Photo uploaded successfully: $publicUrl');
          return publicUrl;
        } catch (e) {
          uploadErrors.add('$bucket => $e');

          // If the primary bucket fails for any reason, try legacy bucket once.
          if (bucket == _primaryPhotoBucket) {
            print(
              'Primary bucket failed, retrying on legacy bucket: $_legacyPhotoBucket/$path',
            );
            continue;
          }

          break;
        }
      }

      final combinedErrors = uploadErrors.join(' | ');
      throw Exception(combinedErrors);
    } catch (e) {
      print('Error uploading photo: $e');

      final errorText = e.toString();
      final lower = errorText.toLowerCase();
      if (lower.contains('permission') ||
          lower.contains('unauthorized') ||
          lower.contains('row-level security') ||
          lower.contains('rls')) {
        throw Exception(
          'Permission refusee sur Storage. Verifiez les policies INSERT du bucket terrain_images/documents pour authenticated.',
        );
      }
      if (lower.contains('404') || lower.contains('not found')) {
        throw Exception(
          'Bucket photo introuvable (terrain_images/documents). Creez le bucket dans Supabase Storage.',
        );
      }
      if (lower.contains('cors')) {
        throw Exception('Erreur CORS Storage.');
      }

      throw Exception('Erreur upload photo: $e');
    }
  }

  // Publish terrain to terrains_foncira table
  Future<String> publishTerrain(
    PublishState publishState, {
    bool featured = false,
  }) async {
    try {
      final currentUserId = await _resolveCurrentUserProfileId();

      final data = publishState.toSupabaseJson();
      data['seller_id'] = currentUserId;

      final response = await _supabase.client
          .from('terrains_foncira')
          .insert(data)
          .select();

      if (response.isEmpty) {
        throw Exception('Erreur lors de la creation du terrain');
      }

      final terrainId = response[0]['id'] as String;

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
        'user_id': userId,
        'subscription_type': 'featured',
        'price_fcfa': 15000,
        'status': 'active',
        'started_at': DateTime.now().toIso8601String(),
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Erreur creation abonnement: $e');
    }
  }

  Future<double> getUploadProgress(int uploadedSize, int totalSize) async {
    return uploadedSize / totalSize;
  }

  // Delete uploaded photos (best effort)
  Future<void> deletePhotos(List<String> photoNames) async {
    try {
      for (final name in photoNames) {
        await _supabase.client.storage.from(_primaryPhotoBucket).remove([name]);
      }
    } catch (e) {
      print('Erreur suppression photos: $e');
    }
  }
}
