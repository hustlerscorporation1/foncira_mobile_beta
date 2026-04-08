import 'package:flutter/material.dart';
import 'package:foncira/services/supabase_service.dart';

class AdminGuard {
  static final AdminGuard _instance = AdminGuard._internal();

  AdminGuard._internal();

  factory AdminGuard() {
    return _instance;
  }

  Future<bool> isUserAdmin() async {
    try {
      final supabase = SupabaseService().client;
      final user = supabase.auth.currentUser;

      if (user == null) {
        return false;
      }

      dynamic response;
      try {
        // Current schema
        response = await supabase
            .from('users')
            .select('primary_role')
            .eq('auth_id', user.id)
            .single();
      } catch (_) {
        // Legacy fallback
        response = await supabase
            .from('users')
            .select('role')
            .eq('id', user.id)
            .single();
      }

      final role = (response['primary_role'] ?? response['role']) as String?;
      return role == 'admin';
    } catch (e) {
      print('[AdminGuard] Erreur lors de la verification: $e');
      return false;
    }
  }

  static Widget protectedRoute({
    required Widget adminPage,
    required BuildContext context,
  }) {
    return FutureBuilder<bool>(
      future: AdminGuard().isUserAdmin(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (!snapshot.hasData || !snapshot.data!) {
          Future.microtask(() {
            Navigator.of(context).pushReplacementNamed('/home');
          });
          return const SizedBox.shrink();
        }

        return adminPage;
      },
    );
  }
}
