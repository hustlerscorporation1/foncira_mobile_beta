import 'package:latlong2/latlong.dart';

// ══════════════════════════════════════════════════════════════
//  FONCIRA — Enriched Terrain Model
// ══════════════════════════════════════════════════════════════

enum DocumentType { titreFoncier, attestation, aucunDocument, enCours }

enum TerrainStatus { disponible, enCoursDeVente, reserve }

enum SellerType { agence, particulier }

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
    final formatted = price
        .toStringAsFixed(0)
        .replaceAllMapped(
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
    double parseDouble(dynamic value, {double fallback = 0}) {
      if (value is num) return value.toDouble();
      if (value == null) return fallback;
      return double.tryParse(value.toString()) ?? fallback;
    }

    double? parseNullableDouble(dynamic value) {
      if (value == null) return null;
      if (value is num) return value.toDouble();
      return double.tryParse(value.toString());
    }

    List<String> parseImageUrls(dynamic value) {
      if (value is List) {
        final urls = <String>[];
        for (final item in value) {
          if (item is String && item.isNotEmpty) {
            urls.add(item);
          } else if (item is Map) {
            final url =
                item['url'] ?? item['photo_url'] ?? item['main_photo_url'];
            if (url is String && url.isNotEmpty) {
              urls.add(url);
            }
          }
        }
        return urls;
      }
      if (value is Map) {
        final url =
            value['url'] ?? value['photo_url'] ?? value['main_photo_url'];
        if (url is String && url.isNotEmpty) {
          return [url];
        }
      }
      return [];
    }

    DateTime parseDateTime(dynamic value) {
      if (value is String) {
        final parsed = DateTime.tryParse(value);
        if (parsed != null) return parsed;
      }
      return DateTime.now();
    }

    DocumentType parseDocumentType(dynamic value) {
      final raw = value?.toString().toLowerCase() ?? '';
      switch (raw) {
        case 'titre_foncier':
          return DocumentType.titreFoncier;
        case 'logement':
        case 'convention':
        case 'recu_vente':
          return DocumentType.attestation;
        case 'aucun_document':
        case 'ne_sais_pas':
          return DocumentType.aucunDocument;
        default:
          return DocumentType.aucunDocument;
      }
    }

    TerrainStatus parseTerrainStatus(dynamic value) {
      final raw = value?.toString().toLowerCase() ?? '';
      switch (raw) {
        case 'disponible':
          return TerrainStatus.disponible;
        case 'en_cours_vente':
          return TerrainStatus.enCoursDeVente;
        case 'reserve':
        case 'verifie':
        case 'suspendu':
        case 'archivee':
          return TerrainStatus.reserve;
        default:
          return TerrainStatus.disponible;
      }
    }

    SellerType parseSellerType(dynamic value) {
      final raw = value?.toString().toLowerCase() ?? '';
      switch (raw) {
        case 'agence':
        case 'agence_immobiliere':
          return SellerType.agence;
        default:
          return SellerType.particulier;
      }
    }

    VerificationFoncira parseVerification(dynamic verificationFonciraRaw) {
      final raw =
          verificationFonciraRaw?.toString().toLowerCase() ??
          json['verification_status']?.toString().toLowerCase() ??
          '';

      switch (raw) {
        case 'verification_demandee':
        case 'verification_requested':
          return VerificationFoncira.verificationDemandee;
        case 'en_cours_verification':
        case 'en_cours_de_verification':
          return VerificationFoncira.enCoursDeVerification;
        case 'verification_base_effectuee':
          return VerificationFoncira.verifieFaibleRisque;
        case 'verification_complete':
          return VerificationFoncira.verifieMoyenRisque;
        case 'risque_identifie':
          return VerificationFoncira.verifieRisqueEleve;
        case 'non_verifie':
        default:
          return VerificationFoncira.nonVerifie;
      }
    }

    return Terrain(
      id: (json['id'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      location: (json['location'] ?? json['ville'] ?? '').toString(),
      quartier: json['quartier'] ?? '',
      zone: json['zone'] ?? '',
      ville: json['ville'] ?? '',
      price: parseDouble(json['price'] ?? json['price_fcfa']),
      surface: parseDouble(json['surface'] ?? json['surface_m2']),
      isConstructible: json['is_constructible'] ?? false,
      vue: json['vue'],
      isViabilise: json['is_viabilise'] ?? false,
      description: json['description'],
      imageUrls: parseImageUrls(
        json['image_urls'] ??
            json['additional_photos'] ??
            (json['photo_url'] != null ? [json['photo_url']] : null) ??
            (json['main_photo_url'] != null ? [json['main_photo_url']] : null),
      ),
      latitude: parseNullableDouble(json['latitude']),
      longitude: parseNullableDouble(json['longitude']),
      createdAt: parseDateTime(json['created_at']),
      documentType: parseDocumentType(json['document_type']),
      terrainStatus: parseTerrainStatus(json['terrain_status']),
      sellerType: parseSellerType(
        json['seller_type'] ?? json['seller_declared_type'],
      ),
      sellerName: json['seller_name'] ?? 'Inconnu',
      sellerPhone: json['seller_phone'],
      sellerAgencyName: json['seller_agency_name'],
      verificationFoncira: parseVerification(
        json['verification_foncira'] ?? json['verification_status'],
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
