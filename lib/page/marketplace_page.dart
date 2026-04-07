import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../theme/colors.dart';
import '../providers/terrain_provider.dart';
import '../component/search_filter_bar.dart';
import '../models/verification_state.dart';
import 'verification_tunnel_page.dart';

// ══════════════════════════════════════════════════════════════
//  FONCIRA — Marketplace (Supabase-backed)
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
          style: GoogleFonts.outfit(fontWeight: FontWeight.w700, fontSize: 20),
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

          // ── Results count ──
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Row(
              children: [
                if (!provider.isLoading)
                  Text(
                    '${provider.terrains.length} terrain${provider.terrains.length > 1 ? 's' : ''}',
                    style: GoogleFonts.inter(color: kTextMuted, fontSize: 13),
                  )
                else
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
              ],
            ),
          ),

          // ── Terrain list ──
          Expanded(
            child: provider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : provider.terrains.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.terrain, size: 48, color: kTextMuted),
                        const SizedBox(height: 12),
                        Text(
                          'Aucun terrain trouvé',
                          style: GoogleFonts.inter(
                            color: kTextMuted,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    itemCount: provider.terrains.length,
                    itemBuilder: (context, index) {
                      final terrain = provider.terrains[index];
                      return _TerrainCard(
                        terrain: terrain,
                        onTap: () => _navigateToVerification(context, terrain),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _navigateToVerification(
    BuildContext context,
    Map<String, dynamic> terrain,
  ) {
    // Create initial state from marketplace terrain
    final initialState = VerificationState(
      terrainTitre: terrain['title'] ?? '',
      terrainPhoto: terrain['photo_url'],
      terrainSurface: (terrain['surface_m2'] ?? '').toString(),
      prixFCFA: (terrain['price_fcfa'] as num?)?.toInt() ?? 150000,
      localisation: terrain['location'] ?? '',
      typeDocument: null,
      niveauRisque: NiveauRisque.faible,
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => VerificationTunnelPage(
          isExternalTerrain: false,
          initialState: initialState,
        ),
      ),
    );
  }

  void _showFilterSheet(BuildContext context, TerrainProvider provider) {
    // TODO: Implement filter sheet
    showModalBottomSheet(
      context: context,
      backgroundColor: kDarkCard,
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Filtres',
                style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: kTextPrimary,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => provider.clearFilters().then((_) {
                  Navigator.pop(context);
                }),
                child: const Text('Réinitialiser les filtres'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TerrainCard extends StatelessWidget {
  final Map<String, dynamic> terrain;
  final VoidCallback onTap;

  const _TerrainCard({required this.terrain, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: kDarkCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: kBorderDark),
        ),
        child: Row(
          children: [
            // Thumbnail
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: kDarkBg,
                borderRadius: BorderRadius.circular(8),
              ),
              child: terrain['photo_url'] != null
                  ? Image.network(terrain['photo_url'], fit: BoxFit.cover)
                  : Icon(Icons.terrain, color: kTextMuted),
            ),
            const SizedBox(width: 12),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    terrain['title'] ?? 'Terrain sans titre',
                    style: GoogleFonts.inter(
                      color: kTextPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    terrain['location'] ?? '',
                    style: GoogleFonts.inter(color: kTextMuted, fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${(terrain['price_fcfa'] ?? 0).toString()} FCFA',
                    style: GoogleFonts.inter(
                      color: kPrimaryLight,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, color: kTextMuted, size: 16),
          ],
        ),
      ),
    );
  }
}
