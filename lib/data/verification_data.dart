import '../models/verification_request.dart';
import '../models/verification_step.dart';

// ══════════════════════════════════════════════════════════════
//  FONCIRA — Mock Verification Data
// ══════════════════════════════════════════════════════════════

final List<VerificationRequest> verificationsData = [
  // ── Verification nearly complete (from marketplace) ────────
  VerificationRequest(
    id: 'VR001',
    userId: 'U001',
    terrainId: 'T001',
    source: VerificationSource.fonciraMarketplace,
    globalStatus: VerificationGlobalStatus.analyseFinale,
    terrainTitle: 'Terrain résidentiel 500m² à Kégué',
    terrainLocation: 'Kégué, Lomé',
    terrainPrice: 15000000,
    terrainImageUrl: 'assets/Image/terrain1.jpg',
    createdAt: DateTime.now().subtract(const Duration(days: 10)),
    updatedAt: DateTime.now().subtract(const Duration(hours: 2)),
    steps: [
      VerificationStep(
        stepName: 'Réception de la demande',
        description: 'Votre demande a été reçue et enregistrée.',
        status: StepStatus.termine,
        startedAt: DateTime.now().subtract(const Duration(days: 10)),
        completedAt: DateTime.now().subtract(const Duration(days: 10)),
        notes: 'Demande #VR001 enregistrée.',
        icon: '📩',
      ),
      VerificationStep(
        stepName: 'Pré-analyse',
        description: 'Analyse préliminaire des documents fournis.',
        status: StepStatus.termine,
        startedAt: DateTime.now().subtract(const Duration(days: 9)),
        completedAt: DateTime.now().subtract(const Duration(days: 8)),
        notes: 'Documents conformes, procédure engagée.',
        icon: '🔍',
      ),
      VerificationStep(
        stepName: 'Vérification administrative',
        description: 'Vérification auprès des services fonciers.',
        status: StepStatus.termine,
        startedAt: DateTime.now().subtract(const Duration(days: 7)),
        completedAt: DateTime.now().subtract(const Duration(days: 4)),
        notes: 'Titre foncier validé au cadastre de Lomé.',
        icon: '📋',
      ),
      VerificationStep(
        stepName: 'Vérification terrain',
        description: 'Visite physique du terrain et vérification des bornes.',
        status: StepStatus.termine,
        startedAt: DateTime.now().subtract(const Duration(days: 3)),
        completedAt: DateTime.now().subtract(const Duration(days: 1)),
        notes: 'Terrain visité. Bornes conformes au plan cadastral.',
        icon: '🗺️',
      ),
      VerificationStep(
        stepName: 'Analyse finale',
        description:
            'Synthèse de toutes les vérifications et évaluation du risque.',
        status: StepStatus.enCours,
        startedAt: DateTime.now().subtract(const Duration(hours: 6)),
        icon: '📊',
      ),
      VerificationStep(
        stepName: 'Livraison du rapport',
        description: 'Rapport de vérification remis à l\'utilisateur.',
        status: StepStatus.enAttente,
        icon: '📄',
      ),
    ],
  ),

  // ── Verification in progress (external terrain) ────────────
  VerificationRequest(
    id: 'VR002',
    userId: 'U001',
    source: VerificationSource.externe,
    globalStatus: VerificationGlobalStatus.verificationAdministrative,
    terrainTitle: 'Terrain trouvé sur Facebook',
    terrainLocation: 'Tokoin, Lomé',
    terrainPrice: 18000000,
    externalLocation: 'Tokoin Wuiti, près du CEG',
    externalSellerContact: '+228 90 00 11 22 (vendeur : M. Agbéko)',
    externalPrice: 18000000,
    externalDescription:
        'Terrain de 600m² vu sur un groupe Facebook, vendeur dit avoir un titre foncier.',
    externalSource: 'Réseaux sociaux (Facebook)',
    createdAt: DateTime.now().subtract(const Duration(days: 5)),
    updatedAt: DateTime.now().subtract(const Duration(hours: 8)),
    steps: [
      VerificationStep(
        stepName: 'Réception de la demande',
        description: 'Votre demande a été reçue et enregistrée.',
        status: StepStatus.termine,
        startedAt: DateTime.now().subtract(const Duration(days: 5)),
        completedAt: DateTime.now().subtract(const Duration(days: 5)),
        icon: '📩',
      ),
      VerificationStep(
        stepName: 'Pré-analyse',
        description: 'Analyse préliminaire des informations fournies.',
        status: StepStatus.termine,
        startedAt: DateTime.now().subtract(const Duration(days: 4)),
        completedAt: DateTime.now().subtract(const Duration(days: 3)),
        notes:
            'Informations suffisantes. Vendeur identifié. Procédure lancée.',
        icon: '🔍',
      ),
      VerificationStep(
        stepName: 'Vérification administrative',
        description: 'Vérification auprès des services fonciers.',
        status: StepStatus.enCours,
        startedAt: DateTime.now().subtract(const Duration(days: 2)),
        icon: '📋',
      ),
      VerificationStep(
        stepName: 'Vérification terrain',
        description: 'Visite physique du terrain.',
        status: StepStatus.enAttente,
        icon: '🗺️',
      ),
      VerificationStep(
        stepName: 'Analyse finale',
        description: 'Synthèse des vérifications.',
        status: StepStatus.enAttente,
        icon: '📊',
      ),
      VerificationStep(
        stepName: 'Livraison du rapport',
        description: 'Rapport de vérification remis.',
        status: StepStatus.enAttente,
        icon: '📄',
      ),
    ],
  ),

  // ── Verification complete ──────────────────────────────────
  VerificationRequest(
    id: 'VR003',
    userId: 'U001',
    terrainId: 'T004',
    source: VerificationSource.fonciraMarketplace,
    globalStatus: VerificationGlobalStatus.rapportLivre,
    terrainTitle: 'Terrain commercial Avédji',
    terrainLocation: 'Avédji, Lomé',
    terrainPrice: 22000000,
    terrainImageUrl: 'assets/Image/terrain4.jpg',
    accompagnementRequested: true,
    createdAt: DateTime.now().subtract(const Duration(days: 30)),
    updatedAt: DateTime.now().subtract(const Duration(days: 15)),
    steps: [
      VerificationStep(
        stepName: 'Réception de la demande',
        description: 'Demande reçue.',
        status: StepStatus.termine,
        startedAt: DateTime.now().subtract(const Duration(days: 30)),
        completedAt: DateTime.now().subtract(const Duration(days: 30)),
        icon: '📩',
      ),
      VerificationStep(
        stepName: 'Pré-analyse',
        description: 'Analyse préliminaire.',
        status: StepStatus.termine,
        startedAt: DateTime.now().subtract(const Duration(days: 29)),
        completedAt: DateTime.now().subtract(const Duration(days: 27)),
        icon: '🔍',
      ),
      VerificationStep(
        stepName: 'Vérification administrative',
        description: 'Vérification cadastrale.',
        status: StepStatus.termine,
        startedAt: DateTime.now().subtract(const Duration(days: 26)),
        completedAt: DateTime.now().subtract(const Duration(days: 22)),
        notes: 'Titre foncier authentique confirmé.',
        icon: '📋',
      ),
      VerificationStep(
        stepName: 'Vérification terrain',
        description: 'Visite terrain effectuée.',
        status: StepStatus.termine,
        startedAt: DateTime.now().subtract(const Duration(days: 21)),
        completedAt: DateTime.now().subtract(const Duration(days: 18)),
        notes: 'Bornes conformes. Pas de litige avec les voisins.',
        icon: '🗺️',
      ),
      VerificationStep(
        stepName: 'Analyse finale',
        description: 'Analyse de risque finalisée.',
        status: StepStatus.termine,
        startedAt: DateTime.now().subtract(const Duration(days: 17)),
        completedAt: DateTime.now().subtract(const Duration(days: 16)),
        notes: 'Risque faible. Achat recommandé.',
        icon: '📊',
      ),
      VerificationStep(
        stepName: 'Livraison du rapport',
        description: 'Rapport livré.',
        status: StepStatus.termine,
        startedAt: DateTime.now().subtract(const Duration(days: 16)),
        completedAt: DateTime.now().subtract(const Duration(days: 15)),
        notes:
            'Rapport de vérification FONCIRA envoyé par email et disponible dans l\'app.',
        icon: '📄',
      ),
    ],
  ),
];
