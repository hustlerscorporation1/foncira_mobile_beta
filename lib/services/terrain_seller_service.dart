// ══════════════════════════════════════════════════════════════
//  FONCIRA — Terrain Seller Service
// ══════════════════════════════════════════════════════════════
// Service for sellers to submit, manage, and publish terrains

import 'package:foncira/services/supabase_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';

class TerrainSellerService {
  static final TerrainSellerService _instance =
      TerrainSellerService._internal();
  final supabase = SupabaseService().client;

  factory TerrainSellerService() {
    return _instance;
  }

  TerrainSellerService._internal();

  Future<String> _resolveCurrentUserId() async {
    final authUserId = supabase.auth.currentUser?.id;
    if (authUserId == null) throw Exception('User not authenticated');

    try {
      final profile = await supabase
          .from('users')
          .select('id')
          .or('id.eq.$authUserId,auth_id.eq.$authUserId')
          .maybeSingle();

      final resolved = profile?['id']?.toString();
      if (resolved != null && resolved.isNotEmpty) return resolved;
    } catch (_) {
      // Fallback to auth uid when profile lookup is not available yet.
    }

    return authUserId;
  }

  Future<List<String>> _resolveCurrentUserCandidateIds() async {
    final authUserId = supabase.auth.currentUser?.id;
    if (authUserId == null) throw Exception('User not authenticated');

    final ids = <String>{authUserId};
    try {
      ids.add(await _resolveCurrentUserId());
    } catch (_) {
      // Keep auth uid fallback only.
    }

    return ids.toList();
  }

  // ══════════════════════════════════════════════════════════════
  // Create Terrain (Draft)
  // ══════════════════════════════════════════════════════════════
  Future<Map<String, dynamic>?> createTerrain({
    required String title,
    required int priceFcfa,
    required double priceUsd,
    required double areaSqm,
    required String city,
    required String documentType, // 'titre', 'cession', 'permission'
    String? description,
    String? sellerNotes,
    File? imageFile,
  }) async {
    try {
      final userId = await _resolveCurrentUserId();

      // 1. Upload image if provided
      String? imageUrl;
      if (imageFile != null) {
        imageUrl = await _uploadImage(imageFile, userId);
      }

      // 2. Create terrain record
      final response = await supabase.from('terrains_foncira').insert({
        'title': title,
        'price_fcfa': priceFcfa,
        'price_usd': priceUsd,
        'area_sqm': areaSqm,
        'city': city,
        'document_type': documentType,
        'description': description,
        'seller_notes': sellerNotes,
        'featured_image': imageUrl,
        'status': 'draft', // Default status
        'seller_id': userId,
        'verification_status': 'non_verifie',
      }).select();

      return response.isNotEmpty ? response[0] as Map<String, dynamic> : null;
    } catch (e) {
      rethrow;
    }
  }

  // ══════════════════════════════════════════════════════════════
  // Update Terrain (Sellers can only update drafts)
  // ══════════════════════════════════════════════════════════════
  Future<Map<String, dynamic>?> updateTerrain({
    required String terrainId,
    String? title,
    int? priceFcfa,
    double? priceUsd,
    double? areaSqm,
    String? city,
    String? documentType,
    String? description,
    String? sellerNotes,
    File? imageFile,
  }) async {
    try {
      final userId = await _resolveCurrentUserId();

      // 1. Verify ownership
      final terrain = await supabase
          .from('terrains_foncira')
          .select('seller_id, status')
          .eq('id', terrainId)
          .single();

      if (terrain['seller_id'] != userId) {
        throw Exception('Vous ne pouvez modifier que vos propres terrains');
      }

      // 2. Upload new image if provided
      String? imageUrl;
      if (imageFile != null) {
        imageUrl = await _uploadImage(imageFile, userId);
      }

      // 3. Build update data
      final updateData = <String, dynamic>{};
      if (title != null) updateData['title'] = title;
      if (priceFcfa != null) updateData['price_fcfa'] = priceFcfa;
      if (priceUsd != null) updateData['price_usd'] = priceUsd;
      if (areaSqm != null) updateData['area_sqm'] = areaSqm;
      if (city != null) updateData['city'] = city;
      if (documentType != null) updateData['document_type'] = documentType;
      if (description != null) updateData['description'] = description;
      if (sellerNotes != null) updateData['seller_notes'] = sellerNotes;
      if (imageUrl != null) updateData['featured_image'] = imageUrl;

      final response = await supabase
          .from('terrains_foncira')
          .update(updateData)
          .eq('id', terrainId)
          .select();

      return response.isNotEmpty ? response[0] as Map<String, dynamic> : null;
    } catch (e) {
      rethrow;
    }
  }

