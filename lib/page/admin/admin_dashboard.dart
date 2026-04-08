// ══════════════════════════════════════════════════════════════
//  FONCIRA — Admin Dashboard Main
// ══════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:foncira/theme/colors.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:foncira/services/admin_guard.dart';
import 'package:foncira/services/supabase_service.dart';
import 'admin_overview_tab_v2.dart';
import 'admin_verifications_tab_v2.dart';
import 'admin_terrains_tab_v2.dart';
import 'admin_users_tab_v2.dart';
import 'admin_settings_tab_v2.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _selectedTabIndex = 0;

  final List<Widget> _tabs = const [
    AdminOverviewTab(),
    AdminVerificationsTab(),
    AdminTerrainsTab(),
    AdminUsersTab(),
    AdminSettingsTab(),
  ];

  final List<String> _tabLabels = [
    'Aperçu',
    'Vérifications',
    'Terrains',
    'Utilisateurs',
    'Paramètres',
  ];

  final List<IconData> _tabIcons = [
    Icons.dashboard,
    Icons.verified_user,
    Icons.landscape,
    Icons.people,
    Icons.settings,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1E),
      appBar: _buildAppBar(),
      body: _tabs[_selectedTabIndex],
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFF0F0F1E),
      elevation: 0,
      title: Row(
        children: [
          // Logo FONCIRA (left)
          Container(
            decoration: BoxDecoration(
              color: kPrimary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Text(
              'FONCIRA',
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: kPrimary,
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Badge "Admin" (red)
          Container(
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.2),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.red, width: 1),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            child: Text(
              'ADMIN',
              style: GoogleFonts.outfit(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
          ),
        ],
      ),
      actions: [
        // Logout button (right)
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: Center(
            child: PopupMenuButton<String>(
              icon: const Icon(Icons.account_circle, size: 28),
              onSelected: (value) {
                if (value == 'logout') {
                  _handleLogout();
                }
              },
              itemBuilder: (BuildContext context) => [
                PopupMenuItem<String>(
                  value: 'logout',
                  child: Row(
                    children: [
                      const Icon(Icons.logout, size: 18, color: Colors.red),
                      const SizedBox(width: 8),
                      Text(
                        'Déconnexion',
                        style: GoogleFonts.inter(
                          color: Colors.red,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomNav() {
    return BottomNavigationBar(
      backgroundColor: const Color(0xFF0F0F1E),
      selectedItemColor: kPrimary,
      unselectedItemColor: Colors.grey[600],
      currentIndex: _selectedTabIndex,
      type: BottomNavigationBarType.fixed,
      onTap: (index) {
        setState(() {
          _selectedTabIndex = index;
        });
      },
      items: List.generate(
        _tabs.length,
        (index) => BottomNavigationBarItem(
          icon: Icon(_tabIcons[index]),
          label: _tabLabels[index],
        ),
      ),
    );
  }

  Future<void> _handleLogout() async {
    // Confirm logout
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        title: Text(
          'Déconnexion',
          style: GoogleFonts.outfit(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        content: Text(
          'Êtes-vous sûr de vouloir vous déconnecter?',
          style: GoogleFonts.inter(color: Colors.grey[300]),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Déconnexion'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      // Logout from Supabase
      await SupabaseService().signOut();

      if (mounted) {
        // Navigate to login
        Navigator.of(
          context,
        ).pushNamedAndRemoveUntil('/login', (route) => false);
      }
    }
  }
}
