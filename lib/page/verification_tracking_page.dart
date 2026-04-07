import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../theme/colors.dart';
import '../providers/verification_provider.dart';
import '../models/verification_request.dart';
import 'verification_detail_page.dart';

// ══════════════════════════════════════════════════════════════
//  FONCIRA — Verification Tracking Page (real-time)
// ══════════════════════════════════════════════════════════════

class VerificationTrackingPage extends StatelessWidget {
  const VerificationTrackingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final verifProv = context.watch<VerificationProvider>();

    return Scaffold(
      backgroundColor: kDarkBg,
      appBar: AppBar(
        backgroundColor: kDarkBg,
        title: Text(
          'Mes vérifications',
          style: GoogleFonts.outfit(fontWeight: FontWeight.w700, fontSize: 20),
        ),
      ),
      body: verifProv.verifications.isEmpty
          ? _buildEmptyState()
          : DefaultTabController(
              length: 2,
              child: Column(
                children: [
                  // ── Tabs ──
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      color: kDarkCard,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: kBorderDark),
                    ),
                    child: TabBar(
                      indicator: BoxDecoration(
                        color: kPrimary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      labelColor: Colors.white,
                      unselectedLabelColor: kTextMuted,
                      labelStyle: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                      unselectedLabelStyle: GoogleFonts.inter(fontSize: 13),
                      indicatorSize: TabBarIndicatorSize.tab,
                      dividerColor: Colors.transparent,
                      padding: const EdgeInsets.all(4),
                      tabs: [
                        Tab(text: 'En cours (${verifProv.activeCount})'),
                        Tab(
                          text:
                              'Terminées (${verifProv.completedVerifications.length})',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ── Tab content ──
                  Expanded(
                    child: TabBarView(
                      children: [
                        _buildList(context, verifProv.activeVerifications),
                        _buildList(context, verifProv.completedVerifications),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildList(
    BuildContext context,
    List<Map<String, dynamic>> verifications,
  ) {
    if (verifications.isEmpty) {
      return Center(
        child: Text(
          'Aucune vérification dans cette catégorie',
          style: GoogleFonts.inter(color: kTextMuted, fontSize: 14),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: verifications.length,
      itemBuilder: (context, index) {
        final verif = verifications[index];
        return _VerificationCard(
          verification: verif,
          onTap: () {
            // For now, just navigate with the Map data
            // VerificationDetailPage would need to be updated to accept Map
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Verification: ${verif['terrain_title'] ?? 'N/A'}',
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: kPrimary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.verified_user_outlined,
              color: kPrimaryLight,
              size: 48,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Aucune vérification',
            style: GoogleFonts.outfit(
              color: kTextPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Vos demandes de vérification\napparaîtront ici',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              color: kTextMuted,
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Verification Card ────────────────────────────────────────

class _VerificationCard extends StatelessWidget {
  final Map<String, dynamic> verification;
  final VoidCallback? onTap;

  const _VerificationCard({required this.verification, this.onTap});

  @override
  Widget build(BuildContext context) {
    final terrainTitle = verification['terrain_title'] ?? 'Terrain';
    final terrainLocation = verification['terrain_location'] ?? '';
    final status = verification['status'] ?? 'receptionnee';
    final progress = _getProgress(status);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: kDarkCard,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: kBorderDark),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Icon
                _iconPlaceholder(),
                const SizedBox(width: 14),

                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        terrainTitle,
                        style: GoogleFonts.inter(
                          color: kTextPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            color: kTextMuted,
                            size: 12,
                          ),
                          const SizedBox(width: 3),
                          Expanded(
                            child: Text(
                              terrainLocation,
                              style: GoogleFonts.inter(
                                color: kTextMuted,
                                fontSize: 11,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      _sourceChip(),
                    ],
                  ),
                ),

                // Arrow
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: kTextMuted,
                  size: 14,
                ),
              ],
            ),
            const SizedBox(height: 14),

            // ── Progress bar ──
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _getStatusLabel(status),
                            style: GoogleFonts.inter(
                              color: status == 'rapport_livre'
                                  ? kSuccess
                                  : kPrimaryLight,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            '${(progress * 100).toInt()}%',
                            style: GoogleFonts.inter(
                              color: kTextMuted,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: progress,
                          backgroundColor: kDarkCardLight,
                          color: status == 'rapport_livre'
                              ? kSuccess
                              : kPrimary,
                          minHeight: 6,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _iconPlaceholder() {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: kPrimary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Icon(
        Icons.landscape_rounded,
        color: kPrimaryLight,
        size: 24,
      ),
    );
  }

  Widget _sourceChip() {
    final source = verification['source'] ?? 'marketplace';
    final isExternal = source == 'externe';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: isExternal ? kGold.withOpacity(0.1) : kPrimary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        isExternal ? 'Externe' : 'Marketplace',
        style: TextStyle(
          color: isExternal ? kGold : kPrimaryLight,
          fontSize: 9,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  double _getProgress(String status) {
    switch (status) {
      case 'receptionnee':
        return 0.1;
      case 'pre_analyse':
        return 0.25;
      case 'verification_administrative':
        return 0.45;
      case 'verification_terrain':
        return 0.65;
      case 'analyse_finale':
        return 0.85;
      case 'rapport_livre':
        return 1.0;
      default:
        return 0.0;
    }
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'receptionnee':
        return 'Demande réceptionnée';
      case 'pre_analyse':
        return 'Pré-analyse';
      case 'verification_administrative':
        return 'Vérification administrative';
      case 'verification_terrain':
        return 'Vérification terrain';
      case 'analyse_finale':
        return 'Analyse finale';
      case 'rapport_livre':
        return 'Rapport livré';
      default:
        return 'En cours';
    }
  }
}
