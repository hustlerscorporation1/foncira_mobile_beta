// carte.dart
import 'package:foncira/data/togo_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

const _kOsmUserAgentPackageName = 'com.foncira';

enum LandStatus {
  litige("En Litige", Colors.red),
  sansLitige("Sans litige", Colors.green),
  coutumier("Coutumier", Colors.orange);

  const LandStatus(this.label, this.color);
  final String label;
  final Color color;
}

class Terre {
  final String id;
  final String nom;
  final LandStatus status;
  final LatLng coord;
  final String region;
  final String prefecture;
  final String commune;
  final String canton;
  final double superficie; // en m²

  Terre({
    required this.id,
    required this.nom,
    required this.status,
    required this.coord,
    required this.region,
    required this.prefecture,
    required this.commune,
    required this.canton,
    required this.superficie,
  });
}

// --- Exemple: 30 terrains ---
final List<Terre> terrains = [
  Terre(
    id: "T001",
    nom: "Terrain Bord de mer",
    status: LandStatus.litige,
    coord: const LatLng(6.1375, 1.2123),
    region: "Maritime",
    prefecture: "Golfe",
    commune: "Golfe 1",
    canton: "Bè-Ablogamé",
    superficie: 600,
  ),
  Terre(
    id: "T002",
    nom: "Terrain Résidentiel Lomé",
    status: LandStatus.sansLitige,
    coord: const LatLng(6.18, 1.25),
    region: "Maritime",
    prefecture: "Golfe",
    commune: "Golfe 2",
    canton: "Tokoin Wuiti",
    superficie: 450,
  ),
  Terre(
    id: "T003",
    nom: "Champ Familial Kara",
    status: LandStatus.coutumier,
    coord: const LatLng(9.55, 1.2),
    region: "Kara",
    prefecture: "Kozah",
    commune: "Kozah 1",
    canton: "Lama",
    superficie: 1200,
  ),
  Terre(
    id: "T004",
    nom: "Terrain Agricole Tsévié",
    status: LandStatus.sansLitige,
    coord: const LatLng(6.42, 1.21),
    region: "Maritime",
    prefecture: "Zio",
    commune: "Zio 1",
    canton: "Tsévié",
    superficie: 800,
  ),
  Terre(
    id: "T005",
    nom: "Parcelle à Vogan",
    status: LandStatus.litige,
    coord: const LatLng(6.33, 1.35),
    region: "Maritime",
    prefecture: "Vo",
    commune: "Vo 1",
    canton: "Vogan",
    superficie: 500,
  ),
  Terre(
    id: "T006",
    nom: "Ferme Avé",
    status: LandStatus.sansLitige,
    coord: const LatLng(6.52, 1.09),
    region: "Maritime",
    prefecture: "Avé",
    commune: "Avé 1",
    canton: "Kévé",
    superficie: 1500,
  ),
  Terre(
    id: "T007",
    nom: "Terrain familiale Kpalimé",
    status: LandStatus.coutumier,
    coord: const LatLng(6.9, 0.63),
    region: "Plateaux",
    prefecture: "Kloto",
    commune: "Kloto 1",
    canton: "Agomé Kpalimé",
    superficie: 400,
  ),
  Terre(
    id: "T008",
    nom: "Terrain de culture Notsé",
    status: LandStatus.litige,
    coord: const LatLng(6.95, 1.17),
    region: "Plateaux",
    prefecture: "Haho",
    commune: "Haho 1",
    canton: "Notsé",
    superficie: 950,
  ),
  Terre(
    id: "T009",
    nom: "Terrain à Atakpamé",
    status: LandStatus.sansLitige,
    coord: const LatLng(7.53, 1.13),
    region: "Plateaux",
    prefecture: "Ogou",
    commune: "Ogou 1",
    canton: "Djama",
    superficie: 700,
  ),
  Terre(
    id: "T010",
    nom: "Champ à Badou",
    status: LandStatus.coutumier,
    coord: const LatLng(7.68, 0.62),
    region: "Plateaux",
    prefecture: "Wawa",
    commune: "Wawa 1",
    canton: "Badou",
    superficie: 1100,
  ),
  Terre(
    id: "T011",
    nom: "Terrain agricole Blitta",
    status: LandStatus.sansLitige,
    coord: const LatLng(8.32, 0.67),
    region: "Centrale",
    prefecture: "Blitta",
    commune: "Blitta 1",
    canton: "Blitta-Gare",
    superficie: 1600,
  ),
  Terre(
    id: "T012",
    nom: "Terrain familiale Sotouboua",
    status: LandStatus.litige,
    coord: const LatLng(8.56, 0.98),
    region: "Centrale",
    prefecture: "Sotouboua",
    commune: "Sotouboua 1",
    canton: "Sotouboua",
    superficie: 500,
  ),
  Terre(
    id: "T013",
    nom: "Terrain de marché Tchamba",
    status: LandStatus.sansLitige,
    coord: const LatLng(9.03, 1.43),
    region: "Centrale",
    prefecture: "Tchamba",
    commune: "Tchamba 1",
    canton: "Tchamba",
    superficie: 900,
  ),
  Terre(
    id: "T014",
    nom: "Champ familial Sokodé",
    status: LandStatus.coutumier,
    coord: const LatLng(8.98, 1.13),
    region: "Centrale",
    prefecture: "Tchaoudjo",
    commune: "Tchaoudjo 1",
    canton: "Tchalo",
    superficie: 1300,
  ),
  Terre(
    id: "T015",
    nom: "Terrain à Bafilo",
    status: LandStatus.sansLitige,
    coord: const LatLng(9.35, 1.27),
    region: "Kara",
    prefecture: "Assoli",
    commune: "Assoli 1",
    canton: "Bafilo",
    superficie: 650,
  ),
  Terre(
    id: "T016",
    nom: "Champ familial Bassar",
    status: LandStatus.litige,
    coord: const LatLng(9.25, 0.78),
    region: "Kara",
    prefecture: "Bassar",
    commune: "Bassar 1",
    canton: "Bassar",
    superficie: 1200,
  ),
  Terre(
    id: "T017",
    nom: "Terrain agricole Pagouda",
    status: LandStatus.sansLitige,
    coord: const LatLng(9.95, 1.2),
    region: "Kara",
    prefecture: "Binah",
    commune: "Binah 1",
    canton: "Pagouda",
    superficie: 800,
  ),
  Terre(
    id: "T018",
    nom: "Terrain familiale Guerin-Kouka",
    status: LandStatus.coutumier,
    coord: const LatLng(9.83, 0.93),
    region: "Kara",
    prefecture: "Dankpen",
    commune: "Dankpen 1",
    canton: "Guérin-Kouka",
    superficie: 550,
  ),
  Terre(
    id: "T019",
    nom: "Terrain agricole Niamtougou",
    status: LandStatus.sansLitige,
    coord: const LatLng(9.77, 1.1),
    region: "Kara",
    prefecture: "Doufelgou",
    commune: "Doufelgou 1",
    canton: "Niamtougou",
    superficie: 1000,
  ),
  Terre(
    id: "T020",
    nom: "Champ familial Kéran",
    status: LandStatus.litige,
    coord: const LatLng(9.95, 1.05),
    region: "Kara",
    prefecture: "Kéran",
    commune: "Kéran 1",
    canton: "Kandé",
    superficie: 850,
  ),
  Terre(
    id: "T021",
    nom: "Terrain familiale Cinkassé",
    status: LandStatus.sansLitige,
    coord: const LatLng(10.1, 0.9),
    region: "Savanes",
    prefecture: "Cinkassé",
    commune: "Cinkassé 1",
    canton: "Cinkassé",
    superficie: 450,
  ),
  Terre(
    id: "T022",
    nom: "Terrain agricole Mandouri",
    status: LandStatus.coutumier,
    coord: const LatLng(10.85, 0.7),
    region: "Savanes",
    prefecture: "Kpendjal",
    commune: "Kpendjal 1",
    canton: "Mandouri",
    superficie: 1500,
  ),
  Terre(
    id: "T023",
    nom: "Terrain familiale Naki-Est",
    status: LandStatus.sansLitige,
    coord: const LatLng(10.95, 0.65),
    region: "Savanes",
    prefecture: "Kpendjal-Ouest",
    commune: "Kpendjal-Ouest 1",
    canton: "Naki-Est",
    superficie: 500,
  ),
  Terre(
    id: "T024",
    nom: "Terrain de culture Mango",
    status: LandStatus.litige,
    coord: const LatLng(10.36, 0.47),
    region: "Savanes",
    prefecture: "Oti",
    commune: "Oti 1",
    canton: "Mango",
    superficie: 1400,
  ),
  Terre(
    id: "T025",
    nom: "Champ familial Gando",
    status: LandStatus.sansLitige,
    coord: const LatLng(10.4, 0.7),
    region: "Savanes",
    prefecture: "Oti-Sud",
    commune: "Oti-Sud 1",
    canton: "Gando",
    superficie: 600,
  ),
  Terre(
    id: "T026",
    nom: "Terrain familiale Tandjouaré",
    status: LandStatus.coutumier,
    coord: const LatLng(10.85, 0.85),
    region: "Savanes",
    prefecture: "Tandjouaré",
    commune: "Tandjouaré 1",
    canton: "Bombouaka",
    superficie: 500,
  ),
  Terre(
    id: "T027",
    nom: "Terrain agricole Dapaong",
    status: LandStatus.sansLitige,
    coord: const LatLng(10.87, 0.21),
    region: "Savanes",
    prefecture: "Tône",
    commune: "Tône 1",
    canton: "Dapaong",
    superficie: 1300,
  ),
  Terre(
    id: "T028",
    nom: "Champ familial Tami",
    status: LandStatus.litige,
    coord: const LatLng(10.92, 0.32),
    region: "Savanes",
    prefecture: "Tône",
    commune: "Tône 3",
    canton: "Tami",
    superficie: 700,
  ),
  Terre(
    id: "T029",
    nom: "Terrain familiale Anié",
    status: LandStatus.sansLitige,
    coord: const LatLng(7.48, 1.25),
    region: "Plateaux",
    prefecture: "Anié",
    commune: "Anié 1",
    canton: "Anié",
    superficie: 550,
  ),
  Terre(
    id: "T030",
    nom: "Parcelle Coutumière Amou",
    status: LandStatus.coutumier,
    coord: const LatLng(7.6, 0.95),
    region: "Plateaux",
    prefecture: "Amou",
    commune: "Amou 1",
    canton: "Amlamé",
    superficie: 1000,
  ),
];

