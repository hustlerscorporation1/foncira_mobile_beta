// ignore_for_file: unused_import

import 'package:foncira/page/home_page.dart';
import 'package:foncira/page/splash_screen.dart';
import 'package:foncira/services/supabase_service.dart';
import 'package:foncira/services/admin_guard.dart';
import 'package:foncira/services/agent_guard.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'page/loginpage_refactored.dart';
import 'page/registerpage.dart';
import 'page/presentation.dart';
import 'page/admin/admin_dashboard.dart';
import 'page/agent/agent_dashboard.dart';
import 'providers/auth_provider.dart';
import 'providers/terrain_provider.dart';
import 'providers/verification_provider.dart';
import 'providers/notification_provider.dart';
import 'providers/user_mode_provider.dart';
import 'providers/user_role_provider.dart';
import 'theme/app_theme.dart';
import 'corbeille/corbeille/accueil_acheteur.dart';
import 'widgets/app_lifecycle_detector.dart';

// ══════════════════════════════════════════════════════════════
//  FONCIRA — Main Entry Point
// ══════════════════════════════════════════════════════════════

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase service
  await SupabaseService().initialize();

  runApp(const FonciraApp());
}

class FonciraApp extends StatelessWidget {
  const FonciraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => TerrainProvider()),
        ChangeNotifierProvider(create: (_) => VerificationProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ChangeNotifierProvider(create: (_) => UserModeProvider()),
        ChangeNotifierProvider(create: (_) => UserRoleProvider()),
      ],
      child: MaterialApp(
        title: 'FONCIRA',
        debugShowCheckedModeBanner: false,
        theme: FonciraTheme.darkTheme,
        initialRoute: '/',
        routes: {
          '/': (context) => const SplashPage(),
          '/onboarding': (context) => const Presentation(),
          '/login': (context) => const LoginPage(),
          '/register': (context) => const Registration(),
          '/home': (context) =>
              WithAppLifecycleDetection(child: const FonciraHomePage()),
          '/admin': (context) => WithAppLifecycleDetection(
            child: AdminGuard.protectedRoute(
              adminPage: const AdminDashboard(),
              context: context,
            ),
          ),
          '/agent': (context) => WithAppLifecycleDetection(
            child: AgentGuard.protectedRoute(
              agentPage: const AgentDashboard(),
              context: context,
            ),
          ),
        },
      ),
    );
  }
}
