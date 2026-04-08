import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/colors.dart';

// ══════════════════════════════════════════════════════════════
//  FONCIRA — Section Garantie (Redesign Épuré)
// ══════════════════════════════════════════════════════════════

class GuaranteeSection extends StatelessWidget {
  const GuaranteeSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ─── Header ───
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Notre garantie',
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: kTextPrimary,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '100% protégé, ou remboursé intégralement',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: kTextSecondary,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // ─── Main Guarantee Card ───
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: kGold.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: kGold.withValues(alpha: 0.25),
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              Icon(Icons.verified_rounded, color: kGold, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Garantie complète',
                      style: GoogleFonts.outfit(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: kGold,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Rapport en 10 jours ou argent remboursé',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: kTextSecondary,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // ─── Three Guarantee Points (Minimal Cards) ───
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              _GuaranteePoint(
                icon: Icons.check_circle_outlined,
                title: 'Rapport complet',
                description:
                    'Cadastre, documents, propriété, litiges — complet',
              ),
              const SizedBox(height: 12),
              _GuaranteePoint(
                icon: Icons.schedule_rounded,
                title: '10 jours maximum',
                description:
                    'Délai garanti. Sinon, remboursement de la vérification',
              ),
              const SizedBox(height: 12),
              _GuaranteePoint(
                icon: Icons.shield_outlined,
                title: 'Remboursement 100%',
                description: 'Aucune question si nous ne livrons pas à temps',
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _GuaranteePoint extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _GuaranteePoint({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: kBorderDark, width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: kPrimary, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: kTextPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: kTextSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
