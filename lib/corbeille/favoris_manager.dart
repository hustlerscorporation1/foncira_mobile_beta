// favoris_manager.dart
import '../component/terrain.dart';

class FavorisManager {
  static final List<Terrain> _favoris = [];

  static List<Terrain> get favoris => _favoris;

  static bool isFavori(Terrain terrain) {
    return _favoris.contains(terrain);
  }

  static void toggleFavori(Terrain terrain) {
    if (isFavori(terrain)) {
      _favoris.remove(terrain);
    } else {
      _favoris.add(terrain);
    }
  }
}
