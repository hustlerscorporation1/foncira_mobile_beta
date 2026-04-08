import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/colors.dart';

// ══════════════════════════════════════════════════════════════
//  FONCIRA — Partenaires & Signaux d'Autorité (Redesign Épuré)
// ══════════════════════════════════════════════════════════════

class PartnersAndAuthority extends StatelessWidget {
  const PartnersAndAuthority({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Section Partenaires ──
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Nos partenaires',
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: kTextPrimary,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Vérifiée avec les institutions les plus respectées du pays',
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
        // Grille 2x2 minimaliste
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1.1,
            children: [
              _PartnerCard(icon: '🏛️', name: 'Notaires\nTogo'),
              _PartnerCard(icon: '📐', name: 'Géomètres\nCertifiés'),
              _PartnerCard(icon: '⚖️', name: 'Autorités\nJudiciaires'),
              _PartnerCard(icon: '🔐', name: 'Certifications\nLégales'),
            ],
          ),
        ),
        const SizedBox(height: 32),
        // ── Section Médias ──
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Présenté dans',
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: kTextPrimary,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _MediaBadge(name: 'Africa Business')),
                  const SizedBox(width: 10),
                  Expanded(child: _MediaBadge(name: 'Diaspora News')),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(child: _MediaBadge(name: 'Land Report')),
                  const SizedBox(width: 10),
                  Expanded(child: _MediaBadge(name: 'Tech Togo')),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PartnerCard extends StatelessWidget {
  final String icon;
  final String name;

  const _PartnerCard({required this.icon, required this.name});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kBorderDark, width: 1.5),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(icon, style: const TextStyle(fontSize: 32)),
          const SizedBox(height: 8),
          Text(
            name,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: kTextPrimary,
              fontWeight: FontWeight.w600,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _MediaBadge extends StatelessWidget {
  final String name;

  const _MediaBadge({required this.name});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: kBorderDark, width: 1),
      ),
      child: Center(
        child: Text(
          name,
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: kGold,
            letterSpacing: 0.3,
          ),
        ),
      ),
    );
  }
}
