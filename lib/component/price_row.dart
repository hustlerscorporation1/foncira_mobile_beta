import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/colors.dart';

/// Widget pour afficher le prix USD et FCFA sur une seule ligne
/// USD en grande taille, FCFA en petite taille avec opacité réduite
/// Alignés verticalement sur la ligne de base
class PriceRow extends StatelessWidget {
  final double priceUsd;
  final double priceFcfa;
  final double usdFontSize;
  final double fcfaFontSize;
  final Color usdColor;
  final Color fcfaColor;
  final double spacing;

  const PriceRow({
    super.key,
    required this.priceUsd,
    required this.priceFcfa,
    this.usdFontSize = 24,
    this.fcfaFontSize = 12,
    this.usdColor = kGold,
    this.fcfaColor = kTextMuted,
    this.spacing = 8,
  });

  @override
  Widget build(BuildContext context) {
    final formattedUsd = priceUsd.toStringAsFixed(0);
    final formattedFcfa = priceFcfa >= 1000000
        ? '${(priceFcfa / 1000000).toStringAsFixed(0)}M'
        : '${(priceFcfa / 1000).toStringAsFixed(0)}k';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '\$$formattedUsd',
          style: GoogleFonts.outfit(
            fontSize: usdFontSize,
            fontWeight: FontWeight.w700,
            color: usdColor,
          ),
        ),
        SizedBox(width: spacing),
        Text(
          '≈ $formattedFcfa FCFA',
          style: GoogleFonts.inter(
            fontSize: fcfaFontSize,
            color: fcfaColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
