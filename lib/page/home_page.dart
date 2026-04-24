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
import '../component/notification_bell_button.dart';
import '../component/price_row.dart';
import '../services/terrain_seller_service.dart';
import '../services/terrain_publish_service.dart';
import '../services/seller_stats_service.dart';
import '../utils/terrain_score_calculator.dart';

import 'marketplace_page.dart';
import 'why_foncira_page.dart';
import 'request_verification_page.dart';
import 'verification_tunnel_page.dart';
import 'verification_tracking_page.dart';
import 'favoris_foncira.dart';
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
    // Load terrains after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<TerrainProvider>().loadTerrains();
    });
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
          _QuickActionCard(
            icon: Icons.favorite_rounded,
            label: 'Favoris',
            color: kDanger,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const FavorisPageFoncira()),
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
    'views_total': 0,
    'verification_requests': 0,
    'sold_count': 0,
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

  Future<void> _suspendTerrain(String terrainId) async {
    try {
      await _terrainService.suspendTerrain(terrainId);
      _showSnackBar('Terrain suspendu temporairement', Colors.orange);
      _refreshData();
    } catch (e) {
      _showSnackBar('Erreur: $e', Colors.red);
    }
  }

  Future<void> _deleteTerrain(String terrainId) async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer le terrain?'),
        content: const Text(
          'Cette action est irréversible. Le terrain sera définitivement supprimé.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Supprimer', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _terrainService.deleteTerrain(terrainId);
        _showSnackBar('Terrain supprimé définitivement', Colors.red);
        _refreshData();
      } catch (e) {
        _showSnackBar('Erreur: $e', Colors.red);
      }
    }
  }

  void _modifyTerrain(Map<String, dynamic> terrain) {
    // Show simple edit dialog for terrain details
    showDialog(
      context: context,
      builder: (context) => _buildModifyTerrainDialog(context, terrain),
    );
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

  Future<void> _showContextMenu(
    BuildContext context,
    Map<String, dynamic> terrain,
  ) async {
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

    final selectedAction = await showMenu<String>(
      context: context,
      position: position,
      items: const <PopupMenuEntry<String>>[
        PopupMenuItem<String>(value: 'modify', child: Text('Modifier')),
        PopupMenuItem<String>(value: 'feature', child: Text('Mettre en avant')),
        PopupMenuItem<String>(
          value: 'sold',
          child: Text('Marquer comme vendu'),
        ),
        PopupMenuItem<String>(value: 'suspend', child: Text('Suspendre')),
        PopupMenuItem<String>(value: 'archive', child: Text('Archiver')),
        PopupMenuDivider(),
        PopupMenuItem<String>(
          value: 'delete',
          child: Text('Supprimer', style: TextStyle(color: Colors.red)),
        ),
      ],
    );

    if (selectedAction == null || !mounted) return;

    if (selectedAction == 'modify') {
      _modifyTerrain(terrain);
      return;
    }

    final terrainId = terrain['id']?.toString();
    if (terrainId == null || terrainId.isEmpty) {
      _showSnackBar('ID du terrain introuvable', Colors.red);
      return;
    }

    switch (selectedAction) {
      case 'feature':
        await _featureTerrain(terrainId);
        break;
      case 'sold':
        await _markAsSold(terrainId);
        break;
      case 'suspend':
        await _suspendTerrain(terrainId);
        break;
      case 'archive':
        await _archiveTerrain(terrainId);
        break;
      case 'delete':
        await _deleteTerrain(terrainId);
        break;
      default:
        break;
    }
  }

  /// Build a simple modify terrain dialog with editable fields
  Widget _buildModifyTerrainDialog(
    BuildContext context,
    Map<String, dynamic> terrain,
  ) {
    final titleController = TextEditingController(
      text: (terrain['title'] ?? terrain['titre'] ?? '').toString(),
    );
    final descriptionController = TextEditingController(
      text: (terrain['description'] ?? '').toString(),
    );
    final priceUsdController = TextEditingController(
      text: (terrain['price_usd'] ?? terrain['prix_usd'] ?? '').toString(),
    );
    final priceFcfaController = TextEditingController(
      text: (terrain['price_fcfa'] ?? terrain['prix_fcfa'] ?? '').toString(),
    );
    final areaController = TextEditingController(
      text: (terrain['area_sqm'] ?? '').toString(),
    );

    return AlertDialog(
      title: const Text('Modifier l\'annonce'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Titre'),
              maxLines: 2,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
              maxLines: 4,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: priceUsdController,
                    decoration: const InputDecoration(labelText: 'Prix (USD)'),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: priceFcfaController,
                    decoration: const InputDecoration(labelText: 'Prix (FCFA)'),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: areaController,
              decoration: const InputDecoration(labelText: 'Superficie (m²)'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Annuler'),
        ),
        ElevatedButton(
          onPressed: () async {
            try {
              await _terrainService.updateTerrain(
                terrainId: terrain['id'],
                title: titleController.text.isNotEmpty
                    ? titleController.text
                    : null,
                description: descriptionController.text.isNotEmpty
                    ? descriptionController.text
                    : null,
                priceUsd: priceUsdController.text.isNotEmpty
                    ? double.parse(priceUsdController.text)
                    : null,
                priceFcfa: priceFcfaController.text.isNotEmpty
                    ? int.parse(priceFcfaController.text)
                    : null,
                areaSqm: areaController.text.isNotEmpty
                    ? double.parse(areaController.text)
                    : null,
              );
              if (mounted) {
                Navigator.pop(context);
                _showSnackBar('Annonce modifiée avec succès', Colors.green);
                _refreshData();
              }
            } catch (e) {
              _showSnackBar('Erreur: $e', Colors.red);
            }
          },
          child: const Text('Sauvegarder'),
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
                // ── Title Row + Mode Pill + Notification Bell ──
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                    // Right: Controls (Notification Bell)
                    const NotificationBellButton(),
                  ],
                ),
                const SizedBox(height: 24),

                // ──────────────────────────────────────────────────
                // METRIC CARDS SECTION (3 columns)
                // ──────────────────────────────────────────────────
                Row(
                  children: [
                    Expanded(
                      child: _buildMetricCard(
                        icon: Icons.visibility_rounded,
                        label: 'Vues totales',
                        value: '${_metrics['views_total'] ?? 0}',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildMetricCard(
                        icon: Icons.check_circle_rounded,
                        label: 'Demandes vérif.',
                        value: '${_metrics['verification_requests'] ?? 0}',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildMetricCard(
                        icon: Icons.sell_rounded,
                        label: 'Biens vendus',
                        value: '${_metrics['sold_count'] ?? 0}',
                      ),
                    ),
                  ],
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

    // Calculate reliability score
    final score = TerrainScoreCalculator.calculateScore(
      title: title,
      description: terrain['description'] as String?,
      photosCount: (terrain['additional_photos'] as List?)?.length ?? 0,
      documentsCount: 0, // TODO: Count actual documents when available
      location: terrain['location'] as String?,
      quartier: terrain['quartier'] as String?,
      ville: location,
      priceFcfa: priceFcfa,
      priceUsd: priceUsd,
      areaSqm: terrain['area_sqm'] is num
          ? (terrain['area_sqm'] as num).toInt()
          : int.tryParse((terrain['area_sqm'] ?? '').toString()) ?? 0,
    );
    final scoreLabel = TerrainScoreCalculator.getScoreLabel(score);
    final scoreColorHex = TerrainScoreCalculator.getScoreColor(score);
    final scoreColor = Color(
      int.parse(scoreColorHex.replaceFirst('#', '0xff')),
    );

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
                PriceRow(
                  priceUsd: priceUsd,
                  priceFcfa: priceFcfa,
                  usdFontSize: 18,
                  fcfaFontSize: 11,
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
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.green, width: 1.5),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.verified_rounded,
                              color: Colors.green,
                              size: 14,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Vérifié',
                              style: GoogleFonts.inter(
                                color: Colors.green,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    // Score badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: scoreColor.withOpacity(0.15),
                        border: Border.all(color: scoreColor, width: 1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.show_chart_rounded,
                            color: scoreColor,
                            size: 12,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '$score/100',
                            style: GoogleFonts.inter(
                              color: scoreColor,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
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
  bool? _selectedFeaturedOption;

  // Document upload properties
  final Map<String, File?> _documentFiles = {
    'titre_foncier': null,
    'plan_terrain': null,
    'autorisation_vente': null,
    'recu_achat': null,
  };
  final Map<String, bool> _documentUploading = {
    'titre_foncier': false,
    'plan_terrain': false,
    'autorisation_vente': false,
    'recu_achat': false,
  };

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

  // ──────────────────────────────────────────────────────────────
  // Document Management Methods
  // ──────────────────────────────────────────────────────────────

  String _getDocumentLabel(String category) {
    switch (category) {
      case 'titre_foncier':
        return 'Titre foncier';
      case 'plan_terrain':
        return 'Plan du terrain';
      case 'autorisation_vente':
        return 'Autorisation de vente';
      case 'recu_achat':
        return 'Reçu d\'achat';
      default:
        return category;
    }
  }

  IconData _getDocumentIcon(String fileName) {
    if (fileName.toLowerCase().endsWith('.pdf')) {
      return Icons.picture_as_pdf_rounded;
    }
    return Icons.image_rounded;
  }

  bool _isValidDocumentFormat(String fileName) {
    final name = fileName.toLowerCase();
    return name.endsWith('.pdf') ||
        name.endsWith('.jpg') ||
        name.endsWith('.jpeg') ||
        name.endsWith('.png');
  }

  Future<void> _pickDocument(String category) async {
    try {
      // First pick the from file system
      final ImagePicker picker = ImagePicker();

      // Show dialog to choose between photo library or file picker
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Sélectionner un document'),
          content: const Text('Choisissez d\'où importer votre document'),
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                // Pick from gallery
                final pickedFile = await picker.pickImage(
                  source: ImageSource.gallery,
                );
                if (pickedFile != null) {
                  await _uploadDocument(category, File(pickedFile.path));
                }
              },
              child: const Text('Galerie photo'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                // In a real app, use file_picker for PDF support
                // For now, show a message
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Sélectionnez une image (PDF sera disponible bientôt)',
                    ),
                  ),
                );
              },
              child: const Text('Fichier (PDF)'),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erreur: $e')));
    }
  }

  Future<void> _uploadDocument(String category, File file) async {
    if (!_isValidDocumentFormat(file.path)) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Format accepté: PDF, JPG, PNG'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final fileSize = await file.length();
    if (fileSize > 10 * 1024 * 1024) {
      // 10 MB max
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Taille maximale: 10 Mo'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _documentUploading[category] = true;
    });

    try {
      // Upload to Supabase Storage
      final fileName = '${category}_${DateTime.now().millisecondsSinceEpoch}';
      final url = await _publishService.uploadDocument(file, fileName);

      if (!mounted) return;

      // Update publish state
      final isRequired = [
        'titre_foncier',
        'plan_terrain',
        'autorisation_vente',
      ].contains(category);

      if (isRequired) {
        final updatedRequired = Map<String, String>.from(
          publishState.requiredDocuments,
        );
        updatedRequired[category] = url;
        publishState = publishState.copyWith(
          requiredDocuments: updatedRequired,
        );
      } else {
        final updatedOptional = Map<String, String>.from(
          publishState.optionalDocuments,
        );
        updatedOptional[category] = url;
        publishState = publishState.copyWith(
          optionalDocuments: updatedOptional,
        );
      }

      setState(() {
        _documentUploading[category] = false;
        _documentFiles[category] = file;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ ${_getDocumentLabel(category)} uploadé'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      setState(() {
        _documentUploading[category] = false;
      });

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erreur: $e')));
    }
  }

  Future<void> _removeDocument(String category) async {
    // Confirm deletion
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer le document?'),
        content: Text(
          'Êtes-vous sûr de vouloir supprimer ${_getDocumentLabel(category)}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Supprimer', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() {
      final isRequired = [
        'titre_foncier',
        'plan_terrain',
        'autorisation_vente',
      ].contains(category);

      if (isRequired) {
        final updatedRequired = Map<String, String>.from(
          publishState.requiredDocuments,
        );
        updatedRequired.remove(category);
        publishState = publishState.copyWith(
          requiredDocuments: updatedRequired,
        );
      } else {
        final updatedOptional = Map<String, String>.from(
          publishState.optionalDocuments,
        );
        updatedOptional.remove(category);
        publishState = publishState.copyWith(
          optionalDocuments: updatedOptional,
        );
      }

      _documentFiles[category] = null;
    });
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
    if (_selectedFeaturedOption == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Choisissez une option de publication avant de continuer',
          ),
        ),
      );
      return;
    }

    if (!publishState.hasMinPhotos()) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Minimum 1 photo requise')));
      return;
    }

    // Final validation: required documents
    if (!publishState.hasAllRequiredDocuments()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tous les documents obligatoires sont requis'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => isPublishing = true);

    try {
      final finalState = publishState.copyWith(
        description: descriptionController.text,
        isPublished: false,
        isFeatured: featured,
      );

      await _publishService.publishTerrain(finalState, featured: featured);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Votre terrain a été soumis. Notre équipe le valide sous 24h. '
            'Vous serez notifié dès qu\'il est en ligne.',
          ),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 5),
        ),
      );

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
        // Validate step 2: essential info + required documents
        if (!publishState.isEssentialInfoComplete()) {
          return null;
        }
        if (!publishState.hasAllRequiredDocuments()) {
          return null;
        }
        return () => _goToStep(3);
      case 3:
        return () => _goToStep(4);
      case 4:
        if (_selectedFeaturedOption == null) return null;
        return () => _publishTerrain(featured: _selectedFeaturedOption!);
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
          'Ajoutez 1 à 8 photos',
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
                '${publishState.photoUrls.length}/1-8 photos',
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

        // ──────────────────────────────────────────────────────────────
        // DOCUMENTS OBLIGATOIRES SECTION
        // ──────────────────────────────────────────────────────────────
        Text(
          'Documents obligatoires',
          style: GoogleFonts.outfit(
            color: kTextPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Téléchargez les 3 documents obligatoires pour continuer.',
          style: GoogleFonts.inter(color: kTextMuted, fontSize: 12),
        ),
        const SizedBox(height: 16),

        // Progress indicator
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: publishState.hasAllRequiredDocuments()
                ? kSuccess.withOpacity(0.1)
                : Colors.orange.withOpacity(0.1),
            border: Border.all(
              color: publishState.hasAllRequiredDocuments()
                  ? kSuccess
                  : Colors.orange,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(
                publishState.hasAllRequiredDocuments()
                    ? Icons.check_circle
                    : Icons.info,
                color: publishState.hasAllRequiredDocuments()
                    ? kSuccess
                    : Colors.orange,
              ),
              const SizedBox(width: 12),
              Text(
                '${publishState.uploadedRequiredDocumentsCount}/3 documents obligatoires',
                style: GoogleFonts.inter(
                  color: publishState.hasAllRequiredDocuments()
                      ? kSuccess
                      : Colors.orange,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Required documents
        ...[
          ('titre_foncier', 'Titre foncier'),
          ('plan_terrain', 'Plan du terrain'),
          ('autorisation_vente', 'Autorisation de vente'),
        ].map((entry) {
          final category = entry.$1;
          final label = entry.$2;
          final isUploaded = publishState.requiredDocuments.containsKey(
            category,
          );
          final isUploading = _documentUploading[category] ?? false;

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: kDarkCard,
                border: Border.all(color: isUploaded ? kSuccess : kBorderDark),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with label and status
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          label,
                          style: GoogleFonts.inter(
                            color: kTextPrimary,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      if (isUploaded)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: kSuccess.withOpacity(0.2),
                            border: Border.all(color: kSuccess),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.check, color: kSuccess, size: 14),
                              const SizedBox(width: 4),
                              Text(
                                'Uploadé',
                                style: GoogleFonts.inter(
                                  color: kSuccess,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // File display or upload button
                  if (isUploaded)
                    Row(
                      children: [
                        Icon(
                          _getDocumentIcon(
                            publishState.requiredDocuments[category] ?? '',
                          ),
                          color: kPrimary,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _documentFiles[category]?.path.split('/').last ??
                                'Document uploadé',
                            style: GoogleFonts.inter(
                              color: kTextMuted,
                              fontSize: 12,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: isUploading
                              ? null
                              : () => _removeDocument(category),
                          child: Icon(Icons.close, color: Colors.red, size: 18),
                        ),
                      ],
                    )
                  else if (isUploading)
                    Row(
                      children: [
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation(kPrimary),
                            strokeWidth: 2,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Upload en cours...',
                          style: GoogleFonts.inter(
                            color: kTextMuted,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    )
                  else
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => _pickDocument(category),
                        icon: const Icon(Icons.cloud_upload_outlined),
                        label: const Text('Sélectionner un fichier'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: kPrimary,
                          side: BorderSide(color: kPrimary),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        }),
        const SizedBox(height: 24),

        // OPTIONAL DOCUMENT SECTION
        Text(
          'Documents optionnels',
          style: GoogleFonts.outfit(
            color: kTextPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Fournissez des documents supplémentaires pour renforcer votre annonce.',
          style: GoogleFonts.inter(color: kTextMuted, fontSize: 12),
        ),
        const SizedBox(height: 16),

        // Optional document
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
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
                // Header with label and "Optional" badge
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Reçu d\'achat',
                      style: GoogleFonts.inter(
                        color: kTextPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: kTextMuted.withOpacity(0.2),
                        border: Border.all(color: kTextMuted),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'Optionnel',
                        style: GoogleFonts.inter(
                          color: kTextMuted,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // File display or upload button
                if (publishState.optionalDocuments.containsKey('recu_achat'))
                  Row(
                    children: [
                      Icon(
                        _getDocumentIcon(
                          publishState.optionalDocuments['recu_achat'] ?? '',
                        ),
                        color: kPrimary,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _documentFiles['recu_achat']?.path.split('/').last ??
                              'Document uploadé',
                          style: GoogleFonts.inter(
                            color: kTextMuted,
                            fontSize: 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: _documentUploading['recu_achat'] == true
                            ? null
                            : () => _removeDocument('recu_achat'),
                        child: Icon(Icons.close, color: Colors.red, size: 18),
                      ),
                    ],
                  )
                else if (_documentUploading['recu_achat'] == true)
                  Row(
                    children: [
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation(kPrimary),
                          strokeWidth: 2,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Upload en cours...',
                        style: GoogleFonts.inter(
                          color: kTextMuted,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  )
                else
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => _pickDocument('recu_achat'),
                      icon: const Icon(Icons.cloud_upload_outlined),
                      label: const Text('Sélectionner un fichier'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: kPrimary,
                        side: BorderSide(color: kPrimary),
                      ),
                    ),
                  ),
              ],
            ),
          ),
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
    final isFreeSelected = _selectedFeaturedOption == false;
    final isFeaturedSelected = _selectedFeaturedOption == true;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recapitulatif',
          style: GoogleFonts.outfit(
            color: kTextPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 24),

        Container(
          decoration: BoxDecoration(
            color: kDarkCard,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: kBorderDark),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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

        Text(
          'Option de publication',
          style: GoogleFonts.inter(
            color: kTextPrimary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 12),

        GestureDetector(
          onTap: isPublishing
              ? null
              : () {
                  setState(() => _selectedFeaturedOption = false);
                },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isFreeSelected ? kPrimary.withOpacity(0.1) : kDarkCard,
              border: Border.all(
                color: isFreeSelected ? kPrimary : kBorderDark,
              ),
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
                    Icon(
                      isFreeSelected
                          ? Icons.radio_button_checked
                          : Icons.radio_button_unchecked,
                      color: isFreeSelected ? kPrimary : kTextMuted,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Votre terrain sera soumis a verification avant affichage.',
                  style: GoogleFonts.inter(color: kTextMuted, fontSize: 12),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),

        GestureDetector(
          onTap: isPublishing
              ? null
              : () {
                  setState(() => _selectedFeaturedOption = true);
                },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isFeaturedSelected
                  ? Colors.amber.withOpacity(0.1)
                  : kDarkCard,
              border: Border.all(
                color: isFeaturedSelected ? Colors.amber : kBorderDark,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 18),
                        const SizedBox(width: 6),
                        Text(
                          'Mettre en avant - 15 000 F/mois',
                          style: GoogleFonts.outfit(
                            color: kTextPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    Icon(
                      isFeaturedSelected
                          ? Icons.radio_button_checked
                          : Icons.radio_button_unchecked,
                      color: isFeaturedSelected ? Colors.amber : kTextMuted,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Apparait en haut de la marketplace apres validation.',
                  style: GoogleFonts.inter(color: kTextMuted, fontSize: 12),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),

        Text(
          'Apres soumission, verification sous 24h. Puis publication sur la marketplace.',
          style: GoogleFonts.inter(color: kTextMuted, fontSize: 12),
        ),
      ],
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
