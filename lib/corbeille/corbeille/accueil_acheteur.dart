// ignore_for_file: no_leading_underscores_for_local_identifiers, deprecated_member_use

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../component/terrain.dart';
import '../../component/notification_bell_button.dart';
import '../../component/social_proof_banner.dart';
import '../../component/partners_authority.dart';
import '../../component/guarantee_section.dart';
import '../favoris_manager.dart';
import '../../data/terrain_data.dart';
import 'favoris.dart';
import 'profilpage.dart';
import '../service_user.dart';
import '../support_logique.dart';
import '../terrain_info.dart';
import 'notification.dart';
import '../../page/profile.dart';
import '../../page/carte.dart';
import '../../page/achat.dart';
import 'historique.dart';
import '../../theme/colors.dart';

File? image;
String userName = "";

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  Future<void> _loadImage() async {
    final prefs = await SharedPreferences.getInstance();
    final path = prefs.getString("profileImagePath");
    final savedName = prefs.getString("name");

    setState(() {
      if (path != null) image = File(path);
      if (savedName != null) userName = savedName;
    });
  }

  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final List<Widget> _pages = [
      SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ---- HEADER ----
              _buildHeader(context),
              const SizedBox(height: 20),

              // ---- SOCIAL PROOF BANNER ----
              const SocialProofBanner(),
              const SizedBox(height: 24),

              // ---- ESPACE de l'acheteur ----
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
                    GestureDetector(
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

              // ---- Recommandation----
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Recommander pour vous",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
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
                height: 250,
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

              // ---- PROPRIÉTÉS PROCHES ----
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Propriétés proches",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
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
                    terrainsFoncira.length > 4
                        ? 4
                        : terrainsFoncira.length, // 👉 max 2
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

              const SizedBox(height: 24),

              // ---- PARTNERS AND AUTHORITY ----
              const PartnersAndAuthority(),

              const SizedBox(height: 24),

              // ---- GUARANTEE SECTION ----
              const GuaranteeSection(),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
      const CartePage(),
      const AchatPage(),
      const Profil(),
    ];

    return Scaffold(
      resizeToAvoidBottomInset: true,
      extendBody: true,
      backgroundColor: Colors.grey[100],
      body: IndexedStack(index: _currentIndex, children: _pages),

      // ---- Barre de navigation horizontal ----
      bottomNavigationBar: Container(
        margin: const EdgeInsets.all(16),
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
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.white,
            selectedItemColor: kGreen,
            unselectedItemColor: Colors.grey,
            showUnselectedLabels: true,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home),
                label: "Bord",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.map_outlined),
                activeIcon: Icon(Icons.map),
                label: "Carte",
              ),

              BottomNavigationBarItem(
                icon: Icon(Icons.landscape_outlined),
                activeIcon: Icon(Icons.landscape),
                label: "Acheter",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_outline),
                activeIcon: Icon(Icons.person),
                label: "Profil",
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---- CATEGORY ITEM ----
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

// ---- PROPERTY CARD ----
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
            // ---- Image + badges ----
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
                      '${terrain.surface} m²',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                // Icône favoris
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

            // ---- Texte + CTA ----
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

                  // bouton affiché SEULEMENT si la carte est horizontale
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

// ---- HEADER ----
Widget _buildHeader(BuildContext context) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        colors: [
          Color(0xFF0D1F17),
          Color(0xFF1B4332),
        ], // vert foncé + noir chic
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.only(
        bottomLeft: Radius.circular(32),
        bottomRight: Radius.circular(32),
      ),
      boxShadow: [
        BoxShadow(color: Colors.black26, blurRadius: 12, offset: Offset(0, 4)),
      ],
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // ---- Avatar VIP ----
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ProfilPage()),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(2.5),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFD4AF37), width: 2),
            ),
            child: CircleAvatar(
              radius: 28,
              backgroundImage: image != null ? FileImage(image!) : null,
              child: image == null ? const Icon(Icons.person, size: 28) : null,
            ),
          ),
        ),

        const SizedBox(width: 14),

        // ---- Infos utilisateur ----
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                userName.isNotEmpty ? (userName.split(" ").first) : "Invité",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
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
            // New Notification Bell with Provider integration
            const NotificationBellButton(),
            // Support
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SupportPage()),
                );
              },
              icon: const Icon(
                Icons.support_agent,
                color: Colors.white,
                size: 26,
              ),
            ),
          ],
        ),
      ],
    ),
  );
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

// Classe personnalisée pour décaler verticalement le FloatingActionButton
class CustomFabLocation extends FloatingActionButtonLocation {
  final FloatingActionButtonLocation location;
  final double verticalOffset;

  CustomFabLocation(this.location, this.verticalOffset);

  @override
  Offset getOffset(ScaffoldPrelayoutGeometry scaffoldGeometry) {
    // On récupère la position de base (ex: centerDocked)
    final Offset fabOffset = location.getOffset(scaffoldGeometry);
    // On retourne une nouvelle position avec notre décalage vertical
    return Offset(fabOffset.dx, fabOffset.dy + verticalOffset);
  }
}

class ConfirmVendre {
  static void show(BuildContext context) {
    const Color primaryTextColor = Color(0xFF2D3748);
    const Color secondaryTextColor = Color(0xFF718096);
    const Color accentColor = Color(0xFF4299E1);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      elevation: 0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                "Confirmer la mise en vente",
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: primaryTextColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                "Êtes-vous sûr de vouloir mettre ce terrain en vente sur le marché ?",
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  color: secondaryTextColor,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),

              // --- Hiérarchie des boutons ---
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        "Annuler",
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          color: secondaryTextColor,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Bouton principal (Vendre) - plus de poids visuel
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => AchatPage()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF0D1F17),
                        foregroundColor: Color(0xFFD4AF37),
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        "Oui, vendre",
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
