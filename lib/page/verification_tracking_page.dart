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
                        Tab(
                          text:
                              'En cours (${verifProv.activeCount})',
                        ),
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
                        _buildList(
                          context,
                          verifProv.activeVerifications,
                        ),
                        _buildList(
                          context,
                          verifProv.completedVerifications,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildList(
      BuildContext context, List<VerificationRequest> verifications) {
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
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => VerificationDetailPage(verification: verif),
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
  final VerificationRequest verification;
  final VoidCallback? onTap;

  const _VerificationCard({required this.verification, this.onTap});

  @override
  Widget build(BuildContext context) {
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
                // Image / icon
                if (verification.terrainImageUrl != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      verification.terrainImageUrl!,
                      width: 56,
                      height: 56,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _iconPlaceholder(),
                    ),
                  )
                else
                  _iconPlaceholder(),
                const SizedBox(width: 14),

                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        verification.terrainTitle,
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
                          const Icon(Icons.location_on_outlined,
                              color: kTextMuted, size: 12),
                          const SizedBox(width: 3),
                          Expanded(
                            child: Text(
                              verification.terrainLocation,
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
                            verification.globalStatus.label,
                            style: GoogleFonts.inter(
                              color: verification.isComplete
                                  ? kSuccess
                                  : kPrimaryLight,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            '${(verification.progressPercent * 100).toInt()}%',
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
                          value: verification.progressPercent,
                          backgroundColor: kDarkCardLight,
                          color: verification.isComplete
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
        color: verification.source == VerificationSource.externe
            ? kGold.withOpacity(0.1)
            : kPrimary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        verification.source == VerificationSource.externe
            ? Icons.language_rounded
            : Icons.landscape_rounded,
        color: verification.source == VerificationSource.externe
            ? kGold
            : kPrimaryLight,
        size: 24,
      ),
    );
  }

  Widget _sourceChip() {
    final isExternal = verification.source == VerificationSource.externe;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: isExternal
            ? kGold.withOpacity(0.1)
            : kPrimary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        verification.source.label,
        style: TextStyle(
          color: isExternal ? kGold : kPrimaryLight,
          fontSize: 9,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
