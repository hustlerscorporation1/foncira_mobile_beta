import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/colors.dart';

// ══════════════════════════════════════════════════════════════
//  FONCIRA — Partenaires & Signaux d'Autorité
// ══════════════════════════════════════════════════════════════

class PartnersAndAuthority extends StatelessWidget {
  const PartnersAndAuthority({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Titre
          Text(
            'Nos partenaires de confiance',
            style: GoogleFonts.outfit(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: kTextPrimary,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 16),
          // Logos partenaires
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                _PartnerLogo(
                  initialsOrIcon: '🏛️',
                  name: 'Notaires\nTogo',
                  size: 90,
                ),
                const SizedBox(width: 12),
                _PartnerLogo(
                  initialsOrIcon: '📐',
                  name: 'Géomètres\nCertifiés',
                  size: 90,
                ),
                const SizedBox(width: 12),
                _PartnerLogo(
                  initialsOrIcon: '🌍',
                  name: 'Diaspora\nConnected',
                  size: 90,
                ),
                const SizedBox(width: 12),
                _PartnerLogo(
                  initialsOrIcon: '🔐',
                  name: 'Legal\nShield',
                  size: 90,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // "Vu dans..." section
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Vu dans les médias',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: kTextSecondary,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _MediaBadge(name: 'Africa Business')),
                  const SizedBox(width: 12),
                  Expanded(child: _MediaBadge(name: 'Diaspora Weekly')),
                  const SizedBox(width: 12),
                  Expanded(child: _MediaBadge(name: 'Land Report')),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PartnerLogo extends StatelessWidget {
  final String initialsOrIcon;
  final String name;
  final double size;

  const _PartnerLogo({
    required this.initialsOrIcon,
    required this.name,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [kPrimarySurface, kGoldSurface],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(color: kBorderDark, width: 1),
          ),
          child: Center(
            child: Text(initialsOrIcon, style: const TextStyle(fontSize: 32)),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: size,
          child: Text(
            name,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 11,
              color: kTextSecondary,
              height: 1.3,
            ),
          ),
        ),
      ],
    );
  }
}

class _MediaBadge extends StatelessWidget {
  final String name;

  const _MediaBadge({required this.name});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
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
          ),
        ),
      ),
    );
  }
}
