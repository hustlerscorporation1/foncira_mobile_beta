import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../models/verification_step.dart';

// ══════════════════════════════════════════════════════════════
//  FONCIRA — Verification Timeline (6 steps)
// ══════════════════════════════════════════════════════════════

class VerificationTimeline extends StatelessWidget {
  final List<VerificationStep> steps;

  const VerificationTimeline({super.key, required this.steps});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(steps.length, (index) {
        final step = steps[index];
        final isLast = index == steps.length - 1;
        return _TimelineItem(step: step, isLast: isLast);
      }),
    );
  }
}

class _TimelineItem extends StatelessWidget {
  final VerificationStep step;
  final bool isLast;

  const _TimelineItem({required this.step, required this.isLast});

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Timeline indicator ──────────────────────────────
          SizedBox(
            width: 40,
            child: Column(
              children: [
                _buildDot(),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: step.isCompleted
                          ? kSuccess.withOpacity(0.4)
                          : kBorderDark,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),

          // ── Content ────────────────────────────────────────
          Expanded(
            child: Container(
              margin: EdgeInsets.only(bottom: isLast ? 0 : 20),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: step.isInProgress
                    ? kPrimary.withOpacity(0.08)
                    : step.isCompleted
                        ? kDarkCardLight
                        : kDarkCard,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: step.isInProgress
                      ? kPrimary.withOpacity(0.3)
                      : step.isCompleted
                          ? kSuccess.withOpacity(0.2)
                          : kBorderDark,
                  width: step.isInProgress ? 1.5 : 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(step.icon, style: const TextStyle(fontSize: 16)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          step.stepName,
                          style: TextStyle(
                            color: kTextPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      _buildStatusChip(),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    step.description,
                    style: TextStyle(
                      color: kTextSecondary,
                      fontSize: 12,
                      height: 1.4,
                    ),
                  ),
                  if (step.notes != null) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: kDarkBg.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.notes_rounded,
                            color: kTextMuted,
                            size: 14,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              step.notes!,
                              style: TextStyle(
                                color: kTextMuted,
                                fontSize: 11,
                                fontStyle: FontStyle.italic,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  if (step.completedAt != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      _formatDate(step.completedAt!),
                      style: TextStyle(
                        color: kTextMuted,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDot() {
    if (step.isCompleted) {
      return Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: kSuccess,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: kSuccess.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Icon(Icons.check_rounded, color: Colors.white, size: 16),
      );
    } else if (step.isInProgress) {
      return Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: kPrimary,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: kPrimary.withOpacity(0.4),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Center(
          child: SizedBox(
            width: 14,
            height: 14,
            child: CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 2,
            ),
          ),
        ),
      );
    } else {
      return Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: kDarkCardLight,
          shape: BoxShape.circle,
          border: Border.all(color: kBorderDark, width: 2),
        ),
        child: Center(
          child: Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: kTextMuted,
              shape: BoxShape.circle,
            ),
          ),
        ),
      );
    }
  }

  Widget _buildStatusChip() {
    Color bgColor;
    Color textColor;
    String label;

    if (step.isCompleted) {
      bgColor = kSuccessSurface;
      textColor = kSuccess;
      label = 'Terminé';
    } else if (step.isInProgress) {
      bgColor = kPrimarySurface;
      textColor = kPrimaryLight;
      label = 'En cours';
    } else {
      bgColor = Colors.transparent;
      textColor = kTextMuted;
      label = 'En attente';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      '', 'Jan', 'Fév', 'Mar', 'Avr', 'Mai', 'Juin',
      'Juil', 'Août', 'Sep', 'Oct', 'Nov', 'Déc'
    ];
    return '${date.day} ${months[date.month]} ${date.year} à ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
