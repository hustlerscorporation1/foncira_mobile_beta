import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/colors.dart';
import 'verification_tunnel_page.dart';
import 'marketplace_page.dart';
import 'verification_tracking_page.dart';

// ══════════════════════════════════════════════════════════════
//  FONCIRA — Request Verification Page (hub)
// ══════════════════════════════════════════════════════════════

class RequestVerificationPage extends StatelessWidget {
  const RequestVerificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kDarkBg,
      appBar: AppBar(
        backgroundColor: kDarkBg,
        title: Text(
          'Vérifier un terrain',
          style: GoogleFonts.outfit(fontWeight: FontWeight.w700, fontSize: 20),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Comment souhaitez-vous\nvérifier un terrain ?',
                style: GoogleFonts.outfit(
                  color: kTextPrimary,
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'FONCIRA vérifie tout terrain au Togo, qu\'il soit publié sur notre marketplace ou trouvé ailleurs.',
                style: GoogleFonts.inter(
                  color: kTextSecondary,
                  fontSize: 14,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 36),

              // ── Option 1: From FONCIRA ──
              _VerificationOption(
                icon: Icons.storefront_rounded,
                title: 'Terrain FONCIRA',
                description:
                    'Vérifier un terrain que vous avez trouvé sur la marketplace FONCIRA.',
                color: kPrimaryLight,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const MarketplacePage()),
                  );
                },
              ),
              const SizedBox(height: 16),

              // ── Option 2: External ──
              _VerificationOption(
                icon: Icons.language_rounded,
                title: 'Terrain externe',
                description:
                    'Vérifier un terrain trouvé sur les réseaux sociaux, par bouche-à-oreille ou via une agence externe.',
                color: kGold,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          const VerificationTunnelPage(isExternalTerrain: true),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),

              // ── Option 3: Track ──
              _VerificationOption(
                icon: Icons.assignment_turned_in_rounded,
                title: 'Suivre mes vérifications',
                description:
                    'Consultez l\'avancement de vos demandes de vérification en temps réel.',
                color: kInfo,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const VerificationTrackingPage(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _VerificationOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color color;
  final VoidCallback? onTap;

  const _VerificationOption({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: kDarkCard,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: kBorderDark),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      color: kTextPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: GoogleFonts.inter(
                      color: kTextMuted,
                      fontSize: 12,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.arrow_forward_ios_rounded, color: kTextMuted, size: 16),
          ],
        ),
      ),
    );
  }
}
