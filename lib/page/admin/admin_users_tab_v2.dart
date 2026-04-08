// ══════════════════════════════════════════════════════════════
//  FONCIRA — Admin Users Tab (Clients, Agents, Sellers + Testimonials)
// ══════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:foncira/theme/colors.dart';
import 'package:foncira/services/supabase_service.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class AdminUsersTab extends StatefulWidget {
  const AdminUsersTab({super.key});

  @override
  State<AdminUsersTab> createState() => _AdminUsersTabState();
}

class _AdminUsersTabState extends State<AdminUsersTab>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // En-tête
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Gestion des utilisateurs',
            style: GoogleFonts.outfit(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),

        // Tabs
        Container(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Colors.grey[800]!),
            ),
          ),
          child: TabBar(
            controller: _tabController,
            labelColor: kPrimary,
            unselectedLabelColor: Colors.grey[600],
            indicatorColor: kPrimary,
            tabs: const [
              Tab(text: 'Clients'),
              Tab(text: 'Agents'),
              Tab(text: 'Vendeurs'),
              Tab(text: 'Témoignages'),
            ],
          ),
        ),

        // Tab views
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: const [
              AdminClientsSubTab(),
              AdminAgentsSubTab(),
              AdminSellersSubTab(),
              AdminTestimonialsSubTab(),
            ],
          ),
        ),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════
// CLIENTS SUB-TAB
// ══════════════════════════════════════════════════════════════

class AdminClientsSubTab extends StatefulWidget {
  const AdminClientsSubTab({super.key});

  @override
  State<AdminClientsSubTab> createState() => _AdminClientsSubTabState();
}

