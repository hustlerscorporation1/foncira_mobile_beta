// ══════════════════════════════════════════════════════════════
//  FONCIRA — Admin Dashboard Overview Tab
// ══════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:foncira/theme/colors.dart';
import 'package:google_fonts/google_fonts.dart';

class AdminOverviewTab extends StatelessWidget {
  const AdminOverviewTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Titre
          Text(
            'Vue d\'ensemble',
            style: GoogleFonts.outfit(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 24),

          // Cartes KPI (4 colonnes)
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            children: [
              _buildKPICard(
                title: 'Terrains en attente',
                value: '12',
                icon: Icons.pending_actions,
                color: Colors.orange,
              ),
              _buildKPICard(
                title: 'Vérifications actives',
                value: '8',
                icon: Icons.verified_user,
                color: kPrimary,
              ),
              _buildKPICard(
                title: 'Utilisateurs',
                value: '342',
                icon: Icons.people,
                color: Colors.purple,
              ),
              _buildKPICard(
                title: 'Revenus (FCFA)',
                value: '45.2M',
                icon: Icons.trending_up,
                color: kSuccess,
              ),
            ],
          ),

          const SizedBox(height: 32),

          // Dernières activités
          Text(
            'Dernières activités',
            style: GoogleFonts.outfit(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          _buildActivityList(),
        ],
      ),
    );
  }

  Widget _buildKPICard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 12),
          Text(
            value,
            style: GoogleFonts.outfit(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: GoogleFonts.inter(fontSize: 12, color: Colors.grey[400]),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 5,
      itemBuilder: (context, index) {
        final activities = [
          ('Nouveau terrain: Kégué 500m²', 'Il y a 2h', Icons.add),
          ('Vérification complétée: Tokoin', 'Il y a 4h', Icons.check_circle),
          ('Utilisateur suspendu: John D.', 'Il y a 6h', Icons.block),
          ('Paiement reçu: 150K FCFA', 'Il y a 8h', Icons.payment),
          ('Rapport soumis: Terrain Avédji', 'Il y a 12h', Icons.description),
        ];
        final (title, time, icon) = activities[index];

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A2E),
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: kPrimary.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  padding: const EdgeInsets.all(8),
                  child: Icon(icon as IconData, color: kPrimary, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title as String,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        time as String,
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
