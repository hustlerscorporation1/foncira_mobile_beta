import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../services/api_service.dart';

class AuthProvider with ChangeNotifier {
  User? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _currentUser != null;

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
      final token = await ApiService.login(email: email, password: password);
      if (token != null) {
        // Get user info after successful login
        final user = await ApiService.getCurrentUser();
        if (user != null) {
          _currentUser = user;
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
      final authResponse = await ApiService.register(
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
        phoneNumber: phoneNumber,
      );

      if (authResponse != null) {
        _currentUser = authResponse.user;
        _setLoading(false);
        return true;
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
    await ApiService.logout();
    _currentUser = null;
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> checkAuthStatus() async {
    _setLoading(true);
    
    try {
      final isLoggedIn = await ApiService.isLoggedIn();
      if (isLoggedIn) {
        final user = await ApiService.getCurrentUser();
        if (user != null) {
          _currentUser = user;
        }
      }
    } catch (e) {
      print('Error checking auth status: $e');
    }
    
    _setLoading(false);
  }

  void clearError() {
    _setError(null);
  }
}

