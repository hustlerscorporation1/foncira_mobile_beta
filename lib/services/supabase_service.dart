import 'package:supabase_flutter/supabase_flutter.dart';
import 'config.dart';

// ══════════════════════════════════════════════════════════════
//  FONCIRA — Supabase Service (Singleton)
// ══════════════════════════════════════════════════════════════

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();

  factory SupabaseService() {
    return _instance;
  }

  SupabaseService._internal();

  late SupabaseClient _client;
  bool _serviceInitialized = false;

  // ── Getters ────────────────────────────────────────────────
  SupabaseClient get client {
    if (_serviceInitialized) return _client;

    // Supports cases where Supabase was already initialized globally
    // (e.g. hot restart) but this service instance state was reset.
    try {
      _client = Supabase.instance.client;
      _serviceInitialized = true;
      return _client;
    } catch (_) {
      throw StateError(
        'SupabaseService not initialized. Call SupabaseService().initialize() first.',
      );
    }
  }

  User? get currentUser => client.auth.currentUser;
  String? get currentUserId => currentUser?.id;
  bool get isAuthenticated => currentUser != null;

  // ── Initialization ─────────────────────────────────────────
  Future<void> initialize() async {
    if (_serviceInitialized) return;

    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
    _client = Supabase.instance.client;
    _serviceInitialized = true;
  }

  // ── Authentication ─────────────────────────────────────────
  Future<bool> signInWithEmail(String email, String password) async {
    try {
      final response = await client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return response.user != null;
    } catch (e) {
      throw Exception('Sign in failed: $e');
    }
  }

  Future<bool> signUpWithEmail(
    String email,
    String password, {
    String? firstName,
    String? lastName,
    String? phoneNumber,
  }) async {
    try {
      final response = await client.auth.signUp(
        email: email,
        password: password,
        data: {
          'first_name': firstName,
          'last_name': lastName,
          'phone_number': phoneNumber,
        },
      );
      return response.user != null;
    } catch (e) {
      throw Exception('Sign up failed: $e');
    }
  }

  Future<void> signOut() async {
    try {
      await client.auth.signOut();
    } catch (e) {
      throw Exception('Sign out failed: $e');
    }
  }

  Future<Map<String, dynamic>?> getCurrentUserData() async {
    if (!isAuthenticated) return null;
    try {
      dynamic response;
      try {
        response = await client
            .from('users')
            .select('*')
            .eq('auth_id', currentUserId!)
            .single();
      } catch (_) {
        response = await client
            .from('users')
            .select('*')
            .eq('id', currentUserId!)
            .single();
      }
      return response;
    } catch (e) {
      return null;
    }
  }

  // ── Utility ────────────────────────────────────────────────
  double convertFcfaToUsd(double fcfa) {
    return fcfa / 655.957;
  }

  double convertUsdToFcfa(double usd) {
    return usd * 655.957;
  }

  String calculateRiskLevel(String documentType) {
    switch (documentType) {
      case 'titre_foncier':
        return 'faible';
      case 'logement':
        return 'faible';
      case 'convention':
        return 'modere';
      case 'recu_vente':
        return 'modere';
      case 'aucun_document':
      case 'ne_sais_pas':
        return 'eleve';
      default:
        return 'modere';
    }
  }
}
