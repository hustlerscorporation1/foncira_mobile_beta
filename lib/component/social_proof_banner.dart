import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/colors.dart';

// ══════════════════════════════════════════════════════════════
//  FONCIRA — Compteur Preuve Sociale
// ══════════════════════════════════════════════════════════════

class SocialProofBanner extends StatefulWidget {
  const SocialProofBanner({super.key});

  @override
  State<SocialProofBanner> createState() => _SocialProofBannerState();
}

class _SocialProofBannerState extends State<SocialProofBanner>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  int _currentTestimonialIndex = 0;

  final List<Map<String, String>> _testimonials = [
    {
      'country': '🇫🇷 France',
      'amount': '\$42,500',
      'risk': 'Évité un faux notaire',
      'name': 'Marc D.',
    },
    {
      'country': '🇺🇸 USA',
      'amount': '\$156,000',
      'risk': 'Détecté conflit de succession',
      'name': 'Asha M.',
    },
    {
      'country': '🇨🇦 Canada',
      'amount': '\$78,300',
      'risk': 'Confirmé propriété coutumière',
      'name': 'Jean-Paul K.',
    },
    {
      'country': '🇫🇷 France',
      'amount': '\$95,200',
      'risk': 'Terrain sans litige confirmé',
      'name': 'Sophie G.',
    },
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 30),
      vsync: this,
    )..repeat();

    // Rotation des témoignages toutes les 5 secondes
    Future.delayed(Duration.zero, () {
      _startTestimonialRotation();
    });
  }

  void _startTestimonialRotation() {
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        setState(() {
          _currentTestimonialIndex =
              (_currentTestimonialIndex + 1) % _testimonials.length;
        });
        _startTestimonialRotation();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [kPrimarySurface, kGoldSurface],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kPrimaryLight.withOpacity(0.3), width: 1),
      ),
      child: Column(
        children: [
          // 1️⃣ Métriques principales
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _MetricItem(icon: '✓', label: 'Terrains\nvérifiés', value: '312'),
              Container(
                width: 1,
                height: 50,
                color: kTextSecondary.withOpacity(0.3),
              ),
              _MetricItem(icon: '🛡️', label: 'Litiges\névités', value: '47'),
              Container(
                width: 1,
                height: 50,
                color: kTextSecondary.withOpacity(0.3),
              ),
              _MetricItem(icon: '💰', label: 'FCFA\nProtégés', value: '4.1B'),
            ],
          ),
          const SizedBox(height: 20),
          // 2️⃣ Témoignage rotatif
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 600),
            transitionBuilder: (child, animation) {
              return FadeTransition(opacity: animation, child: child);
            },
            child: _TestimonialCard(
              key: ValueKey(_currentTestimonialIndex),
              testimonial: _testimonials[_currentTestimonialIndex],
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricItem extends StatelessWidget {
  final String icon;
  final String label;
  final String value;

  const _MetricItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(icon, style: const TextStyle(fontSize: 24)),
        const SizedBox(height: 8),
        Text(
          value,
          style: GoogleFonts.outfit(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: kTextPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: 11,
            color: kTextSecondary,
            height: 1.2,
          ),
        ),
      ],
    );
  }
}

class _TestimonialCard extends StatelessWidget {
  final Map<String, String> testimonial;

  const _TestimonialCard({super.key, required this.testimonial});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kGold.withOpacity(0.3), width: 1),
      ),
      child: Column(
        children: [
          Text(
            '"${testimonial['risk']}"',
            style: GoogleFonts.inter(
              fontSize: 13,
              fontStyle: FontStyle.italic,
              color: kTextPrimary,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${testimonial['country']} • ${testimonial['amount']}',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: kGold,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '— ${testimonial['name']}',
                style: GoogleFonts.inter(fontSize: 12, color: kTextSecondary),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
