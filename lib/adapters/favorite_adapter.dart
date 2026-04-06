import 'package:supabase_flutter/supabase_flutter.dart';

class FavoriteAdapter {
  Future addFavorite(String terrainId) async {
    final userId = Supabase.instance.client.auth.currentUser!.id;
    return await Supabase.instance.client.from('favorites').insert({
      'user_id': userId,
      'terrain_id': terrainId,
    });
  }

  Future removeFavorite(String terrainId) async {
    final userId = Supabase.instance.client.auth.currentUser!.id;
    return await Supabase.instance.client.from('favorites')
        .delete()
        .match({'user_id': userId, 'terrain_id': terrainId});
  }

  Future<List<dynamic>> getFavorites() async {
    final userId = Supabase.instance.client.auth.currentUser!.id;
    return await Supabase.instance.client
        .from('favorites')
        .select('terrain_id')
        .eq('user_id', userId);
  }
}
