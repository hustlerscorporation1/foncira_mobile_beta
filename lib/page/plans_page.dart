import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../component/price_display.dart';

const Color darkBackground = Color(0xFF101C17);
const Color cardBackground = Color(0xFF1B2B24);
const Color primaryGreen = Color(0xFF00C853);
const Color textColor = Colors.white;
const Color hintColor = Colors.white70;
const Color premiumGold = Color(0xFFD4AF37);

class PlansPage extends StatelessWidget {
  const PlansPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkBackground,
      appBar: AppBar(
        title: Text(
          "Découvrir nos plans",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
        backgroundColor: darkBackground,
        elevation: 0,
        iconTheme: const IconThemeData(color: textColor),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Text(
              "Choisissez le plan qui vous correspond",
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ).animate().fade(duration: 600.ms).slideY(begin: -0.2),

            const SizedBox(height: 16),

            Text(
              "Débloquez plus de fonctionnalités et accélérez vos ventes avec nos offres sur mesure.",
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(fontSize: 16, color: hintColor),
            ).animate().fade(duration: 600.ms, delay: 200.ms),

            const SizedBox(height: 48),

            _buildPlanCard(
              title: "Standard",
              priceWidget: Text(
                "Gratuit",
                style: GoogleFonts.poppins(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              description:
                  "Idéal pour commencer et mettre en vente vos premiers terrains.",
              features: [
                "Jusqu'à 3 annonces actives",
                "Visibilité de base",
                "Support par email",
              ],
              buttonText: "Votre plan actuel",
              isRecommended: false,
            ).animate().fade(duration: 600.ms, delay: 400.ms).slideX(begin: -0.5),

            const SizedBox(height: 24),

            _buildPlanCard(
              title: "Premium",
              priceWidget: PriceDisplay(
                fcfaAmount: 80000,
                dollarStyle: GoogleFonts.poppins(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
                fcfaStyle: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: hintColor,
                ),
                alignment: MainAxisAlignment.start,
              ),
              description:
                  "Pour les vendeurs sérieux qui veulent maximiser leur visibilité.",
              features: [
                "Annonces illimitées",
                "Terrains plus privilégiés",
                "Délai Moyen de vente \"7 jours\"",
                "Support prioritaire 24/7",
              ],
              buttonText: "Passer au Premium",
              isRecommended: true,
            ).animate().fade(duration: 600.ms, delay: 600.ms).slideX(begin: 0.5),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanCard({
    required String title,
    required Widget priceWidget,
    required String description,
    required List<String> features,
    required String buttonText,
    bool isRecommended = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(1.5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: isRecommended
            ? const LinearGradient(colors: [premiumGold, primaryGreen])
            : null,
      ),
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
        decoration: BoxDecoration(
          color: cardBackground,
          borderRadius: BorderRadius.circular(19),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: isRecommended ? premiumGold : textColor,
                  ),
                ),
                if (isRecommended)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: premiumGold.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      "RECOMMANDÉ",
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: premiumGold,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            priceWidget,
            const SizedBox(height: 16),
            Text(
              description,
              style: GoogleFonts.poppins(fontSize: 14, color: hintColor),
            ),
            const Divider(height: 32, color: Colors.white12),

            // Liste des avantages
            ...features
                .map(
                  (feature) => Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: Row(
                      children: [
                        Icon(Icons.check_circle, color: primaryGreen, size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            feature,
                            style: GoogleFonts.poppins(
                              color: textColor,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),

            const SizedBox(height: 24),

            // Bouton d'action
            ElevatedButton(
              onPressed: isRecommended ? () {} : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: isRecommended
                    ? primaryGreen
                    : Colors.transparent,
                disabledBackgroundColor: cardBackground,
                foregroundColor: textColor,
                side: isRecommended ? null : BorderSide(color: hintColor),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                buttonText,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: isRecommended ? Colors.black : hintColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
