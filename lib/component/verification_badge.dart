import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../models/terrain.dart';

// ══════════════════════════════════════════════════════════════
//  FONCIRA — Verification Badge
// ══════════════════════════════════════════════════════════════

class VerificationBadge extends StatelessWidget {
  final VerificationFoncira status;
  final bool compact;

  const VerificationBadge({
    super.key,
    required this.status,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 12,
        vertical: compact ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: _bgColor,
        borderRadius: BorderRadius.circular(compact ? 8 : 10),
        border: Border.all(color: _borderColor, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: compact ? 2 : 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_icon, color: _iconColor, size: compact ? 12 : 14),
          SizedBox(width: compact ? 4 : 6),
          Text(
            compact ? status.shortLabel : status.label,
            style: TextStyle(
              color: Colors.white,
              fontSize: compact ? 10 : 12,
              fontWeight: FontWeight.w700,
              shadows: [
                Shadow(
                  offset: const Offset(0, 1),
                  blurRadius: 3,
                  color: Colors.black.withOpacity(0.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color get _bgColor {
    switch (status) {
      case VerificationFoncira.nonVerifie:
        return kVerifNone.withOpacity(0.32);
      case VerificationFoncira.verificationDemandee:
        return kVerifRequested.withOpacity(0.32);
      case VerificationFoncira.enCoursDeVerification:
        return kVerifInProgress.withOpacity(0.32);
      case VerificationFoncira.verifieFaibleRisque:
        return kVerifDoneLow.withOpacity(0.32);
      case VerificationFoncira.verifieMoyenRisque:
        return kVerifDoneMedium.withOpacity(0.32);
      case VerificationFoncira.verifieRisqueEleve:
        return kVerifDoneHigh.withOpacity(0.32);
    }
  }

  Color get _borderColor {
    switch (status) {
      case VerificationFoncira.nonVerifie:
        return kVerifNone.withOpacity(0.7);
      case VerificationFoncira.verificationDemandee:
        return kVerifRequested.withOpacity(0.7);
      case VerificationFoncira.enCoursDeVerification:
        return kVerifInProgress.withOpacity(0.7);
      case VerificationFoncira.verifieFaibleRisque:
        return kVerifDoneLow.withOpacity(0.7);
      case VerificationFoncira.verifieMoyenRisque:
        return kVerifDoneMedium.withOpacity(0.7);
      case VerificationFoncira.verifieRisqueEleve:
        return kVerifDoneHigh.withOpacity(0.7);
    }
  }

  Color get _iconColor {
    switch (status) {
      case VerificationFoncira.nonVerifie:
        return kVerifNone;
      case VerificationFoncira.verificationDemandee:
        return kVerifRequested;
      case VerificationFoncira.enCoursDeVerification:
        return kVerifInProgress;
      case VerificationFoncira.verifieFaibleRisque:
        return kVerifDoneLow;
      case VerificationFoncira.verifieMoyenRisque:
        return kVerifDoneMedium;
      case VerificationFoncira.verifieRisqueEleve:
        return kVerifDoneHigh;
    }
  }

  IconData get _icon {
    switch (status) {
      case VerificationFoncira.nonVerifie:
        return Icons.help_outline_rounded;
      case VerificationFoncira.verificationDemandee:
        return Icons.schedule_rounded;
      case VerificationFoncira.enCoursDeVerification:
        return Icons.hourglass_top_rounded;
      case VerificationFoncira.verifieFaibleRisque:
        return Icons.verified_rounded;
      case VerificationFoncira.verifieMoyenRisque:
        return Icons.warning_amber_rounded;
      case VerificationFoncira.verifieRisqueEleve:
        return Icons.dangerous_rounded;
    }
  }
}
