import 'dart:io';
import 'supabase_service.dart';

// ══════════════════════════════════════════════════════════════
//  FONCIRA — Storage Service (File uploads)
// ══════════════════════════════════════════════════════════════

class StorageService {
  final SupabaseService _supabase = SupabaseService();
  static const String bucketName = 'documents';

  // ── Upload document ────────────────────────────────────────
  Future<String?> uploadDocument({
    required String verificationId,
    required File file,
    required String documentCategory,
  }) async {
    try {
      if (_supabase.currentUserId == null) {
        throw Exception('User not authenticated');
      }

      // Generate unique filename
      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${file.path.split('/').last}';
      final filePath = '$verificationId/$fileName';

      // Upload to Supabase Storage
      await _supabase.client.storage.from(bucketName).upload(filePath, file);

      // Register document metadata in database
      final fileExtension = file.path.split('.').last.toUpperCase();
      await _supabase.client.from('verification_documents').insert({
        'verification_id': verificationId,
        'file_name': file.path.split('/').last,
        'file_path': filePath,
        'file_type': fileExtension,
        'document_category': documentCategory,
        'uploaded_at': DateTime.now().toIso8601String(),
      });

      // Get public URL
      final publicUrl = _supabase.client.storage
          .from(bucketName)
          .getPublicUrl(filePath);

      return publicUrl;
    } catch (e) {
      throw Exception('Failed to upload document: $e');
    }
  }

  // ── Upload multiple documents ──────────────────────────────
  Future<List<String>> uploadDocuments({
    required String verificationId,
    required List<File> files,
    required String documentCategory,
  }) async {
    try {
      final urls = <String>[];
      for (final file in files) {
        final url = await uploadDocument(
          verificationId: verificationId,
          file: file,
          documentCategory: documentCategory,
        );
        if (url != null) {
          urls.add(url);
        }
      }
      return urls;
    } catch (e) {
      throw Exception('Failed to upload documents: $e');
    }
  }

  // ── Get documents for verification ────────────────────────
  Future<List<Map<String, dynamic>>> getDocuments(String verificationId) async {
    try {
      final response = await _supabase.client
          .from('verification_documents')
          .select('*')
          .eq('verification_id', verificationId)
          .order('uploaded_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Failed to get documents: $e');
    }
  }

  // ── Delete document ────────────────────────────────────────
  Future<bool> deleteDocument(String documentId, String filePath) async {
    try {
      // Delete from storage
      await _supabase.client.storage.from(bucketName).remove([filePath]);

      // Delete from database
      await _supabase.client
          .from('verification_documents')
          .delete()
          .eq('id', documentId);

      return true;
    } catch (e) {
      throw Exception('Failed to delete document: $e');
    }
  }

  // ── Get public URL for file ────────────────────────────────
  String getPublicUrl(String filePath) {
    try {
      return _supabase.client.storage.from(bucketName).getPublicUrl(filePath);
    } catch (e) {
      return '';
    }
  }

  // ── Upload terrain photo ───────────────────────────────────
  Future<String?> uploadTerrainPhoto({
    required String terrainId,
    required File file,
  }) async {
    try {
      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}_terrain_photo.${file.path.split('.').last}';
      final filePath = 'terrains/$terrainId/$fileName';

      await _supabase.client.storage.from(bucketName).upload(filePath, file);

      return _supabase.client.storage.from(bucketName).getPublicUrl(filePath);
    } catch (e) {
      throw Exception('Failed to upload terrain photo: $e');
    }
  }

  // ── Upload milestone photo ────────────────────────────────
  Future<String?> uploadMilestonePhoto({
    required String verificationId,
    required String milestoneDay,
    required File file,
  }) async {
    try {
      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${milestoneDay}.${file.path.split('.').last}';
      final filePath = 'milestones/$verificationId/$fileName';

      await _supabase.client.storage.from(bucketName).upload(filePath, file);

      return _supabase.client.storage.from(bucketName).getPublicUrl(filePath);
    } catch (e) {
      throw Exception('Failed to upload milestone photo: $e');
    }
  }
}
