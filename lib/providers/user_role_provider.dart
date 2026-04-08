import 'dart:async';
import 'package:flutter/foundation.dart';
import '../services/supabase_service.dart';

// ══════════════════════════════════════════════════════════════
//  USER ROLE PROVIDER — Synchronisation des rôles
// ══════════════════════════════════════════════════════════════

class UserRoleProvider with ChangeNotifier {
  final SupabaseService _supabaseService = SupabaseService();

  String? _currentRole; // 'client', 'agent', 'admin'
  String? _previousRole; // Pour détecter les changements
  bool _isInitialized = false;
  bool _isSyncing = false;
  String? _errorMessage;

  String? get currentRole => _currentRole;
  String? get previousRole => _previousRole;
  bool get isInitialized => _isInitialized;
  bool get isSyncing => _isSyncing;
  String? get errorMessage => _errorMessage;

  // Getters pour les vérifications rapides
  bool get isAdmin => _currentRole == 'admin';
  bool get isAgent => _currentRole == 'agent';
  bool get isClient => _currentRole == 'client';

  // Détecte si le rôle a changé
  bool get hasRoleChanged =>
      _previousRole != null && _previousRole != _currentRole;

  /// Initialise et synchronise le rôle de l'utilisateur
  /// Retourne true si succès, false si erreur
  /// Redémarrage: le rôle courant dans l'app
  Future<bool> initializeUserRole() async {
    if (_isInitialized && !_isSyncing) {
      // Déjà initialisé et pas en cours de synchronisation
      return true;
    }

    _isSyncing = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Vérifie que l'utilisateur est authentifié
      final currentAuthUser = _supabaseService.client.auth.currentUser;
      if (currentAuthUser == null) {
        _errorMessage = 'Aucun utilisateur authentifié';
        _isSyncing = false;
        _isInitialized = false;
        notifyListeners();
        return false;
      }

      // Récupère les données de l'utilisateur depuis Supabase (avec timeout)
      final role = await _fetchUserRole(currentAuthUser.id);

      if (role != null) {
        _previousRole = _currentRole; // Sauvegarde l'ancien rôle
        _currentRole = role;
        _isInitialized = true;
        _errorMessage = null;

        // Log les changements
        if (_previousRole != null && _previousRole != role) {
          print('🔄 [Role Sync] Rôle changé: $_previousRole → $role');
        } else {
          print('✅ [Role Sync] Rôle initialisé: $role');
        }
      } else {
        _errorMessage = 'Impossible de récupérer le rôle utilisateur';
        _isInitialized = false;
      }

      _isSyncing = false;
      notifyListeners();
      return _currentRole != null;
    } catch (e) {
      _errorMessage = 'Erreur lors de la synchronisation du rôle: $e';
      _isSyncing = false;
      notifyListeners();
      print('❌ [Role Sync] Erreur: $e');
      return false;
    }
  }

  /// Récupère le rôle de l'utilisateur depuis Supabase (avec timeout)
  Future<String?> _fetchUserRole(String userId) async {
    try {
      // Timeout de 5 secondes
      final result = await _supabaseService.client
          .from('users')
          .select('primary_role')
          .eq('auth_id', userId)
          .maybeSingle()
          .timeout(const Duration(seconds: 5));

      if (result != null) {
        final role = result['primary_role'] as String?;
        return role;
      }

      // Si pas de résultat, essaye avec l'ID directement
      final resultById = await _supabaseService.client
          .from('users')
          .select('primary_role')
          .eq('id', userId)
          .maybeSingle()
          .timeout(const Duration(seconds: 5));

      return resultById?['primary_role'] as String?;
    } on TimeoutException {
      print('⏱️  [Role Sync] Timeout lors de la récupération du rôle');
      return null;
    } catch (e) {
      print('❌ [Role Sync] Erreur lors de la récupération: $e');
      return null;
    }
  }

  /// Synchronise le rôle en arrière-plan (appelé lors du retour au foreground)
  /// Ne bloque pas l'UI
  void syncRoleInBackground() {
    if (_isSyncing) return; // Évite les sync multiples

    print('🔄 [Role Sync] Synchronisation en arrière-plan...');
    initializeUserRole().then((_) {
      if (hasRoleChanged) {
        print('⚠️  [Role Sync] Rôle a changé en arrière-plan!');
      }
    });
  }

  /// Réinitialise le provider (útile au logout)
  void reset() {
    _currentRole = null;
    _previousRole = null;
    _isInitialized = false;
    _isSyncing = false;
    _errorMessage = null;
    notifyListeners();
  }

  /// Définit manuellement le rôle (pour les tests)
  void setRoleForTesting(String role) {
    _previousRole = _currentRole;
    _currentRole = role;
    _isInitialized = true;
    notifyListeners();
  }
}
