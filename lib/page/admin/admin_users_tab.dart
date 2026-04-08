// ══════════════════════════════════════════════════════════════
//  FONCIRA — Admin Dashboard Users Tab
// ══════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:foncira/theme/colors.dart';
import 'package:google_fonts/google_fonts.dart';

class AdminUsersTab extends StatefulWidget {
  const AdminUsersTab({super.key});

  @override
  State<AdminUsersTab> createState() => _AdminUsersTabState();
}

class _AdminUsersTabState extends State<AdminUsersTab> {
  String _selectedRole = 'Tous';

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Titre + Filtres
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Gestion des utilisateurs',
                style: GoogleFonts.outfit(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildRoleButton('Tous'),
                    _buildRoleButton('Acheteurs'),
                    _buildRoleButton('Vendeurs'),
                    _buildRoleButton('Agents'),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Liste des utilisateurs
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: 8,
            itemBuilder: (context, index) {
              final roles = [
                'Acheteur',
                'Vendeur',
                'Agent',
                'Acheteur',
                'Vendeur',
                'Agent',
                'Acheteur',
                'Vendeur',
              ];
              final statuses = [
                'Actif',
                'Actif',
                'Actif',
                'Suspendu',
                'Actif',
                'Actif',
                'Actif',
                'Suspendu',
              ];

              return _buildUserCard(
                name: [
                  'Jean Koffi',
                  'Amos Adjao',
                  'Baye Keita',
                  'Maria Diallo',
                  'Kofi Mensah',
                  'Tunde Okafor',
                  'Ama Owusu',
                  'Kwame Boateng',
                ][index],
                role: roles[index],
                email: [
                  'jean@email.com',
                  'amos@email.com',
                  'baye@email.com',
                  'maria@email.com',
                  'kofi@email.com',
                  'tunde@email.com',
                  'ama@email.com',
                  'kwame@email.com',
                ][index],
                status: statuses[index],
                joinDate: '${index + 1} mois',
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRoleButton(String label) {
    final isSelected = _selectedRole == label;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedRole = label;
          });
        },
        child: Container(
          decoration: BoxDecoration(
            color: isSelected ? kPrimary : const Color(0xFF1A1A2E),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? kPrimary : Colors.grey[700]!,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white : Colors.grey[400],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUserCard({
    required String name,
    required String role,
    required String email,
    required String status,
    required String joinDate,
  }) {
    final roleColor = role == 'Acheteur'
        ? Colors.blue
        : role == 'Vendeur'
        ? Colors.orange
        : Colors.purple;

    final statusIsActive = status == 'Actif';
    final statusColor = statusIsActive ? kSuccess : Colors.red;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A2E),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[800]!),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête: Nom + Status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        email,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: roleColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      child: Text(
                        role,
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: roleColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: statusColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Info supplémentaires
            Row(
              children: [
                Icon(Icons.calendar_today, size: 16, color: Colors.grey[500]),
                const SizedBox(width: 6),
                Text(
                  'Inscrit il y a $joinDate',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
                const SizedBox(width: 16),
                Icon(Icons.info_outline, size: 16, color: Colors.grey[500]),
                const SizedBox(width: 6),
                Text(
                  status,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: statusColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Actions
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      // Voir détails
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: kPrimary,
                      side: BorderSide(color: kPrimary.withOpacity(0.5)),
                    ),
                    child: const Text('Détails'),
                  ),
                ),
                const SizedBox(width: 8),
                if (!statusIsActive)
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        // Réactiver
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Utilisateur réactivé'),
                            backgroundColor: kSuccess,
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kSuccess,
                      ),
                      child: const Text('Réactiver'),
                    ),
                  )
                else
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        // Suspendre
                        _showSuspendDialog(context);
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: BorderSide(color: Colors.red.withOpacity(0.5)),
                      ),
                      child: const Text('Suspendre'),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showSuspendDialog(BuildContext context) {
    final reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        title: Text(
          'Suspendre l\'utilisateur',
          style: GoogleFonts.outfit(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Raison de la suspension:',
              style: GoogleFonts.inter(color: Colors.grey[300]),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: reasonController,
              maxLines: 3,
              style: GoogleFonts.inter(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Décrivez la raison...',
                hintStyle: GoogleFonts.inter(color: Colors.grey[600]),
                filled: true,
                fillColor: Colors.grey[900],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Utilisateur suspendu'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Suspendre'),
          ),
        ],
      ),
    );
  }
}
