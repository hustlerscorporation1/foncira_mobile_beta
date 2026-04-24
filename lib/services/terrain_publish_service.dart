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

      // Save required documents to verification_documents table
      await _saveDocumentsToDatabase(
        terrainId,
        publishState.requiredDocuments,
        publishState.optionalDocuments,
        currentUserId,
      );

      if (featured) {
        await _createVendorSubscription(terrainId, currentUserId);
      }

      // ── Create admin notification ──
      await _createAdminNotification(
        terrainId: terrainId,
        title: publishState.titre,
        sellerId: currentUserId,
      );

      return terrainId;
    } catch (e) {
      throw Exception('Erreur publication: $e');
    }
  }

  // Save documents to verification_documents table
  Future<void> _saveDocumentsToDatabase(
    String terrainId,
    Map<String, String> requiredDocuments,
    Map<String, String> optionalDocuments,
    String userId,
  ) async {
    try {
      final documents = <Map<String, dynamic>>[];

      // Add required documents
      for (final entry in requiredDocuments.entries) {
        documents.add({
          'terrain_id': terrainId,
          'document_url': entry.value,
          'document_category': entry.key,
          'document_type': _mapCategoryToType(entry.key),
          'uploaded_by': userId,
          'is_verified': false,
          'created_at': DateTime.now().toIso8601String(),
        });
      }

      // Add optional documents
      for (final entry in optionalDocuments.entries) {
        documents.add({
          'terrain_id': terrainId,
          'document_url': entry.value,
          'document_category': entry.key,
          'document_type': _mapCategoryToType(entry.key),
          'uploaded_by': userId,
          'is_verified': false,
          'is_optional': true,
          'created_at': DateTime.now().toIso8601String(),
        });
      }

      if (documents.isNotEmpty) {
        await _supabase.client.from('verification_documents').insert(documents);
        print('Documents saved successfully');
      }
    } catch (e) {
      print('Error saving documents: $e');
      // Don't throw - document save error shouldn't block terrain creation
    }
  }

  // Map document category to type
  String _mapCategoryToType(String category) {
    switch (category) {
      case 'titre_foncier':
        return 'titre_de_propriete';
      case 'plan_terrain':
        return 'plan_cadastral';
      case 'autorisation_vente':
        return 'autorisation';
      case 'recu_achat':
        return 'facture';
      default:
        return 'autre';
    }
  }

  // Create notification for admin to review terrain
  Future<void> _createAdminNotification({
    required String terrainId,
    required String title,
    required String sellerId,
  }) async {
    try {
      // Get all admin users
      final adminUsers = await _supabase.client
          .from('users')
          .select('id')
          .eq('role', 'admin');

      if (adminUsers.isEmpty) {
        print('Warning: No admin users found for notifications');
        return;
      }

      // Create notification for each admin
      for (final admin in adminUsers as List) {
        final adminId = admin['id'] as String;

        await _supabase.client.from('notifications').insert({
          'recipient_id': adminId,
          'notification_type': 'action_required',
          'title': 'Nouveau terrain à valider',
          'message': 'Terrain "$title" en attente de validation',
          'related_verification_id': terrainId,
          'is_read': false,
          'created_at': DateTime.now().toIso8601String(),
        });
      }
    } catch (e) {
      print('Error creating admin notification: $e');
      // Don't throw - notification error shouldn't block terrain creation
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

  // Upload document to Supabase Storage
  Future<String> uploadDocument(File file, String fileName) async {
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
          'seller_terrains/$currentUserId/documents/${DateTime.now().millisecondsSinceEpoch}_$safeFileName';

      print('Uploading document to: $_legacyPhotoBucket/$path');
      await _supabase.client.storage
          .from(_legacyPhotoBucket)
          .upload(path, file);

      final publicUrl = _supabase.client.storage
          .from(_legacyPhotoBucket)
          .getPublicUrl(path);

      print('Document uploaded successfully: $publicUrl');
      return publicUrl;
    } catch (e) {
      print('Error uploading document: $e');
      final errorText = e.toString();
      final lower = errorText.toLowerCase();

      if (lower.contains('permission') ||
          lower.contains('unauthorized') ||
          lower.contains('row-level security') ||
          lower.contains('rls')) {
        throw Exception(
          'Permission refusee. Verifiez les policies du bucket documents.',
        );
      }
      if (lower.contains('404') || lower.contains('not found')) {
        throw Exception('Bucket documents introuvable.');
      }

      throw Exception('Erreur upload: $e');
    }
  }

  // Delete uploaded document (best effort)
  Future<void> deleteDocument(String documentPath) async {
    try {
      await _supabase.client.storage.from(_legacyPhotoBucket).remove([
        documentPath,
      ]);
    } catch (e) {
      print('Erreur suppression document: $e');
    }
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
