import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/colors.dart';

class AvailabilityIndicator extends StatelessWidget {
  const AvailabilityIndicator({super.key});

  /// Détermine si l'agent est disponible selon l'heure locale
  bool get isAvailable {
    final now = DateTime.now();
    final hour = now.hour;
    // Disponible de 7h à 23h, indisponible de 23h à 7h
    return hour >= 7 && hour < 23;
  }

  String get statusText {
    if (isAvailable) {
      return 'Assistant disponible';
    } else {
      return 'Reprend à 8h';
    }
  }

  Color get indicatorColor {
    return isAvailable ? kSuccess : kWarning;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Point animé avec pulse
        Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: indicatorColor,
                shape: BoxShape.circle,
              ),
            )
            .animate(onComplete: (controller) => controller.repeat())
            .scale(
              begin: const Offset(1, 1),
              end: const Offset(1.4, 1.4),
              duration: 1500.ms,
            )
            .fadeOut(duration: 1500.ms, curve: Curves.easeOut),

        const SizedBox(width: 6),

        // Label de statut
        Text(
          statusText,
          style: GoogleFonts.inter(
            color: kTextSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
