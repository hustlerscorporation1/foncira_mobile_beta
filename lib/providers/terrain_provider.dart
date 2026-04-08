import 'package:flutter/foundation.dart';
import '../services/terrain_service.dart';

// ══════════════════════════════════════════════════════════════
//  FONCIRA — Terrain Provider (Supabase-backed)
// ══════════════════════════════════════════════════════════════

class TerrainProvider with ChangeNotifier {
  final TerrainService _terrainService = TerrainService();

  List<Map<String, dynamic>> _terrains = [];
  List<Map<String, dynamic>> _filteredTerrains = [];
  final Set<String> _favoriteIds = {};
  bool _isLoading = false;
  String? _errorMessage;

  // Filters
  String _searchQuery = '';
  String? _filterVille;
  String? _filterDocumentType;
  double? _filterMinPrice;
  double? _filterMaxPrice;

  List<Map<String, dynamic>> get terrains => _filteredTerrains;
  List<Map<String, dynamic>> get allTerrains => _terrains;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;

  TerrainProvider() {
    loadTerrains();
  }

  Future<void> loadTerrains() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _terrains = await _terrainService.getTerrains();
      _applyFilters();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ── Search ─────────────────────────────────────────────────
  Future<void> search(String query) async {
    _searchQuery = query;

    if (query.isEmpty) {
      await _reloadWithFilters();
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      _terrains = await _terrainService.searchTerrains(query);
      _applyFilters();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ── Filters ────────────────────────────────────────────────
  Future<void> setFilterVille(String? ville) async {
    _filterVille = ville;
    await _reloadWithFilters();
  }

  Future<void> setFilterDocumentType(String? type) async {
    _filterDocumentType = type;
    await _reloadWithFilters();
  }

  Future<void> setFilterPriceRange(double? min, double? max) async {
    _filterMinPrice = min;
    _filterMaxPrice = max;
    await _reloadWithFilters();
  }

  Future<void> clearFilters() async {
    _searchQuery = '';
    _filterVille = null;
    _filterDocumentType = null;
    _filterMinPrice = null;
    _filterMaxPrice = null;
    await loadTerrains();
  }

  bool get hasActiveFilters =>
      _searchQuery.isNotEmpty ||
      _filterVille != null ||
      _filterDocumentType != null ||
      _filterMinPrice != null ||
      _filterMaxPrice != null;

  Future<void> _reloadWithFilters() async {
    _isLoading = true;
    notifyListeners();

    try {
      _terrains = await _terrainService.getTerrains(
        ville: _filterVille,
        documentType: _filterDocumentType,
        minPrice: _filterMinPrice,
        maxPrice: _filterMaxPrice,
      );
      _applyFilters();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _applyFilters() {
    _filteredTerrains = _terrains.where((t) {
      // Search query
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        final title = (t['title'] ?? '').toString().toLowerCase();
        final location = (t['location'] ?? '').toString().toLowerCase();
        final matches = title.contains(q) || location.contains(q);
        if (!matches) return false;
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
  Map<String, dynamic>? getTerrainById(String id) {
    try {
      return _terrains.firstWhere((t) => t['id'] == id);
    } catch (e) {
      return null;
    }
  }

  Future<List<String>> getAvailableVilles() async {
    try {
      return await _terrainService.getAvailableVilles();
    } catch (e) {
      return [];
    }
  }

  Future<Map<String, double>> getPriceRange() async {
    try {
      return await _terrainService.getPriceRange();
    } catch (e) {
      return {'min': 0, 'max': 10000000};
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // ── Additional getters (for compatibility) ─────────────────
  List<Map<String, dynamic>> get verifiedTerrains => _terrains
      .where(
        (t) =>
            (t['status'] ?? '').toString().toLowerCase() == 'publie' &&
            ((t['verification_status'] ?? '').toString().toLowerCase() ==
                    'verification_base_effectuee' ||
                (t['verification_status'] ?? '').toString().toLowerCase() ==
                    'verification_complete' ||
                (t['verification_status'] ?? '').toString().toLowerCase() ==
                    'risque_identifie' ||
                (t['verification_status'] ?? '')
                    .toString()
                    .toLowerCase()
                    .contains('verif')),
      )
      .toList();

  List<Map<String, dynamic>> get recentTerrains {
    if (_terrains.isEmpty) return [];
    final sorted = List<Map<String, dynamic>>.from(_terrains);
    sorted.sort((a, b) {
      final dateA = a['created_at'] ?? DateTime.now().toIso8601String();
      final dateB = b['created_at'] ?? DateTime.now().toIso8601String();
      return DateTime.parse(
        dateB.toString(),
      ).compareTo(DateTime.parse(dateA.toString()));
    });
    return sorted.take(6).toList();
  }

  List<Map<String, dynamic>> get favorites =>
      _terrains.where((t) => _favoriteIds.contains(t['id'])).toList();
}
