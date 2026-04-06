// ----- Fichier : lib/page/achat.dart (corrigé et optimisé) -----

import 'package:flutter/material.dart';
import '../data/terrain_data.dart'; // Importe les données fictives
import '../component/terrain.dart'; // Modèle Terrain
import '../corbeille/terrain_info.dart'; // Page de détails du terrain

const kLightBackgroundColor = Color(0xFFF7F8FC);
const kPrimaryColor = Color(0xFF16A34A);
const kCardColor = Colors.white;
const kFontColor = Color(0xFF2D3748);
const kHintColor = Color(0xFF718096);

class AchatPage extends StatefulWidget {
  const AchatPage({super.key});

  @override
  State<AchatPage> createState() => _AchatPageState();
}

class _AchatPageState extends State<AchatPage> {
  final TextEditingController _searchController = TextEditingController();

  // --- Données ---
  final List<Terrain> _allTerrains = terrainsFoncira;
  late List<Terrain> _filteredTerrains;

  // --- États des filtres ---
  RangeValues _currentPriceRange = const RangeValues(5000000, 50000000);
  RangeValues _currentSurfaceRange = const RangeValues(300, 10000);
  bool _isConstructibleOnly = false;
  String _activeFilter = 'Tout';

  @override
  void initState() {
    super.initState();
    _filteredTerrains = _allTerrains;
    _searchController.addListener(_applyFilters);
  }

  @override
  void dispose() {
    _searchController.removeListener(_applyFilters);
    _searchController.dispose();
    super.dispose();
  }

  void _applyFilters() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredTerrains = _allTerrains.where((terrain) {
        final matchesQuery =
            terrain.title.toLowerCase().contains(query) ||
            terrain.location.toLowerCase().contains(query);

        final matchesPrice =
            terrain.price >= _currentPriceRange.start &&
            terrain.price <= _currentPriceRange.end;

        final matchesSurface =
            terrain.surface >= _currentSurfaceRange.start &&
            terrain.surface <= _currentSurfaceRange.end;

        final matchesConstructible =
            !_isConstructibleOnly || terrain.isConstructible;

        final matchesStatus =
            _activeFilter == 'Tout' ||
            terrain.verificationFoncira.label == _activeFilter;

        return matchesQuery &&
            matchesPrice &&
            matchesSurface &&
            matchesConstructible &&
            matchesStatus;
      }).toList();
    });
  }

  void _setActiveFilter(String filter) {
    setState(() => _activeFilter = filter);
    _applyFilters();
  }

  // --- Panel des filtres avancés ---
  void _showFilterPanel() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.75,
          maxChildSize: 0.95,
          minChildSize: 0.5,
          builder: (_, controller) {
            return StatefulBuilder(
              builder: (context, setModalState) {
                return Container(
                  decoration: BoxDecoration(
                    color: kLightBackgroundColor,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(30),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 20,
                        offset: const Offset(0, -4),
                      ),
                    ],
                  ),
                  child: ListView(
                    controller: controller,
                    padding: const EdgeInsets.all(20),
                    children: [
                      Row(
                        children: [
                          Container(
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: kPrimaryColor,
                            ),
                            padding: const EdgeInsets.all(8),
                            child: const Icon(
                              Icons.tune_rounded,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            "Filtres intelligents",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: kFontColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      _buildFilterCard(
                        icon: Icons.attach_money,
                        title: "Budget (FCFA)",
                        child: RangeSlider(
                          values: _currentPriceRange,
                          min: 5000000,
                          max: 50000000,
                          divisions: 9,
                          activeColor: kPrimaryColor,
                          labels: RangeLabels(
                            '${(_currentPriceRange.start / 1000000).toStringAsFixed(1)}M',
                            '${(_currentPriceRange.end / 1000000).toStringAsFixed(1)}M',
                          ),
                          onChanged: (values) {
                            setModalState(() => _currentPriceRange = values);
                          },
                        ),
                      ),

                      const SizedBox(height: 30),

                      // --- BOUTON ---
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                            backgroundColor: kPrimaryColor,
                            elevation: 6,
                          ),
                          onPressed: () {
                            _applyFilters();
                            Navigator.pop(context);
                          },
                          child: const Text(
                            "Appliquer les filtres",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildFilterCard({
    required IconData icon,
    required String title,
    required Widget child,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: kPrimaryColor, size: 22),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: kFontColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }

  // --- UI ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kLightBackgroundColor,
      appBar: AppBar(
        title: const Text(
          "Acheter un terrain",
          style: TextStyle(color: kFontColor),
        ),
        backgroundColor: kLightBackgroundColor,
        elevation: 0,
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildSearchHeader(),
            Expanded(child: _buildListView()),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: _buildSearchBar()),
              const SizedBox(width: 12),
              _buildFilterButton(),
            ],
          ),
          const SizedBox(height: 12),
          _buildFilterChips(),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: kCardColor,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: "Rechercher par lieu, titre...",
          hintStyle: const TextStyle(color: kHintColor),
          prefixIcon: const Icon(Icons.search, color: kHintColor),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildFilterButton() {
    return GestureDetector(
      onTap: _showFilterPanel,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: kCardColor,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Icon(Icons.filter_list, color: kPrimaryColor),
      ),
    );
  }

  Widget _buildFilterChips() {
    final filters = ['Tout', 'Vérifié', 'En attente', 'Litige'];
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = _activeFilter == filter;
          return ChoiceChip(
            label: Text(filter),
            selected: isSelected,
            onSelected: (_) => _setActiveFilter(filter),
            backgroundColor: kCardColor,
            selectedColor: kPrimaryColor,
            labelStyle: TextStyle(
              color: isSelected ? Colors.white : kFontColor,
              fontWeight: FontWeight.bold,
            ),
            side: BorderSide.none,
          );
        },
        separatorBuilder: (context, index) => const SizedBox(width: 8),
      ),
    );
  }

  Widget _buildListView() {
    if (_filteredTerrains.isEmpty) {
      return const Center(
        child: Text(
          "Aucun terrain ne correspond à vos critères.",
          style: TextStyle(color: kHintColor),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _filteredTerrains.length,
      itemBuilder: (context, index) {
        return _TerrainCard(terrain: _filteredTerrains[index]);
      },
    );
  }
}

// --- Carte d'un terrain ---
class _TerrainCard extends StatelessWidget {
  final Terrain terrain;
  const _TerrainCard({required this.terrain});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => TerrainDetailPage(terrain: terrain),
          ),
        );
      },
      child: Card(
        elevation: 0,
        color: kCardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.only(bottom: 16),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  terrain.imageUrl,
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 100,
                    height: 100,
                    color: Colors.grey.shade200,
                    child: const Icon(Icons.landscape, color: Colors.grey),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      terrain.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: kFontColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          size: 14,
                          color: kHintColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          terrain.location,
                          style: const TextStyle(color: kHintColor),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${terrain.price.toStringAsFixed(0)} FCFA',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: kPrimaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
