import 'package:latlong2/latlong.dart';

// ══════════════════════════════════════════════════════════════
//  FONCIRA — Enriched Terrain Model
// ══════════════════════════════════════════════════════════════

enum DocumentType {
  titreFoncier,
  attestation,
  aucunDocument,
  enCours,
}

enum TerrainStatus {
  disponible,
  enCoursDeVente,
  reserve,
}

enum SellerType {
  agence,
  particulier,
}

enum VerificationFoncira {
  nonVerifie,
  verificationDemandee,
  enCoursDeVerification,
  verifieFaibleRisque,
  verifieMoyenRisque,
  verifieRisqueEleve,
}

extension DocumentTypeExtension on DocumentType {
  String get label {
    switch (this) {
      case DocumentType.titreFoncier:
        return 'Titre Foncier';
      case DocumentType.attestation:
        return 'Attestation';
      case DocumentType.aucunDocument:
        return 'Aucun document';
      case DocumentType.enCours:
        return 'En cours';
    }
  }
}

extension TerrainStatusExtension on TerrainStatus {
  String get label {
    switch (this) {
      case TerrainStatus.disponible:
        return 'Disponible';
      case TerrainStatus.enCoursDeVente:
        return 'En cours de vente';
      case TerrainStatus.reserve:
        return 'Réservé';
    }
  }
}

extension SellerTypeExtension on SellerType {
  String get label {
    switch (this) {
      case SellerType.agence:
        return 'Agence';
      case SellerType.particulier:
        return 'Particulier';
    }
  }
}

extension VerificationFonciraExtension on VerificationFoncira {
  String get label {
    switch (this) {
      case VerificationFoncira.nonVerifie:
        return 'Non vérifié';
      case VerificationFoncira.verificationDemandee:
        return 'Vérification demandée';
      case VerificationFoncira.enCoursDeVerification:
        return 'En cours de vérification';
      case VerificationFoncira.verifieFaibleRisque:
        return 'Vérifié · Faible risque';
      case VerificationFoncira.verifieMoyenRisque:
        return 'Vérifié · Risque moyen';
      case VerificationFoncira.verifieRisqueEleve:
        return 'Vérifié · Risque élevé';
    }
  }

  String get shortLabel {
    switch (this) {
      case VerificationFoncira.nonVerifie:
        return 'Non vérifié';
      case VerificationFoncira.verificationDemandee:
        return 'Demandée';
      case VerificationFoncira.enCoursDeVerification:
        return 'En cours';
      case VerificationFoncira.verifieFaibleRisque:
        return 'Vérifié ✓';
      case VerificationFoncira.verifieMoyenRisque:
        return 'Risque moyen';
      case VerificationFoncira.verifieRisqueEleve:
        return 'Risque élevé';
    }
  }
}

class Terrain {
  final String id;
  final String title;
  final String location;
  final String quartier;
  final String zone;
  final String ville;
  final double price;
  final double surface;
  final bool isConstructible;
  final String? vue;
  final bool isViabilise;
  final String? description;
  final List<String> imageUrls;
  final double? latitude;
  final double? longitude;
  final DateTime createdAt;

  // ─── New FONCIRA fields ──────────────────────────────────
  final DocumentType documentType;
  final TerrainStatus terrainStatus;
  final SellerType sellerType;
  final String sellerName;
  final String? sellerPhone;
  final String? sellerAgencyName;
  final VerificationFoncira verificationFoncira;

  Terrain({
    required this.id,
    required this.title,
    required this.location,
    this.quartier = '',
    this.zone = '',
    this.ville = '',
    required this.price,
    required this.surface,
    required this.isConstructible,
    this.vue,
    required this.isViabilise,
    this.description,
    required this.imageUrls,
    this.latitude,
    this.longitude,
    required this.createdAt,
    required this.documentType,
    required this.terrainStatus,
    required this.sellerType,
    required this.sellerName,
    this.sellerPhone,
    this.sellerAgencyName,
    required this.verificationFoncira,
  });

  LatLng? get coordinates {
    if (latitude != null && longitude != null) {
      return LatLng(latitude!, longitude!);
    }
    return null;
  }

  String get imageUrl {
    if (imageUrls.isNotEmpty) {
      return imageUrls.first;
    }
    return 'assets/Image/terrain1.jpg';
  }

