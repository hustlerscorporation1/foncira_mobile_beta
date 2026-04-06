import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/colors.dart';

// ══════════════════════════════════════════════════════════════
//  FONCIRA — Prix Dollar/FCFA (Source de vérité: FCFA)
// ══════════════════════════════════════════════════════════════

class PriceDisplay extends StatelessWidget {
  final double fcfaAmount; // Montant en FCFA (source de vérité)
  final TextStyle? dollarStyle;
  final TextStyle? fcfaStyle;
  final MainAxisAlignment alignment;

  const PriceDisplay({
    super.key,
    required this.fcfaAmount,
    this.dollarStyle,
    this.fcfaStyle,
    this.alignment = MainAxisAlignment.start,
  });

  String formatNumber(double value) {
    final formatted = value.toStringAsFixed(0);
    final parts = formatted.split('.');
    final intPart = parts[0];
    final chars = intPart.split('').reversed.toList();
    final segments = <String>[];
    for (int i = 0; i < chars.length; i += 3) {
      final end = (i + 3 > chars.length) ? chars.length : i + 3;
      segments.add(chars.sublist(i, end).reversed.join());
    }
    return segments.reversed.join(' ');
  }

  @override
  Widget build(BuildContext context) {
    // Calcul: FCFA → USD (rond à l'entier le plus proche)
    final dollarAmount = (fcfaAmount / kFcfaToUsdRate).roundToDouble();

    return Column(
      mainAxisAlignment: alignment,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Dollar en grand (PRIMARY)
        Text(
          '\$${formatNumber(dollarAmount)}',
          style:
              dollarStyle ??
              GoogleFonts.outfit(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: kTextPrimary,
                letterSpacing: -0.5,
              ),
        ),
        const SizedBox(height: 4),
        // FCFA en petit (SECONDARY)
        Text(
          '≈ ${formatNumber(fcfaAmount)} FCFA',
          style:
              fcfaStyle ??
              GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: kTextSecondary,
              ),
        ),
      ],
    );
  }
}

// Variant compact (inline)
class PriceDisplayCompact extends StatelessWidget {
  final double fcfaAmount; // Montant en FCFA (source de vérité)

  const PriceDisplayCompact({super.key, required this.fcfaAmount});

  String formatNumber(double value) {
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    } else if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(0)}K';
    }
    return value.toStringAsFixed(0);
  }

  @override
  Widget build(BuildContext context) {
    // Calcul: FCFA → USD
    final dollarAmount = (fcfaAmount / kFcfaToUsdRate).roundToDouble();

    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: '\$${formatNumber(dollarAmount)}',
            style: GoogleFonts.outfit(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: kTextPrimary,
            ),
          ),
          TextSpan(
            text: ' (≈${formatNumber(fcfaAmount)} FCFA)',
            style: GoogleFonts.inter(fontSize: 11, color: kTextSecondary),
          ),
        ],
      ),
    );
  }
}
