import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import '../theme/colors.dart';
import '../providers/terrain_provider.dart';
import '../providers/verification_provider.dart';
import '../providers/user_mode_provider.dart';
import '../models/publish_state.dart';
import '../models/terrain.dart';
import '../component/terrain_card.dart';
import '../services/terrain_seller_service.dart';
import '../services/terrain_publish_service.dart';
import '../services/seller_stats_service.dart';

import 'marketplace_page.dart';
import 'why_foncira_page.dart';
import 'request_verification_page.dart';
import 'verification_tunnel_page.dart';
import 'verification_tracking_page.dart';
import 'terrain_detail_foncira.dart';
import 'profile.dart';
import 'carte.dart';
import 'chat_support_page.dart';

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
  UserMode _lastMode = UserMode.buyer;

  @override
  Widget build(BuildContext context) {
    return Consumer<UserModeProvider>(
      builder: (context, modeProvider, _) {
        // Reset index to 0 when mode changes
        if (modeProvider.currentMode != _lastMode) {
          _currentIndex = 0;
          _lastMode = modeProvider.currentMode;
        }

        final List<Widget> pages = modeProvider.isBuyerMode
            ? [
                const _HomeContent(),
                const CartePage(),
                const RequestVerificationPage(),
                const Profil(),
              ]
            : [
                const _SellerAnnouncesTab(),
                const _SellerPublishTab(),
                const _SellerStatsTab(),
                const Profil(),
              ];

        return Scaffold(
          backgroundColor: kDarkBg,
          body: IndexedStack(index: _currentIndex, children: pages),
          bottomNavigationBar: _buildBottomNav(modeProvider),
        );
      },
    );
  }

  Widget _buildBottomNav(UserModeProvider modeProvider) {
    final navItems = modeProvider.isBuyerMode
        ? [
            const BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home_rounded),
              label: 'Accueil',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.map_outlined),
              activeIcon: Icon(Icons.map_rounded),
              label: 'Carte',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.verified_user_outlined),
              activeIcon: Icon(Icons.verified_user_rounded),
              label: 'Vérifier',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.person_outline_rounded),
              activeIcon: Icon(Icons.person_rounded),
              label: 'Profil',
            ),
          ]
        : [
            const BottomNavigationBarItem(
              icon: Icon(Icons.list_outlined),
              activeIcon: Icon(Icons.list_rounded),
              label: 'Annonces',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.add_circle_outline),
              activeIcon: Icon(Icons.add_circle),
              label: 'Publier',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart_outlined),
              activeIcon: Icon(Icons.bar_chart_rounded),
              label: 'Stats',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.person_outline_rounded),
              activeIcon: Icon(Icons.person_rounded),
              label: 'Profil',
            ),
          ];

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
          items: navItems,
        ),
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────
}

// ══════════════════════════════════════════════════════════════

class _HomeContent extends StatefulWidget {
  const _HomeContent();

