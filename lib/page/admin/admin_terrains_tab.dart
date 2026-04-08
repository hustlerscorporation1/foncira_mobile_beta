// ══════════════════════════════════════════════════════════════
//  FONCIRA — Admin Dashboard Terrains Tab
// ══════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:foncira/theme/colors.dart';
import 'package:google_fonts/google_fonts.dart';

class AdminTerrainsTab extends StatefulWidget {
  const AdminTerrainsTab({super.key});

  @override
  State<AdminTerrainsTab> createState() => _AdminTerrainsTabState();
}

class _AdminTerrainsTabState extends State<AdminTerrainsTab> {
  String _selectedStatus = 'En attente';

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
                'Modération des terrains',
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
                    _buildStatusButton('En attente'),
                    _buildStatusButton('Approuvés'),
                    _buildStatusButton('Rejetés'),
                    _buildStatusButton('Suspendus'),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Liste des terrains
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: 5,
            itemBuilder: (context, index) {
              return _buildTerrainCard(
                location: [
                  'Tokoin',
                  'Kégué',
                  'Zongo',
                  'Sissoko',
                  'Baoule',
                ][index],
                size: ['500m²', '250m²', '1000m²', '750m²', '600m²'][index],
                seller: [
                  'Amos Adjao',
                  'Kofi Mensah',
                  'Baye Keita',
                  'Tunde Okafor',
                  'Ama Owusu',
                ][index],
                price: ['75M', '80M', '120M', '95M', '55M'][index],
                submittedDaysAgo: [2, 5, 8, 1, 3][index],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStatusButton(String label) {
    final isSelected = _selectedStatus == label;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedStatus = label;
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

  Widget _buildTerrainCard({
    required String location,
    required String size,
    required String seller,
    required String price,
    required int submittedDaysAgo,
  }) {
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
            // En-tête
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        location,
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        '$size • $seller',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: Colors.grey[400],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: kPrimary.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  child: Text(
                    price,
                    style: GoogleFonts.outfit(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: kPrimary,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Info supplémentaires
            Row(
              children: [
                Icon(Icons.schedule, size: 16, color: Colors.grey[500]),
                const SizedBox(width: 6),
                Text(
                  'Soumis il y a $submittedDaysAgo jours',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Actions (Approuver / Rejeter)
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      // Approuver
                      _showApprovalDialog(context);
                    },
                    icon: const Icon(Icons.check_circle, size: 16),
                    label: const Text('Approuver'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: kSuccess,
                      side: BorderSide(color: kSuccess.withOpacity(0.5)),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      // Rejeter
                      _showRejectionDialog(context);
                    },
                    icon: const Icon(Icons.close, size: 16),
                    label: const Text('Rejeter'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: BorderSide(color: Colors.red.withOpacity(0.5)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showApprovalDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        title: Text(
          'Approuver le terrain?',
          style: GoogleFonts.outfit(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        content: Text(
          'Ce terrain sera publié dans la marketplace.',
          style: GoogleFonts.inter(color: Colors.grey[300]),
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
                SnackBar(
                  content: const Text('Terrain approuvé'),
                  backgroundColor: kSuccess,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: kSuccess),
            child: const Text('Approuver'),
          ),
        ],
      ),
    );
  }

  void _showRejectionDialog(BuildContext context) {
    final reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        title: Text(
          'Rejeter le terrain',
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
              'Raison du rejet:',
              style: GoogleFonts.inter(color: Colors.grey[300]),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: reasonController,
              maxLines: 3,
              style: GoogleFonts.inter(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Décrivez la raison du rejet...',
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
                  content: Text('Terrain rejeté'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Rejeter'),
          ),
        ],
      ),
    );
  }
}
