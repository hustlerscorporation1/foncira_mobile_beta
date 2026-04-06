import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../theme/colors.dart';

// ══════════════════════════════════════════════════════════════
//  FONCIRA — Splash Screen (premium)
// ══════════════════════════════════════════════════════════════

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  bool _isFadingOut = false;
  late AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startRedirectTimer();
    });
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  void _startRedirectTimer() {
    Timer(const Duration(milliseconds: 3000), _redirect);
  }

  Future<void> _redirect() async {
    if (!mounted) return;

    final session = Supabase.instance.client.auth.currentSession;
    String destination;

    if (session == null) {
      destination = '/onboarding';
    } else {
      destination = '/home';
    }

    setState(() {
      _isFadingOut = true;
    });

    await Future.delayed(const Duration(milliseconds: 600));

    if (mounted) {
      Navigator.of(context).pushReplacementNamed(destination);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: _isFadingOut ? 0.0 : 1.0,
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOut,
      child: Scaffold(
        backgroundColor: kDarkBg,
        body: Stack(
          children: [
            // ── Subtle radial glow ──
            Center(
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      kPrimary.withOpacity(0.08),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            // ── Content ──
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Logo
                  Image.asset(
                    'assets/Image/FONCIRA.png',
                    width: 140,
                  )
                      .animate()
                      .fade(duration: 1200.ms, curve: Curves.easeIn)
                      .scale(
                        begin: const Offset(0.8, 0.8),
                        end: const Offset(1.0, 1.0),
                        duration: 1200.ms,
                        curve: Curves.easeOutBack,
                      ),

                  const SizedBox(height: 24),

                  // Tagline
                  Text(
                    'Sécurisez votre terrain',
                    style: GoogleFonts.inter(
                      color: kTextSecondary,
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      letterSpacing: 1.5,
                    ),
                  )
                      .animate()
                      .fade(duration: 800.ms, delay: 800.ms)
                      .slideY(begin: 0.3, curve: Curves.easeOut),

                  const SizedBox(height: 48),

                  // Loading bar
                  SizedBox(
                    width: 120,
                    child: AnimatedBuilder(
                      animation: _shimmerController,
                      builder: (context, child) {
                        return LinearProgressIndicator(
                          backgroundColor: kDarkCardLight,
                          color: kPrimary.withOpacity(0.5),
                          minHeight: 2,
                        );
                      },
                    ),
                  )
                      .animate()
                      .fade(duration: 600.ms, delay: 1200.ms),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
