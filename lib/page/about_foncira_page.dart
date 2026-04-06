import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/colors.dart';

class AboutFonciraPage extends StatelessWidget {
  const AboutFonciraPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kDarkBg,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: kDarkBg, surfaceTintColor: Colors.transparent,
            pinned: true, expandedHeight: 200,
            leading: IconButton(icon: const Icon(Icons.arrow_back_ios_rounded, color: kTextPrimary, size: 20), onPressed: () => Navigator.pop(context)),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF1A1000), kDarkBg], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
                child: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const SizedBox(height: 40),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: kGradientGold,
                      shape: BoxShape.circle,
                      boxShadow: [BoxShadow(color: kGold.withValues(alpha: 0.3), blurRadius: 30, spreadRadius: 2)],
                    ),
                    child: const Icon(Icons.landscape_rounded, color: Colors.white, size: 36),
                  ),
                  const SizedBox(height: 16),
                  Text('FONCIRA', style: GoogleFonts.outfit(color: kTextPrimary, fontSize: 28, fontWeight: FontWeight.w800, letterSpacing: 3)),
                  const SizedBox(height: 4),
                  Text('v1.0.0', style: GoogleFonts.inter(color: kTextMuted, fontSize: 13)),
                ])),
              ),
            ),
          ),

          SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Mission
            _sectionHeader('Notre mission'),
            const SizedBox(height: 14),
            _card(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: kGoldSurface, borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.shield_rounded, color: kGold, size: 24)),
                const SizedBox(width: 14),
                Expanded(child: Text('Sécuriser les transactions foncières', style: GoogleFonts.outfit(color: kTextPrimary, fontSize: 16, fontWeight: FontWeight.w600))),
              ]),
              const SizedBox(height: 16),
              Text(
                'FONCIRA est née d\'un constat simple : trop de conflits fonciers en Afrique de l\'Ouest sont causés par un manque de transparence et de vérification.\n\nNotre plateforme permet à chaque acheteur de vérifier la fiabilité d\'un terrain avant tout engagement, et à chaque vendeur de prouver la légitimité de son bien.',
                style: GoogleFonts.inter(color: kTextSecondary, fontSize: 13, height: 1.7),
              ),
            ])),

            const SizedBox(height: 28),

            // How it works
            _sectionHeader('Comment ça marche'),
            const SizedBox(height: 14),
            _stepCard('1', 'Explorez', 'Parcourez des centaines de terrains vérifiés dans toute la région.', Icons.explore_rounded, kPrimaryLight),
            _stepCard('2', 'Vérifiez', 'Demandez une vérification foncière complète pour tout terrain.', Icons.verified_user_rounded, kGold),
            _stepCard('3', 'Décidez', 'Consultez le rapport de vérification et prenez votre décision en confiance.', Icons.check_circle_rounded, kSuccess),

            const SizedBox(height: 28),

            // Stats
            _sectionHeader('FONCIRA en chiffres'),
            const SizedBox(height: 14),
            Row(children: [
              Expanded(child: _statCard('500+', 'Terrains vérifiés', Icons.landscape_rounded, kPrimaryLight)),
              const SizedBox(width: 12),
              Expanded(child: _statCard('1 200+', 'Utilisateurs', Icons.people_rounded, kGold)),
            ]),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: _statCard('150+', 'Vérifications/mois', Icons.fact_check_rounded, kInfo)),
              const SizedBox(width: 12),
              Expanded(child: _statCard('98%', 'Satisfaction', Icons.sentiment_very_satisfied_rounded, kSuccess)),
            ]),

            const SizedBox(height: 28),

            // Team
            _sectionHeader('L\'équipe'),
            const SizedBox(height: 14),
            _card(child: Column(children: [
              Text(
                'FONCIRA est développée par une équipe passionnée de technologie et d\'immobilier, basée au Togo.',
                style: GoogleFonts.inter(color: kTextSecondary, fontSize: 13, height: 1.6),
              ),
              const SizedBox(height: 16),
              Row(children: [
                _teamChip('Développement'),
                const SizedBox(width: 8),
                _teamChip('Juridique'),
                const SizedBox(width: 8),
                _teamChip('Topographie'),
              ]),
            ])),

            const SizedBox(height: 28),

            // Legal
            _sectionHeader('Mentions légales'),
            const SizedBox(height: 14),
            _legalCard([
              _legalItem('Conditions d\'utilisation', Icons.description_outlined),
              _legalItem('Politique de confidentialité', Icons.privacy_tip_outlined),
              _legalItem('Licence open source', Icons.code_rounded),
            ]),

            const SizedBox(height: 32),

            // Footer
            Center(child: Column(children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(color: kGoldSurface, borderRadius: BorderRadius.circular(10)),
                child: Text('Votre terrain, votre sécurité.', style: GoogleFonts.inter(color: kGold, fontSize: 12, fontWeight: FontWeight.w600, fontStyle: FontStyle.italic)),
              ),
              const SizedBox(height: 16),
              Text('© ${DateTime.now().year} FONCIRA. Tous droits réservés.', style: GoogleFonts.inter(color: kTextMuted, fontSize: 11)),
              const SizedBox(height: 4),
              Text('Fait avec ❤️ au Togo 🇹🇬', style: GoogleFonts.inter(color: kTextMuted, fontSize: 11)),
            ])),
            const SizedBox(height: 60),
          ]))),
        ],
      ),
    );
  }

  static Widget _sectionHeader(String t) => Row(children: [
    Container(width: 3, height: 16, decoration: BoxDecoration(color: kGold, borderRadius: BorderRadius.circular(2))),
    const SizedBox(width: 10),
    Text(t.toUpperCase(), style: GoogleFonts.inter(color: kGold, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1.2)),
  ]);

  static Widget _card({required Widget child}) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(color: kDarkCard, borderRadius: BorderRadius.circular(16), border: Border.all(color: kBorderDark)),
    child: child,
  );

  static Widget _stepCard(String num, String title, String desc, IconData icon, Color color) => Container(
    margin: const EdgeInsets.only(bottom: 10),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: kDarkCard, borderRadius: BorderRadius.circular(14), border: Border.all(color: kBorderDark)),
    child: Row(children: [
      Container(
        width: 40, height: 40,
        decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)),
        child: Center(child: Text(num, style: GoogleFonts.outfit(color: color, fontSize: 18, fontWeight: FontWeight.w800))),
      ),
      const SizedBox(width: 14),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: GoogleFonts.inter(color: kTextPrimary, fontSize: 14, fontWeight: FontWeight.w600)),
        const SizedBox(height: 2),
        Text(desc, style: GoogleFonts.inter(color: kTextMuted, fontSize: 12, height: 1.4)),
      ])),
      Icon(icon, color: color.withValues(alpha: 0.4), size: 28),
    ]),
  );

  static Widget _statCard(String value, String label, IconData icon, Color color) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: kDarkCard, borderRadius: BorderRadius.circular(14), border: Border.all(color: kBorderDark)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Icon(icon, color: color, size: 22),
      const SizedBox(height: 10),
      Text(value, style: GoogleFonts.outfit(color: kTextPrimary, fontSize: 22, fontWeight: FontWeight.w800)),
      const SizedBox(height: 2),
      Text(label, style: GoogleFonts.inter(color: kTextMuted, fontSize: 11)),
    ]),
  );

  static Widget _teamChip(String t) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: BoxDecoration(color: kPrimarySurface, borderRadius: BorderRadius.circular(8)),
    child: Text(t, style: GoogleFonts.inter(color: kPrimaryLight, fontSize: 11, fontWeight: FontWeight.w600)),
  );

  static Widget _legalCard(List<Widget> children) => Container(
    decoration: BoxDecoration(color: kDarkCard, borderRadius: BorderRadius.circular(16), border: Border.all(color: kBorderDark)),
    child: Column(children: children),
  );

  static Widget _legalItem(String t, IconData i) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    child: Row(children: [
      Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: kGoldSurface, borderRadius: BorderRadius.circular(10)), child: Icon(i, color: kGold, size: 18)),
      const SizedBox(width: 14),
      Expanded(child: Text(t, style: GoogleFonts.inter(color: kTextPrimary, fontSize: 14, fontWeight: FontWeight.w500))),
      const Icon(Icons.arrow_forward_ios_rounded, color: kTextMuted, size: 14),
    ]),
  );
}
