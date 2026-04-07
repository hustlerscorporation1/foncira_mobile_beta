import 'supabase_service.dart';

// ══════════════════════════════════════════════════════════════
//  FONCIRA — Terrain Service
// ══════════════════════════════════════════════════════════════

class TerrainService {
  final SupabaseService _supabase = SupabaseService();

  // ── Get all terrains with filters ──────────────────────────
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
          .eq('status', status ?? 'disponible');

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
        query = query.gte('surface_m2', minSurface);
      }
      if (maxSurface != null) {
        query = query.lte('surface_m2', maxSurface);
      }

      final response = await query.order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Failed to get terrains: $e');
    }
  }

  // ── Search terrains by title/location ──────────────────────
  Future<List<Map<String, dynamic>>> searchTerrains(String query) async {
    try {
      final response = await _supabase.client
          .from('terrains_foncira')
          .select('*')
          .textSearch('fts', query)
          .eq('status', 'disponible')
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      // Fallback to simple filter if full text search fails
      return await getTerrains();
    }
  }

  // ── Get single terrain ────────────────────────────────────
  Future<Map<String, dynamic>?> getTerrain(String terrainId) async {
    try {
      final response = await _supabase.client
          .from('terrains_foncira')
          .select('*')
          .eq('id', terrainId)
          .single();

      return response;
    } catch (e) {
      return null;
    }
  }

  // ── Get available villes ──────────────────────────────────
  Future<List<String>> getAvailableVilles() async {
    try {
      final response = await _supabase.client
          .from('terrains_foncira')
          .select('ville')
          .eq('status', 'disponible')
          .order('ville', ascending: true);

      final villes = <String>{};
      for (var item in response) {
        if (item['ville'] != null) {
          villes.add(item['ville']);
        }
      }
      return villes.toList();
    } catch (e) {
      return [];
    }
  }

  // ── Get price range ────────────────────────────────────────
  Future<Map<String, double>> getPriceRange() async {
    try {
      final response = await _supabase.client
          .from('terrains_foncira')
          .select('price_fcfa')
          .eq('status', 'disponible');

      if (response.isEmpty) {
        return {'min': 0, 'max': 10000000};
      }

      final prices = (response as List)
          .map((e) => (e['price_fcfa'] as num).toDouble())
          .toList();
      prices.sort();

      return {'min': prices.first, 'max': prices.last};
    } catch (e) {
      return {'min': 0, 'max': 10000000};
    }
  }

  // ── Get surface range ───────────────────────────────────────
  Future<Map<String, double>> getSurfaceRange() async {
    try {
      final response = await _supabase.client
          .from('terrains_foncira')
          .select('surface_m2')
          .eq('status', 'disponible');

      if (response.isEmpty) {
        return {'min': 0, 'max': 10000};
      }

      final surfaces = (response as List)
          .map((e) => (e['surface_m2'] as num).toDouble())
          .toList();
      surfaces.sort();

      return {'min': surfaces.first, 'max': surfaces.last};
    } catch (e) {
      return {'min': 0, 'max': 10000};
    }
  }

  // ── Get terrains for stream (real-time updates) ───────────
  Stream<List<Map<String, dynamic>>> getTerrainStream() {
    try {
      return _supabase.client
          .from('terrains_foncira')
          .stream(primaryKey: ['id'])
          .eq('status', 'disponible')
          .order('created_at', ascending: false)
          .map((maps) => List<Map<String, dynamic>>.from(maps));
    } catch (e) {
      return Stream.error('Failed to stream terrains: $e');
    }
  }

  // ── Get document types ─────────────────────────────────────
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

  // ── Get status list ────────────────────────────────────────
  List<String> getTerrainStatuses() {
    return ['disponible', 'en_cours_vente', 'reserve', 'verifie'];
  }
}
