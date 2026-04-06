import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/colors.dart';
import '../component/foncira_button.dart';

// ══════════════════════════════════════════════════════════════
//  FONCIRA — Onboarding Presentation (3 slides)
// ══════════════════════════════════════════════════════════════

class Presentation extends StatefulWidget {
  const Presentation({super.key});

  @override
  State<Presentation> createState() => _PresentationState();
}

class _PresentationState extends State<Presentation>
    with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  late AnimationController _bgController;
  late Animation<double> _bgScale;

  final List<_OnboardingSlide> _slides = [
    _OnboardingSlide(
      title: 'Trouvez votre\nterrain idéal',
      subtitle:
          'Parcourez des centaines de terrains vérifiés avec des fiches détaillées et standardisées.',
      icon: Icons.landscape_rounded,
      accentColor: kPrimaryLight,
    ),
    _OnboardingSlide(
      title: 'Vérifiez avant\nd\'acheter',
      subtitle:
          'Demandez une vérification approfondie de tout terrain, même trouvé en dehors de FONCIRA.',
      icon: Icons.verified_user_rounded,
      accentColor: kGold,
    ),
    _OnboardingSlide(
      title: 'Sécurisez votre\ninvestissement',
      subtitle:
          'Suivez votre vérification en temps réel et bénéficiez d\'un accompagnement administratif complet.',
      icon: Icons.shield_rounded,
      accentColor: kSuccess,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat(reverse: true);
    _bgScale = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _bgController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _bgController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: kDarkBg,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── Background image ──
          AnimatedBuilder(
            animation: _bgScale,
            builder: (context, child) {
              return Transform.scale(
                scale: _bgScale.value,
                child: Image.asset(
                  'assets/Image/presentation.png',
                  fit: BoxFit.cover,
                  color: Colors.black.withOpacity(0.55),
                  colorBlendMode: BlendMode.darken,
                ),
              );
            },
          ),

          // ── Gradient overlay ──
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.3),
                  Colors.transparent,
                  kDarkBg.withOpacity(0.85),
                  kDarkBg,
                ],
                stops: const [0.0, 0.3, 0.6, 1.0],
              ),
            ),
          ),

          // ── Content ──
          SafeArea(
            child: Column(
              children: [
                // ── Logo ──
                Padding(
                  padding: const EdgeInsets.only(top: 24),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 20,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.2),
                          ),
                        ),
                        child: Text(
                          'FONCIRA',
                          style: GoogleFonts.outfit(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: 3,
                          ),
                        ),
                      ),
                    ),
                  ),
                ).animate().fade(duration: 800.ms, delay: 200.ms),

                // ── Pages ──
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() => _currentPage = index);
                    },
                    itemCount: _slides.length,
                    itemBuilder: (context, index) {
                      final slide = _slides[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            // Icon circle
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: slide.accentColor.withOpacity(0.15),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: slide.accentColor.withOpacity(0.3),
                                ),
                              ),
                              child: Icon(
                                slide.icon,
                                color: slide.accentColor,
                                size: 36,
                              ),
                            ),
                            const SizedBox(height: 32),

                            Text(
                              slide.title,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.outfit(
                                fontSize: size.width * 0.08,
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                height: 1.2,
                              ),
                            ),
                            const SizedBox(height: 16),

                            Text(
                              slide.subtitle,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.inter(
                                fontSize: 15,
                                color: kTextSecondary,
                                height: 1.6,
                              ),
                            ),
                            const SizedBox(height: 60),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                // ── Page indicator ──
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    _slides.length,
                    (index) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: _currentPage == index ? 24 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _currentPage == index
                            ? kPrimaryLight
                            : kTextMuted.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // ── CTA ──
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: FonciraButton(
                    label: _currentPage == _slides.length - 1
                        ? 'Commencer'
                        : 'Suivant',
                    icon: _currentPage == _slides.length - 1
                        ? Icons.arrow_forward_rounded
                        : null,
                    onPressed: () {
                      if (_currentPage < _slides.length - 1) {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeInOut,
                        );
                      } else {
                        Navigator.pushReplacementNamed(context, '/login');
                      }
                    },
                  ),
                ),
                const SizedBox(height: 12),

                // Skip button
                TextButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/login');
                  },
                  child: Text(
                    'Passer',
                    style: GoogleFonts.inter(
                      color: kTextMuted,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OnboardingSlide {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color accentColor;

  _OnboardingSlide({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accentColor,
  });
}
