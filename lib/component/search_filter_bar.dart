import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/colors.dart';

// ══════════════════════════════════════════════════════════════
//  FONCIRA — Search & Filter Bar
// ══════════════════════════════════════════════════════════════

class SearchFilterBar extends StatelessWidget {
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onFilterTap;
  final bool hasActiveFilters;
  final String hintText;

  const SearchFilterBar({
    super.key,
    this.controller,
    this.onChanged,
    this.onFilterTap,
    this.hasActiveFilters = false,
    this.hintText = 'Rechercher un terrain, une ville...',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: kDarkCardLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kBorderDark),
      ),
      child: Row(
        children: [
          const SizedBox(width: 16),
          const Icon(Icons.search_rounded, color: kTextMuted, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              style: GoogleFonts.inter(
                color: kTextPrimary,
                fontSize: 14,
              ),
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: GoogleFonts.inter(
                  color: kTextMuted,
                  fontSize: 14,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                isDense: true,
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: onFilterTap,
            child: Container(
              padding: const EdgeInsets.all(8),
              margin: const EdgeInsets.only(right: 6),
              decoration: BoxDecoration(
                color: hasActiveFilters ? kPrimarySurface : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
                border: hasActiveFilters
                    ? Border.all(color: kPrimary.withOpacity(0.3))
                    : null,
              ),
              child: Stack(
                children: [
                  Icon(
                    Icons.tune_rounded,
                    color: hasActiveFilters ? kPrimaryLight : kTextMuted,
                    size: 20,
                  ),
                  if (hasActiveFilters)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: kPrimary,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
