import 'package:flutter/material.dart';

// ══════════════════════════════════════════════════════════════
//  ROLE-BASED NAVIGATION SERVICE
// ══════════════════════════════════════════════════════════════

class RoleBasedNavigation {
  /// Détermine la route de destination basée sur le rôle
  static String getRouteForRole(String? role) {
    switch (role) {
      case 'admin':
        return '/admin';
      case 'agent':
        return '/agent';
      case 'client':
      default:
        return '/home';
    }
  }

  /// Navigue vers la route appropriée selon le rôle
  /// Si forceNavigation=true, utilise pushReplacementNamed (remplace l'historique)
  static Future<void> navigateByRole(
    BuildContext context,
    String? role, {
    bool forceNavigation = false,
    bool isRoleChange = false,
  }) async {
    final route = getRouteForRole(role);

    if (isRoleChange) {
      print(
        '🔄 [Navigation] Redirection due au changement de rôle: $role → $route',
      );
    } else {
      print('📍 [Navigation] Navigation initiale: $role → $route');
    }

    if (forceNavigation) {
      await Navigator.of(context).pushReplacementNamed(route);
    } else {
      await Navigator.of(context).pushNamedAndRemoveUntil(
        route,
        (route) => false, // Supprime tout l'historique
      );
    }
  }

  /// Vérifie si l'utilisateur a accès à une route
  static bool hasAccessToRoute(String userRole, String targetRoute) {
    final allowedRoles = _getAllowedRolesForRoute(targetRoute);
    return allowedRoles.contains(userRole);
  }

  /// Retourne les rôles autorisés pour une route
  static List<String> _getAllowedRolesForRoute(String route) {
    switch (route) {
      case '/admin':
        return ['admin'];
      case '/agent':
        return ['agent', 'admin']; // Admin peut aussi accéder
      case '/home':
      case '/':
        return ['client', 'agent', 'admin']; // Tous peuvent accéder au home
      default:
        return [];
    }
  }

  /// Affiche une snackbar pour indiquer un changement de rôle
  static void showRoleChangeNotification(
    BuildContext context,
    String oldRole,
    String newRole,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '🔄 Votre rôle a été mis à jour: $oldRole → $newRole',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
