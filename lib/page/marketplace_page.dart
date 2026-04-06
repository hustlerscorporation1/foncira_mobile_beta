import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../theme/colors.dart';
import '../providers/terrain_provider.dart';
import '../models/terrain.dart';
import '../component/terrain_card.dart';
import '../component/search_filter_bar.dart';
import 'terrain_detail_foncira.dart';

// ══════════════════════════════════════════════════════════════
//  FONCIRA — Marketplace Page (full terrain listing)
// ══════════════════════════════════════════════════════════════

class MarketplacePage extends StatefulWidget {
  const MarketplacePage({super.key});

  @override
  State<MarketplacePage> createState() => _MarketplacePageState();
}

class _MarketplacePageState extends State<MarketplacePage> {
  final _searchController = TextEditingController();
  bool _isGridView = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TerrainProvider>();

    return Scaffold(
      backgroundColor: kDarkBg,
      appBar: AppBar(
        backgroundColor: kDarkBg,
        title: Text(
          'Marketplace',
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              setState(() => _isGridView = !_isGridView);
            },
            icon: Icon(
              _isGridView ? Icons.view_list_rounded : Icons.grid_view_rounded,
              color: kTextSecondary,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Search & Filter ──
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
            child: SearchFilterBar(
              controller: _searchController,
              onChanged: (q) => provider.search(q),
              hasActiveFilters: provider.hasActiveFilters,
              onFilterTap: () => _showFilterSheet(context, provider),
            ),
          ),

          // ── Filter chips ──
          if (provider.hasActiveFilters)
            Container(
              height: 42,
              margin: const EdgeInsets.only(top: 12),
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  _buildClearChip(provider),
                  const SizedBox(width: 8),
                ],
              ),
            ),

          // ── Results count ──
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Row(
              children: [
                Text(
                  '${provider.terrains.length} terrain${provider.terrains.length > 1 ? 's' : ''}',
                  style: GoogleFonts.inter(
                    color: kTextMuted,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),

          // ── Terrain List ──
          Expanded(
            child: provider.terrains.isEmpty
                ? _buildEmptyState()
                : _isGridView
                    ? _buildGridView(provider)
                    : _buildListView(provider),
          ),
        ],
      ),
    );
  }

  Widget _buildListView(TerrainProvider provider) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: provider.terrains.length,
      itemBuilder: (context, index) {
        final terrain = provider.terrains[index];
        return TerrainCard(
          terrain: terrain,
          isHorizontal: true,
          isFavorite: provider.isFavorite(terrain.id),
          onFavoriteTap: () => provider.toggleFavorite(terrain.id),
          onTap: () => _openDetail(terrain),
        );
      },
    );
  }

  Widget _buildGridView(TerrainProvider provider) {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        childAspectRatio: 0.68,
      ),
      itemCount: provider.terrains.length,
      itemBuilder: (context, index) {
        final terrain = provider.terrains[index];
        return TerrainCard(
          terrain: terrain,
          isFavorite: provider.isFavorite(terrain.id),
          onFavoriteTap: () => provider.toggleFavorite(terrain.id),
          onTap: () => _openDetail(terrain),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.search_off_rounded, color: kTextMuted, size: 48),
          const SizedBox(height: 16),
          Text(
            'Aucun terrain trouvé',
            style: GoogleFonts.outfit(
              color: kTextSecondary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Essayez de modifier vos filtres',
            style: GoogleFonts.inter(
              color: kTextMuted,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClearChip(TerrainProvider provider) {
    return GestureDetector(
      onTap: () {
        provider.clearFilters();
        _searchController.clear();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: kDangerSurface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: kDanger.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.close_rounded, color: kDanger, size: 14),
            const SizedBox(width: 4),
            Text(
              'Effacer filtres',
              style: GoogleFonts.inter(
                color: kDanger,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openDetail(Terrain terrain) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TerrainDetailFoncira(terrain: terrain),
      ),
    );
  }

  void _showFilterSheet(BuildContext context, TerrainProvider provider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: kDarkCard,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => _FilterSheet(provider: provider),
    );
  }
}

class _FilterSheet extends StatefulWidget {
  final TerrainProvider provider;
  const _FilterSheet({required this.provider});

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  @override
  Widget build(BuildContext context) {
    final cities = widget.provider.availableCities;

    return Container(
      padding: const EdgeInsets.all(24),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.7,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: kBorderDark,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Filtres',
            style: GoogleFonts.outfit(
              color: kTextPrimary,
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 24),

          // ── City filter ──
          Text(
            'Ville',
            style: GoogleFonts.inter(
              color: kTextSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _filterChip('Toutes', null, widget.provider),
              ...cities.map(
                (city) => _filterChip(city, city, widget.provider),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // ── Document type ──
          Text(
            'Type de document',
            style: GoogleFonts.inter(
              color: kTextSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: DocumentType.values.map((type) {
              return _docFilterChip(type, widget.provider);
            }).toList(),
          ),
          const SizedBox(height: 24),

          // ── Apply button ──
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(
                'Appliquer',
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _filterChip(String label, String? city, TerrainProvider provider) {
    // Note: comparing with provider internal state would need a getter — simplified here
    return GestureDetector(
      onTap: () {
        provider.setFilterVille(city);
        setState(() {});
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: kDarkCardLight,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: kBorderDark),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            color: kTextSecondary,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _docFilterChip(DocumentType type, TerrainProvider provider) {
    return GestureDetector(
      onTap: () {
        provider.setFilterDocumentType(type);
        setState(() {});
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: kDarkCardLight,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: kBorderDark),
        ),
        child: Text(
          type.label,
          style: GoogleFonts.inter(
            color: kTextSecondary,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
