import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:showcaseview/showcaseview.dart';
import '../component/terrain.dart';
import 'favoris_manager.dart';
import '../data/terrain_data.dart';
import 'corbeille/favoris.dart';
import 'service_user.dart';
import 'terrain_info.dart';
import 'corbeille/notification.dart';
import '../page/profile.dart';
import '../page/carte.dart';
import '../page/achat.dart';
import 'corbeille/historique.dart';
import 'corbeille/vendre.dart';
import '../theme/colors.dart';

class TourAccueilPage extends StatefulWidget {
  const TourAccueilPage({super.key});

  @override
  State<TourAccueilPage> createState() => _TourAccueilPageState();
}

class _TourAccueilPageState extends State<TourAccueilPage> {
  int _currentIndex = 0;

  final GlobalKey _avatarKey = GlobalKey();
  final GlobalKey _notificationKey = GlobalKey();
  final GlobalKey _supportKey = GlobalKey();
  final GlobalKey _explorerKey = GlobalKey();
  final GlobalKey _recommendationsKey = GlobalKey();
  final GlobalKey _nearbyKey = GlobalKey();

  final GlobalKey _navHomeKey = GlobalKey();
  final GlobalKey _navMapKey = GlobalKey();
  final GlobalKey _navBuyKey = GlobalKey();
  final GlobalKey _navProfileKey = GlobalKey();
  final GlobalKey _fabKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final List<Widget> _pages = [
      SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              const SizedBox(height: 20),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Votre espace",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Showcase(
                      key: _explorerKey,
                      targetShapeBorder: const CircleBorder(),
                      description:
                          "Accédez à votre tableau de bord personnel avec toutes vos activités",
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const CategoriesPage(),
                            ),
                          );
                        },
                        child: const Text(
                          "Explorer",
                          style: TextStyle(
                            color: kGreen,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              SizedBox(
                height: 100,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    _CategoryItem(
                      icon: Icons.sell,
                      title: "À Vendre",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const VendrePage()),
                        );
                      },
                    ),
                    _CategoryItem(
                      icon: Icons.shopping_bag,
                      title: "Achetés",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const AchatPage()),
                        );
                      },
                    ),
                    _CategoryItem(
                      icon: Icons.favorite,
                      title: "Favoris",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const FavorisPage(),
                          ),
                        );
                      },
                    ),
                    _CategoryItem(
                      icon: Icons.help,
                      title: "Service",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const DemandeServicePremiumPage(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Showcase(
                      key: _recommendationsKey,
                      targetShapeBorder: const CircleBorder(),
                      description:
                          "Découvrez des terrains spécialement sélectionnés selon vos préférences",
                      child: const Text(
                        "Recommander pour vous",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AchatPage(),
                          ),
                        );
                      },
                      child: const Text(
                        "Voir tout",
                        style: TextStyle(
                          color: kGreen,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              SizedBox(
                height: 240,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: terrainsFoncira.length > 4
                      ? 4
                      : terrainsFoncira.length,
                  itemBuilder: (context, index) {
                    final terrain = terrainsFoncira[index];
                    return _PropertyCard(
                      terrain: terrain,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => TerrainDetailPage(terrain: terrain),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),

              const SizedBox(height: 20),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Showcase(
                      key: _nearbyKey,
                      targetShapeBorder: const CircleBorder(),
                      description:
                          "Parcourez les terrains disponibles près de votre localisation",
                      child: const Text(
                        "Propriétés proches",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AchatPage(),
                          ),
                        );
                      },
                      child: const Text(
                        "Voir tout",
                        style: TextStyle(
                          color: kGreen,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: List.generate(
                    terrainsFoncira.length > 4 ? 4 : terrainsFoncira.length,
                    (index) {
                      final terrain = terrainsFoncira[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _PropertyCard(
                          terrain: terrain,
                          isHorizontal: true,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    TerrainDetailPage(terrain: terrain),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      const CartePage(),
      const VendrePage(),
      const AchatPage(),
      const Profil(),
    ];

    return ShowCaseWidget(
      builder: (context) {
        return _ShowcaseStarter(
          showcaseKeys: [
            _avatarKey,
            _notificationKey,
            _supportKey,
            _explorerKey,
            _recommendationsKey,
            _nearbyKey,
            _fabKey,
            _navHomeKey,
            _navMapKey,
            _navBuyKey,
            _navProfileKey,
          ],
          child: Scaffold(
            resizeToAvoidBottomInset: true,
            extendBody: true,
            backgroundColor: Colors.grey[100],
            body: IndexedStack(index: _currentIndex, children: _pages),
            floatingActionButton: Showcase(
              key: _fabKey,
              description:
                  "Utilisez ce bouton pour mettre rapidement un nouveau terrain en vente.",
              targetShapeBorder: const CircleBorder(),
              child: FloatingActionButton(
                backgroundColor: kGreen,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const VendrePage()),
                  );
                },
                child: const Icon(Icons.add, size: 28, color: Colors.white),
              ),
            ),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerDocked,

            bottomNavigationBar: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Showcase(
                    key: _navHomeKey,
                    targetShapeBorder: const CircleBorder(),
                    description:
                        "Accédez à la page d'accueil et à votre tableau de bord.",
                    child: _buildNavItem(
                      icon: Icons.home_outlined,
                      activeIcon: Icons.home,
                      label: "Bord",
                      index: 0,
                    ),
                  ),
                  Showcase(
                    key: _navMapKey,
                    targetShapeBorder: const CircleBorder(),
                    description:
                        "Explorez les terrains disponibles sur la carte.",
                    child: _buildNavItem(
                      icon: Icons.map_outlined,
                      activeIcon: Icons.map,
                      label: "Carte",
                      index: 1,
                    ),
                  ),
                  const SizedBox(width: 40),
                  Showcase(
                    key: _navBuyKey,
                    targetShapeBorder: const CircleBorder(),
                    description: "Consultez la liste des terrains à acheter.",
                    child: _buildNavItem(
                      icon: Icons.landscape_outlined,
                      activeIcon: Icons.landscape,
                      label: "Acheter",
                      index: 3,
                    ),
                  ),
                  Showcase(
                    key: _navProfileKey,
                    targetShapeBorder: const CircleBorder(),
                    description:
                        "Gérez votre profil, vos paramètres et documents.",
                    child: _buildNavItem(
                      icon: Icons.person_outline,
                      activeIcon: Icons.person,
                      label: "Profil",
                      index: 4,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0D1F17), Color(0xFF1B4332)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Showcase(
            targetShapeBorder: const CircleBorder(),
            key: _avatarKey,
            description:
                "Votre profil - Accédez à vos informations personnelles et paramètres",
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Profil()),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(2.5),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFD4AF37), width: 2),
                ),
                child: const CircleAvatar(
                  radius: 28,
                  backgroundImage: AssetImage("assets/Image/muso.jpg"),
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  "Joel A.",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  "Membre Premium",
                  style: TextStyle(
                    color: Color(0xFFD4AF37),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              Showcase(
                key: _notificationKey,
                targetShapeBorder: const CircleBorder(),
                description:
                    "Notifications - Restez informé des demandes et activités importantes",
                child: IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const Notifications(),
                      ),
                    );
                  },
                  icon: const Icon(
                    Icons.notifications_outlined,
                    color: Colors.white,
                    size: 26,
                  ),
                ),
              ),
              Showcase(
                key: _supportKey,
                targetShapeBorder: const CircleBorder(),
                description:
                    "Support - Assistance 24h/24 et 7j/7 pour toutes vos questions",
                child: IconButton(
                  onPressed: () {},
                  icon: const Icon(
                    Icons.support_agent,
                    color: Colors.white,
                    size: 26,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required int index,
  }) {
    final bool isSelected = _currentIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _currentIndex = index),

        child: SizedBox(
          width: 60,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isSelected ? activeIcon : icon,
                color: isSelected ? kGreen : Colors.grey,
                size: 24,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? kGreen : Colors.grey,
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ShowcaseStarter extends StatefulWidget {
  final Widget child;
  final List<GlobalKey> showcaseKeys;

  const _ShowcaseStarter({required this.child, required this.showcaseKeys});

  @override
  State<_ShowcaseStarter> createState() => _ShowcaseStarterState();
}

class _ShowcaseStarterState extends State<_ShowcaseStarter> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 800), () {
        ShowCaseWidget.of(context).startShowCase(widget.showcaseKeys);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

class _CategoryItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback? onTap;
  const _CategoryItem({required this.icon, required this.title, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 90,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: Colors.green.shade50,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: kGreen, size: 28),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}

class _PropertyCard extends StatelessWidget {
  final Terrain terrain;
  final bool isHorizontal;
  final VoidCallback? onTap;
  const _PropertyCard({
    required this.terrain,
    this.isHorizontal = false,
    this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    final isFavori = FavorisManager.isFavori(terrain);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: isHorizontal ? double.infinity : 190,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(18),
                  ),
                  child: Image.asset(
                    terrain.imageUrl,
                    height: isHorizontal ? 150 : 130,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),

                Positioned(
                  top: 10,
                  left: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      terrain.title.split(" ")[0],
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: () {
                      FavorisManager.toggleFavori(terrain);
                      (context as Element).markNeedsBuild();
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.85),
                        shape: BoxShape.circle,
                      ),
                      padding: const EdgeInsets.all(6),
                      child: Icon(
                        isFavori ? Icons.favorite : Icons.favorite_border,
                        color: Colors.redAccent,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    terrain.title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    terrain.location,
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  const SizedBox(height: 8),

                  Text(
                    '${terrain.price.toStringAsFixed(0)} FCFA',
                    style: const TextStyle(
                      color: kGreen,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 6),

                  if (isHorizontal)
                    Align(
                      alignment: Alignment.centerRight,
                      child: OutlinedButton.icon(
                        onPressed: onTap,
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: kGreen),
                          minimumSize: const Size(0, 32),
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        icon: const Icon(
                          Icons.arrow_forward,
                          size: 16,
                          color: kGreen,
                        ),
                        label: const Text(
                          "Voir +",
                          style: TextStyle(
                            color: kGreen,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CategoriesPage extends StatelessWidget {
  const CategoriesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Votre espace")),
      body: GridView.count(
        padding: const EdgeInsets.all(16),
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        children: [
          _CategoryItem(icon: Icons.sell, title: "Mes terrains à vendre"),
          _CategoryItem(
            icon: Icons.shopping_bag,
            title: "Mes terrains achetés",
          ),
          _CategoryItem(
            icon: Icons.favorite,
            title: "Favoris",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const FavorisPage()),
              );
            },
          ),
          _CategoryItem(
            icon: Icons.help,
            title: "Demande de service",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const DemandeServicePremiumPage(),
                ),
              );
            },
          ),
          _CategoryItem(icon: Icons.security, title: "Litiges"),
          _CategoryItem(icon: Icons.description, title: "Documents"),
        ],
      ),
    );
  }
}
