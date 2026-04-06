import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/colors.dart';

// ══════════════════════════════════════════════════════════════
//  FONCIRA — Préanalyse Gratuite Post-Formulaire
// ══════════════════════════════════════════════════════════════

class PreAnalysisWidget extends StatelessWidget {
  final String documentType;
  final String location;
  final String riskLevel;
  final VoidCallback onProceedToAnalysis;

  const PreAnalysisWidget({
    super.key,
    required this.documentType,
    required this.location,
    required this.riskLevel,
    required this.onProceedToAnalysis,
  });

  String _getRiskDescription(String risk) {
    switch (risk.toLowerCase()) {
      case 'low':
        return 'Terrain avec titre foncier en zone cadastrée — risque faible';
      case 'medium':
        return 'Terrain sans titre foncier en zone périphérique — risque modéré';
      case 'high':
        return 'Terrain sans documentation formelle en zone coutumière — risque élevé';
      default:
        return 'Analyse du risque en cours...';
    }
  }

  String _getRecommendation(String risk) {
    switch (risk.toLowerCase()) {
      case 'low':
        return 'Ce terrain semble bien documenté. Une vérification standard suffira pour valider l\'intégrité du titre.';
      case 'medium':
        return 'Sans titre officiel, une vérification approfondie avec les autorités locales est recommandée. Nous consulterons le chef du quartier et la mairie.';
      case 'high':
        return 'Ce terrain nécessite une enquête complète en trois étapes : cadastrale, administrative et coutumière. Nous sécuriserons votre position avant tout engagement.';
      default:
        return 'Nous analyserons ce terrain selon les protocoles FONCIRA complets.';
    }
  }

  Color _getRiskColor(String risk) {
    switch (risk.toLowerCase()) {
      case 'low':
        return kSuccess;
      case 'medium':
        return kWarning;
      case 'high':
        return kDanger;
      default:
        return kTextSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final riskColor = _getRiskColor(riskLevel);
    final riskDesc = _getRiskDescription(riskLevel);
    final recommendation = _getRecommendation(riskLevel);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: kDarkCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kBorderDark, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // En-tête
          Row(
            children: [
              Icon(Icons.insights_outlined, color: kGold, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Préanalyse gratuite',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: kTextSecondary,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Lecture initiale de votre terrain',
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: kTextPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Résumé du terrain
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: kBorderDark, width: 1),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Type de document',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: kTextSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      documentType,
                      style: GoogleFonts.outfit(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: kTextPrimary,
                      ),
                    ),
                  ],
                ),
                Container(width: 1, height: 40, color: kBorderDark),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Localisation',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: kTextSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      location,
                      style: GoogleFonts.outfit(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: kTextPrimary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Badge risque
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: riskColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: riskColor.withOpacity(0.5), width: 1),
            ),
            child: Row(
              children: [
                Icon(Icons.warning_rounded, color: riskColor, size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    riskDesc,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: riskColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Recommandation
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Notre analyse complète vous dira :',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: kTextSecondary,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                recommendation,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: kTextPrimary,
                  height: 1.6,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // CTA
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onProceedToAnalysis,
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                'Passer à l\'analyse complète',
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: Text(
              '💡 Vous payerez seulement après voir les résultats',
              style: GoogleFonts.inter(
                fontSize: 11,
                fontStyle: FontStyle.italic,
                color: kTextSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
