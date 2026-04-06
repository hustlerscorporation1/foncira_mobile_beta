import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../models/terrain.dart';
import '../models/auth_response.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:8000'; // Change this to your backend URL
  
  // Authentication endpoints
  static Future<AuthResponse?> register({
    required String email,
    required String password,
    String? firstName,
    String? lastName,
    String? phoneNumber,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
          'first_name': firstName,
          'last_name': lastName,
          'phone_number': phoneNumber,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return AuthResponse.fromJson(data);
      } else {
        print('Registration failed: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Registration error: $e');
      return null;
    }
  }

  static Future<String?> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data['access_token'];
        
        // Save token to shared preferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('access_token', token);
        
        return token;
      } else {
        print('Login failed: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Login error: $e');
      return null;
    }
  }

  static Future<User?> getCurrentUser() async {
    try {
      final token = await getToken();
      if (token == null) return null;

      final response = await http.get(
        Uri.parse('$baseUrl/auth/me'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return User.fromJson(data);
      } else {
        print('Get current user failed: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Get current user error: $e');
      return null;
    }
  }

  // Terrain endpoints
  static Future<List<Terrain>> getTerrains({
    int skip = 0,
    int limit = 100,
    String? location,
    double? minPrice,
    double? maxPrice,
    double? minSurface,
    double? maxSurface,
    bool? isConstructible,
    String? vue,
    bool? isViabilise,
    String? verificationStatus,
  }) async {
    try {
      final queryParams = <String, String>{
        'skip': skip.toString(),
        'limit': limit.toString(),
      };

      if (location != null) queryParams['location'] = location;
      if (minPrice != null) queryParams['min_price'] = minPrice.toString();
      if (maxPrice != null) queryParams['max_price'] = maxPrice.toString();
      if (minSurface != null) queryParams['min_surface'] = minSurface.toString();
      if (maxSurface != null) queryParams['max_surface'] = maxSurface.toString();
      if (isConstructible != null) queryParams['is_constructible'] = isConstructible.toString();
      if (vue != null) queryParams['vue'] = vue;
      if (isViabilise != null) queryParams['is_viabilise'] = isViabilise.toString();
      if (verificationStatus != null) queryParams['verification_status'] = verificationStatus;

      final uri = Uri.parse('$baseUrl/terrains/').replace(queryParameters: queryParams);
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Terrain.fromJson(json)).toList();
      } else {
        print('Get terrains failed: ${response.body}');
        return [];
      }
    } catch (e) {
      print('Get terrains error: $e');
      return [];
    }
  }

  static Future<Terrain?> getTerrain(String terrainId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/terrains/$terrainId'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Terrain.fromJson(data);
      } else {
        print('Get terrain failed: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Get terrain error: $e');
      return null;
    }
  }

  static Future<Terrain?> createTerrain(Terrain terrain) async {
    try {
      final token = await getToken();
      if (token == null) return null;

      final response = await http.post(
        Uri.parse('$baseUrl/terrains/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(terrain.toJson()),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Terrain.fromJson(data);
      } else {
        print('Create terrain failed: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Create terrain error: $e');
      return null;
    }
  }

  static Future<Terrain?> updateTerrain(String terrainId, Terrain terrain) async {
    try {
      final token = await getToken();
      if (token == null) return null;

      final response = await http.put(
        Uri.parse('$baseUrl/terrains/$terrainId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(terrain.toJson()),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Terrain.fromJson(data);
      } else {
        print('Update terrain failed: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Update terrain error: $e');
      return null;
    }
  }

  static Future<bool> deleteTerrain(String terrainId) async {
    try {
      final token = await getToken();
      if (token == null) return false;

      final response = await http.delete(
        Uri.parse('$baseUrl/terrains/$terrainId'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Delete terrain error: $e');
      return false;
    }
  }

  // Favorites endpoints
  static Future<bool> addToFavorites(String terrainId) async {
    try {
      final token = await getToken();
      if (token == null) return false;

      final response = await http.post(
        Uri.parse('$baseUrl/favorites/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'terrain_id': terrainId}),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Add to favorites error: $e');
      return false;
    }
  }

  static Future<bool> removeFromFavorites(String terrainId) async {
    try {
      final token = await getToken();
      if (token == null) return false;

      final response = await http.delete(
        Uri.parse('$baseUrl/favorites/$terrainId'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Remove from favorites error: $e');
      return false;
    }
  }

  static Future<List<Terrain>> getFavorites() async {
    try {
      final token = await getToken();
      if (token == null) return [];

      final response = await http.get(
        Uri.parse('$baseUrl/favorites/me'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Terrain.fromJson(json)).toList();
      } else {
        print('Get favorites failed: ${response.body}');
        return [];
      }
    } catch (e) {
      print('Get favorites error: $e');
      return [];
    }
  }

  // Utility methods
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token');
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
  }

  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null;
  }
}

