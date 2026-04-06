import 'package:flutter/foundation.dart';
import '../models/terrain.dart';
import '../data/terrain_data.dart';

// ══════════════════════════════════════════════════════════════
//  FONCIRA — Terrain Provider (enriched)
// ══════════════════════════════════════════════════════════════

class TerrainProvider with ChangeNotifier {
  List<Terrain> _terrains = [];
  List<Terrain> _filteredTerrains = [];
  final Set<String> _favoriteIds = {};
  bool _isLoading = false;
  String? _errorMessage;

  // Filters
  String _searchQuery = '';
  String? _filterVille;
  DocumentType? _filterDocumentType;
  TerrainStatus? _filterStatus;
  VerificationFoncira? _filterVerification;
  double? _filterMinPrice;
  double? _filterMaxPrice;
  double? _filterMinSurface;
  double? _filterMaxSurface;

  List<Terrain> get terrains => _filteredTerrains;
  List<Terrain> get allTerrains => _terrains;
  List<Terrain> get favorites =>
      _terrains.where((t) => _favoriteIds.contains(t.id)).toList();
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;

  TerrainProvider() {
    loadTerrains();
  }

  void loadTerrains() {
    _isLoading = true;
    notifyListeners();

    // Load mock data
    _terrains = List.from(terrainsFoncira);
    _applyFilters();

    _isLoading = false;
    notifyListeners();
  }

  // ── Search ─────────────────────────────────────────────────
  void search(String query) {
    _searchQuery = query;
    _applyFilters();
  }

  // ── Filters ────────────────────────────────────────────────
  void setFilterVille(String? ville) {
    _filterVille = ville;
    _applyFilters();
  }

  void setFilterDocumentType(DocumentType? type) {
    _filterDocumentType = type;
    _applyFilters();
  }

  void setFilterStatus(TerrainStatus? status) {
    _filterStatus = status;
    _applyFilters();
  }

  void setFilterVerification(VerificationFoncira? v) {
    _filterVerification = v;
    _applyFilters();
  }

  void setFilterPriceRange(double? min, double? max) {
    _filterMinPrice = min;
    _filterMaxPrice = max;
    _applyFilters();
  }

  void setFilterSurfaceRange(double? min, double? max) {
    _filterMinSurface = min;
    _filterMaxSurface = max;
    _applyFilters();
  }

  void clearFilters() {
    _searchQuery = '';
    _filterVille = null;
    _filterDocumentType = null;
    _filterStatus = null;
    _filterVerification = null;
    _filterMinPrice = null;
    _filterMaxPrice = null;
    _filterMinSurface = null;
    _filterMaxSurface = null;
    _applyFilters();
  }

  bool get hasActiveFilters =>
      _searchQuery.isNotEmpty ||
      _filterVille != null ||
      _filterDocumentType != null ||
      _filterStatus != null ||
      _filterVerification != null ||
      _filterMinPrice != null ||
      _filterMaxPrice != null ||
      _filterMinSurface != null ||
      _filterMaxSurface != null;

  void _applyFilters() {
    _filteredTerrains = _terrains.where((t) {
      // Search query
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        final matches = t.title.toLowerCase().contains(q) ||
            t.location.toLowerCase().contains(q) ||
            t.quartier.toLowerCase().contains(q) ||
            t.ville.toLowerCase().contains(q) ||
            t.zone.toLowerCase().contains(q) ||
            (t.description?.toLowerCase().contains(q) ?? false);
        if (!matches) return false;
      }

      // City filter
      if (_filterVille != null && t.ville != _filterVille) return false;

      // Document type filter
      if (_filterDocumentType != null && t.documentType != _filterDocumentType) {
        return false;
      }

      // Status filter
      if (_filterStatus != null && t.terrainStatus != _filterStatus) {
        return false;
      }

      // Verification filter
      if (_filterVerification != null &&
          t.verificationFoncira != _filterVerification) {
        return false;
      }

      // Price range
      if (_filterMinPrice != null && t.price < _filterMinPrice!) return false;
      if (_filterMaxPrice != null && t.price > _filterMaxPrice!) return false;

      // Surface range
      if (_filterMinSurface != null && t.surface < _filterMinSurface!) {
        return false;
      }
      if (_filterMaxSurface != null && t.surface > _filterMaxSurface!) {
        return false;
      }

      return true;
    }).toList();

    notifyListeners();
  }

  // ── Favorites ──────────────────────────────────────────────
  bool isFavorite(String terrainId) => _favoriteIds.contains(terrainId);

  void toggleFavorite(String terrainId) {
    if (_favoriteIds.contains(terrainId)) {
      _favoriteIds.remove(terrainId);
    } else {
      _favoriteIds.add(terrainId);
    }
    notifyListeners();
  }

  // ── Getters ────────────────────────────────────────────────
  Terrain? getTerrainById(String id) {
    try {
      return _terrains.firstWhere((t) => t.id == id);
    } catch (e) {
      return null;
    }
  }

  List<Terrain> get verifiedTerrains => _terrains
      .where((t) =>
          t.verificationFoncira == VerificationFoncira.verifieFaibleRisque ||
          t.verificationFoncira == VerificationFoncira.verifieMoyenRisque)
      .toList();

  List<Terrain> get recentTerrains {
    final sorted = List<Terrain>.from(_terrains);
    sorted.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return sorted.take(5).toList();
  }

  List<String> get availableCities {
    return _terrains.map((t) => t.ville).toSet().toList()..sort();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // ── Create Terrain (legacy support) ───────────────────────
  Future<Terrain?> createTerrain(Terrain terrain) async {
    _isLoading = true;
    notifyListeners();

    try {
      // TODO: Replace with actual Supabase insert
      final newTerrain = terrain.copyWith(
        id: 'T${DateTime.now().millisecondsSinceEpoch}',
      );
      _terrains.add(newTerrain);
      _applyFilters();
      _isLoading = false;
      notifyListeners();
      return newTerrain;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }
}
