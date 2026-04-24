import 'supabase_service.dart';

class TerrainService {
  final SupabaseService _supabase = SupabaseService();

  Map<String, dynamic> _normalizeTerrain(Map<String, dynamic> row) {
    final map = Map<String, dynamic>.from(row);
    final photoUrl =
        map['main_photo_url'] ??
        _extractFirstPhotoUrl(map['additional_photos']);

    final priceValue = map['price'] ?? map['price_fcfa'];
    final surfaceValue = map['surface'] ?? map['surface_m2'];

    map['price'] = priceValue is num
        ? priceValue
        : num.tryParse(priceValue?.toString() ?? '') ?? 0;
    map['price_fcfa'] = map['price_fcfa'] ?? map['price'];
    map['surface'] = surfaceValue is num
        ? surfaceValue
        : num.tryParse(surfaceValue?.toString() ?? '') ?? 0;
    map['photo_url'] = map['photo_url'] ?? photoUrl;
    map['surface_m2'] = map['surface_m2'] ?? map['surface'];
    map['city'] = map['city'] ?? map['ville'];
    map['location'] = map['location'] ?? map['ville'] ?? '';

    return map;
  }

  String? _extractFirstPhotoUrl(dynamic additionalPhotos) {
    if (additionalPhotos == null) return null;

    if (additionalPhotos is List && additionalPhotos.isNotEmpty) {
      final first = additionalPhotos.first;
      if (first is String && first.isNotEmpty) return first;
      if (first is Map) {
        final url = first['url'] ?? first['photo_url'];
        if (url is String && url.isNotEmpty) return url;
      }
    }

    if (additionalPhotos is Map) {
      final url = additionalPhotos['url'] ?? additionalPhotos['photo_url'];
      if (url is String && url.isNotEmpty) return url;
    }

    return null;
  }

  Future<List<Map<String, dynamic>>> getTerrains({
    String? ville,
    String? documentType,
    double? minPrice,
    double? maxPrice,
    double? minSurface,
    double? maxSurface,
    String? status,
  }) async {
    try {
      var query = _supabase.client
          .from('terrains_foncira')
          .select('*')
          .eq('status', status ?? 'publie')
          .isFilter('deleted_at', null);

      if (ville != null && ville.isNotEmpty) {
        query = query.eq('ville', ville);
      }
      if (documentType != null && documentType.isNotEmpty) {
        query = query.eq('document_type', documentType);
      }
      if (minPrice != null) {
        query = query.gte('price_fcfa', minPrice);
      }
      if (maxPrice != null) {
        query = query.lte('price_fcfa', maxPrice);
      }
      if (minSurface != null) {
        query = query.gte('surface', minSurface);
      }
      if (maxSurface != null) {
        query = query.lte('surface', maxSurface);
      }

      final response = await query
          .order('published_at', ascending: false)
          .order('created_at', ascending: false);

      return (response as List)
          .map((e) => _normalizeTerrain(Map<String, dynamic>.from(e)))
          .toList();
    } catch (e) {
      throw Exception('Failed to get terrains: $e');
    }
  }

  Future<List<Map<String, dynamic>>> searchTerrains(String query) async {
    try {
      final q = query.trim();
      if (q.isEmpty) return getTerrains();

      final escaped = q.replaceAll('%', '').replaceAll(',', ' ');
      final response = await _supabase.client
          .from('terrains_foncira')
          .select('*')
          .eq('status', 'publie')
          .isFilter('deleted_at', null)
          .or(
            'title.ilike.%$escaped%,location.ilike.%$escaped%,ville.ilike.%$escaped%,quartier.ilike.%$escaped%',
          )
          .order('published_at', ascending: false)
          .order('created_at', ascending: false);

      return (response as List)
          .map((e) => _normalizeTerrain(Map<String, dynamic>.from(e)))
          .toList();
    } catch (e) {
      final terrains = await getTerrains();
      final q = query.toLowerCase();
      return terrains.where((terrain) {
        final title = (terrain['title'] ?? '').toString().toLowerCase();
        final location = (terrain['location'] ?? '').toString().toLowerCase();
        final ville = (terrain['ville'] ?? '').toString().toLowerCase();
        return title.contains(q) || location.contains(q) || ville.contains(q);
      }).toList();
    }
  }

  Future<Map<String, dynamic>?> getTerrain(String terrainId) async {
    try {
      final response = await _supabase.client
          .from('terrains_foncira')
          .select('*')
          .eq('id', terrainId)
          .eq('status', 'publie')
          .isFilter('deleted_at', null)
          .single();

      return _normalizeTerrain(Map<String, dynamic>.from(response));
    } catch (e) {
      return null;
    }
  }

  Future<List<String>> getAvailableVilles() async {
    try {
      final response = await _supabase.client
          .from('terrains_foncira')
          .select('ville')
          .eq('status', 'publie')
          .isFilter('deleted_at', null)
          .order('ville', ascending: true);

      final villes = <String>{};
      for (final item in response) {
        if (item['ville'] != null) {
          villes.add(item['ville'].toString());
        }
      }
      return villes.toList();
    } catch (e) {
      return [];
    }
  }

  Future<Map<String, double>> getPriceRange() async {
    try {
      final response = await _supabase.client
          .from('terrains_foncira')
          .select('price_fcfa')
          .eq('status', 'publie')
          .isFilter('deleted_at', null);

      if (response.isEmpty) {
        return {'min': 0, 'max': 10000000};
      }

      final prices = (response as List)
          .map((e) => e['price_fcfa'])
          .map((v) {
            if (v is num) return v.toDouble();
            return double.tryParse(v?.toString() ?? '');
          })
          .whereType<double>()
          .toList();

      if (prices.isEmpty) {
        return {'min': 0, 'max': 10000000};
      }
      prices.sort();

      return {'min': prices.first, 'max': prices.last};
    } catch (e) {
      return {'min': 0, 'max': 10000000};
    }
  }

  Future<Map<String, double>> getSurfaceRange() async {
    try {
      final response = await _supabase.client
          .from('terrains_foncira')
          .select('surface')
          .eq('status', 'publie')
          .isFilter('deleted_at', null);

      if (response.isEmpty) {
        return {'min': 0, 'max': 10000};
      }

      final surfaces = (response as List)
          .map((e) => e['surface'])
          .map((v) {
            if (v is num) return v.toDouble();
            return double.tryParse(v?.toString() ?? '');
          })
          .whereType<double>()
          .toList();

      if (surfaces.isEmpty) {
        return {'min': 0, 'max': 10000};
      }
      surfaces.sort();

      return {'min': surfaces.first, 'max': surfaces.last};
    } catch (e) {
      return {'min': 0, 'max': 10000};
    }
  }

  Stream<List<Map<String, dynamic>>> getTerrainStream() {
    try {
      return _supabase.client
          .from('terrains_foncira')
          .stream(primaryKey: ['id'])
          .eq('status', 'publie')
          .order('created_at', ascending: false)
          .map(
            (maps) => maps
                .where((m) => m['deleted_at'] == null)
                .map((e) => _normalizeTerrain(Map<String, dynamic>.from(e)))
                .toList(),
          );
    } catch (e) {
      return Stream.error('Failed to stream terrains: $e');
    }
  }

  List<String> getDocumentTypes() {
    return [
      'titre_foncier',
      'logement',
      'convention',
      'recu_vente',
      'aucun_document',
      'ne_sais_pas',
    ];
  }

  List<String> getTerrainStatuses() {
    return ['draft', 'publie', 'suspendu', 'vendu', 'archive'];
  }
}
