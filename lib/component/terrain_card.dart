import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/colors.dart';
import '../models/terrain.dart';
import 'verification_badge.dart';

// ══════════════════════════════════════════════════════════════
//  FONCIRA — Premium Terrain Card
// ══════════════════════════════════════════════════════════════

class TerrainCard extends StatelessWidget {
  final Terrain terrain;
  final VoidCallback? onTap;
  final VoidCallback? onFavoriteTap;
  final bool isFavorite;
  final bool isHorizontal;

  const TerrainCard({
    super.key,
    required this.terrain,
    this.onTap,
    this.onFavoriteTap,
    this.isFavorite = false,
    this.isHorizontal = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isHorizontal) return _buildHorizontal(context);
    return _buildVertical(context);
  }

  // ── Vertical Card (for horizontal scroll lists) ────────────
  Widget _buildVertical(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 200,
        margin: const EdgeInsets.only(right: 14),
        decoration: BoxDecoration(
          color: kDarkCard,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: kBorderDark),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Image ──
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(18),
                  ),
                  child: _buildTerrainImage(
                    terrain.imageUrl,
                    height: 130,
                    width: double.infinity,
                  ),
                ),
                // Surface badge
                Positioned(
                  top: 10,
                  left: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      terrain.formattedSurface,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                // Favorite
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: onFavoriteTap,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.4),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isFavorite
                            ? Icons.favorite_rounded
                            : Icons.favorite_border_rounded,
                        color: isFavorite ? kDanger : Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                ),
                // Verification badge
                Positioned(
                  bottom: 8,
                  left: 8,
                  child: VerificationBadge(
                    status: terrain.verificationFoncira,
                    compact: true,
                  ),
                ),
              ],
            ),

            // ── Info ──
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      terrain.title,
                      style: GoogleFonts.inter(
                        color: kTextPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          color: kTextMuted,
                          size: 12,
                        ),
                        const SizedBox(width: 3),
                        Expanded(
                          child: Text(
                            terrain.fullLocation,
                            style: GoogleFonts.inter(
                              color: kTextMuted,
                              fontSize: 11,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            terrain.formattedPrice,
                            style: GoogleFonts.outfit(
                              color: kPrimaryLight,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        _buildDocBadge(),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Horizontal Card (for vertical lists) ───────────────────
  Widget _buildHorizontal(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: kDarkCard,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: kBorderDark),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            // ── Image ──
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.horizontal(
                    left: Radius.circular(18),
                  ),
                  child: _buildTerrainImage(
                    terrain.imageUrl,
                    width: 130,
                    height: 130,
                  ),
                ),
                Positioned(
                  bottom: 6,
                  left: 6,
                  child: VerificationBadge(
                    status: terrain.verificationFoncira,
                    compact: true,
                  ),
                ),
              ],
            ),

            // ── Info ──
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            terrain.title,
                            style: GoogleFonts.inter(
                              color: kTextPrimary,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        GestureDetector(
                          onTap: onFavoriteTap,
                          child: Icon(
                            isFavorite
                                ? Icons.favorite_rounded
                                : Icons.favorite_border_rounded,
                            color: isFavorite ? kDanger : kTextMuted,
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          color: kTextMuted,
                          size: 13,
                        ),
                        const SizedBox(width: 3),
                        Expanded(
                          child: Text(
                            terrain.fullLocation,
                            style: GoogleFonts.inter(
                              color: kTextMuted,
                              fontSize: 12,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildDocBadge(),
                        const SizedBox(width: 6),
                        _buildInfoChip(
                          terrain.formattedSurface,
                          Icons.straighten_rounded,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          terrain.formattedPrice,
                          style: GoogleFonts.outfit(
                            color: kPrimaryLight,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          terrain.timeAgo,
                          style: GoogleFonts.inter(
                            color: kTextMuted,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDocBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: _docColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: _docColor.withOpacity(0.2)),
      ),
      child: Text(
        terrain.documentType.label,
        style: TextStyle(
          color: _docColor,
          fontSize: 9,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildInfoChip(String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: kDarkCardLight,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: kTextMuted, size: 10),
          const SizedBox(width: 3),
          Text(
            text,
            style: const TextStyle(
              color: kTextMuted,
              fontSize: 9,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Color get _docColor {
    switch (terrain.documentType) {
      case DocumentType.titreFoncier:
        return kSuccess;
      case DocumentType.attestation:
        return kInfo;
      case DocumentType.enCours:
        return kWarning;
      case DocumentType.aucunDocument:
        return kDanger;
    }
  }

  Widget _buildTerrainImage(String imagePath, {double? width, double? height}) {
    final isNetworkImage =
        imagePath.startsWith('http://') || imagePath.startsWith('https://');

    if (isNetworkImage) {
      return Image.network(
        imagePath,
        width: width,
        height: height,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) =>
            _buildImageFallback(width: width, height: height),
      );
    }

    return Image.asset(
      imagePath,
      width: width,
      height: height,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) =>
          _buildImageFallback(width: width, height: height),
    );
  }

  Widget _buildImageFallback({double? width, double? height}) {
    return Container(
      width: width,
      height: height,
      color: kDarkCardLight,
      child: const Icon(Icons.landscape_rounded, color: kTextMuted, size: 36),
    );
  }
}
