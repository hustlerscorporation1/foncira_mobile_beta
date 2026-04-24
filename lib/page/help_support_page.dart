import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/colors.dart';

class HelpSupportPage extends StatefulWidget {
  const HelpSupportPage({super.key});
  @override
  State<HelpSupportPage> createState() => _HelpSupportPageState();
}

class _HelpSupportPageState extends State<HelpSupportPage> {
  int? _expandedFaq;
  final _msgCtrl = TextEditingController();
  String _selectedCat = 'Général';

  final _faqs = const [
    {
      'q': 'Comment vérifier un terrain sur FONCIRA ?',
      'a':
          'Rendez-vous sur la fiche du terrain et cliquez sur « Demander une vérification ». Vous pouvez aussi vérifier un terrain externe depuis le menu. Notre équipe analysera les documents fonciers sous 48 à 72h.',
    },
    {
      'q': 'Combien coûte une vérification ?',
      'a':
          'La vérification complète d\'un terrain coûte \$380 (≈250 000 FCFA). Cela inclut : demande validée, vérification administrative, vérification coutumière, vérification du voisinage & géomètre, et rapport détaillé. Faible risque ou risque élevé : le prix reste le même.',
    },
    {
      'q': 'Comment publier un terrain à vendre ?',
      'a':
          'Accédez à « Publier un terrain » depuis l\'écran d\'accueil. Remplissez le formulaire avec les informations du terrain et soumettez. Votre annonce sera visible après modération.',
    },
    {
      'q': 'Que signifie « Vérifié · Faible risque » ?',
      'a':
          'Notre équipe a vérifié les documents fonciers et n\'a trouvé aucun litige majeur. Le risque de conflit est considéré comme faible. Cela n\'est pas une garantie absolue mais un indicateur de confiance.',
    },
    {
      'q': 'Comment contacter le vendeur d\'un terrain ?',
      'a':
          'Sur la fiche du terrain, cliquez sur « Contacter le vendeur ». Vous pourrez l\'appeler directement ou envoyer un message via la plateforme.',
    },
    {
      'q': 'Mes données sont-elles sécurisées ?',
      'a':
          'Oui. FONCIRA utilise un chiffrement de bout en bout et héberge vos données sur des serveurs sécurisés.',
    },
  ];

  final _cats = ['Général', 'Vérification', 'Paiement', 'Compte', 'Technique'];

