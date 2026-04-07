// ══════════════════════════════════════════════════════════════
//  PUBLISH STATE — 4-Step Terrain Publication Model
// ══════════════════════════════════════════════════════════════

enum PublishDocumentType {
  titreFoncier,
  logement,
  convention,
  recuVente,
  aucunDocument,
  neSaisPas,
}

String documentTypeToString(PublishDocumentType? type) {
  if (type == null) return 'Non sélectionné';
  switch (type) {
    case PublishDocumentType.titreFoncier:
      return 'Titre foncier';
    case PublishDocumentType.logement:
      return 'Logement';
    case PublishDocumentType.convention:
      return 'Convention';
    case PublishDocumentType.recuVente:
      return 'Reçu de vente';
    case PublishDocumentType.aucunDocument:
      return 'Aucun document';
    case PublishDocumentType.neSaisPas:
      return 'Je ne sais pas';
  }
}

class PublishState {
  // Step 1: Photos
  final List<String> photoUrls; // Supabase Storage URLs
  final List<int> photoOrders; // Order indices for drag-and-drop

  // Step 2: Essential info
  final String titre;
  final String localisation;
  final int superficie; // in m²
  final int prixFCFA;
  final PublishDocumentType? typeDocument;

  // Step 3: Description
  final String description;

  // Step 4: Publication status
  final bool isPublished;
  final bool isFeatured;

  const PublishState({
    this.photoUrls = const [],
    this.photoOrders = const [],
    this.titre = '',
    this.localisation = '',
    this.superficie = 0,
    this.prixFCFA = 0,
    this.typeDocument,
    this.description = '',
    this.isPublished = false,
    this.isFeatured = false,
  });

  // ── Getters ──
  bool hasMinPhotos() => photoUrls.length >= 3;
  bool hasMaxPhotos() => photoUrls.length >= 8;
  bool isEssentialInfoComplete() =>
      titre.isNotEmpty &&
      localisation.isNotEmpty &&
      superficie > 0 &&
      prixFCFA > 0 &&
      typeDocument != null;

  // ── Conversion USD ──
  static const double kFcfaToUsdRate = 655.957;

  static int convertToUSD(int fcfa) {
    return (fcfa / kFcfaToUsdRate).round();
  }

  int get prixUSD => convertToUSD(prixFCFA);

  // ── Copy with modifications ──
  PublishState copyWith({
    List<String>? photoUrls,
    List<int>? photoOrders,
    String? titre,
    String? localisation,
    int? superficie,
    int? prixFCFA,
    PublishDocumentType? typeDocument,
    String? description,
    bool? isPublished,
    bool? isFeatured,
  }) {
    return PublishState(
      photoUrls: photoUrls ?? this.photoUrls,
      photoOrders: photoOrders ?? this.photoOrders,
      titre: titre ?? this.titre,
      localisation: localisation ?? this.localisation,
      superficie: superficie ?? this.superficie,
      prixFCFA: prixFCFA ?? this.prixFCFA,
      typeDocument: typeDocument ?? this.typeDocument,
      description: description ?? this.description,
      isPublished: isPublished ?? this.isPublished,
      isFeatured: isFeatured ?? this.isFeatured,
    );
  }

  // ── Convert to Supabase JSON ──
  Map<String, dynamic> toSupabaseJson() {
    return {
      'titre': titre,
      'localisation': localisation,
      'superficie': superficie,
      'prix_fcfa': prixFCFA,
      'prix_usd': prixUSD,
      'type_document': typeDocument != null
          ? documentTypeToString(typeDocument)
          : null,
      'description': description,
      'photos_urls': photoUrls,
      'status': 'disponible',
      'is_archived': false,
      'is_featured': isFeatured,
      'featured_at': isFeatured ? DateTime.now().toIso8601String() : null,
      'views_count': 0,
      'verification_requests_count': 0,
      'direct_contacts_count': 0,
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    };
  }
}
