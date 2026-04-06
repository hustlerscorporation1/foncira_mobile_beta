import 'package:flutter/material.dart';
import '../theme/colors.dart';

// ══════════════════════════════════════════════════════════════
//  FONCIRA — Branded Buttons
// ══════════════════════════════════════════════════════════════

enum FonciraButtonVariant { primary, gold, outlined, danger }

class FonciraButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final FonciraButtonVariant variant;
  final IconData? icon;
  final bool isLoading;
  final bool fullWidth;
  final double height;
  final double borderRadius;

  const FonciraButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = FonciraButtonVariant.primary,
    this.icon,
    this.isLoading = false,
    this.fullWidth = true,
    this.height = 56,
    this.borderRadius = 16,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: fullWidth ? double.infinity : null,
      height: height,
      child: _buildButton(),
    );
  }

  Widget _buildButton() {
    switch (variant) {
      case FonciraButtonVariant.primary:
        return _GradientButton(
          gradient: kGradientCTA,
          label: label,
          icon: icon,
          isLoading: isLoading,
          onPressed: onPressed,
          borderRadius: borderRadius,
          shadowColor: kPrimary,
        );
      case FonciraButtonVariant.gold:
        return _GradientButton(
          gradient: kGradientGoldCTA,
          label: label,
          icon: icon,
          isLoading: isLoading,
          onPressed: onPressed,
          borderRadius: borderRadius,
          shadowColor: kGold,
          textColor: kDarkBg,
        );
      case FonciraButtonVariant.outlined:
        return _OutlinedFonciraButton(
          label: label,
          icon: icon,
          isLoading: isLoading,
          onPressed: onPressed,
          borderRadius: borderRadius,
        );
      case FonciraButtonVariant.danger:
        return _GradientButton(
          gradient: const LinearGradient(
            colors: [kDanger, Color(0xFFDC2626)],
          ),
          label: label,
          icon: icon,
          isLoading: isLoading,
          onPressed: onPressed,
          borderRadius: borderRadius,
          shadowColor: kDanger,
        );
    }
  }
}

class _GradientButton extends StatelessWidget {
  final LinearGradient gradient;
  final String label;
  final IconData? icon;
  final bool isLoading;
  final VoidCallback? onPressed;
  final double borderRadius;
  final Color shadowColor;
  final Color textColor;

  const _GradientButton({
    required this.gradient,
    required this.label,
    this.icon,
    this.isLoading = false,
    this.onPressed,
    this.borderRadius = 16,
    this.shadowColor = kPrimary,
    this.textColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: onPressed != null ? gradient : null,
        color: onPressed == null ? Colors.grey.shade700 : null,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: onPressed != null
            ? [
                BoxShadow(
                  color: shadowColor.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: BorderRadius.circular(borderRadius),
          child: Center(
            child: isLoading
                ? SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: textColor,
                      strokeWidth: 2.5,
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (icon != null) ...[
                        Icon(icon, color: textColor, size: 20),
                        const SizedBox(width: 10),
                      ],
                      Text(
                        label,
                        style: TextStyle(
                          color: textColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

class _OutlinedFonciraButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final bool isLoading;
  final VoidCallback? onPressed;
  final double borderRadius;

  const _OutlinedFonciraButton({
    required this.label,
    this.icon,
    this.isLoading = false,
    this.onPressed,
    this.borderRadius = 16,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: kBorderDark, width: 1.5),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: BorderRadius.circular(borderRadius),
          child: Center(
            child: isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: kTextPrimary,
                      strokeWidth: 2.5,
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (icon != null) ...[
                        Icon(icon, color: kTextPrimary, size: 20),
                        const SizedBox(width: 10),
                      ],
                      Text(
                        label,
                        style: const TextStyle(
                          color: kTextPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
