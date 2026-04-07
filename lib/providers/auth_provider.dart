import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../services/supabase_service.dart';

class AuthProvider with ChangeNotifier {
  final SupabaseService _supabaseService = SupabaseService();

  User? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _supabaseService.isAuthenticated;

  AuthProvider() {
    _checkAuthStatus();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _setError(null);

    try {
      final success = await _supabaseService.signInWithEmail(email, password);
      if (success) {
        final userData = await _supabaseService.getCurrentUserData();
        if (userData != null) {
          _currentUser = User(
            id: userData['id'] ?? '',
            email: userData['email'] ?? email,
            firstName: userData['first_name'],
            phoneNumber: userData['phone_number'],
            isActive: true,
            createdAt: DateTime.now(),
          );
          _setLoading(false);
          return true;
        }
      }
      _setError('Login failed. Please check your credentials.');
      _setLoading(false);
      return false;
    } catch (e) {
      _setError('An error occurred during login: $e');
      _setLoading(false);
      return false;
    }
  }

  Future<bool> register({
    required String email,
    required String password,
    String? firstName,
    String? lastName,
    String? phoneNumber,
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      final success = await _supabaseService.signUpWithEmail(
        email,
        password,
        firstName: firstName,
        lastName: lastName,
        phoneNumber: phoneNumber,
      );

      if (success) {
        final userData = await _supabaseService.getCurrentUserData();
        if (userData != null) {
          _currentUser = User(
            id: userData['id'] ?? '',
            email: email,
            firstName: firstName,
            phoneNumber: phoneNumber,
            isActive: true,
            createdAt: DateTime.now(),
          );
          _setLoading(false);
          return true;
        }
      }
      _setError('Registration failed. Please try again.');
      _setLoading(false);
      return false;
    } catch (e) {
      _setError('An error occurred during registration: $e');
      _setLoading(false);
      return false;
    }
  }

  Future<void> logout() async {
    try {
      await _supabaseService.signOut();
      _currentUser = null;
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _setError('Logout failed: $e');
    }
  }

  Future<void> _checkAuthStatus() async {
    _setLoading(true);

    try {
      if (_supabaseService.isAuthenticated) {
        final userData = await _supabaseService.getCurrentUserData();
        if (userData != null) {
          _currentUser = User(
            id: userData['id'] ?? '',
            email: userData['email'] ?? '',
            firstName: userData['first_name'],
            phoneNumber: userData['phone_number'],
            isActive: true,
            createdAt: DateTime.now(),
          );
        }
      }
    } catch (e) {
      _setError('Failed to check auth status: $e');
    } finally {
      _setLoading(false);
    }
  }
}