  @override
  void dispose() {
    _msgCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kDarkBg,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: kDarkBg,
            surfaceTintColor: Colors.transparent,
            pinned: true,
            expandedHeight: 140,
            leading: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_rounded,
                color: kTextPrimary,
                size: 20,
              ),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 56, bottom: 16),
              title: Text(
                'Aide & Support',
                style: GoogleFonts.outfit(
                  color: kTextPrimary,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF0A1A2E), kDarkBg],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 50, right: 20),
                    child: Icon(
                      Icons.support_agent_rounded,
                      color: kInfo.withValues(alpha: 0.15),
                      size: 80,
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Quick Actions
                  Row(
                    children: [
                      Expanded(
                        child: _quickAction(
                          Icons.chat_bubble_outline_rounded,
                          'Chat',
                          'En direct',
                          kPrimaryLight,
                          () => _snack('Chat bientôt disponible 🚀'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _quickAction(
                          Icons.email_outlined,
                          'Email',
                          'support@foncira.com',
                          kGold,
                          () {},
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _quickAction(
                          Icons.phone_outlined,
                          'Appeler',
                          '+228 99 00 00',
                          kInfo,
                          () {},
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // FAQ
                  _sectionHeader('Questions fréquentes', Icons.quiz_rounded),
                  const SizedBox(height: 14),
                  ...List.generate(
                    _faqs.length,
                    (i) => _faqItem(
                      _faqs[i]['q']!,
                      _faqs[i]['a']!,
                      _expandedFaq == i,
                      () => setState(
                        () => _expandedFaq = _expandedFaq == i ? null : i,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Contact Form
                  _sectionHeader('Nous contacter', Icons.send_rounded),
                  const SizedBox(height: 14),
                  _contactForm(),
                  const SizedBox(height: 32),

                  // Useful Links
                  _sectionHeader('Liens utiles', Icons.link_rounded),
                  const SizedBox(height: 14),
                  _card([
                    _linkTile(
                      'Conditions d\'utilisation',
                      Icons.description_outlined,
                    ),
                    const Divider(color: kBorderDark, height: 1, indent: 56),
                    _linkTile(
                      'Politique de confidentialité',
                      Icons.privacy_tip_outlined,
                    ),
                    const Divider(color: kBorderDark, height: 1, indent: 56),
                    _linkTile(
                      'Guide de vérification',
                      Icons.menu_book_outlined,
                    ),
                  ]),
                  const SizedBox(height: 60),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _quickAction(
    IconData icon,
    String title,
    String sub,
    Color c,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: kDarkCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: kBorderDark),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: c.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: c, size: 22),
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: GoogleFonts.inter(
                color: kTextPrimary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 2),
            Text(
              sub,
              style: GoogleFonts.inter(color: kTextMuted, fontSize: 9),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _faqItem(String q, String a, bool open, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: open ? kDarkCardLight : kDarkCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: open ? kPrimaryLight.withValues(alpha: 0.3) : kBorderDark,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: kPrimarySurface,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.help_outline_rounded,
                    color: kPrimaryLight,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    q,
                    style: GoogleFonts.inter(
                      color: kTextPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                AnimatedRotation(
                  turns: open ? 0.5 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: const Icon(
                    Icons.expand_more_rounded,
                    color: kTextMuted,
                    size: 20,
                  ),
                ),
              ],
            ),
            AnimatedCrossFade(
              firstChild: const SizedBox.shrink(),
              secondChild: Padding(
                padding: const EdgeInsets.only(top: 12, left: 38),
                child: Text(
                  a,
                  style: GoogleFonts.inter(
                    color: kTextSecondary,
                    fontSize: 12,
                    height: 1.6,
                  ),
                ),
              ),
              crossFadeState: open
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 250),
            ),
          ],
        ),
      ),
    );
  }

  Widget _contactForm() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: kDarkCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kBorderDark),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Sujet',
            style: GoogleFonts.inter(
              color: kTextMuted,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _cats.map((c) {
              final sel = _selectedCat == c;
              return GestureDetector(
                onTap: () => setState(() => _selectedCat = c),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: sel ? kPrimarySurface : kDarkCardLight,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: sel
                          ? kPrimaryLight.withValues(alpha: 0.4)
                          : kBorderDark,
                    ),
                  ),
                  child: Text(
                    c,
                    style: GoogleFonts.inter(
                      color: sel ? kPrimaryLight : kTextMuted,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          Text(
            'Votre message',
            style: GoogleFonts.inter(
              color: kTextMuted,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: kDarkSurface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: kBorderDark),
            ),
            child: TextField(
              controller: _msgCtrl,
              maxLines: 5,
              style: GoogleFonts.inter(color: kTextPrimary, fontSize: 13),
              decoration: InputDecoration(
                hintText: 'Décrivez votre problème...',
                hintStyle: GoogleFonts.inter(color: kTextMuted, fontSize: 13),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(14),
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                if (_msgCtrl.text.trim().isEmpty) return;
                _msgCtrl.clear();
                _snack('Message envoyé ✓ Réponse sous 24h.');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Envoyer le message',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader(String t, IconData i) => Row(
    children: [
      Icon(i, color: kGold, size: 18),
      const SizedBox(width: 8),
      Text(
        t.toUpperCase(),
        style: GoogleFonts.inter(
          color: kGold,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
        ),
      ),
    ],
  );
  Widget _card(List<Widget> c) => Container(
    decoration: BoxDecoration(
      color: kDarkCard,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: kBorderDark),
    ),
    child: Column(children: c),
  );
  Widget _linkTile(String t, IconData i) => InkWell(
    onTap: () {},
    borderRadius: BorderRadius.circular(16),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: kGoldSurface,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(i, color: kGold, size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              t,
              style: GoogleFonts.inter(
                color: kTextPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const Icon(Icons.open_in_new_rounded, color: kTextMuted, size: 16),
        ],
      ),
    ),
  );

  void _snack(String m) => ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(m, style: GoogleFonts.inter(fontSize: 13)),
      backgroundColor: kDarkCard,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  );
}
