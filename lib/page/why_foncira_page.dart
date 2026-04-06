import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/colors.dart';
import '../component/partners_authority.dart';
import '../component/guarantee_section.dart';
import '../component/social_proof_banner.dart';

// ══════════════════════════════════════════════════════════════
//  FONCIRA — Pourquoi nous faire confiance ?
// ══════════════════════════════════════════════════════════════

class WhyFonciraPage extends StatelessWidget {
  const WhyFonciraPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kDarkBg,
      appBar: AppBar(
        backgroundColor: kDarkBg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Pourquoi nous faire confiance',
          style: GoogleFonts.outfit(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: kTextPrimary,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Section 1: Autorité & Partenaires
              const PartnersAndAuthority(),
              const SizedBox(height: 28),

              // Section 2: Garantie Dédiée
              const GuaranteeSection(),
              const SizedBox(height: 28),

              // Section 3: Preuve Sociale Animée
              const SocialProofBanner(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