class CartePage extends StatefulWidget {
  const CartePage({super.key});

  @override
  State<CartePage> createState() => _CartePageState();
}

class _CartePageState extends State<CartePage> {
  final MapController _mapController = MapController();

  String? selectedRegion;
  String? selectedPrefecture;
  String? selectedCommune;
  String? selectedCanton;

  final TextEditingController _searchController = TextEditingController();

  void _showTerrainDetails(Terre terrain) {
    try {
      showModalBottomSheet(
        context: context,
        backgroundColor: Colors.black.withOpacity(0.8),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (_) => Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Titre + statut
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      terrain.nom,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Chip(
                    label: Text(terrain.status.label),
                    backgroundColor: terrain.status.color,
                    labelStyle: const TextStyle(color: Colors.white),
                  ),
                ],
              ),

              const SizedBox(height: 12),
              _buildDetailRow(
                Icons.confirmation_number,
                "Numéro FONCIRA",
                terrain.id,
              ),
              _buildDetailRow(
                Icons.square_foot,
                "Superficie",
                "${terrain.superficie} m²",
              ),

              const Divider(color: Colors.white24, height: 24),

              // Localisation pratique
              _buildDetailRow(
                Icons.place,
                "Localisation",
                "${terrain.commune}, ${terrain.canton}",
              ),

              const SizedBox(height: 8),

              // Bouton pour infos administratives
              ExpansionTile(
                collapsedIconColor: Colors.white70,
                iconColor: Colors.white,
                collapsedTextColor: Colors.white70,
                textColor: Colors.white,
                title: const Text("Voir infos administratives"),
                children: [
                  _buildDetailRow(Icons.map, "Région", terrain.region),
                  _buildDetailRow(
                    Icons.location_city,
                    "Préfecture",
                    terrain.prefecture,
                  ),
                  _buildDetailRow(Icons.apartment, "Commune", terrain.commune),
                  _buildDetailRow(Icons.pin_drop, "Canton", terrain.canton),
                ],
              ),
            ],
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Impossible d'afficher les details du terrain"),
          backgroundColor: Colors.redAccent,
        ),
      );
      debugPrint('Erreur _showTerrainDetails: $e');
    }
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.white54, size: 20),
          const SizedBox(width: 12),
          Text("$label:", style: const TextStyle(color: Colors.white54)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(value, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _handleSearch() {
    final q = _searchController.text.trim().toLowerCase();
    if (q.isEmpty) return;
    try {
      final t = terrains.firstWhere((e) => e.id.toLowerCase() == q);
      _mapController.move(t.coord, 15.0);
      _showTerrainDetails(t);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Terrain introuvable"),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<String> regions = togoData.map<String>((r) => r.nom).toList();

    Region? selectedRegionData;
    for (final region in togoData) {
      if (region.nom == selectedRegion) {
        selectedRegionData = region;
        break;
      }
    }

    Prefecture? selectedPrefectureData;
    if (selectedRegionData != null) {
      for (final prefecture in selectedRegionData.prefectures) {
        if (prefecture.nom == selectedPrefecture) {
          selectedPrefectureData = prefecture;
          break;
        }
      }
    }

    Commune? selectedCommuneData;
    if (selectedPrefectureData != null) {
      for (final commune in selectedPrefectureData.communes) {
        if (commune.nom == selectedCommune) {
          selectedCommuneData = commune;
          break;
        }
      }
    }

    final List<String> prefectures = selectedRegionData == null
        ? <String>[]
        : selectedRegionData.prefectures.map<String>((p) => p.nom).toList();

    final List<String> communes = selectedPrefectureData == null
        ? <String>[]
        : selectedPrefectureData.communes.map<String>((c) => c.nom).toList();

    final List<String> cantons = selectedCommuneData == null
        ? <String>[]
        : selectedCommuneData.cantons.map<String>((ct) => ct.nom).toList();

    final filteredTerrains = terrains.where((t) {
      if (selectedRegion != null && t.region != selectedRegion) return false;
      if (selectedPrefecture != null && t.prefecture != selectedPrefecture)
        return false;
      if (selectedCommune != null && t.commune != selectedCommune) return false;
      if (selectedCanton != null && t.canton != selectedCanton) return false;
      return true;
    }).toList();

    return Theme(
      data: ThemeData.dark(useMaterial3: false),
      child: Scaffold(
        appBar: AppBar(
          title: const Text("🌍 Carte FONCIRA"),
          backgroundColor: Colors.black.withOpacity(0.8),
        ),
        body: Stack(
          children: [
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: const LatLng(8.6195, 0.8248),
                initialZoom: 7,
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                  subdomains: const ['a', 'b', 'c'],
                  userAgentPackageName: _kOsmUserAgentPackageName,
                ),
                MarkerLayer(
                  markers: filteredTerrains.map((t) {
                    return Marker(
                      point: t.coord,
                      width: 36,
                      height: 36,
                      child: GestureDetector(
                        onTap: () => _showTerrainDetails(t),
                        child: Icon(
                          Icons.location_pin,
                          size: 36,
                          color: t.status.color,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),

            // --- UI (recherche + filtres) ---
            SafeArea(
              child: Align(
                alignment: Alignment.topRight,
                child: Container(
                  margin: const EdgeInsets.all(12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.45),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 250),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // --- Barre de recherche + bouton dans 250px ---
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _searchController,
                                onSubmitted: (_) => _handleSearch(),
                                style: const TextStyle(color: Colors.white),
                                decoration: InputDecoration(
                                  hintText: "🔍 ID (ex: T001)",
                                  hintStyle: TextStyle(color: Colors.white70),
                                  filled: true,
                                  fillColor: Colors.black.withOpacity(0.25),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            SizedBox(
                              height: 40,
                              width: 40,
                              child: ElevatedButton(
                                onPressed: _handleSearch,
                                style: ElevatedButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: const Icon(Icons.search, size: 20),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        // --- Dropdown Région (toujours visible) ---
                        _buildDropdown("Région", selectedRegion, regions, (
                          val,
                        ) {
                          setState(() {
                            selectedRegion = val;
                            selectedPrefecture = null;
                            selectedCommune = null;
                            selectedCanton = null;
                          });
                        }),

                        // --- Dropdown Préfecture ---
                        if (selectedRegion != null) ...[
                          const SizedBox(height: 8),
                          _buildDropdown(
                            "Préfecture",
                            selectedPrefecture,
                            prefectures,
                            (val) {
                              setState(() {
                                selectedPrefecture = val;
                                selectedCommune = null;
                                selectedCanton = null;
                              });
                            },
                          ),
                        ],

                        // --- Dropdown Commune ---
                        if (selectedPrefecture != null) ...[
                          const SizedBox(height: 8),
                          _buildDropdown("Commune", selectedCommune, communes, (
                            val,
                          ) {
                            setState(() {
                              selectedCommune = val;
                              selectedCanton = null;
                            });
                          }),
                        ],

                        // --- Dropdown Canton ---
                        if (selectedCommune != null) ...[
                          const SizedBox(height: 8),
                          _buildDropdown("Canton", selectedCanton, cantons, (
                            val,
                          ) {
                            setState(() {
                              selectedCanton = val;
                            });
                          }),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown(
    String hint,
    String? value,
    List<String> items,
    Function(String?) onChanged,
  ) {
    final safeValue = (value != null && items.contains(value)) ? value : null;
    return DropdownButtonFormField<String>(
      initialValue: safeValue,
      items: items
          .map(
            (item) => DropdownMenuItem<String>(
              value: item,
              child: Text(item, style: const TextStyle(color: Colors.white)),
            ),
          )
          .toList(),
      onChanged: onChanged,
      dropdownColor: Colors.black87,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
        filled: true,
        fillColor: Colors.black.withOpacity(0.28),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
      ),
      isExpanded: true,
    );
  }
}