  // ══════════════════════════════════════════════════════════════
  // Publish Terrain (Change status from draft to publie)
  // ══════════════════════════════════════════════════════════════
  Future<Map<String, dynamic>?> publishTerrain(String terrainId) async {
    try {
      final userId = await _resolveCurrentUserId();

      // 1. Verify ownership
      final terrain = await supabase
          .from('terrains_foncira')
          .select('seller_id, status')
          .eq('id', terrainId)
          .single();

      if (terrain['seller_id'] != userId) {
        throw Exception('Vous ne pouvez publier que vos propres terrains');
      }

      if (terrain['status'] != 'draft') {
        throw Exception('Seuls les brouillons peuvent être publiés');
      }

      // 2. Update status
      final response = await supabase
          .from('terrains_foncira')
          .update({
            'status': 'publie',
            'published_at': DateTime.now().toIso8601String(),
          })
          .eq('id', terrainId)
          .select();

      return response.isNotEmpty ? response[0] as Map<String, dynamic> : null;
    } catch (e) {
      rethrow;
    }
  }

  // ══════════════════════════════════════════════════════════════
  // Unpublish Terrain (Change status from publie to draft)
  // ══════════════════════════════════════════════════════════════
  Future<Map<String, dynamic>?> unpublishTerrain(String terrainId) async {
    try {
      final userId = await _resolveCurrentUserId();

      // 1. Verify ownership
      final terrain = await supabase
          .from('terrains_foncira')
          .select('seller_id, status')
          .eq('id', terrainId)
          .single();

      if (terrain['seller_id'] != userId) {
        throw Exception('Vous ne pouvez dépublier que vos propres terrains');
      }

      // 2. Update status
      final response = await supabase
          .from('terrains_foncira')
          .update({'status': 'draft'})
          .eq('id', terrainId)
          .select();

      return response.isNotEmpty ? response[0] as Map<String, dynamic> : null;
    } catch (e) {
      rethrow;
    }
  }

