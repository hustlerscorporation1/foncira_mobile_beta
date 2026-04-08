import 'package:flutter/material.dart';
import 'package:foncira/services/supabase_service.dart';

class AgentGuard {
  static final AgentGuard _instance = AgentGuard._internal();

  AgentGuard._internal();

  factory AgentGuard() {
    return _instance;
  }

  Future<bool> isUserAgent() async {
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
      return role == 'agent';
    } catch (e) {
      print('[AgentGuard] Erreur lors de la verification: $e');
      return false;
    }
  }

  static Widget protectedRoute({
    required Widget agentPage,
    required BuildContext context,
  }) {
    return FutureBuilder<bool>(
      future: AgentGuard().isUserAgent(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            backgroundColor: const Color(0xFF0F0F1E),
            body: const Center(
              child: CircularProgressIndicator(color: Color(0xFF00A86B)),
            ),
          );
        }

        if (snapshot.hasError || snapshot.data != true) {
          Future.microtask(() {
            Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
          });
          return const SizedBox.shrink();
        }

        return agentPage;
      },
    );
  }
}