  @override
  State<_HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<_HomeContent> {
  @override
  void initState() {
    super.initState();
    // Show tooltip after first frame if not seen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<TerrainProvider>().loadTerrains();
      final modeProvider = context.read<UserModeProvider>();
      if (modeProvider.shouldShowModeTooltip && modeProvider.isBuyerMode) {
        _showModeTooltip();
        modeProvider.markModeTooltipSeen();
      }
    });
  }

  void _showModeTooltip() {
    if (!mounted) return;
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Appuyez ici pour passer en mode vendeur',
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
          backgroundColor: kSuccess.withOpacity(0.9),
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.fromLTRB(20, 0, 20, 80),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    } catch (e) {
      // Silently fail if context not available
    }
  }

  @override
  Widget build(BuildContext context) {
    final terrainProvider = context.watch<TerrainProvider>();
    final verifProvider = context.watch<VerificationProvider>();
    final modeProvider = context.watch<UserModeProvider>();

    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──
            _buildHeader(context, verifProvider),
            const SizedBox(height: 20),

            // ── Context Text + Mode Pill (side by side) ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left: Statistics text (expandable)
                  Expanded(
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
                  const SizedBox(width: 12),
                  // Right: Mode Selection Pill (fixed width)
                  GestureDetector(
                    onTap: () => _showModeSelectionSheet(modeProvider),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 150),
                      transitionBuilder: (child, animation) {
                        return FadeTransition(opacity: animation, child: child);
                      },
                      child: Container(
                        key: ValueKey(modeProvider.currentMode),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: modeProvider.isBuyerMode
                              ? kPrimary.withOpacity(0.15)
                              : kSuccess.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: modeProvider.isBuyerMode
                                ? kPrimary.withOpacity(0.3)
                                : kSuccess.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              modeProvider.isBuyerMode
                                  ? Icons.person_rounded
                                  : Icons.sell_rounded,
                              size: 14,
                              color: modeProvider.isBuyerMode
                                  ? kPrimary
                                  : kSuccess,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              modeProvider.isBuyerMode ? 'Acheteur' : 'Vendeur',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: modeProvider.isBuyerMode
                                    ? kPrimary
                                    : kSuccess,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              Icons.expand_more_rounded,
                              size: 14,
                              color: modeProvider.isBuyerMode
                                  ? kPrimary
                                  : kSuccess,
                            ),
                          ],
                        ),
                      ),
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
                  final terrainData = terrainProvider.verifiedTerrains[index];
                  final terrain = Terrain.fromJson(terrainData);

                  return TerrainCard(
                    terrain: terrain,
                    isFavorite: terrainProvider.isFavorite(terrain.id),
                    onFavoriteTap: () {
                      terrainProvider.toggleFavorite(terrain.id);
                    },
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              TerrainDetailFoncira(terrain: terrain),
                        ),
                      );
                    },
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
                children: terrainProvider.recentTerrains.map((terrainData) {
                  final terrain = Terrain.fromJson(terrainData);

                  return TerrainCard(
                    terrain: terrain,
                    isHorizontal: true,
                    isFavorite: terrainProvider.isFavorite(terrain.id),
                    onFavoriteTap: () {
                      terrainProvider.toggleFavorite(terrain.id);
                    },
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              TerrainDetailFoncira(terrain: terrain),
                        ),
                      );
                    },
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

  // ──────────────────────────────────────────────────────────────
  //  MODE SELECTION BOTTOM SHEET
  // ──────────────────────────────────────────────────────────────
  void _showModeSelectionSheet(UserModeProvider modeProvider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.4),
      isScrollControlled: true,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: kDarkCard,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(28),
              topRight: Radius.circular(28),
            ),
            border: Border(
              top: BorderSide(color: kBorderDark, width: 1),
              left: BorderSide(color: kBorderDark, width: 1),
              right: BorderSide(color: kBorderDark, width: 1),
            ),
          ),
          padding: EdgeInsets.fromLTRB(
            20,
            28,
            20,
            20 + MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Mode cards (large layout)
              Row(
                children: [
                  // Acheteur card
                  Expanded(
                    child: _buildModeOptionCard(
                      icon: Icons.person_outline_rounded,
                      icon_size: 32,
                      title: 'Acheteur',
                      subtitle: 'Explorez et vérifiez\ndes terrains',
                      isActive: modeProvider.isBuyerMode,
                      color: kPrimary,
                      onTap: () {
                        if (!modeProvider.isBuyerMode) {
                          modeProvider.switchMode(UserMode.buyer);
                          Navigator.pop(context);
                          _showModeChangedSnackbar('Acheteur');
                        } else {
                          Navigator.pop(context);
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Vendeur card
                  Expanded(
                    child: _buildModeOptionCard(
                      icon: Icons.sell_rounded,
                      icon_size: 32,
                      title: 'Vendeur',
                      subtitle: 'Publiez et gérez\nvos annonces',
                      isActive: modeProvider.isSellerMode,
                      color: kSuccess,
                      onTap: () {
                        if (!modeProvider.isSellerMode) {
                          modeProvider.switchMode(UserMode.seller);
                          Navigator.pop(context);
                          _showModeChangedSnackbar('Vendeur');
                        } else {
                          Navigator.pop(context);
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  // Mode option card widget
  Widget _buildModeOptionCard({
    required IconData icon,
    required double icon_size,
    required String title,
    required String subtitle,
    required bool isActive,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isActive ? color.withOpacity(0.12) : kDarkBg,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isActive ? color : kBorderDark,
            width: isActive ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: isActive ? color.withOpacity(0.2) : kDarkCardLight,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isActive ? color.withOpacity(0.3) : kBorderDark,
                  width: 1,
                ),
              ),
              child: Icon(icon, color: color, size: icon_size),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: kTextPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: kTextMuted,
                fontWeight: FontWeight.w400,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Show snackbar on mode change
  void _showModeChangedSnackbar(String modeName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Passé en mode $modeName',
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: (modeName == 'Vendeur' ? kSuccess : kPrimary)
            .withOpacity(0.9),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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

// ══════════════════════════════════════════════════════════════
//  SELLER ANNOUNCES TAB (Mode Vendeur - Onglet 1)
// ══════════════════════════════════════════════════════════════

class _SellerAnnouncesTab extends StatefulWidget {
  const _SellerAnnouncesTab();

  @override
  State<_SellerAnnouncesTab> createState() => _SellerAnnouncesTabState();
}

class _SellerAnnouncesTabState extends State<_SellerAnnouncesTab> {
  final TerrainSellerService _terrainService = TerrainSellerService();
  List<Map<String, dynamic>> _terrains = [];
  Map<String, dynamic> _metrics = {
    'views_week': 0,
    'verification_requests': 0,
    'direct_contacts': 0,
  };
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final terrains = await _terrainService.getSellerTerrains();
      final metrics = await _terrainService.getSellerMetrics();
      setState(() {
        _terrains = terrains;
        _metrics = metrics;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erreur: $e')));
    }
  }

  Future<void> _refreshData() async {
    await _loadData();
  }

  Future<void> _featureTerrain(String terrainId) async {
    try {
      await _terrainService.featureTerrain(terrainId);
      _showSnackBar('Terrain mis en avant!', Colors.green);
      _refreshData();
    } catch (e) {
      _showSnackBar('Erreur: $e', Colors.red);
    }
  }

  Future<void> _markAsSold(String terrainId) async {
    try {
      await _terrainService.markAsSold(terrainId);
      _showSnackBar('Terrain marqué comme vendu', Colors.green);
      _refreshData();
    } catch (e) {
      _showSnackBar('Erreur: $e', Colors.red);
    }
  }

  Future<void> _archiveTerrain(String terrainId) async {
    try {
      await _terrainService.archiveTerrain(terrainId);
      _showSnackBar('Terrain archivé', Colors.green);
      _refreshData();
    } catch (e) {
      _showSnackBar('Erreur: $e', Colors.red);
    }
  }

  void _showSnackBar(String message, Color backgroundColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showContextMenu(BuildContext context, Map<String, dynamic> terrain) {
    final RenderBox button = context.findRenderObject() as RenderBox;
    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;
    final RelativeRect position = RelativeRect.fromRect(
      Rect.fromPoints(
        button.localToGlobal(Offset.zero, ancestor: overlay),
        button.localToGlobal(
          button.size.bottomRight(Offset.zero),
          ancestor: overlay,
        ),
      ),
      Offset.zero & overlay.size,
    );

    showMenu(
      context: context,
      position: position,
      items: [
        PopupMenuItem(
          child: const Text('Modifier'),
          onTap: () {
            _showSnackBar('Modification en cours...', Colors.blue);
          },
        ),
        PopupMenuItem(
          child: const Text('Mettre en avant'),
          onTap: () {
            _featureTerrain(terrain['id']);
          },
        ),
        PopupMenuItem(
          child: const Text('Marquer comme vendu'),
          onTap: () {
            _markAsSold(terrain['id']);
          },
        ),
        PopupMenuItem(
          child: const Text('Archiver'),
          onTap: () {
            _archiveTerrain(terrain['id']);
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final modeProvider = context.watch<UserModeProvider>();

    if (_isLoading) {
      return SafeArea(
        child: Center(child: CircularProgressIndicator(color: kPrimary)),
      );
    }

    return SafeArea(
      child: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.only(
              left: 20,
              right: 20,
              top: 20,
              bottom: 100,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Title Row + Mode Pill ──
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left: Title (expandable)
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Mes Annonces',
                            style: GoogleFonts.outfit(
                              color: kTextPrimary,
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Gérez vos terrains à vendre',
                            style: GoogleFonts.inter(
                              color: kTextMuted,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Right: Mode Selection Pill (fixed width)
                    GestureDetector(
                      onTap: () => _showModeSelectionSheet(modeProvider),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 150),
                        transitionBuilder: (child, animation) {
                          return FadeTransition(
                            opacity: animation,
                            child: child,
                          );
                        },
                        child: Container(
                          key: ValueKey(modeProvider.currentMode),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: modeProvider.isBuyerMode
                                ? kPrimary.withOpacity(0.15)
                                : kSuccess.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: modeProvider.isBuyerMode
                                  ? kPrimary.withOpacity(0.3)
                                  : kSuccess.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                modeProvider.isBuyerMode
                                    ? Icons.person_rounded
                                    : Icons.sell_rounded,
                                size: 14,
                                color: modeProvider.isBuyerMode
                                    ? kPrimary
                                    : kSuccess,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                modeProvider.isBuyerMode
                                    ? 'Acheteur'
                                    : 'Vendeur',
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: modeProvider.isBuyerMode
                                      ? kPrimary
                                      : kSuccess,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Icon(
                                Icons.expand_more_rounded,
                                size: 14,
                                color: modeProvider.isBuyerMode
                                    ? kPrimary
                                    : kSuccess,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // ──────────────────────────────────────────────────
                // METRIC CARDS SECTION
                // ──────────────────────────────────────────────────
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildMetricCard(
                        icon: Icons.visibility_rounded,
                        label: 'Vues cette semaine',
                        value: '${_metrics['views_week'] ?? 0}',
                      ),
                      const SizedBox(width: 12),
                      _buildMetricCard(
                        icon: Icons.check_circle_rounded,
                        label: 'Demandes vérification',
                        value: '${_metrics['verification_requests'] ?? 0}',
                      ),
                      const SizedBox(width: 12),
                      _buildMetricCard(
                        icon: Icons.mail_rounded,
                        label: 'Contacts directs',
                        value: '${_metrics['direct_contacts'] ?? 0}',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // ──────────────────────────────────────────────────
                // TERRAINS LIST OR EMPTY STATE
                // ──────────────────────────────────────────────────
                if (_terrains.isEmpty)
                  Center(
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: kDarkCardLight,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: kBorderDark),
                          ),
                          child: Icon(
                            Icons.list_alt_rounded,
                            color: kTextMuted,
                            size: 56,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Vous n\'avez pas encore de terrain',
                          style: GoogleFonts.outfit(
                            color: kTextSecondary,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Publiez votre premier terrain en moins de 3 minutes.',
                          style: GoogleFonts.inter(
                            color: kTextMuted,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  Column(
                    children: [
                      for (final terrain in _terrains)
                        _buildTerrainCard(context, terrain),
                    ],
                  ),
              ],
            ),
          ),

          // ──────────────────────────────────────────────────
          // FLOATING ACTION BUTTON
          // ──────────────────────────────────────────────────
          Positioned(
            bottom: 20,
            right: 20,
            child: FloatingActionButton.extended(
              onPressed: () {
                // Navigate to publish tab (index 1)
                final state = context
                    .findAncestorStateOfType<_FonciraHomePageState>();
                if (state != null) {
                  state.setState(() {
                    state._currentIndex = 1;
                  });
                }
              },
              backgroundColor: kPrimary,
              icon: const Icon(Icons.add),
              label: Text(
                'Publier un terrain',
                style: GoogleFonts.inter(fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kDarkCard,
        border: Border.all(color: kBorderDark),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: kPrimary, size: 28),
          const SizedBox(height: 12),
          Text(
            value,
            style: GoogleFonts.outfit(
              color: kTextPrimary,
              fontSize: 24,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.inter(color: kTextMuted, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildTerrainCard(BuildContext context, Map<String, dynamic> terrain) {
    final isFeatured = terrain['is_featured'] ?? false;
    final status = (terrain['status'] ?? 'draft').toString();
    final verificationStatus = (terrain['verification_status'] ?? 'non_verifie')
        .toString();
    final viewsThisWeek = terrain['views_count'] ?? 0;
    final title = (terrain['title'] ?? terrain['titre'] ?? 'Sans titre')
        .toString();
    final location =
        (terrain['location'] ??
                terrain['localisation'] ??
                terrain['ville'] ??
                'Localisation inconnue')
            .toString();
    final priceUsdRaw = terrain['price_usd'] ?? terrain['prix_usd'] ?? 0;
    final priceFcfaRaw = terrain['price_fcfa'] ?? terrain['prix_fcfa'] ?? 0;
    final priceUsd = priceUsdRaw is num
        ? priceUsdRaw.toDouble()
        : double.tryParse(priceUsdRaw.toString()) ?? 0;
    final priceFcfa = priceFcfaRaw is num
        ? priceFcfaRaw.toDouble()
        : double.tryParse(priceFcfaRaw.toString()) ?? 0;

    // Determine status badge color and text
    Color statusColor = kTextMuted;
    String statusText = 'Brouillon';
    if (status == 'publie') {
      statusColor = kSuccess;
      statusText = 'Publie';
    } else if (status == 'suspendu') {
      statusColor = Colors.orange;
      statusText = 'Suspendu';
    } else if (status == 'vendu') {
      statusColor = Colors.red;
      statusText = 'Vendu';
    } else if (status == 'archive') {
      statusColor = Colors.blueGrey;
      statusText = 'Archive';
    } else if (status == 'reserve') {
      statusColor = Colors.orange;
      statusText = 'Reserve';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: kDarkCard,
        border: Border.all(color: kBorderDark),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // Header with context menu
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.outfit(
                          color: kTextPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        location,
                        style: GoogleFonts.inter(
                          color: kTextMuted,
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Builder(
                  builder: (context) => IconButton(
                    icon: const Icon(Icons.more_vert),
                    color: kTextMuted,
                    onPressed: () => _showContextMenu(context, terrain),
                  ),
                ),
              ],
            ),
          ),
          Divider(color: kBorderDark, height: 1),

          // Price section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '\$${priceUsd.toStringAsFixed(0)}',
                      style: GoogleFonts.outfit(
                        color: kPrimaryLight,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      '${priceFcfa.toStringAsFixed(0)} FCFA',
                      style: GoogleFonts.inter(color: kTextMuted, fontSize: 11),
                    ),
                  ],
                ),
                // Badges
                Wrap(
                  spacing: 8,
                  children: [
                    // Status badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.2),
                        border: Border.all(color: statusColor),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        statusText,
                        style: GoogleFonts.inter(
                          color: statusColor,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    // Verification badge (only if verified)
                    if (verificationStatus != 'non_verifie')
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.2),
                          border: Border.all(color: Colors.green),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'Verifie',
                          style: GoogleFonts.inter(
                            color: Colors.green,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    // Performance indicator
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: viewsThisWeek > 0
                            ? Colors.green.withOpacity(0.2)
                            : Colors.grey.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.fiber_manual_record,
                        color: viewsThisWeek > 0 ? Colors.green : Colors.grey,
                        size: 8,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Featured banner
          if (isFeatured)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 6),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.1),
                border: Border(
                  top: BorderSide(color: Colors.amber.withOpacity(0.3)),
                ),
              ),
              child: Center(
                child: Text(
                  'En avant',
                  style: GoogleFonts.inter(
                    color: Colors.amber,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showModeSelectionSheet(UserModeProvider modeProvider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.4),
      isScrollControlled: true,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: kDarkCard,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(28),
              topRight: Radius.circular(28),
            ),
            border: Border(
              top: BorderSide(color: kBorderDark, width: 1),
              left: BorderSide(color: kBorderDark, width: 1),
              right: BorderSide(color: kBorderDark, width: 1),
            ),
          ),
          padding: EdgeInsets.fromLTRB(
            20,
            28,
            20,
            20 + MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Mode cards (large layout)
              Row(
                children: [
                  // Acheteur card
                  Expanded(
                    child: _buildModeOptionCard(
                      icon: Icons.person_outline_rounded,
                      icon_size: 32,
                      title: 'Acheteur',
                      subtitle: 'Explorez et vérifiez\ndes terrains',
                      isActive: modeProvider.isBuyerMode,
                      color: kPrimary,
                      onTap: () {
                        if (!modeProvider.isBuyerMode) {
                          modeProvider.switchMode(UserMode.buyer);
                          Navigator.pop(context);
                          _showModeChangedSnackbar('Acheteur');
                        } else {
                          Navigator.pop(context);
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Vendeur card
                  Expanded(
                    child: _buildModeOptionCard(
                      icon: Icons.sell_rounded,
                      icon_size: 32,
                      title: 'Vendeur',
                      subtitle: 'Publiez et gérez\nvos annonces',
                      isActive: modeProvider.isSellerMode,
                      color: kSuccess,
                      onTap: () {
                        if (!modeProvider.isSellerMode) {
                          modeProvider.switchMode(UserMode.seller);
                          Navigator.pop(context);
                          _showModeChangedSnackbar('Vendeur');
                        } else {
                          Navigator.pop(context);
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  // Mode option card widget
  Widget _buildModeOptionCard({
    required IconData icon,
    required double icon_size,
    required String title,
    required String subtitle,
    required bool isActive,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isActive ? color.withOpacity(0.12) : kDarkBg,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isActive ? color : kBorderDark,
            width: isActive ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: isActive ? color.withOpacity(0.2) : kDarkCardLight,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isActive ? color.withOpacity(0.3) : kBorderDark,
                  width: 1,
                ),
              ),
              child: Icon(icon, color: color, size: icon_size),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: kTextPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: kTextMuted,
                fontWeight: FontWeight.w400,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Show snackbar on mode change
  void _showModeChangedSnackbar(String modeName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Passé en mode $modeName',
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: (modeName == 'Vendeur' ? kSuccess : kPrimary)
            .withOpacity(0.9),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
//  SELLER PUBLISH TAB (Mode Vendeur - Onglet 2)
// ══════════════════════════════════════════════════════════════

class _SellerPublishTab extends StatefulWidget {
  const _SellerPublishTab();

  @override
  State<_SellerPublishTab> createState() => _SellerPublishTabState();
}

class _SellerPublishTabState extends State<_SellerPublishTab> {
  int currentStep = 1;
  late PublishState publishState;
  final TerrainPublishService _publishService = TerrainPublishService();

  // Controllers
  late TextEditingController titreController;
  late TextEditingController localisationController;
  late TextEditingController superficieController;
  late TextEditingController prixController;
  late TextEditingController descriptionController;

  bool isPublishing = false;

  @override
  void initState() {
    super.initState();
    publishState = const PublishState();
    titreController = TextEditingController();
    localisationController = TextEditingController();
    superficieController = TextEditingController();
    prixController = TextEditingController();
    descriptionController = TextEditingController();
  }

  @override
  void dispose() {
    titreController.dispose();
    localisationController.dispose();
    superficieController.dispose();
    prixController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  void _goToStep(int step) {
    setState(() => currentStep = step);
  }

  Future<void> _pickPhotos() async {
    final picker = ImagePicker();
    try {
      // Request permission to access photos
      final status = await Permission.photos.request();
      if (!status.isGranted) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Permission d\'accès aux photos refusée'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final pickedFiles = await picker.pickMultiImage();
      if (pickedFiles.isEmpty) return;

      print('📸 Photos sélectionnées: ${pickedFiles.length}');

      // Max 8 photos combined
      final maxToAdd = 8 - publishState.photoUrls.length;
      if (maxToAdd <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Maximum 8 photos atteint')),
        );
        return;
      }

      final filesToUpload = pickedFiles.take(maxToAdd);

      // Show loading indicator
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            '📤 Upload en cours... Cela peut prendre quelques secondes',
          ),
          duration: Duration(seconds: 30),
        ),
      );

      final newUrls = <String>[];
      final failedPhotos = <String>[];
      String? firstUploadError;

      for (final file in filesToUpload) {
        try {
          print('⏳ Upload photo: ${file.name}');
          // Import dart:io for File
          final uploadedUrl = await _publishService.uploadPhoto(
            File(file.path),
            file.name,
          );
          print('✅ Photo uploadée: ${file.name}');
          newUrls.add(uploadedUrl);
        } catch (e) {
          print('❌ Erreur upload photo ${file.name}: $e');
          failedPhotos.add(file.name);
          firstUploadError ??= e.toString().replaceFirst('Exception: ', '');
        }
      }

      if (!mounted) return;

      if (newUrls.isEmpty) {
        // Toutes les uploads ont échoué
        print('🚨 Aucune photo n\'a pu être uploadée');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('❌ Erreur : Impossible d\'uploader les photos'),
                const SizedBox(height: 8),
                Text(
                  failedPhotos.isNotEmpty
                      ? 'Fichiers echoues: ${failedPhotos.join(', ')}\n${firstUploadError != null ? 'Raison: $firstUploadError' : ''}'
                      : 'Verifiez que:\n- Les buckets "terrain_images" et "documents" existent\n- Les policies RLS Storage sont configurees\n- Vous etes bien connecte',
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
            backgroundColor: Colors.red[700],
            duration: const Duration(seconds: 5),
          ),
        );
        return;
      }

      if (newUrls.isNotEmpty) {
        setState(() {
          final combinedPhotos = [...publishState.photoUrls, ...newUrls];
          publishState = publishState.copyWith(
            photoUrls: combinedPhotos,
            photoOrders: List.generate(combinedPhotos.length, (i) => i),
          );
        });

        // Show success message
        if (!mounted) return;
        String successMsg = '✅ ${newUrls.length} photo(s) ajoutée(s)';
        if (failedPhotos.isNotEmpty) {
          successMsg += ' (${failedPhotos.length} échouée(s))';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(successMsg),
            backgroundColor: Colors.green[700],
            duration: const Duration(seconds: 2),
          ),
        );

        print(
          '✅ Total: ${newUrls.length} photos ajoutées, ${failedPhotos.length} échouées',
        );
      }
    } catch (e) {
      print('🚨 Erreur globale _pickPhotos: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red[700]),
      );
    }
  }

  void _removePhoto(int index) {
    setState(() {
      final newPhotos = List<String>.from(publishState.photoUrls);
      newPhotos.removeAt(index);
      publishState = publishState.copyWith(photoUrls: newPhotos);
    });
  }

  void _submitStep2() {
    if (titreController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Titre requis')));
      return;
    }
    if (localisationController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Localisation requise')));
      return;
    }
    if (superficieController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Superficie requise')));
      return;
    }
    if (prixController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Prix requis')));
      return;
    }
    if (publishState.typeDocument == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Type de document requis')));
      return;
    }

    setState(() {
      publishState = publishState.copyWith(
        titre: titreController.text,
        localisation: localisationController.text,
        superficie: int.tryParse(superficieController.text) ?? 0,
        prixFCFA: int.tryParse(prixController.text.replaceAll(' ', '')) ?? 0,
      );
      currentStep = 3;
    });
  }

  Future<void> _publishTerrain({required bool featured}) async {
    if (!publishState.hasMinPhotos()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Minimum 3 photos requises')),
      );
      return;
    }

    setState(() => isPublishing = true);

    try {
      // Save description
      final finalState = publishState.copyWith(
        description: descriptionController.text,
      );

      // Publish to Supabase
      await _publishService.publishTerrain(finalState, featured: featured);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            featured
                ? 'Terrain publié et mis en avant!'
                : 'Terrain publié avec succès!',
          ),
          backgroundColor: Colors.green,
        ),
      );

      // Navigate back to announcements tab
      final homeState = context
          .findAncestorStateOfType<_FonciraHomePageState>();
      if (homeState != null) {
        homeState.setState(() {
          homeState._currentIndex = 0;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erreur: $e')));
    } finally {
      setState(() => isPublishing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Stack(
        children: [
          // Progress bar at top
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Column(
              children: [
                LinearProgressIndicator(
                  value: currentStep / 4,
                  backgroundColor: kBorderDark,
                  valueColor: AlwaysStoppedAnimation(kPrimary),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Étape $currentStep sur 4',
                        style: GoogleFonts.inter(
                          color: kTextMuted,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        [
                          'Photos',
                          'Infos',
                          'Description',
                          'Récapitulatif',
                        ][currentStep - 1],
                        style: GoogleFonts.outfit(
                          color: kTextPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Current step content
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 120, 20, 100),
            child: _buildCurrentStep(),
          ),

          // Navigation footer
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              color: kDarkBg,
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (currentStep > 1)
                    ElevatedButton.icon(
                      onPressed: () => _goToStep(currentStep - 1),
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('Retour'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kDarkCard,
                        foregroundColor: kTextPrimary,
                        side: BorderSide(color: kBorderDark),
                      ),
                    )
                  else
                    const SizedBox.shrink(),
                  ElevatedButton.icon(
                    onPressed: _getNextButtonAction(),
                    icon: Icon(
                      currentStep == 4 ? Icons.check : Icons.arrow_forward,
                    ),
                    label: Text(currentStep == 4 ? 'Publier' : 'Suivant'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kPrimary,
                      foregroundColor: Colors.white,
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

  VoidCallback? _getNextButtonAction() {
    if (isPublishing) return null;

    switch (currentStep) {
      case 1:
        return publishState.hasMinPhotos() ? () => _goToStep(2) : null;
      case 2:
        return () => _submitStep2();
      case 3:
        return () => _goToStep(4);
      case 4:
        return null; // Handled by bottom sheet
      default:
        return null;
    }
  }

  Widget _buildCurrentStep() {
    switch (currentStep) {
      case 1:
        return _buildStep1Photos();
      case 2:
        return _buildStep2Info();
      case 3:
        return _buildStep3Description();
      case 4:
        return _buildStep4Summary();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildStep1Photos() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ajoutez 3 à 8 photos',
          style: GoogleFonts.outfit(
            color: kTextPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'La première photo sera la photo principale. Vous pouvez les réorganiser en déplaçant.',
          style: GoogleFonts.inter(color: kTextMuted, fontSize: 13),
        ),
        const SizedBox(height: 24),

        // Photo count indicator
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: publishState.hasMinPhotos()
                ? kSuccess.withOpacity(0.1)
                : Colors.orange.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: publishState.hasMinPhotos() ? kSuccess : Colors.orange,
            ),
          ),
          child: Row(
            children: [
              Icon(
                publishState.hasMinPhotos() ? Icons.check_circle : Icons.info,
                color: publishState.hasMinPhotos() ? kSuccess : Colors.orange,
              ),
              const SizedBox(width: 12),
              Text(
                '${publishState.photoUrls.length}/3-8 photos',
                style: GoogleFonts.inter(
                  color: publishState.hasMinPhotos() ? kSuccess : Colors.orange,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Photos grid
        if (publishState.photoUrls.isNotEmpty)
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: publishState.photoUrls.length,
            itemBuilder: (context, index) {
              return Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: kDarkCard,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: kBorderDark),
                      image: DecorationImage(
                        image: NetworkImage(publishState.photoUrls[index]),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  if (index == 0)
                    Positioned(
                      top: 4,
                      left: 4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: kPrimary,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'PRINCIPALE',
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: 8,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  Positioned(
                    bottom: 4,
                    right: 4,
                    child: GestureDetector(
                      onTap: () => _removePhoto(index),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        const SizedBox(height: 24),

        // Add photos button
        if (!publishState.hasMaxPhotos())
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _pickPhotos,
              icon: const Icon(Icons.add_photo_alternate),
              label: const Text('Ajouter des photos'),
              style: OutlinedButton.styleFrom(
                foregroundColor: kPrimary,
                side: BorderSide(color: kPrimary),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildStep2Info() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Infos essentielles',
          style: GoogleFonts.outfit(
            color: kTextPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 24),

        // Titre
        Text(
          'Titre du terrain',
          style: GoogleFonts.inter(
            color: kTextPrimary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: titreController,
          style: GoogleFonts.inter(color: kTextPrimary),
          decoration: InputDecoration(
            hintText: 'Ex: Terrain résidentiel avec vue',
            hintStyle: GoogleFonts.inter(color: kTextMuted),
            filled: true,
            fillColor: kDarkCard,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: kBorderDark),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: kBorderDark),
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Localisation
        Text(
          'Localisation',
          style: GoogleFonts.inter(
            color: kTextPrimary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: localisationController,
          style: GoogleFonts.inter(color: kTextPrimary),
          decoration: InputDecoration(
            hintText: 'Ex: Cocody, rue de la Paix',
            hintStyle: GoogleFonts.inter(color: kTextMuted),
            filled: true,
            fillColor: kDarkCard,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: kBorderDark),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: kBorderDark),
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Superficie
        Text(
          'Superficie (m²)',
          style: GoogleFonts.inter(
            color: kTextPrimary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: superficieController,
          keyboardType: TextInputType.number,
          style: GoogleFonts.inter(color: kTextPrimary),
          decoration: InputDecoration(
            hintText: 'Ex: 2500',
            hintStyle: GoogleFonts.inter(color: kTextMuted),
            filled: true,
            fillColor: kDarkCard,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: kBorderDark),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: kBorderDark),
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Prix FCFA
        Text(
          'Prix en FCFA',
          style: GoogleFonts.inter(
            color: kTextPrimary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: prixController,
          keyboardType: TextInputType.number,
          style: GoogleFonts.inter(color: kTextPrimary),
          onChanged: (value) {
            setState(() {}); // Trigger USD conversion update
          },
          decoration: InputDecoration(
            hintText: 'Ex: 50000000',
            hintStyle: GoogleFonts.inter(color: kTextMuted),
            filled: true,
            fillColor: kDarkCard,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: kBorderDark),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: kBorderDark),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '≈ \$${PublishState.convertToUSD(int.tryParse(prixController.text.replaceAll(' ', '')) ?? 0)}',
          style: GoogleFonts.inter(color: kTextMuted, fontSize: 12),
        ),
        const SizedBox(height: 24),

        // Type de document
        Text(
          'Type de document',
          style: GoogleFonts.inter(
            color: kTextPrimary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: PublishDocumentType.values.map((doc) {
            final isSelected = publishState.typeDocument == doc;
            return GestureDetector(
              onTap: () {
                setState(() {
                  publishState = publishState.copyWith(typeDocument: doc);
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? kPrimary : kDarkCard,
                  border: Border.all(
                    color: isSelected ? kPrimary : kBorderDark,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  documentTypeToString(doc),
                  style: GoogleFonts.inter(
                    color: isSelected ? Colors.white : kTextPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildStep3Description() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Description du terrain',
          style: GoogleFonts.outfit(
            color: kTextPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Facultatif — décrivez l\'emplacement, les accès, les avantages',
          style: GoogleFonts.inter(color: kTextMuted, fontSize: 13),
        ),
        const SizedBox(height: 24),

        TextField(
          controller: descriptionController,
          maxLines: 8,
          style: GoogleFonts.inter(color: kTextPrimary),
          decoration: InputDecoration(
            hintText:
                'Décrivez l\'emplacement, les accès, les avantages du terrain...',
            hintStyle: GoogleFonts.inter(color: kTextMuted),
            filled: true,
            fillColor: kDarkCard,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: kBorderDark),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: kBorderDark),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStep4Summary() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Récapitulatif',
          style: GoogleFonts.outfit(
            color: kTextPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 24),

        // Preview card
        Container(
          decoration: BoxDecoration(
            color: kDarkCard,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: kBorderDark),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Photo
              if (publishState.photoUrls.isNotEmpty)
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                  child: Image.network(
                    publishState.photoUrls[0],
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),

              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titreController.text,
                      style: GoogleFonts.outfit(
                        color: kTextPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      localisationController.text,
                      style: GoogleFonts.inter(color: kTextMuted, fontSize: 12),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '\$${PublishState.convertToUSD(int.tryParse(prixController.text.replaceAll(' ', '')) ?? 0)}',
                              style: GoogleFonts.outfit(
                                color: kPrimaryLight,
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              '${prixController.text} FCFA',
                              style: GoogleFonts.inter(
                                color: kTextMuted,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '${superficieController.text} m²',
                              style: GoogleFonts.inter(
                                color: kTextPrimary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              documentTypeToString(publishState.typeDocument),
                              style: GoogleFonts.inter(
                                color: kTextMuted,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),

        // Publication options
        Text(
          'Option de publication',
          style: GoogleFonts.inter(
            color: kTextPrimary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 12),

        // Free option
        GestureDetector(
          onTap: isPublishing ? null : () => _publishTerrain(featured: false),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: kPrimary.withOpacity(0.1),
              border: Border.all(color: kPrimary),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Publier gratuitement',
                      style: GoogleFonts.outfit(
                        color: kTextPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (isPublishing)
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(kPrimary),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Votre terrain apparaîtra dans la marketplace',
                  style: GoogleFonts.inter(color: kTextMuted, fontSize: 12),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Featured option
        GestureDetector(
          onTap: isPublishing ? null : () => _publishFeaturedDialog(),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: kDarkCard,
              border: Border.all(color: kBorderDark),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.star,
                              color: Colors.amber,
                              size: 18,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Mettre en avant — 15 000 F/mois',
                              style: GoogleFonts.outfit(
                                color: kTextPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Apparaît en haut de la marketplace',
                          style: GoogleFonts.inter(
                            color: kTextMuted,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _publishFeaturedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: kDarkCard,
        title: Text(
          'Mettre en avant',
          style: GoogleFonts.outfit(color: kTextPrimary),
        ),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Votre terrain sera mis en avant en haut de la marketplace pendant 1 mois.',
              style: GoogleFonts.inter(color: kTextMuted),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.amber),
              ),
              child: Text(
                'Coût: 15 000 FCFA/mois (≈\$23)',
                style: GoogleFonts.inter(
                  color: Colors.amber,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Annuler', style: GoogleFonts.inter(color: kTextMuted)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _publishTerrain(featured: true);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
            child: Text('Confirmer', style: GoogleFonts.inter(color: kDarkBg)),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
//  SELLER STATS TAB (Mode Vendeur - Onglet 3)
// ══════════════════════════════════════════════════════════════

class _SellerStatsTab extends StatefulWidget {
  const _SellerStatsTab();

  @override
  State<_SellerStatsTab> createState() => _SellerStatsTabState();
}

class _SellerStatsTabState extends State<_SellerStatsTab> {
  final SellerStatsService _statsService = SellerStatsService();
  late StatsPeriod selectedPeriod = StatsPeriod.days7;
  List<Map<String, dynamic>> stats = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() => isLoading = true);
    final loadedStats = await _statsService.getSellerStats(selectedPeriod);
    setState(() {
      stats = loadedStats;
      isLoading = false;
    });
  }

  void _changePeriod(StatsPeriod period) {
    setState(() => selectedPeriod = period);
    _loadStats();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Statistiques',
              style: GoogleFonts.outfit(
                color: kTextPrimary,
                fontSize: 28,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Suivez la performance de vos annonces',
              style: GoogleFonts.inter(color: kTextMuted, fontSize: 14),
            ),
            const SizedBox(height: 24),

            // Period selector pills
            Row(
              children: [
                _buildPeriodPill('7 jours', StatsPeriod.days7),
                const SizedBox(width: 12),
                _buildPeriodPill('30 jours', StatsPeriod.days30),
                const SizedBox(width: 12),
                _buildPeriodPill('3 mois', StatsPeriod.days90),
              ],
            ),
            const SizedBox(height: 24),

            // Stats list
            if (isLoading)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(40),
                  child: CircularProgressIndicator(color: kPrimary),
                ),
              )
            else if (stats.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(40),
                  child: Column(
                    children: [
                      Icon(
                        Icons.bar_chart_outlined,
                        color: kTextMuted,
                        size: 48,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Aucune statistique disponible',
                        style: GoogleFonts.outfit(
                          color: kTextMuted,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              Column(
                children: [
                  for (final stat in stats) _buildStatCard(context, stat),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodPill(String label, StatsPeriod period) {
    final isSelected = selectedPeriod == period;
    return GestureDetector(
      onTap: () => _changePeriod(period),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? kPrimary : kDarkCard,
          border: Border.all(color: isSelected ? kPrimary : kBorderDark),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            color: isSelected ? Colors.white : kTextPrimary,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, Map<String, dynamic> stat) {
    final views = stat['views'] ?? 0;
    final requests = stat['verification_requests'] ?? 0;
    final contacts = stat['direct_contacts'] ?? 0;
    final message = stat['contextual_message'] ?? '';
    final title = stat['titre'] ?? 'Sans titre';
    final photoUrl = stat['photo_url'];

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: kDarkCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kBorderDark),
      ),
      child: Column(
        children: [
          // Header with photo and title
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Photo thumbnail
                if (photoUrl != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      photoUrl,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                    ),
                  )
                else
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: kBorderDark,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.image_outlined, color: kTextMuted),
                  ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.outfit(
                          color: kTextPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Divider(color: kBorderDark, height: 1),

          // Stats metrics
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Simple bar chart for views
                Text(
                  'Vues',
                  style: GoogleFonts.inter(
                    color: kTextMuted,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: (views / 100).clamp(0, 1),
                    backgroundColor: kBorderDark,
                    valueColor: AlwaysStoppedAnimation(kPrimary),
                    minHeight: 8,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$views vues',
                  style: GoogleFonts.inter(
                    color: kTextPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),

                // Metrics grid
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildMetricBox('Demandes', requests),
                    _buildMetricBox('Contacts', contacts),
                  ],
                ),
              ],
            ),
          ),

          // Contextual message if present
          if (message.isNotEmpty) ...[
            Divider(color: kBorderDark, height: 1),
            Container(
              padding: const EdgeInsets.all(12),
              color: kPrimaryLight.withOpacity(0.1),
              child: Row(
                children: [
                  Icon(
                    Icons.lightbulb_outlined,
                    color: kPrimaryLight,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      message,
                      style: GoogleFonts.inter(
                        color: kPrimaryLight,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMetricBox(String label, int value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: kBorderDark,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Column(
          children: [
            Text(
              '$value',
              style: GoogleFonts.outfit(
                color: kTextPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              label,
              style: GoogleFonts.inter(color: kTextMuted, fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }
}