  // ══════════════════════════════════════════════════════════════
  // Get Seller's Terrains (all statuses for seller's dashboard)
  // ══════════════════════════════════════════════════════════════
  Future<List<Map<String, dynamic>>> getSellerTerrains({
    String?
    status, // Optional filter: 'draft', 'publie', 'verification_base_effectuee', etc.
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final userIds = await _resolveCurrentUserCandidateIds();

      var query = supabase
          .from('terrains_foncira')
          .select('*')
          .isFilter('deleted_at', null);

      if (userIds.length == 1) {
        query = query.eq('seller_id', userIds.first);
      } else {
        query = query.or(userIds.map((id) => 'seller_id.eq.$id').join(','));
      }

      if (status != null) {
        query = query.eq('status', status);
      }

      final response = await query
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);
      return (response as List).cast<Map<String, dynamic>>();
    } catch (e) {
      rethrow;
    }
  }

  // ══════════════════════════════════════════════════════════════
  // Get Seller's Published Terrains (for marketplace view)
  // ══════════════════════════════════════════════════════════════
  Future<List<Map<String, dynamic>>> getSellerPublishedTerrains({
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final userIds = await _resolveCurrentUserCandidateIds();

      var query = supabase
          .from('terrains_foncira')
          .select('*')
          .eq('status', 'publie')
          .isFilter('deleted_at', null);

      if (userIds.length == 1) {
        query = query.eq('seller_id', userIds.first);
      } else {
        query = query.or(userIds.map((id) => 'seller_id.eq.$id').join(','));
      }

      final response = await query
          .order('published_at', ascending: false)
          .range(offset, offset + limit - 1);

      return (response as List).cast<Map<String, dynamic>>();
    } catch (e) {
      rethrow;
    }
  }

  // ══════════════════════════════════════════════════════════════
  // Get Single Terrain (verify ownership)
  // ══════════════════════════════════════════════════════════════
  Future<Map<String, dynamic>?> getTerrain(String terrainId) async {
    try {
      final userId = await _resolveCurrentUserId();

      final response = await supabase
          .from('terrains_foncira')
          .select('*')
          .eq('id', terrainId)
          .eq('seller_id', userId)
          .isFilter('deleted_at', null)
          .single();

      return response as Map<String, dynamic>;
    } catch (e) {
      return null; // Terrain not found or not owned by user
    }
  }

  // ══════════════════════════════════════════════════════════════
  // Get Verification Status of Terrain
  // ══════════════════════════════════════════════════════════════
  Future<List<Map<String, dynamic>>> getTerrainVerifications(
    String terrainId,
  ) async {
    try {
      final userId = await _resolveCurrentUserId();

      // Verify ownership
      final terrain = await supabase
          .from('terrains_foncira')
          .select('seller_id')
          .eq('id', terrainId)
          .single();

      if (terrain['seller_id'] != userId) {
        throw Exception('Accès refusé');
      }

      final response = await supabase
          .from('verifications')
          .select('*, agents(name)')
          .eq('terrain_id', terrainId)
          .order('submitted_at', ascending: false);

      return (response as List).cast<Map<String, dynamic>>();
    } catch (e) {
      rethrow;
    }
  }

  // ══════════════════════════════════════════════════════════════
  // Archive Terrain (soft delete)
  // ══════════════════════════════════════════════════════════════
  Future<void> archiveTerrain(String terrainId) async {
    try {
      final userId = await _resolveCurrentUserId();

      // Verify ownership
      final terrain = await supabase
          .from('terrains_foncira')
          .select('seller_id')
          .eq('id', terrainId)
          .single();

      if (terrain['seller_id'] != userId) {
        throw Exception('Vous ne pouvez archiver que vos propres terrains');
      }

      await supabase
          .from('terrains_foncira')
          .update({'deleted_at': DateTime.now().toIso8601String()})
          .eq('id', terrainId);
    } catch (e) {
      rethrow;
    }
  }

  // ══════════════════════════════════════════════════════════════
  // Image Upload Helper
  // ══════════════════════════════════════════════════════════════
  Future<String> _uploadImage(File imageFile, String userId) async {
    try {
      final fileName = '${userId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final path = 'seller_terrains/$userId/$fileName';

      await supabase.storage
          .from('terrain_images')
          .upload(
            path,
            imageFile,
            fileOptions: FileOptions(cacheControl: '3600', upsert: false),
          );

      final publicUrl = supabase.storage
          .from('terrain_images')
          .getPublicUrl(path);

      return publicUrl;
    } catch (e) {
      throw Exception('Erreur lors du téléchargement de l\'image: $e');
    }
  }

  // ══════════════════════════════════════════════════════════════
  // Pick Image from Gallery
  // ══════════════════════════════════════════════════════════════
  Future<File?> pickImageFromGallery() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        return File(pickedFile.path);
      }
      return null;
    } catch (e) {
      throw Exception('Erreur lors de la sélection de l\'image: $e');
    }
  }

  // ══════════════════════════════════════════════════════════════
  // Stats for Seller Dashboard
  // ══════════════════════════════════════════════════════════════
  Future<Map<String, int>> getSellerStats() async {
    try {
      final userIds = await _resolveCurrentUserCandidateIds();

      var draftsQuery = supabase
          .from('terrains_foncira')
          .select('id')
          .eq('status', 'draft')
          .isFilter('deleted_at', null);
      if (userIds.length == 1) {
        draftsQuery = draftsQuery.eq('seller_id', userIds.first);
      } else {
        draftsQuery = draftsQuery.or(
          userIds.map((id) => 'seller_id.eq.$id').join(','),
        );
      }
      final drafts = await draftsQuery;

      var publishedQuery = supabase
          .from('terrains_foncira')
          .select('id')
          .eq('status', 'publie')
          .isFilter('deleted_at', null);
      if (userIds.length == 1) {
        publishedQuery = publishedQuery.eq('seller_id', userIds.first);
      } else {
        publishedQuery = publishedQuery.or(
          userIds.map((id) => 'seller_id.eq.$id').join(','),
        );
      }
      final published = await publishedQuery;

      var underVerificationQuery = supabase
          .from('terrains_foncira')
          .select('id')
          .neq('status', 'draft')
          .neq('status', 'publie')
          .isFilter('deleted_at', null);
      if (userIds.length == 1) {
        underVerificationQuery = underVerificationQuery.eq(
          'seller_id',
          userIds.first,
        );
      } else {
        underVerificationQuery = underVerificationQuery.or(
          userIds.map((id) => 'seller_id.eq.$id').join(','),
        );
      }
      final underVerification = await underVerificationQuery;

      return {
        'drafts': (drafts as List).length,
        'published': (published as List).length,
        'under_verification': (underVerification as List).length,
      };
    } catch (e) {
      return {'drafts': 0, 'published': 0, 'under_verification': 0};
    }
  }

  // Compatibility helpers used by seller dashboard widgets
  Future<Map<String, dynamic>> getSellerMetrics() async {
    try {
      final userIds = await _resolveCurrentUserCandidateIds();

      // Get terrains for this seller
      var query = supabase
          .from('terrains_foncira')
          .select('id, views_count, verification_requests_count, status')
          .isFilter('deleted_at', null);

      if (userIds.length == 1) {
        query = query.eq('seller_id', userIds.first);
      } else {
        query = query.or(userIds.map((id) => 'seller_id.eq.$id').join(','));
      }

      final terrains = await query;
      final terrainIds = (terrains as List)
          .map((t) => (t as Map)['id'] as String)
          .toList();

      // Sum verification requests and count sold terrains
      int verificationRequests = 0;
      int soldCount = 0;
      for (final terrain in terrains) {
        verificationRequests += _toInt(terrain['verification_requests_count']);
        if ((terrain['status'] as String?) == 'vendu') {
          soldCount++;
        }
      }

      // Get total views from terrain_analytics
      int viewsTotal = 0;
      if (terrainIds.isNotEmpty) {
        try {
          final analyticsQuery = supabase
              .from('terrain_analytics')
              .select('views_count');

          if (terrainIds.length == 1) {
            analyticsQuery.eq('terrain_id', terrainIds.first);
          } else {
            analyticsQuery.or(
              terrainIds.map((id) => 'terrain_id.eq.$id').join(','),
            );
          }

          final analytics = await analyticsQuery;
          for (final item in analytics as List) {
            viewsTotal += _toInt(item['views_count']);
          }
        } catch (_) {
          // Analytics not available, use terrain views_count as fallback
          for (final terrain in terrains) {
            viewsTotal += _toInt(terrain['views_count']);
          }
        }
      }

      return {
        'views_total': viewsTotal,
        'verification_requests': verificationRequests,
        'sold_count': soldCount,
      };
    } catch (_) {
      return {'views_total': 0, 'verification_requests': 0, 'sold_count': 0};
    }
  }

  Future<void> featureTerrain(String terrainId) async {
    final userId = await _resolveCurrentUserId();

    await supabase
        .from('terrains_foncira')
        .update({
          'is_featured': true,
          'featured_at': DateTime.now().toIso8601String(),
        })
        .eq('id', terrainId)
        .eq('seller_id', userId);
  }

  Future<void> markAsSold(String terrainId) async {
    final userId = await _resolveCurrentUserId();

    await supabase
        .from('terrains_foncira')
        .update({'status': 'sold', 'sold_at': DateTime.now().toIso8601String()})
        .eq('id', terrainId)
        .eq('seller_id', userId);
  }

  // ══════════════════════════════════════════════════════════════
  // Suspend Terrain (temporarily disable from marketplace)
  // ══════════════════════════════════════════════════════════════
  Future<void> suspendTerrain(String terrainId) async {
    try {
      final userId = await _resolveCurrentUserId();

      // Verify ownership
      final terrain = await supabase
          .from('terrains_foncira')
          .select('seller_id, status')
          .eq('id', terrainId)
          .single();

      if (terrain['seller_id'] != userId) {
        throw Exception('Vous ne pouvez suspendre que vos propres terrains');
      }

      await supabase
          .from('terrains_foncira')
          .update({
            'status': 'suspendu',
            'suspended_at': DateTime.now().toIso8601String(),
          })
          .eq('id', terrainId);
    } catch (e) {
      rethrow;
    }
  }

  // ══════════════════════════════════════════════════════════════
  // Delete Terrain (hard delete - permanent removal)
  // ══════════════════════════════════════════════════════════════
  Future<void> deleteTerrain(String terrainId) async {
    try {
      final userId = await _resolveCurrentUserId();

      // Verify ownership
      final terrain = await supabase
          .from('terrains_foncira')
          .select('seller_id')
          .eq('id', terrainId)
          .single();

      if (terrain['seller_id'] != userId) {
        throw Exception('Vous ne pouvez supprimer que vos propres terrains');
      }

      // First check if sold - only allow deletion of unsold terrains
      final terrainData = await supabase
          .from('terrains_foncira')
          .select('status')
          .eq('id', terrainId)
          .single();

      if (terrainData['status'] == 'sold') {
        throw Exception('Impossible de supprimer un terrain vendu');
      }

      // Soft delete by setting deleted_at timestamp
      await supabase
          .from('terrains_foncira')
          .update({
            'deleted_at': DateTime.now().toIso8601String(),
            'status': 'deleted',
          })
          .eq('id', terrainId);
    } catch (e) {
      rethrow;
    }
  }

  int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '0') ?? 0;
  }
}
