import 'package:supabase_flutter/supabase_flutter.dart';

class TerrainAdapter {
  Future<List<dynamic>> getAvailableTerrains() async {
    final response = await Supabase.instance.client
        .from('terrains')
        .select()
        .eq('status', 'available');
    return response;
  }

  Future addTerrain(Map<String, dynamic> terrain) async {
    return await Supabase.instance.client.from('terrains').insert(terrain);
  }

  Future updateTerrain(String id, Map<String, dynamic> data) async {
    return await Supabase.instance.client
        .from('terrains')
        .update(data)
        .eq('id', id);
  }
}


