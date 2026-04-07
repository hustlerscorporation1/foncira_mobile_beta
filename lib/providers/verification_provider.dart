import 'package:flutter/foundation.dart';
import '../models/verification_request.dart';
import '../models/verification_step.dart';
import '../services/verification_service.dart';
import '../services/supabase_service.dart';

// ══════════════════════════════════════════════════════════════
//  FONCIRA — Verification Provider (Supabase-backed)
// ══════════════════════════════════════════════════════════════

class VerificationProvider with ChangeNotifier {
  final VerificationService _verificationService = VerificationService();
  final SupabaseService _supabaseService = SupabaseService();

  List<Map<String, dynamic>> _verifications = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Map<String, dynamic>> get verifications => _verifications;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  VerificationProvider() {
    loadVerifications();
  }

  Future<void> loadVerifications() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      if (!_supabaseService.isAuthenticated) {
        _verifications = [];
      } else {
        _verifications = await _verificationService.getUserVerifications();
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  List<Map<String, dynamic>> get activeVerifications =>
      _verifications.where((v) => v['status'] != 'rapport_livre').toList();

  List<Map<String, dynamic>> get completedVerifications =>
      _verifications.where((v) => v['status'] == 'rapport_livre').toList();

  int get activeCount => activeVerifications.length;

  Map<String, dynamic>? getById(String id) {
    try {
      return _verifications.firstWhere((v) => v['id'] == id);
    } catch (e) {
      return null;
    }
  }

  // ── Create from marketplace ────────────────────────────────
  Future<bool> createFromMarketplace({
    required String terrainId,
    required String terrainTitle,
    required String terrainLocation,
    double? terrainPrice,
    String? documentType,
    String? sharingLink,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final verificationId = await _verificationService
          .createMarketplaceVerification(
            terrainId: terrainId,
            terrainTitle: terrainTitle,
            terrainLocation: terrainLocation,
            priceFCFA: terrainPrice ?? 150000,
            documentType: documentType ?? 'ne_sais_pas',
            sharingLink: sharingLink,
          );

      if (verificationId != null) {
        await loadVerifications();
        return true;
      }
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ── Create from external ───────────────────────────────────
  Future<bool> createFromExternal({
    required String title,
    required String location,
    double? price,
    String? sellerContact,
    String? description,
    String? documentType,
    String? sharingLink,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final verificationId = await _verificationService
          .createExternalVerification(
            terrainTitle: title,
            terrainLocation: location,
            priceFCFA: price ?? 150000,
            documentType: documentType ?? 'ne_sais_pas',
            sharingLink: sharingLink,
          );

      if (verificationId != null) {
        await loadVerifications();
        return true;
      }
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ── Update status ───────────────────────────────────────────
  Future<bool> updateStatus(String verificationId, String newStatus) async {
    try {
      final success = await _verificationService.updateVerificationStatus(
        verificationId,
        newStatus,
      );
      if (success) {
        await loadVerifications();
      }
      return success;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    }
  }

  // ── Complete milestone ────────────────────────────────────
  Future<bool> completeMilestone({
    required String milestoneId,
    String? notes,
    Map<String, dynamic>? locationPhotos,
  }) async {
    try {
      final success = await _verificationService.completeMilestone(
        milestoneId,
        notes: notes,
        locationPhotos: locationPhotos,
      );
      if (success) {
        await loadVerifications();
      }
      return success;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
