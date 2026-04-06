import 'package:flutter/material.dart';
import '../../component/terrain.dart';
import '../favoris_manager.dart';
import '../terrain_info.dart';

class FavorisPage extends StatelessWidget {
  const FavorisPage({super.key});

  @override
  Widget build(BuildContext context) {
    final favoris = FavorisManager.favoris;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Mes favoris ❤️"),
        backgroundColor: Colors.green,
      ),
      body: favoris.isEmpty
          ? const Center(child: Text("Aucun terrain en favori pour le moment."))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: favoris.length,
              itemBuilder: (context, index) {
                final terrain = favoris[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.asset(
                        terrain.imageUrl,
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                      ),
                    ),
                    title: Text(terrain.title),
                    subtitle: Text("${terrain.location}\n${terrain.price}"),
                    isThreeLine: true,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => TerrainDetailPage(terrain: terrain),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}