  String get formattedPrice {
    if (price >= 1000000) {
      final millions = price / 1000000;
      if (millions == millions.roundToDouble()) {
        return '${millions.toInt()} M FCFA';
      }
      return '${millions.toStringAsFixed(1)} M FCFA';
    }
    final formatted = price.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]} ',
    );
    return '$formatted FCFA';
  }

  String get formattedSurface {
    if (surface >= 10000) {
      final hectares = surface / 10000;
      return '${hectares.toStringAsFixed(hectares == hectares.roundToDouble() ? 0 : 1)} ha';
    }
    return '${surface.toStringAsFixed(0)} m²';
  }

  String get fullLocation {
    final parts = <String>[];
    if (quartier.isNotEmpty) parts.add(quartier);
    if (zone.isNotEmpty) parts.add(zone);
    if (ville.isNotEmpty) parts.add(ville);
    return parts.isNotEmpty ? parts.join(', ') : location;
  }

  String get timeAgo {
    final diff = DateTime.now().difference(createdAt);
    if (diff.inDays > 30) {
      return 'Il y a ${(diff.inDays / 30).floor()} mois';
    } else if (diff.inDays > 0) {
      return 'Il y a ${diff.inDays} jour${diff.inDays > 1 ? 's' : ''}';
    } else if (diff.inHours > 0) {
      return 'Il y a ${diff.inHours}h';
    } else {
      return 'À l\'instant';
    }
  }

  factory Terrain.fromJson(Map<String, dynamic> json) {
    return Terrain(
      id: json['id'],
      title: json['title'],
      location: json['location'] ?? '',
      quartier: json['quartier'] ?? '',
      zone: json['zone'] ?? '',
      ville: json['ville'] ?? '',
      price: (json['price'] as num).toDouble(),
      surface: (json['surface'] as num).toDouble(),
      isConstructible: json['is_constructible'] ?? false,
      vue: json['vue'],
      isViabilise: json['is_viabilise'] ?? false,
      description: json['description'],
      imageUrls: json['image_urls'] != null
          ? List<String>.from(json['image_urls'])
          : [],
      latitude: json['latitude'] != null
          ? (json['latitude'] as num).toDouble()
          : null,
      longitude: json['longitude'] != null
          ? (json['longitude'] as num).toDouble()
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      documentType: DocumentType.values.firstWhere(
        (e) => e.name == json['document_type'],
        orElse: () => DocumentType.aucunDocument,
      ),
      terrainStatus: TerrainStatus.values.firstWhere(
        (e) => e.name == json['terrain_status'],
        orElse: () => TerrainStatus.disponible,
      ),
      sellerType: SellerType.values.firstWhere(
        (e) => e.name == json['seller_type'],
        orElse: () => SellerType.particulier,
      ),
      sellerName: json['seller_name'] ?? 'Inconnu',
      sellerPhone: json['seller_phone'],
      sellerAgencyName: json['seller_agency_name'],
      verificationFoncira: VerificationFoncira.values.firstWhere(
        (e) => e.name == json['verification_foncira'],
        orElse: () => VerificationFoncira.nonVerifie,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'location': location,
      'quartier': quartier,
      'zone': zone,
      'ville': ville,
      'price': price,
      'surface': surface,
      'is_constructible': isConstructible,
      'vue': vue,
      'is_viabilise': isViabilise,
      'description': description,
      'image_urls': imageUrls,
      'latitude': latitude,
      'longitude': longitude,
      'created_at': createdAt.toIso8601String(),
      'document_type': documentType.name,
      'terrain_status': terrainStatus.name,
      'seller_type': sellerType.name,
      'seller_name': sellerName,
      'seller_phone': sellerPhone,
      'seller_agency_name': sellerAgencyName,
      'verification_foncira': verificationFoncira.name,
    };
  }

  Terrain copyWith({
    String? id,
    String? title,
    String? location,
    String? quartier,
    String? zone,
    String? ville,
    double? price,
    double? surface,
    bool? isConstructible,
    String? vue,
    bool? isViabilise,
    String? description,
    List<String>? imageUrls,
    double? latitude,
    double? longitude,
    DateTime? createdAt,
    DocumentType? documentType,
    TerrainStatus? terrainStatus,
    SellerType? sellerType,
    String? sellerName,
    String? sellerPhone,
    String? sellerAgencyName,
    VerificationFoncira? verificationFoncira,
  }) {
    return Terrain(
      id: id ?? this.id,
      title: title ?? this.title,
      location: location ?? this.location,
      quartier: quartier ?? this.quartier,
      zone: zone ?? this.zone,
      ville: ville ?? this.ville,
      price: price ?? this.price,
      surface: surface ?? this.surface,
      isConstructible: isConstructible ?? this.isConstructible,
      vue: vue ?? this.vue,
      isViabilise: isViabilise ?? this.isViabilise,
      description: description ?? this.description,
      imageUrls: imageUrls ?? this.imageUrls,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      createdAt: createdAt ?? this.createdAt,
      documentType: documentType ?? this.documentType,
      terrainStatus: terrainStatus ?? this.terrainStatus,
      sellerType: sellerType ?? this.sellerType,
      sellerName: sellerName ?? this.sellerName,
      sellerPhone: sellerPhone ?? this.sellerPhone,
      sellerAgencyName: sellerAgencyName ?? this.sellerAgencyName,
      verificationFoncira: verificationFoncira ?? this.verificationFoncira,
    );
  }
}
