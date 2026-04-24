import 'package:supabase_flutter/supabase_flutter.dart';

/// Service pour gérer les terrains favoris
class FavorisService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Récupère les terrains favoris de l'utilisateur
  Future<List<Map<String, dynamic>>> getFavorisList(String userId) async {
    try {
      final response = await _supabase
          .from('favoris')
          .select('*, terrains_foncira(*)')
          .eq('user_id', userId)
          .order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Erreur GetFavorisList: $e');
      rethrow;
    }
  }

  /// Stream pour les favoris en temps réel
  Stream<List<Map<String, dynamic>>> favoriStream(String userId) {
    return _supabase
        .from('favoris')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .order('created_at', ascending: false)
        .map((event) => List<Map<String, dynamic>>.from(event));
  }

  /// Ajoute un terrain en favori
  Future<void> addFavori(String userId, String terrainId) async {
    try {
      await _supabase.from('favoris').insert({
        'user_id': userId,
        'terrain_id': terrainId,
      });
    } catch (e) {
      // Favoris déjà existant ou erreur
      print('Erreur AddFavori: $e');
      rethrow;
    }
  }

  /// Supprime un terrain des favoris
  Future<void> removeFavori(String userId, String terrainId) async {
    try {
      await _supabase
          .from('favoris')
          .delete()
          .eq('user_id', userId)
          .eq('terrain_id', terrainId);
    } catch (e) {
      print('Erreur RemoveFavori: $e');
      rethrow;
    }
  }

  /// Vérifie si un terrain est en favori
  Future<bool> isFavori(String userId, String terrainId) async {
    try {
      final response = await _supabase
          .from('favoris')
          .select()
          .eq('user_id', userId)
          .eq('terrain_id', terrainId);
      return response.isNotEmpty;
    } catch (e) {
      print('Erreur IsFavori: $e');
      return false;
    }
  }

  /// Toggle favori
  Future<bool> toggleFavori(String userId, String terrainId) async {
    final isFavori_ = await isFavori(userId, terrainId);
    if (isFavori_) {
      await removeFavori(userId, terrainId);
      return false;
    } else {
      await addFavori(userId, terrainId);
      return true;
    }
  }
}
