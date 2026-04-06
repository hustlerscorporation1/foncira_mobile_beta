import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../theme/colors.dart';
import '../providers/terrain_provider.dart';
import '../providers/verification_provider.dart';
import '../component/terrain_card.dart';

import 'marketplace_page.dart';
import 'why_foncira_page.dart';
import 'terrain_detail_foncira.dart';
import 'request_verification_page.dart';
import 'verification_tunnel_page.dart';
import 'verification_tracking_page.dart';
import 'profile.dart';
import 'carte.dart';
import 'chat_support_page.dart';
import '../component/availability_indicator.dart';

// ══════════════════════════════════════════════════════════════
//  FONCIRA — Unified Home Page (Hub Central)
// ══════════════════════════════════════════════════════════════

class FonciraHomePage extends StatefulWidget {
  const FonciraHomePage({super.key});

  @override
  State<FonciraHomePage> createState() => _FonciraHomePageState();
}

class _FonciraHomePageState extends State<FonciraHomePage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [];

  @override
  void initState() {
    super.initState();
    _pages.addAll([
      const _HomeContent(),
      const CartePage(),
      const RequestVerificationPage(),
      const Profil(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kDarkBg,
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      decoration: BoxDecoration(
        color: kDarkCard,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: kBorderDark),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: kPrimaryLight,
          unselectedItemColor: kTextMuted,
          selectedLabelStyle: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: GoogleFonts.inter(fontSize: 11),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home_rounded),
              label: 'Accueil',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.map_outlined),
              activeIcon: Icon(Icons.map_rounded),
              label: 'Carte',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.verified_user_outlined),
              activeIcon: Icon(Icons.verified_user_rounded),
              label: 'Vérifier',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline_rounded),
              activeIcon: Icon(Icons.person_rounded),
              label: 'Profil',
            ),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
//  HOME CONTENT (Tab Accueil)
// ══════════════════════════════════════════════════════════════

class _HomeContent extends StatelessWidget {
  const _HomeContent();

