// ══════════════════════════════════════════════════════════════
//  FONCIRA — Verification Request Model
// ══════════════════════════════════════════════════════════════

import 'verification_step.dart';

enum VerificationSource {
  fonciraMarketplace,
  externe,
}

enum VerificationGlobalStatus {
  receptionnee,
  preAnalyse,
  verificationAdministrative,
  verificationTerrain,
  analyseFinale,
  rapportLivre,
}

extension VerificationSourceExtension on VerificationSource {
  String get label {
    switch (this) {
      case VerificationSource.fonciraMarketplace:
        return 'Marketplace FONCIRA';
      case VerificationSource.externe:
        return 'Terrain externe';
    }
  }
}

extension VerificationGlobalStatusExtension on VerificationGlobalStatus {
  String get label {
    switch (this) {
      case VerificationGlobalStatus.receptionnee:
        return 'Demande réceptionnée';
      case VerificationGlobalStatus.preAnalyse:
        return 'Pré-analyse';
      case VerificationGlobalStatus.verificationAdministrative:
        return 'Vérification administrative';
      case VerificationGlobalStatus.verificationTerrain:
        return 'Vérification terrain';
      case VerificationGlobalStatus.analyseFinale:
        return 'Analyse finale';
      case VerificationGlobalStatus.rapportLivre:
        return 'Rapport livré';
    }
  }

  double get progress {
    switch (this) {
      case VerificationGlobalStatus.receptionnee:
        return 0.1;
      case VerificationGlobalStatus.preAnalyse:
        return 0.25;
      case VerificationGlobalStatus.verificationAdministrative:
        return 0.45;
      case VerificationGlobalStatus.verificationTerrain:
        return 0.65;
      case VerificationGlobalStatus.analyseFinale:
        return 0.85;
      case VerificationGlobalStatus.rapportLivre:
        return 1.0;
    }
  }
}

class VerificationRequest {
  final String id;
  final String userId;
  final String? terrainId; // null if external terrain
  final VerificationSource source;
  final VerificationGlobalStatus globalStatus;
  final List<VerificationStep> steps;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Terrain info (for display)
  final String terrainTitle;
  final String terrainLocation;
  final double? terrainPrice;
  final String? terrainImageUrl;

  // External terrain info
  final String? externalLocation;
  final String? externalSellerContact;
  final double? externalPrice;
  final String? externalDescription;
  final List<String>? externalPhotos;
  final String? externalSource; // "réseaux sociaux", "bouche-à-oreille", etc.

  // Accompaniment
  final bool accompagnementRequested;

  VerificationRequest({
    required this.id,
    required this.userId,
    this.terrainId,
    required this.source,
    required this.globalStatus,
    required this.steps,
    required this.createdAt,
    required this.updatedAt,
    required this.terrainTitle,
    required this.terrainLocation,
    this.terrainPrice,
    this.terrainImageUrl,
    this.externalLocation,
    this.externalSellerContact,
    this.externalPrice,
    this.externalDescription,
    this.externalPhotos,
    this.externalSource,
    this.accompagnementRequested = false,
  });

  bool get isComplete =>
      globalStatus == VerificationGlobalStatus.rapportLivre;

  int get currentStepIndex =>
      VerificationGlobalStatus.values.indexOf(globalStatus);

  double get progressPercent => globalStatus.progress;
}
