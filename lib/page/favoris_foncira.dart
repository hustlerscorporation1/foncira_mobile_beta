import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../theme/colors.dart';
import '../models/terrain.dart';
import '../models/verification_state.dart';
import '../providers/terrain_provider.dart';
import '../component/terrain_card.dart';
import 'terrain_detail_foncira.dart';
import 'verification_tunnel_page.dart';

// ══════════════════════════════════════════════════════════════
//  FONCIRA — Favorites Page (Premium)
// ══════════════════════════════════════════════════════════════

class FavorisPageFoncira extends StatelessWidget {
  const FavorisPageFoncira({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kDarkBg,
      body: Consumer<TerrainProvider>(
        builder: (context, provider, _) {
          final favoris = provider.favorites;

          return CustomScrollView(
            slivers: [
              // ── App Bar ──
              SliverAppBar(
                backgroundColor: kDarkBg,
                surfaceTintColor: Colors.transparent,
                pinned: true,
                expandedHeight: 140,
                leading: IconButton(
                  icon: const Icon(
                    Icons.arrow_back_ios_rounded,
                    color: kTextPrimary,
                    size: 20,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  titlePadding: const EdgeInsets.only(left: 56, bottom: 16),
                  title: Text(
                    'Mes favoris',
                    style: GoogleFonts.outfit(
                      color: kTextPrimary,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  background: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF1A0A0A), kDarkBg],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    child: Align(
                      alignment: Alignment.topRight,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 50, right: 20),
                        child: Icon(
                          Icons.favorite_rounded,
                          color: kDanger.withValues(alpha: 0.15),
                          size: 80,
                        ),
                      ),
                    ),
                  ),
                ),
                actions: [
                  if (favoris.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: TextButton.icon(
                        onPressed: () => _showClearDialog(context, provider),
                        icon: const Icon(
                          Icons.delete_outline_rounded,
                          color: kTextMuted,
                          size: 18,
                        ),
                        label: Text(
                          'Tout vider',
                          style: GoogleFonts.inter(
                            color: kTextMuted,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                ],
              ),

              // ── Counter chip ──
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: kDangerSurface,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${favoris.length} terrain${favoris.length > 1 ? 's' : ''}',
                          style: GoogleFonts.inter(
                            color: kDanger,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const Spacer(),
                      if (favoris.isNotEmpty)
                        Text(
                          'Glissez pour retirer',
                          style: GoogleFonts.inter(
                            color: kTextMuted,
                            fontSize: 11,
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              // ── List ──
              if (favoris.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: _buildEmptyState(),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final terrain = favoris[index];
                      final terrainId = terrain['id'] ?? '';
                      final title = terrain['title'] ?? 'Terrain';
                      final location = terrain['location'] ?? '';

                      return Dismissible(
                        key: ValueKey(terrainId),
                        direction: DismissDirection.endToStart,
                        onDismissed: (_) {
                          provider.toggleFavorite(terrainId);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                '$title retiré des favoris',
                                style: GoogleFonts.inter(fontSize: 13),
                              ),
                              backgroundColor: kDarkCard,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              action: SnackBarAction(
                                label: 'Annuler',
                                textColor: kGold,
                                onPressed: () =>
                                    provider.toggleFavorite(terrainId),
                              ),
                            ),
                          );
                        },
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 24),
                          margin: const EdgeInsets.only(bottom: 14),
                          decoration: BoxDecoration(
                            color: kDangerSurface,
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: const Icon(
                            Icons.delete_rounded,
                            color: kDanger,
                            size: 28,
                          ),
                        ),
                        child: GestureDetector(
                          onTap: () {
                            final initialState = VerificationState(
                              terrainTitre: title,
                              localisation: location,
                              prixFCFA:
                                  (terrain['price_fcfa'] as num?)?.toInt() ??
                                  150000,
                            );
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => VerificationTunnelPage(
                                  initialState: initialState,
                                ),
                              ),
                            );
                          },
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 14),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: kDarkCard,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: kBorderDark),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    color: kDarkCardLight,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Center(
                                    child: Icon(
                                      Icons.landscape,
                                      color: kPrimaryLight,
                                      size: 36,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        title,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.outfit(
                                          color: kTextPrimary,
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.location_on_outlined,
                                            color: kTextMuted,
                                            size: 13,
                                          ),
                                          const SizedBox(width: 3),
                                          Expanded(
                                            child: Text(
                                              location,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: GoogleFonts.inter(
                                                color: kTextMuted,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        '${terrain['price_fcfa'] ?? 0} FCFA',
                                        style: GoogleFonts.inter(
                                          color: kPrimaryLight,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    GestureDetector(
                                      onTap: () =>
                                          provider.toggleFavorite(terrainId),
                                      child: const Icon(
                                        Icons.favorite_rounded,
                                        color: kGold,
                                        size: 20,
                                      ),
                                    ),
                                    const Icon(
                                      Icons.arrow_forward_ios,
                                      color: kTextMuted,
                                      size: 14,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }, childCount: favoris.length),
                  ),
                ),

              const SliverToBoxAdapter(child: SizedBox(height: 40)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: kDangerSurface,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.favorite_border_rounded,
            color: kDanger,
            size: 44,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Pas encore de favoris',
          style: GoogleFonts.outfit(
            color: kTextPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 48),
          child: Text(
            'Explorez le marketplace et ajoutez des terrains à vos favoris en appuyant sur le ❤️',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              color: kTextMuted,
              fontSize: 13,
              height: 1.5,
            ),
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  void _showClearDialog(BuildContext context, TerrainProvider provider) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: kDarkCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Vider les favoris',
          style: GoogleFonts.outfit(
            color: kTextPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'Voulez-vous retirer tous les terrains de vos favoris ?',
          style: GoogleFonts.inter(color: kTextSecondary, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Annuler', style: GoogleFonts.inter(color: kTextMuted)),
          ),
          TextButton(
            onPressed: () {
              final ids = provider.favorites
                  .map((t) => t['id']?.toString())
                  .whereType<String>()
                  .where((id) => id.isNotEmpty)
                  .toList();
              for (final id in ids) {
                provider.toggleFavorite(id);
              }
              Navigator.pop(context);
            },
            child: Text(
              'Tout vider',
              style: GoogleFonts.inter(
                color: kDanger,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
