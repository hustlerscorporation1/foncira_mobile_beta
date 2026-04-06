import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/colors.dart';
import '../models/verification_request.dart';
import '../component/verification_timeline.dart';
import '../component/assigned_agent_card.dart';
import '../component/foncira_button.dart';
import 'admin_support_page.dart';

// ══════════════════════════════════════════════════════════════
//  FONCIRA — Verification Detail Page
// ══════════════════════════════════════════════════════════════

class VerificationDetailPage extends StatelessWidget {
  final VerificationRequest verification;

  const VerificationDetailPage({super.key, required this.verification});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kDarkBg,
      appBar: AppBar(
        backgroundColor: kDarkBg,
        title: Text(
          'Suivi #${verification.id}',
          style: GoogleFonts.outfit(fontWeight: FontWeight.w700, fontSize: 18),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Terrain info card ──
            _buildTerrainCard(),
            const SizedBox(height: 24),

            // ── Progress overview ──
            _buildProgressOverview(),
            const SizedBox(height: 28),

            // ── Assigned Agent ──
            AssignedAgentCard(
              agentName: 'Séna Amégavi',
              agentTitle: 'Agent Vérificateur',
              agentPhoto: 'SA',
              showFieldPhoto: verification.progressPercent > 0.3,
            ),
            const SizedBox(height: 28),

            // ── Timeline ──
            Text(
              'Étapes de vérification',
              style: GoogleFonts.outfit(
                color: kTextPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            VerificationTimeline(steps: verification.steps),

            const SizedBox(height: 28),

            // ── External info (if applicable) ──
            if (verification.source == VerificationSource.externe) ...[
              _buildExternalInfo(),
              const SizedBox(height: 28),
            ],

            // ── Accompaniment CTA ──
            if (verification.isComplete &&
                !verification.accompagnementRequested) ...[
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: kGold.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: kGold.withOpacity(0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.support_agent_rounded,
                          color: kGold,
                          size: 24,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Besoin d\'un accompagnement ?',
                            style: GoogleFonts.outfit(
                              color: kGoldLight,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Faites-vous accompagner pour les démarches administratives liées à l\'acquisition de ce terrain.',
                      style: GoogleFonts.inter(
                        color: kTextSecondary,
                        fontSize: 13,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 16),
                    FonciraButton(
                      label: 'Demander un accompagnement',
                      icon: Icons.handshake_rounded,
                      variant: FonciraButtonVariant.gold,
                      height: 48,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AdminSupportPage(
                              verificationId: verification.id,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],

            if (verification.accompagnementRequested)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: kSuccessSurface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: kSuccess.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.check_circle_rounded,
                      color: kSuccess,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Accompagnement administratif demandé',
                        style: GoogleFonts.inter(
                          color: kSuccess,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildTerrainCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kDarkCard,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: kBorderDark),
      ),
      child: Row(
        children: [
          if (verification.terrainImageUrl != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                verification.terrainImageUrl!,
                width: 70,
                height: 70,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _placeholder(),
              ),
            )
          else
            _placeholder(),

          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  verification.terrainTitle,
                  style: GoogleFonts.inter(
                    color: kTextPrimary,
                    fontSize: 15,
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
                      size: 13,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      verification.terrainLocation,
                      style: GoogleFonts.inter(color: kTextMuted, fontSize: 12),
                    ),
                  ],
                ),
                if (verification.terrainPrice != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    _formatPrice(verification.terrainPrice!),
                    style: GoogleFonts.outfit(
                      color: kPrimaryLight,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressOverview() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: kDarkCard,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: kBorderDark),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Progression',
                style: GoogleFonts.inter(color: kTextSecondary, fontSize: 13),
              ),
              Text(
                '${(verification.progressPercent * 100).toInt()}%',
                style: GoogleFonts.outfit(
                  color: verification.isComplete ? kSuccess : kPrimaryLight,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: verification.progressPercent,
              backgroundColor: kDarkCardLight,
              color: verification.isComplete ? kSuccess : kPrimary,
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _statusChip(
                verification.globalStatus.label,
                verification.isComplete ? kSuccess : kPrimary,
              ),
              Text(
                verification.source.label,
                style: GoogleFonts.inter(color: kTextMuted, fontSize: 11),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildExternalInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kDarkCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kBorderDark),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Informations soumises',
            style: GoogleFonts.outfit(
              color: kTextPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (verification.externalLocation != null) ...[
            const SizedBox(height: 10),
            _infoRow('Localisation', verification.externalLocation!),
          ],
          if (verification.externalSellerContact != null) ...[
            const SizedBox(height: 8),
            _infoRow('Contact vendeur', verification.externalSellerContact!),
          ],
          if (verification.externalSource != null) ...[
            const SizedBox(height: 8),
            _infoRow('Source', verification.externalSource!),
          ],
          if (verification.externalDescription != null) ...[
            const SizedBox(height: 8),
            _infoRow('Notes', verification.externalDescription!),
          ],
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 110,
          child: Text(
            label,
            style: GoogleFonts.inter(
              color: kTextMuted,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.inter(color: kTextSecondary, fontSize: 12),
          ),
        ),
      ],
    );
  }

  Widget _placeholder() {
    return Container(
      width: 70,
      height: 70,
      decoration: BoxDecoration(
        color: kDarkCardLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Icon(Icons.landscape_rounded, color: kTextMuted, size: 28),
    );
  }

  Widget _statusChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  String _formatPrice(double price) {
    if (price >= 1000000) {
      return '${(price / 1000000).toStringAsFixed(0)} M FCFA';
    }
    return '${price.toStringAsFixed(0)} FCFA';
  }
}
