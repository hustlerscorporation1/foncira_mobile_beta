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
  TypeDocument? typeDocument;
  int prixFCFA;
  int prixUSD;
  String lienPartage; // Sharing link (optional)
  List<DocumentUpload> documents; // Uploaded documents (optional)

  // FONCIRA terrain data (marketplace)
  String? terrainTitre; // Readonly terrain title from marketplace
  String? terrainPhoto; // Readonly terrain photo from marketplace
  String? terrainSurface; // Readonly terrain surface from marketplace

  // Client data
  String prenom;
  String whatsapp;
  String paysCode; // Déduit de l'indicatif WhatsApp

  // Verification data
  NiveauRisque niveauRisque;
  String agentNom;
  String agentPhoto; // Asset path
  DateTime? dateLivraison;

  VerificationState({
    this.localisation = '',
    this.typeDocument,
    this.prixFCFA = 0,
    this.prixUSD = 0,
    this.lienPartage = '',
    this.documents = const [],
    this.terrainTitre,
    this.terrainPhoto,
    this.terrainSurface,
    this.prenom = '',
    this.whatsapp = '',
    this.paysCode = 'TG', // Default: Togo
    this.niveauRisque = NiveauRisque.faible,
    this.agentNom = 'Kofi Mensah',
    this.agentPhoto = 'assets/agent_placeholder.png',
    this.dateLivraison,
  });

  // Calculate risk based on document type
  static NiveauRisque calculateRisk(TypeDocument? type) {
    if (type == null) return NiveauRisque.faible;
    switch (type) {
      case TypeDocument.titreFoncier:
        return NiveauRisque.faible;
      case TypeDocument.aucunDocument:
      case TypeDocument.neSaisPas:
        return NiveauRisque.eleve;
      case TypeDocument.logement:
      case TypeDocument.convention:
      case TypeDocument.recuVente:
        return NiveauRisque.modere;
    }
  }

  // Convert FCFA to USD using centralized rate
  static int convertToUSD(int fcfa) {
    const double kFcfaToUsdRate = 655.957;
    return (fcfa / kFcfaToUsdRate).round();
  }

  // Copy with
  VerificationState copyWith({
    String? localisation,
    TypeDocument? typeDocument,
    int? prixFCFA,
    int? prixUSD,
    String? lienPartage,
    List<DocumentUpload>? documents,
    String? terrainTitre,
    String? terrainPhoto,
    String? terrainSurface,
    String? prenom,
    String? whatsapp,
    String? paysCode,
    NiveauRisque? niveauRisque,
    String? agentNom,
    String? agentPhoto,
    DateTime? dateLivraison,
  }) {
    return VerificationState(
      localisation: localisation ?? this.localisation,
      typeDocument: typeDocument ?? this.typeDocument,
      prixFCFA: prixFCFA ?? this.prixFCFA,
      prixUSD: prixUSD ?? this.prixUSD,
      lienPartage: lienPartage ?? this.lienPartage,
      documents: documents ?? this.documents,
      terrainTitre: terrainTitre ?? this.terrainTitre,
      terrainPhoto: terrainPhoto ?? this.terrainPhoto,
      terrainSurface: terrainSurface ?? this.terrainSurface,
      prenom: prenom ?? this.prenom,
      whatsapp: whatsapp ?? this.whatsapp,
      paysCode: paysCode ?? this.paysCode,
      niveauRisque: niveauRisque ?? this.niveauRisque,
      agentNom: agentNom ?? this.agentNom,
      agentPhoto: agentPhoto ?? this.agentPhoto,
      dateLivraison: dateLivraison ?? this.dateLivraison,
    );
  }
}
