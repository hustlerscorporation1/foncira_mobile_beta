import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../theme/colors.dart';
import '../component/foncira_button.dart';
import '../services/favoris_service.dart';
import '../providers/auth_provider.dart';
import '../page/verification_tunnel_page.dart';
import '../models/verification_state.dart';

// ══════════════════════════════════════════════════════════════
//  Mes Favoris — Saved Terrains
// ══════════════════════════════════════════════════════════════

class FavorisPage extends StatefulWidget {
  const FavorisPage({super.key});

  @override
  State<FavorisPage> createState() => _FavorisPageState();
}

class _FavorisPageState extends State<FavorisPage> {
  late FavorisService _favorisService;

  @override
  void initState() {
    super.initState();
    _favorisService = FavorisService();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kDarkBg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Mes favoris',
          style: GoogleFonts.outfit(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: kTextPrimary,
          ),
        ),
      ),
      backgroundColor: kDarkBg,
      body: SafeArea(
        child: Consumer<AuthProvider>(
          builder: (context, authProvider, _) {
            final userId = authProvider.currentUser?.id;

            if (userId == null) {
              return _NotAuthenticatedState();
            }

            return StreamBuilder(
              stream: _favorisService.favoriStream(userId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Erreur: ${snapshot.error}',
                      style: GoogleFonts.inter(color: kDanger),
                    ),
                  );
                }

                final favoris = snapshot.data ?? [];

                if (favoris.isEmpty) {
                  return _EmptyFavorisState();
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(24),
                  itemCount: favoris.length,
                  itemBuilder: (context, index) {
                    final terrain = favoris[index]['terrain'];
                    if (terrain == null) return const SizedBox.shrink();

                    return _FavoriTerrainCard(
                      terrain: terrain,
                      favorisService: _favorisService,
                      userId: userId,
                      terrainId: terrain['id'] as String,
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _FavoriTerrainCard extends StatelessWidget {
  final Map<String, dynamic> terrain;
  final FavorisService favorisService;
  final String userId;
  final String terrainId;

  const _FavoriTerrainCard({
    required this.terrain,
    required this.favorisService,
    required this.userId,
    required this.terrainId,
  });

  @override
  Widget build(BuildContext context) {
    final title = terrain['title'] ?? 'Terrain';
    final location = terrain['location'] ?? '';
    const price = 0;
    const surface = 0;
    final niveauRisque = terrain['niveau_risque'] ?? 'inconnu';

    return GestureDetector(
      onTap: () {
        // Navigate to verification tunnel with this terrain
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VerificationTunnelPage(
              isExternalTerrain: true,
              initialState: VerificationState(
                terrainId: terrainId,
                terrainTitre: title,
                terrainLocation: location,
              ),
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: kDarkCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: kBorderDark),
        ),
        clipBehavior: Clip.hardEdge,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image placeholder + Remove button
            Container(
              height: 120,
              color: kBorderDark,
              child: Stack(
                children: [
                  // Image or placeholder
                  Container(
                    color: kBorderDark,
                    child: const Center(
                      child: Icon(
                        Icons.image_rounded,
                        size: 40,
                        color: kTextMuted,
                      ),
                    ),
                  ),
                  // Remove favorite button
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: () {
                        favorisService.removeFavori(userId, terrainId);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Retiré des favoris'),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: kDanger.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(
                          Icons.close_rounded,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and risk level
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.outfit(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: kTextPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              location,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: kTextMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      _RiskBadge(niveauRisque),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Price and surface
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Prix',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              color: kTextMuted,
                            ),
                          ),
                          Text(
                            '${price ~/ 1000000}M FCFA',
                            style: GoogleFonts.outfit(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: kGold,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Surface',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              color: kTextMuted,
                            ),
                          ),
                          Text(
                            '${surface.toStringAsFixed(0)}m²',
                            style: GoogleFonts.outfit(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: kGold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RiskBadge extends StatelessWidget {
  final String niveauRisque;

  const _RiskBadge(this.niveauRisque);

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;
    String emoji;

    switch (niveauRisque.toLowerCase()) {
      case 'faible':
        color = kSuccess;
        label = 'Bas';
        emoji = '🟢';
        break;
      case 'moyen':
        color = const Color(0xFFFFB84D);
        label = 'Moyen';
        emoji = '🟡';
        break;
      case 'eleve':
        color = kDanger;
        label = 'Haut';
        emoji = '🔴';
        break;
      default:
        color = kTextMuted;
        label = '?';
        emoji = '⚪';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 12)),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyFavorisState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: kBorderDark,
                borderRadius: BorderRadius.circular(50),
              ),
              child: const Center(
                child: Icon(
                  Icons.favorite_outline_rounded,
                  size: 50,
                  color: kTextMuted,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Aucun favori',
              style: GoogleFonts.outfit(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: kTextPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Ajoutez des terrains à vos favoris pour les retrouver facilement plus tard.',
              style: GoogleFonts.inter(
                fontSize: 13,
                color: kTextMuted,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            FonciraButton(
              label: 'Explorer les terrains →',
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotAuthenticatedState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: kBorderDark,
                borderRadius: BorderRadius.circular(50),
              ),
              child: const Center(
                child: Icon(
                  Icons.lock_outline_rounded,
                  size: 50,
                  color: kTextMuted,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Connexion requise',
              style: GoogleFonts.outfit(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: kTextPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Connectez-vous pour accéder à vos favoris.',
              style: GoogleFonts.inter(
                fontSize: 13,
                color: kTextMuted,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            FonciraButton(
              label: 'Se connecter →',
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
}
