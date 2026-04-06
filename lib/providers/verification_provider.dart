import 'package:flutter/foundation.dart';
import '../models/verification_request.dart';
import '../models/verification_step.dart';
import '../data/verification_data.dart';

// ══════════════════════════════════════════════════════════════
//  FONCIRA — Verification Provider
// ══════════════════════════════════════════════════════════════

class VerificationProvider with ChangeNotifier {
  List<VerificationRequest> _verifications = [];
  bool _isLoading = false;

  List<VerificationRequest> get verifications => _verifications;
  bool get isLoading => _isLoading;

  VerificationProvider() {
    loadVerifications();
  }

  void loadVerifications() {
    _isLoading = true;
    notifyListeners();

    _verifications = List.from(verificationsData);

    _isLoading = false;
    notifyListeners();
  }

  List<VerificationRequest> get activeVerifications =>
      _verifications.where((v) => !v.isComplete).toList();

  List<VerificationRequest> get completedVerifications =>
      _verifications.where((v) => v.isComplete).toList();

  int get activeCount => activeVerifications.length;

  VerificationRequest? getById(String id) {
    try {
      return _verifications.firstWhere((v) => v.id == id);
    } catch (e) {
      return null;
    }
  }

  // ── Create new verification request ────────────────────────
  void createFromMarketplace({
    required String terrainId,
    required String terrainTitle,
    required String terrainLocation,
    double? terrainPrice,
    String? terrainImageUrl,
  }) {
    final newRequest = VerificationRequest(
      id: 'VR${_verifications.length + 1}'.padLeft(5, '0'),
      userId: 'U001',
      terrainId: terrainId,
      source: VerificationSource.fonciraMarketplace,
      globalStatus: VerificationGlobalStatus.receptionnee,
      terrainTitle: terrainTitle,
      terrainLocation: terrainLocation,
      terrainPrice: terrainPrice,
      terrainImageUrl: terrainImageUrl,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      steps: _createInitialSteps(),
    );

    _verifications.insert(0, newRequest);
    notifyListeners();
  }

  void createFromExternal({
    required String title,
    required String location,
    double? price,
    String? sellerContact,
    String? description,
    String? source,
    List<String>? photos,
  }) {
    final newRequest = VerificationRequest(
      id: 'VR${_verifications.length + 1}'.padLeft(5, '0'),
      userId: 'U001',
      source: VerificationSource.externe,
      globalStatus: VerificationGlobalStatus.receptionnee,
      terrainTitle: title,
      terrainLocation: location,
      terrainPrice: price,
      externalLocation: location,
      externalSellerContact: sellerContact,
      externalPrice: price,
      externalDescription: description,
      externalSource: source,
      externalPhotos: photos,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      steps: _createInitialSteps(),
    );

    _verifications.insert(0, newRequest);
    notifyListeners();
  }

  List<VerificationStep> _createInitialSteps() {
    return [
      VerificationStep(
        stepName: 'Réception de la demande',
        description: 'Votre demande a été reçue et enregistrée.',
        status: StepStatus.termine,
        startedAt: DateTime.now(),
        completedAt: DateTime.now(),
        icon: '📩',
      ),
      VerificationStep(
        stepName: 'Pré-analyse',
        description: 'Analyse préliminaire des documents fournis.',
        status: StepStatus.enAttente,
        icon: '🔍',
      ),
      VerificationStep(
        stepName: 'Vérification administrative',
        description: 'Vérification auprès des services fonciers.',
        status: StepStatus.enAttente,
        icon: '📋',
      ),
      VerificationStep(
        stepName: 'Vérification terrain',
        description: 'Visite physique du terrain et vérification des bornes.',
        status: StepStatus.enAttente,
        icon: '🗺️',
      ),
      VerificationStep(
        stepName: 'Analyse finale',
        description: 'Synthèse et évaluation du risque.',
        status: StepStatus.enAttente,
        icon: '📊',
      ),
      VerificationStep(
        stepName: 'Livraison du rapport',
        description: 'Rapport de vérification remis à l\'utilisateur.',
        status: StepStatus.enAttente,
        icon: '📄',
      ),
    ];
  }
}
