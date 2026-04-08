// ══════════════════════════════════════════════════════════════
//  FONCIRA — Agent Dashboard Main
//  Interface protégée pour les agents de terrain
// ══════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:foncira/theme/colors.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:foncira/services/agent_service.dart';
import 'agent_missions_tab.dart';

class AgentDashboard extends StatefulWidget {
  const AgentDashboard({super.key});

  @override
  State<AgentDashboard> createState() => _AgentDashboardState();
}

class _AgentDashboardState extends State<AgentDashboard> {
  int _selectedTabIndex = 0;
  late AgentService _agentService;

  final List<Widget> _tabs = const [AgentMissionsTab()];

  final List<String> _tabLabels = ['Mes missions'];

  final List<IconData> _tabIcons = [Icons.assignment];

  @override
  void initState() {
    super.initState();
    _agentService = AgentService();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1E),
      appBar: _buildAppBar(),
      body: _tabs[_selectedTabIndex],
      bottomNavigationBar: _tabs.length >= 2 ? _buildBottomNav() : null,
    );
  }

  /// AppBar avec badge AGENT (vert)
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFF0F0F1E),
      elevation: 0,
      title: Row(
        children: [
          // Logo FONCIRA
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
          // Badge AGENT (vert)
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF00A86B).withOpacity(0.2),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: const Color(0xFF00A86B), width: 1),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            child: Text(
              'AGENT',
              style: GoogleFonts.outfit(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF00A86B),
              ),
            ),
          ),
        ],
      ),
      actions: [
        // Bouton logout
        IconButton(
          icon: const Icon(Icons.logout, color: Color(0xFFB0B0B0)),
          onPressed: () => _showLogoutDialog(),
        ),
      ],
    );
  }

  /// BottomNavigationBar (actuellement 1 tab, mais extensible)
  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: const Color(0xFF1E1E2E), width: 1),
        ),
      ),
      child: BottomNavigationBar(
        backgroundColor: const Color(0xFF0F0F1E),
        selectedItemColor: kPrimary,
        unselectedItemColor: const Color(0xFF6B6B7F),
        currentIndex: _selectedTabIndex,
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
      ),
    );
  }

  /// Dialog de déconnexion
  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E2E),
        title: Text(
          'Déconnexion',
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Êtes-vous sûr de vouloir vous déconnecter?',
          style: GoogleFonts.outfit(color: const Color(0xFFB0B0B0)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Annuler', style: GoogleFonts.outfit(color: kPrimary)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _logout();
            },
            child: Text(
              'Déconnexion',
              style: GoogleFonts.outfit(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  /// Action déconnexion
  void _logout() {
    Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
  }
}