class _AdminClientsSubTabState extends State<AdminClientsSubTab> {
  final supabase = SupabaseService().client;
  final _searchController = TextEditingController();
  int _currentPage = 0;
  final int _itemsPerPage = 20;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Barre de recherche
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: _searchController,
            style: GoogleFonts.inter(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Rechercher par nom ou email...',
              hintStyle: GoogleFonts.inter(color: Colors.grey[600]),
              prefixIcon: const Icon(Icons.search, color: Colors.grey),
              filled: true,
              fillColor: const Color(0xFF1A1A2E),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey[800]!),
              ),
            ),
            onChanged: (_) => setState(() => _currentPage = 0),
          ),
        ),

        // Liste
        Expanded(
          child: FutureBuilder<List<Map<String, dynamic>>>(
            future: _fetchClients(),
            builder: (context, snapshot) {
              if (!snapshot.hasData)
                return Center(
                  child: SizedBox(
                    width: 40,
                    height: 40,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(kPrimary),
                    ),
                  ),
                );

              final clients = snapshot.data ?? [];
              if (clients.isEmpty)
                return Center(
                  child: Text(
                    'Aucun client trouvé',
                    style: GoogleFonts.inter(color: Colors.grey[500]),
                  ),
                );

              return Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: clients.length,
                      itemBuilder: (context, index) {
                        return _buildClientCard(clients[index]);
                      },
                    ),
                  ),
                  _buildPaginationControls(clients.length),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildClientCard(Map<String, dynamic> client) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A2E),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[800]!),
        ),
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        client['email']?.split('@')[0] ?? 'Client',
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        client['email'] ?? 'N/A',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  color: const Color(0xFF1A1A2E),
                  onSelected: (value) {
                    _handleClientAction(value, client['id']);
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'view_profile',
                      child: Row(
                        children: [
                          const Icon(Icons.person, color: kPrimary, size: 16),
                          const SizedBox(width: 8),
                          const Text('Voir profil'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'change_role',
                      child: Row(
                        children: [
                          const Icon(Icons.admin_panel_settings,
                              color: Colors.orange, size: 16),
                          const SizedBox(width: 8),
                          const Text('Changer rôle'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'view_payments',
                      child: Row(
                        children: [
                          const Icon(Icons.payment, color: Colors.blue, size: 16),
                          const SizedBox(width: 8),
                          const Text('Paiements'),
                        ],
                      ),
                    ),
                    const PopupMenuDivider(),
                    PopupMenuItem(
                      value: 'deactivate',
                      child: Row(
                        children: [
                          const Icon(Icons.block, color: Colors.red, size: 16),
                          const SizedBox(width: 8),
                          const Text('Désactiver'),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Infos
            Row(
              children: [
                _buildInfoBadge(
                  '${client['referral_balance_usd'] ?? 0} USD',
                  'Parrainage',
                  Colors.green,
                ),
                const SizedBox(width: 12),
                _buildInfoBadge(
                  '${client['country_code'] ?? 'N/A'}',
                  'Pays',
                  Colors.blue,
                ),
                const SizedBox(width: 12),
                _buildInfoBadge(
                  '${client['verification_count'] ?? 0}',
                  'Vérifications',
                  Colors.purple,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoBadge(String value, String label, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Column(
        children: [
          Text(
            value,
            style: GoogleFonts.outfit(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 10,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaginationControls(int totalItems) {
    final totalPages = (totalItems / _itemsPerPage).ceil();
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            onPressed: _currentPage > 0 ? () => setState(() => _currentPage--) : null,
            icon: const Icon(Icons.chevron_left),
            color: _currentPage > 0 ? kPrimary : Colors.grey[600],
          ),
          Text(
            'Page ${_currentPage + 1}/$totalPages',
            style: GoogleFonts.inter(color: Colors.grey[400]),
          ),
          IconButton(
            onPressed:
                _currentPage < totalPages - 1 ? () => setState(() => _currentPage++) : null,
            icon: const Icon(Icons.chevron_right),
            color: _currentPage < totalPages - 1 ? kPrimary : Colors.grey[600],
          ),
        ],
      ),
    );
  }

  void _handleClientAction(String action, String clientId) {
    switch (action) {
      case 'change_role':
        _showChangeRoleDialog(clientId);
        break;
      case 'view_payments':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Historique des paiements')),
        );
        break;
      case 'deactivate':
        _showDeactivateDialog(clientId);
        break;
    }
  }

  void _showChangeRoleDialog(String userId) {
    const roles = ['client', 'agent', 'vendor', 'admin'];
    String? selectedRole;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        title: Text(
          'Changer le rôle',
          style: GoogleFonts.outfit(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        content: StatefulBuilder(
          builder: (context, setState) => Column(
            mainAxisSize: MainAxisSize.min,
            children: roles
                .map(
                  (role) => GestureDetector(
                    onTap: () => setState(() => selectedRole = role),
                    child: Container(
                      decoration: BoxDecoration(
                        color: selectedRole == role
                            ? kPrimary.withOpacity(0.2)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: selectedRole == role ? kPrimary : Colors.grey[700]!,
                        ),
                      ),
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        role.toUpperCase(),
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (selectedRole != null) {
                await supabase
                    .from('users')
                    .update({'primary_role': selectedRole})
                    .eq('id', userId);

                if (mounted) {
                  Navigator.pop(context);
                  setState(() {});
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Rôle mis à jour'),
                      backgroundColor: kSuccess,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: kPrimary),
            child: const Text('Appliquer'),
          ),
        ],
      ),
    );
  }

  void _showDeactivateDialog(String userId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        title: Text(
          'Désactiver le compte',
          style: GoogleFonts.outfit(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.red,
          ),
        ),
        content: Text(
          'Cette action désactivera le compte. Êtes-vous sûr?',
          style: GoogleFonts.inter(color: Colors.grey[300]),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              await supabase.from('users').update({'is_active': false}).eq('id', userId);

              if (mounted) {
                Navigator.pop(context);
                setState(() {});
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Compte désactivé'),
                    backgroundColor: Colors.orange,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Désactiver'),
          ),
        ],
      ),
    );
  }

  Future<List<Map<String, dynamic>>> _fetchClients() async {
    try {
      var query = supabase
          .from('users')
          .select('id, email, country_code, referral_balance_usd')
          .eq('primary_role', 'client');

      if (_searchController.text.isNotEmpty) {
        query = query.or('email.ilike.%${_searchController.text}%');
      }

      final offset = _currentPage * _itemsPerPage;
      final response = await query.range(offset, offset + _itemsPerPage - 1);

      // Ajouter le comptage des vérifications
      return (response as List).map<Map<String, dynamic>>((client) {
        final row = Map<String, dynamic>.from(client as Map);
        return {
          ...row,
          'verification_count': 0, // Fetch dynamiquement si nécessaire
        };
      }).toList();
    } catch (e) {
      return [];
    }
  }
}

// ══════════════════════════════════════════════════════════════
// AGENTS SUB-TAB
// ══════════════════════════════════════════════════════════════

class AdminAgentsSubTab extends StatefulWidget {
  const AdminAgentsSubTab({super.key});

  @override
  State<AdminAgentsSubTab> createState() => _AdminAgentsSubTabState();
}

class _AdminAgentsSubTabState extends State<AdminAgentsSubTab> {
  final supabase = SupabaseService().client;
  final _searchController = TextEditingController();
  int _currentPage = 0;
  final int _itemsPerPage = 20;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Barre de recherche
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: _searchController,
            style: GoogleFonts.inter(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Rechercher par nom...',
              hintStyle: GoogleFonts.inter(color: Colors.grey[600]),
              prefixIcon: const Icon(Icons.search, color: Colors.grey),
              filled: true,
              fillColor: const Color(0xFF1A1A2E),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey[800]!),
              ),
            ),
            onChanged: (_) => setState(() => _currentPage = 0),
          ),
        ),

        // Liste
        Expanded(
          child: FutureBuilder<List<Map<String, dynamic>>>(
            future: _fetchAgents(),
            builder: (context, snapshot) {
              if (!snapshot.hasData)
                return Center(
                  child: SizedBox(
                    width: 40,
                    height: 40,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(kPrimary),
                    ),
                  ),
                );

              final agents = snapshot.data ?? [];
              if (agents.isEmpty)
                return Center(
                  child: Text(
                    'Aucun agent trouvé',
                    style: GoogleFonts.inter(color: Colors.grey[500]),
                  ),
                );

              return Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: agents.length,
                      itemBuilder: (context, index) {
                        return _buildAgentCard(agents[index]);
                      },
                    ),
                  ),
                  _buildPaginationControls(agents.length),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAgentCard(Map<String, dynamic> agent) {
    final isAvailable = agent['is_available'] as bool? ?? false;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A2E),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[800]!),
        ),
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête avec toggle
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        agent['name'] ?? 'Agent',
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        agent['phone'] ?? 'N/A',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ),
                // Toggle disponibilité
                Switch(
                  value: isAvailable,
                  activeColor: kPrimary,
                  onChanged: (value) async {
                    await supabase
                        .from('agents')
                        .update({'is_available': value}).eq('id', agent['id']);
                    setState(() {});
                  },
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Infos travail
            Row(
              children: [
                Expanded(
                  child: _buildInfoBadgeAgent(
                    '${agent['current_workload'] ?? 0}',
                    'Workload actuel',
                    Colors.orange,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildInfoBadgeAgent(
                    '${agent['completed_verifications'] ?? 0}',
                    'Complétées',
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildInfoBadgeAgent(
                    '${(agent['average_rating'] ?? 0).toStringAsFixed(1)}⭐',
                    'Note moyenne',
                    Colors.yellow,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoBadgeAgent(String value, String label, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            value,
            style: GoogleFonts.outfit(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 9,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaginationControls(int totalItems) {
    final totalPages = (totalItems / _itemsPerPage).ceil();
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            onPressed: _currentPage > 0 ? () => setState(() => _currentPage--) : null,
            icon: const Icon(Icons.chevron_left),
            color: _currentPage > 0 ? kPrimary : Colors.grey[600],
          ),
          Text(
            'Page ${_currentPage + 1}/$totalPages',
            style: GoogleFonts.inter(color: Colors.grey[400]),
          ),
          IconButton(
            onPressed:
                _currentPage < totalPages - 1 ? () => setState(() => _currentPage++) : null,
            icon: const Icon(Icons.chevron_right),
            color: _currentPage < totalPages - 1 ? kPrimary : Colors.grey[600],
          ),
        ],
      ),
    );
  }

  Future<List<Map<String, dynamic>>> _fetchAgents() async {
    try {
      var query = supabase
          .from('agents')
          .select('id, name, phone, is_available, current_workload, completed_verifications, average_rating');

      if (_searchController.text.isNotEmpty) {
        query = query.ilike('name', '%${_searchController.text}%');
      }

      final offset = _currentPage * _itemsPerPage;
      final response = await query.range(offset, offset + _itemsPerPage - 1);

      return response as List<Map<String, dynamic>>;
    } catch (e) {
      return [];
    }
  }
}

// ══════════════════════════════════════════════════════════════
// SELLERS SUB-TAB
// ══════════════════════════════════════════════════════════════

class AdminSellersSubTab extends StatefulWidget {
  const AdminSellersSubTab({super.key});

  @override
  State<AdminSellersSubTab> createState() => _AdminSellersSubTabState();
}

class _AdminSellersSubTabState extends State<AdminSellersSubTab> {
  final supabase = SupabaseService().client;
  int _currentPage = 0;
  final int _itemsPerPage = 20;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: FutureBuilder<List<Map<String, dynamic>>>(
            future: _fetchSellers(),
            builder: (context, snapshot) {
              if (!snapshot.hasData)
                return Center(
                  child: SizedBox(
                    width: 40,
                    height: 40,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(kPrimary),
                    ),
                  ),
                );

              final sellers = snapshot.data ?? [];
              if (sellers.isEmpty)
                return Center(
                  child: Text(
                    'Aucun vendeur trouvé',
                    style: GoogleFonts.inter(color: Colors.grey[500]),
                  ),
                );

              return Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: sellers.length,
                      itemBuilder: (context, index) {
                        return _buildSellerCard(sellers[index]);
                      },
                    ),
                  ),
                  _buildPaginationControls(sellers.length),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSellerCard(Map<String, dynamic> seller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A2E),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[800]!),
        ),
        padding: const EdgeInsets.all(14),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    seller['email']?.split('@')[0] ?? 'Vendeur',
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    seller['email'] ?? 'N/A',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        child: Text(
                          '${seller['active_listings'] ?? 0} annonces',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: (seller['subscription_status'] == 'active'
                                  ? Colors.green
                                  : Colors.red)
                              .withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        child: Text(
                          seller['subscription_status'] ?? 'Inactif',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: seller['subscription_status'] == 'active'
                                ? Colors.green
                                : Colors.red,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            PopupMenuButton<String>(
              color: const Color(0xFF1A1A2E),
              onSelected: (value) {},
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'view_profile',
                  child: Row(
                    children: [
                      const Icon(Icons.person, color: kPrimary, size: 16),
                      const SizedBox(width: 8),
                      const Text('Voir annonces'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaginationControls(int totalItems) {
    final totalPages = (totalItems / _itemsPerPage).ceil();
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            onPressed: _currentPage > 0 ? () => setState(() => _currentPage--) : null,
            icon: const Icon(Icons.chevron_left),
            color: _currentPage > 0 ? kPrimary : Colors.grey[600],
          ),
          Text(
            'Page ${_currentPage + 1}/$totalPages',
            style: GoogleFonts.inter(color: Colors.grey[400]),
          ),
          IconButton(
            onPressed:
                _currentPage < totalPages - 1 ? () => setState(() => _currentPage++) : null,
            icon: const Icon(Icons.chevron_right),
            color: _currentPage < totalPages - 1 ? kPrimary : Colors.grey[600],
          ),
        ],
      ),
    );
  }

  Future<List<Map<String, dynamic>>> _fetchSellers() async {
    try {
      // Récupérer les vendeurs (users ayant au moins un terrain)
      final terrains = await supabase
          .from('terrains_foncira')
          .select('seller_id')
          .isFilter('deleted_at', null);

      final sellerIds = (terrains as List)
          .map((t) => (t as Map)['seller_id'])
          .whereType<Object>()
          .toSet()
          .toList();

      if (sellerIds.isEmpty) return [];

      var query = supabase
          .from('users')
          .select('id, email')
          .inFilter('id', sellerIds as List<dynamic>);

      final offset = _currentPage * _itemsPerPage;
      final response = await query.range(offset, offset + _itemsPerPage - 1);

      return (response as List).map<Map<String, dynamic>>((seller) {
        final row = Map<String, dynamic>.from(seller as Map);
        return {
          ...row,
          'active_listings': 0, // Fetch dynamiquement
          'subscription_status': 'active',
        };
      }).toList();
    } catch (e) {
      return [];
    }
  }
}

// ══════════════════════════════════════════════════════════════
// TESTIMONIALS SUB-TAB
// ══════════════════════════════════════════════════════════════

class AdminTestimonialsSubTab extends StatefulWidget {
  const AdminTestimonialsSubTab({super.key});

  @override
  State<AdminTestimonialsSubTab> createState() => _AdminTestimonialsSubTabState();
}

class _AdminTestimonialsSubTabState extends State<AdminTestimonialsSubTab> {
  final supabase = SupabaseService().client;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _fetchTestimonials(),
      builder: (context, snapshot) {
        if (!snapshot.hasData)
          return Center(
            child: SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(kPrimary),
              ),
            ),
          );

        final testimonials = snapshot.data ?? [];
        if (testimonials.isEmpty)
          return Center(
            child: Text(
              'Aucun témoignage',
              style: GoogleFonts.inter(color: Colors.grey[500]),
            ),
          );

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: testimonials.length,
          itemBuilder: (context, index) {
            return _buildTestimonialCard(testimonials[index]);
          },
        );
      },
    );
  }

  Widget _buildTestimonialCard(Map<String, dynamic> testimonial) {
    final isPublished = testimonial['is_published'] as bool? ?? false;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A2E),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[800]!),
        ),
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête avec toggle publish
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        testimonial['author_name'] ?? 'Auteur',
                        style: GoogleFonts.outfit(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        '${testimonial['author_location'] ?? 'N/A'} • ⭐ ${testimonial['rating'] ?? 0}',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: isPublished,
                  activeColor: kPrimary,
                  onChanged: (value) async {
                    await supabase
                        .from('testimonials')
                        .update({'is_published': value}).eq('id', testimonial['id']);
                    setState(() {});
                  },
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Contenu
            Text(
              testimonial['content'] ?? '',
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: Colors.grey[300],
              ),
            ),

            const SizedBox(height: 12),

            // Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () {
                    supabase.from('testimonials').delete().eq('id', testimonial['id']);
                    setState(() {});
                  },
                  icon: const Icon(Icons.delete, size: 16),
                  label: const Text('Supprimer'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<List<Map<String, dynamic>>> _fetchTestimonials() async {
    try {
      final response = await supabase
          .from('testimonials')
          .select('*')
          .order('created_at', ascending: false);

      return response as List<Map<String, dynamic>>;
    } catch (e) {
      return [];
    }
  }
}
