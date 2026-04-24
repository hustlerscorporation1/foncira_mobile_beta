import 'package:flutter/material.dart';

// Simple document upload model
class DocumentUpload {
  final String fileName;
  final String filePath; // Local path or URL
  final String fileType; // PDF, JPG, PNG
  final DateTime uploadedAt;

  DocumentUpload({
    required this.fileName,
    required this.filePath,
    required this.fileType,
    required this.uploadedAt,
  });
}

enum TypeDocument {
  titreFoncier('Titre foncier'),
  logement('Logement'),
  convention('Convention'),
  recuVente('Reçu de vente'),
  aucunDocument('Aucun document'),
  neSaisPas('Je ne sais pas');

  final String label;
  const TypeDocument(this.label);
}

enum NiveauRisque {
  faible('Risque faible', Color.fromARGB(255, 76, 175, 80)), // vert
  modere('Risque modéré', Color.fromARGB(255, 255, 152, 0)), // orange
  eleve('Risque élevé', Color.fromARGB(255, 244, 67, 54)); // rouge

  final String label;
  final Color color;
  const NiveauRisque(this.label, this.color);
}

class VerificationState {
  // Terrain data
  String localisation;
  List<TypeDocument> typeDocuments; // Multiple document types
  int prixFCFA;
  int prixUSD;
  String lienPartage; // Sharing link (optional)
  List<DocumentUpload> documents; // Uploaded documents (optional)
  bool consentGiven; // Case à cocher: accord du vendeur

  // FONCIRA terrain data (marketplace)
  String? terrainId; // Terrain ID from marketplace
  String? terrainTitre; // Readonly terrain title from marketplace
  String? terrainPhoto; // Readonly terrain photo from marketplace
  String? terrainSurface; // Readonly terrain surface from marketplace
  String? terrainLocation; // Terrain location/address

  // Client data
  String prenom;
  String whatsapp;
  String sellerWhatsapp; // Numéro WhatsApp du vendeur (obligatoire)
  String paysCode; // Déduit de l'indicatif WhatsApp

  // Service data
  String serviceType; // 'complete' ou 'accompaniment'

  // Verification data
  NiveauRisque niveauRisque;
  String agentNom;
  String agentPhoto; // Asset path
  DateTime? dateLivraison;

  // Backward-compatible view for legacy single-document code paths.
  TypeDocument? get typeDocument =>
      typeDocuments.isNotEmpty ? typeDocuments.first : null;

  VerificationState({
    this.localisation = '',
    List<TypeDocument>? typeDocuments,
    TypeDocument? typeDocument,
    this.prixFCFA = 0,
    this.prixUSD = 0,
    this.lienPartage = '',
    this.documents = const [],
    this.consentGiven = false,
    this.terrainId,
    this.terrainTitre,
    this.terrainPhoto,
    this.terrainSurface,
    this.terrainLocation,
    this.prenom = '',
    this.whatsapp = '',
    this.sellerWhatsapp = '',
    this.paysCode = 'TG', // Default: Togo
    this.serviceType = 'complete', // Vérification complète par défaut
    this.niveauRisque = NiveauRisque.faible,
    this.agentNom = 'Kofi Mensah',
    this.agentPhoto = 'assets/agent_placeholder.png',
    this.dateLivraison,
  }) : typeDocuments =
           typeDocuments ?? (typeDocument != null ? [typeDocument] : const []);

  // Calculate risk based on document types (highest risk wins)
  static NiveauRisque calculateRisk(List<TypeDocument> types) {
    if (types.isEmpty) return NiveauRisque.faible;

    // Check for high risk first
    if (types.contains(TypeDocument.aucunDocument) ||
        types.contains(TypeDocument.neSaisPas)) {
      return NiveauRisque.eleve;
    }

    // Check for moderate risk
    if (types.contains(TypeDocument.logement) ||
        types.contains(TypeDocument.convention) ||
        types.contains(TypeDocument.recuVente)) {
      return NiveauRisque.modere;
    }

    // Default to low risk (titre foncier or others)
    return NiveauRisque.faible;
  }

  // Convert FCFA to USD using centralized rate
  static int convertToUSD(int fcfa) {
    const double kFcfaToUsdRate = 655.957;
    return (fcfa / kFcfaToUsdRate).round();
  }

  // Copy with
  VerificationState copyWith({
    String? localisation,
    List<TypeDocument>? typeDocuments,
    int? prixFCFA,
    int? prixUSD,
    String? lienPartage,
    List<DocumentUpload>? documents,
    bool? consentGiven,
    String? terrainId,
    String? terrainTitre,
    String? terrainPhoto,
    String? terrainSurface,
    String? terrainLocation,
    String? prenom,
    String? whatsapp,
    String? sellerWhatsapp,
    String? paysCode,
    String? serviceType,
    NiveauRisque? niveauRisque,
    String? agentNom,
    String? agentPhoto,
    DateTime? dateLivraison,
  }) {
    return VerificationState(
      localisation: localisation ?? this.localisation,
      typeDocuments: typeDocuments ?? this.typeDocuments,
      prixFCFA: prixFCFA ?? this.prixFCFA,
      prixUSD: prixUSD ?? this.prixUSD,
      lienPartage: lienPartage ?? this.lienPartage,
      documents: documents ?? this.documents,
      consentGiven: consentGiven ?? this.consentGiven,
      terrainId: terrainId ?? this.terrainId,
      terrainTitre: terrainTitre ?? this.terrainTitre,
      terrainPhoto: terrainPhoto ?? this.terrainPhoto,
      terrainSurface: terrainSurface ?? this.terrainSurface,
      terrainLocation: terrainLocation ?? this.terrainLocation,
      prenom: prenom ?? this.prenom,
      whatsapp: whatsapp ?? this.whatsapp,
      sellerWhatsapp: sellerWhatsapp ?? this.sellerWhatsapp,
      paysCode: paysCode ?? this.paysCode,
      serviceType: serviceType ?? this.serviceType,
      niveauRisque: niveauRisque ?? this.niveauRisque,
      agentNom: agentNom ?? this.agentNom,
      agentPhoto: agentPhoto ?? this.agentPhoto,
      dateLivraison: dateLivraison ?? this.dateLivraison,
    );
  }
}
