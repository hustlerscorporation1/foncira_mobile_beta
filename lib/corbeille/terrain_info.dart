import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import '../component/terrain.dart';
import 'corbeille/achat_process.dart';

const kLightBackgroundColor = Color(0xFFF7F8FC);
const kPrimaryColor = Color(0xFF16A34A);
const kCardColor = Colors.white;
const kFontColor = Color(0xFF2D3748);
const kHintColor = Color(0xFF718096);
const _kOsmUserAgentPackageName = 'com.foncira';

class TerrainDetailPage extends StatefulWidget {
  final Terrain terrain;
  const TerrainDetailPage({super.key, required this.terrain});

  @override
  State<TerrainDetailPage> createState() => _TerrainDetailPageState();
}

class _TerrainDetailPageState extends State<TerrainDetailPage> {
  bool _isFavorite = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kLightBackgroundColor,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 24),
                  _buildKeyFeaturesGrid(),
                  const SizedBox(height: 24),
                  _buildSectionTitle("Localisation"),
                  const SizedBox(height: 16),
                  _buildMapPreview(),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildActionButtons(context),
    );
  }

  SliverAppBar _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 260,
      pinned: true,
      elevation: 0,
      backgroundColor: kPrimaryColor,
      iconTheme: const IconThemeData(color: Colors.white),
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            Hero(
              tag: widget.terrain.id,
              child: Image.asset(widget.terrain.imageUrl, fit: BoxFit.cover),
            ),

            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.black.withOpacity(0.4), Colors.transparent],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(
            _isFavorite ? Icons.favorite : Icons.favorite_border,
            color: _isFavorite ? Colors.redAccent : Colors.white,
          ),
          onPressed: () {
            setState(() {
              _isFavorite = !_isFavorite;
            });
          },
        ),
        IconButton(
          icon: const Icon(Icons.share, color: Colors.white),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.terrain.title,
          style: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: kFontColor,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Icon(Icons.location_on_outlined, size: 18, color: kHintColor),
            const SizedBox(width: 4),
            Text(
              widget.terrain.location,
              style: const TextStyle(color: kHintColor, fontSize: 16),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          '${widget.terrain.price.toStringAsFixed(0)} FCFA',
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: kPrimaryColor,
          ),
        ),
      ],
    );
  }

  Widget _buildKeyFeaturesGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle("Caractéristiques"),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 3.5,
          mainAxisSpacing: 14,
          crossAxisSpacing: 14,
          children: [
            _InfoChip(
              icon: Icons.area_chart,
              label: 'Surface',
              value: '${widget.terrain.surface} m²',
            ),
            _InfoChip(
              icon: Icons.home_work,
              label: 'Constructible',
              value: widget.terrain.isConstructible ? 'Oui' : 'Non',
            ),
            _InfoChip(
              icon: Icons.visibility,
              label: 'Vue',
              value: widget.terrain.vue ?? 'Aucune',
            ),
            _InfoChip(
              icon: Icons.water_drop,
              label: 'Viabilisé',
              value: widget.terrain.isViabilise ? 'Oui' : 'Non',
            ),
            _InfoChip(
              icon: Icons.verified,
              label: 'Statut',
              value: widget.terrain.verificationFoncira.label,
              highlight: true,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMapPreview() {
    if (widget.terrain.coordinates == null) {
      return const SizedBox(
        height: 200,
        child: Center(child: Text('Localisation non disponible')),
      );
    }
    return SizedBox(
      height: 200,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: FlutterMap(
          options: MapOptions(
            initialCenter: widget.terrain.coordinates!,
            initialZoom: 15,
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: _kOsmUserAgentPackageName,
            ),
            MarkerLayer(
              markers: [
                Marker(
                  point: widget.terrain.coordinates!,
                  width: 40,
                  height: 40,
                  child: const Icon(
                    Icons.location_on,
                    color: Colors.red,
                    size: 36,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16).copyWith(top: 0),
      decoration: BoxDecoration(
        color: kCardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        AchatProcessPage(terrain: widget.terrain),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                backgroundColor: kPrimaryColor,
              ),
              child: const Text(
                "Acheter ce terrain",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            decoration: BoxDecoration(
              color: kLightBackgroundColor,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: IconButton(
              icon: const Icon(Icons.chat_bubble_outline, color: kPrimaryColor),
              onPressed: () {},
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: kFontColor,
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool highlight;

  const _InfoChip({
    required this.icon,
    required this.label,
    required this.value,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: kCardColor.withOpacity(0.9),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: highlight ? kPrimaryColor : kHintColor, size: 22),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: const TextStyle(color: kHintColor, fontSize: 12),
              ),
              Text(
                value,
                style: TextStyle(
                  color: highlight ? kPrimaryColor : kFontColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
