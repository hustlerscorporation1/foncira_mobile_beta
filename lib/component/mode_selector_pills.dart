import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/user_mode_provider.dart';
import '../theme/colors.dart';

// ══════════════════════════════════════════════════════════════
//  Mode Selector Pills (Acheteur / Vendeur)
// ══════════════════════════════════════════════════════════════

class ModeSelectorPills extends StatefulWidget {
  final VoidCallback? onModeChanged;
  final bool showTooltip;

  const ModeSelectorPills({
    super.key,
    this.onModeChanged,
    this.showTooltip = false,
  });

  @override
  State<ModeSelectorPills> createState() => _ModeSelectorPillsState();
}

class _ModeSelectorPillsState extends State<ModeSelectorPills>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _slideAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _animationController.forward();

    // Show tooltip if needed
    if (widget.showTooltip) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showModeTooltip();
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _showModeTooltip() {
    if (!mounted) return;
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Appuyez ici pour passer en mode vendeur',
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
          backgroundColor: kSuccess.withOpacity(0.9),
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.fromLTRB(20, 0, 20, 80),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    } catch (e) {
      // Silently fail if context not available
    }
  }

  @override
  Widget build(BuildContext context) {
    final modeProvider = context.watch<UserModeProvider>();

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: kDarkCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: kBorderDark, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Acheteur Pill ──
          _buildModePill(
            context: context,
            label: 'Acheteur',
            icon: Icons.person_rounded,
            isActive: modeProvider.isBuyerMode,
            color: kPrimary,
            onTap: () {
              if (!modeProvider.isBuyerMode) {
                modeProvider.switchMode(UserMode.buyer);
                widget.onModeChanged?.call();
              }
            },
          ),
          const SizedBox(width: 8),

          // ── Vendeur Pill ──
          _buildModePill(
            context: context,
            label: 'Vendeur',
            icon: Icons.sell_rounded,
            isActive: !modeProvider.isBuyerMode,
            color: kSuccess,
            onTap: () {
              if (modeProvider.isBuyerMode) {
                modeProvider.switchMode(UserMode.seller);
                widget.onModeChanged?.call();
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildModePill({
    required BuildContext context,
    required String label,
    required IconData icon,
    required bool isActive,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? color.withOpacity(0.25) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isActive ? color.withOpacity(0.5) : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: isActive ? color : kTextMuted),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w600,
                color: isActive ? color : kTextMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
