import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_role_provider.dart';
import '../services/role_based_navigation.dart';

// ══════════════════════════════════════════════════════════════
//  APP LIFECYCLE MIXIN — Détecte les changements en foreground
// ══════════════════════════════════════════════════════════════

mixin AppLifecycleMixin on WidgetsBindingObserver {
  /// Appelé quand l'app revient au foreground
  void onAppResumed(BuildContext context) {
    print(
      '🔄 [Lifecycle] App resumed - Synchronisation du rôle en arrière-plan',
    );

    try {
      final userRoleProvider = context.read<UserRoleProvider>();
      final oldRole = userRoleProvider.currentRole;

      // Synchronise en arrière-plan
      userRoleProvider.syncRoleInBackground();

      // Écoute les changements de rôle
      Future.delayed(const Duration(milliseconds: 500), () {
        if (context.mounted && userRoleProvider.hasRoleChanged) {
          print(
            '⚠️  [Lifecycle] Rôle changé: $oldRole → ${userRoleProvider.currentRole}',
          );

          // Affiche une notification
          if (context.mounted) {
            RoleBasedNavigation.showRoleChangeNotification(
              context,
              oldRole ?? 'inconnu',
              userRoleProvider.currentRole ?? 'inconnu',
            );

            // Redirige après 2 secondes
            Future.delayed(const Duration(seconds: 2), () {
              if (context.mounted) {
                RoleBasedNavigation.navigateByRole(
                  context,
                  userRoleProvider.currentRole,
                  forceNavigation: true,
                  isRoleChange: true,
                );
              }
            });
          }
        }
      });
    } catch (e) {
      print('❌ [Lifecycle] Erreur: $e');
    }
  }
}

// ══════════════════════════════════════════════════════════════
//  HOME PAGE WITH LIFECYCLE DETECTION
// ══════════════════════════════════════════════════════════════

/// Wrapper pour détecter les changements en foreground
/// À utiliser sur les pages principales (home, admin, agent)
class WithAppLifecycleDetection extends StatefulWidget {
  final Widget child;
  final Function(BuildContext)? onAppResumed;

  const WithAppLifecycleDetection({
    super.key,
    required this.child,
    this.onAppResumed,
  });

  @override
  State<WithAppLifecycleDetection> createState() =>
      _WithAppLifecycleDetectionState();
}

class _WithAppLifecycleDetectionState extends State<WithAppLifecycleDetection>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    print('✅ [Lifecycle] Listener ajouté');
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    print('❌ [Lifecycle] Listener supprimé');
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        print('🔄 [Lifecycle] App resumed (foreground)');
        _onAppResumed();
        break;
      case AppLifecycleState.paused:
        print('⏸️  [Lifecycle] App paused (background)');
        break;
      case AppLifecycleState.detached:
        print('🔌 [Lifecycle] App detached');
        break;
      case AppLifecycleState.hidden:
        print('👻 [Lifecycle] App hidden');
        break;
      case AppLifecycleState.inactive:
        print('📵 [Lifecycle] App inactive');
        break;
    }
  }

  void _onAppResumed() {
    if (!mounted) return;

    try {
      final userRoleProvider = context.read<UserRoleProvider>();
      final oldRole = userRoleProvider.currentRole;

      // Synchronise en arrière-plan
      print('🔄 Synchronisation du rôle...');
      userRoleProvider.syncRoleInBackground();

      // Vérifie après un délai pour laisser la sync se faire
      Future.delayed(const Duration(milliseconds: 800), () {
        if (!mounted) return;

        if (userRoleProvider.hasRoleChanged) {
          print('⚠️  Rôle changé: $oldRole → ${userRoleProvider.currentRole}');

          // Affiche notification
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  '🔄 Votre rôle a été mis à jour: $oldRole → ${userRoleProvider.currentRole}',
                ),
                backgroundColor: Colors.blue,
                duration: const Duration(seconds: 2),
              ),
            );

            // Redirige après notification
            Future.delayed(const Duration(seconds: 2), () {
              if (mounted) {
                RoleBasedNavigation.navigateByRole(
                  context,
                  userRoleProvider.currentRole,
                  forceNavigation: true,
                  isRoleChange: true,
                );
              }
            });
          }
        }
      });

      // Appel custom si fourni
      widget.onAppResumed?.call(context);
    } catch (e) {
      print('❌ Erreur lors de onAppResumed: $e');
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