  @override
  Widget build(BuildContext context) {
    final terrainProvider = context.watch<TerrainProvider>();
    final verifProvider = context.watch<VerificationProvider>();

    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──
            _buildHeader(context, verifProvider),
            const SizedBox(height: 24),

            // ── Context Text ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Au Togo, 7 terrains sur 10 présentent un risque juridique.',
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      color: kTextPrimary.withOpacity(0.6),
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'FONCIRA vérifie le vôtre avant tout paiement.',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: kPrimaryLight.withOpacity(0.7),
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ── Quick Actions ──
            _buildQuickActions(context, verifProvider),
            const SizedBox(height: 28),

            // ── Terrains vérifiés ──
            _buildSectionHeader(
              'Terrains vérifiés',
              'Voir tout',
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MarketplacePage()),
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              height: 270,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: terrainProvider.verifiedTerrains.length,
                itemBuilder: (context, index) {
                  final terrain = terrainProvider.verifiedTerrains[index];
                  return TerrainCard(
                    terrain: terrain,
                    isFavorite: terrainProvider.isFavorite(terrain.id),
                    onFavoriteTap: () =>
                        terrainProvider.toggleFavorite(terrain.id),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => TerrainDetailFoncira(terrain: terrain),
                      ),
                    ),
                  );
                },
              ),
            ).animate().fade(duration: 500.ms, delay: 200.ms),

            const SizedBox(height: 28),

            // ── Derniers ajouts ──
            _buildSectionHeader(
              'Derniers ajouts',
              'Voir tout',
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MarketplacePage()),
              ),
            ),
            const SizedBox(height: 14),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: terrainProvider.recentTerrains.map((terrain) {
                  return TerrainCard(
                    terrain: terrain,
                    isHorizontal: true,
                    isFavorite: terrainProvider.isFavorite(terrain.id),
                    onFavoriteTap: () =>
                        terrainProvider.toggleFavorite(terrain.id),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => TerrainDetailFoncira(terrain: terrain),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ).animate().fade(duration: 500.ms, delay: 400.ms),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    VerificationProvider verifProvider,
  ) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [kDarkBg, kPrimary.withOpacity(0.08)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Logo
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: kDarkCard,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: kBorderDark),
                ),
                child: Image.asset(
                  'assets/Image/FONCIRA.png',
                  width: 28,
                  height: 28,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'FONCIRA',
                      style: GoogleFonts.outfit(
                        color: kTextPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.5,
                      ),
                    ),
                    Text(
                      'Marketplace foncière sécurisée',
                      style: GoogleFonts.inter(color: kTextMuted, fontSize: 11),
                    ),
                  ],
                ),
              ),
              // Notification bell
              Stack(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: kDarkCard,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: kBorderDark),
                    ),
                    child: const Icon(
                      Icons.notifications_outlined,
                      color: kTextSecondary,
                      size: 20,
                    ),
                  ),
                  if (verifProvider.activeCount > 0)
                    Positioned(
                      right: 6,
                      top: 6,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: kPrimaryLight,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            'Trouvez et sécurisez\nvotre terrain',
            style: GoogleFonts.outfit(
              color: kTextPrimary,
              fontSize: 28,
              fontWeight: FontWeight.w700,
              height: 1.2,
            ),
          ).animate().fade(duration: 600.ms).slideX(begin: -0.05),
        ],
      ),
    );
  }

  Widget _buildQuickActions(
    BuildContext context,
    VerificationProvider verifProvider,
  ) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          _QuickActionCard(
            icon: Icons.explore_rounded,
            label: 'Explorer',
            color: kPrimaryLight,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const MarketplacePage()),
            ),
          ),
          const SizedBox(width: 10),
          _QuickActionCard(
            icon: Icons.verified_user_rounded,
            label: 'Vérifier',
            color: kGold,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    const VerificationTunnelPage(isExternalTerrain: true),
              ),
            ),
          ),
          const SizedBox(width: 10),
          _QuickActionCard(
            icon: Icons.assignment_rounded,
            label: 'Suivi',
            color: kInfo,
            badge: verifProvider.activeCount > 0
                ? verifProvider.activeCount.toString()
                : null,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const VerificationTrackingPage(),
              ),
            ),
          ),
          const SizedBox(width: 10),
          _QuickActionCard(
            icon: Icons.shield_rounded,
            label: 'Confiance',
            color: kSuccess,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const WhyFonciraPage()),
            ),
          ),
          const SizedBox(width: 10),
          _HelpActionCard(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ChatSupportPage()),
            ),
          ),
        ],
      ),
    ).animate().fade(duration: 500.ms, delay: 100.ms);
  }

  Widget _buildSectionHeader(
    String title,
    String actionText,
    VoidCallback? onAction,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: GoogleFonts.outfit(
              color: kTextPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          GestureDetector(
            onTap: onAction,
            child: Row(
              children: [
                Text(
                  actionText,
                  style: GoogleFonts.inter(
                    color: kPrimaryLight,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: kPrimaryLight,
                  size: 12,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Quick Action Card ────────────────────────────────────────

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;
  final String? badge;

  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.color,
    this.onTap,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 90,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: kDarkCard,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: kBorderDark),
          ),
          child: Column(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: color, size: 22),
                  ),
                  if (badge != null)
                    Positioned(
                      right: -4,
                      top: -4,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: kDanger,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          badge!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: GoogleFonts.inter(
                  color: kTextSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Help Action Card (Aide + Disponibilité) ──────────────────

class _HelpActionCard extends StatefulWidget {
  final VoidCallback? onTap;

  const _HelpActionCard({this.onTap});

  @override
  State<_HelpActionCard> createState() => _HelpActionCardState();
}

class _HelpActionCardState extends State<_HelpActionCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 90,
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: kDarkCard,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: kBorderDark),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icône animée avec glow
              AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  final scale =
                      1 + (0.1 * ((_controller.value - 0.5).abs() * 2));
                  return Transform.scale(
                    scale: scale,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Glow background
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                kGold.withOpacity(0.3),
                                kGold.withOpacity(0.05),
                              ],
                            ),
                          ),
                        ),
                        // Icône support agent
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                kGold.withOpacity(0.9),
                                kPrimaryLight.withOpacity(0.7),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: kGold.withOpacity(0.5),
                                blurRadius: 8,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.support_agent_rounded,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 8),

              // Label "Aide"
              Text(
                'Aide',
                style: GoogleFonts.inter(
                  color: kTextPrimary,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
