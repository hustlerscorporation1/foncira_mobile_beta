import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/colors.dart';

// ══════════════════════════════════════════════════════════════
//  FONCIRA — Section Garantie Dédiée
// ══════════════════════════════════════════════════════════════

class GuaranteeSection extends StatelessWidget {
  const GuaranteeSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [kPrimarySurface, kDarkCard],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kPrimaryLight.withOpacity(0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon cadenas + titre
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: kGold.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Icon(Icons.lock_rounded, color: kGold, size: 24),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Votre investissement foncier',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: kTextSecondary,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '100% protégé & garanti',
                      style: GoogleFonts.outfit(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: kTextPrimary,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Callout principal
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: kGold.withOpacity(0.3), width: 1),
            ),
            child: Text(
              'On garantit un rapport complet, honnête et livré en 10 jours. '
              'Si on ne livre pas, vous êtes remboursé.',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontStyle: FontStyle.italic,
                color: kTextPrimary,
                height: 1.6,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 20),
          // 3 points concrets
          Column(
            children: [
              _GuaranteePoint(
                icon: Icons.verified_user_rounded,
                title: 'Rapport complet',
                description:
                    'Vérification cadastrale, terrain, documents légaux — analyse exhaustive',
              ),
              const SizedBox(height: 12),
              _GuaranteePoint(
                icon: Icons.schedule_rounded,
                title: 'Livraison en 10 jours',
                description:
                    'Vous recevez votre rapport dans les 10 jours, garanti',
              ),
              const SizedBox(height: 12),
              _GuaranteePoint(
                icon: Icons.currency_exchange_rounded,
                title: 'Remboursement intégral',
                description:
                    'Si on ne livre pas à temps, vous êtes remboursés 100%',
              ),
            ],
          ),
          const SizedBox(height: 20),
          // CTA
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Détails de la garantie')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: kGold,
                foregroundColor: kDarkBg,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                'Lire les conditions complètes',
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
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
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: kSuccess.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(child: Icon(icon, color: kSuccess, size: 20)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
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
    );
  }
}
