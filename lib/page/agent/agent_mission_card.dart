// ══════════════════════════════════════════════════════════════
//  FONCIRA — Agent Mission Card
//  Card affichant une mission en résumé
// ══════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:foncira/theme/colors.dart';
import 'package:google_fonts/google_fonts.dart';

class AgentMissionCard extends StatelessWidget {
  final Map<String, dynamic> mission;
  final VoidCallback onTap;

  const AgentMissionCard({
    required this.mission,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final title = mission['terrain_title'] ?? 'Sans titre';
    final location = mission['terrain_location'] ?? '';
    final documentType = mission['document_type'] ?? '';
    final status = mission['verification_status'] ?? '';
    final createdAt = mission['created_at'] != null
        ? DateTime.parse(mission['created_at'] as String)
        : DateTime.now();

    // Récupérer infos client
    final clientData = mission['users'] ?? {};
    final clientName =
        '${clientData['first_name'] ?? ''} ${clientData['last_name'] ?? ''}'
            .trim();

    // Formater la date
    final formattedDate =
        '${createdAt.day}/${createdAt.month}/${createdAt.year}';

    // Couleur du statut
    final statusColor = _getStatusColor(status);
    final statusLabel = _getStatusLabel(status);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E2E),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF2D2D3F), width: 1),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Titre + Statut
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Titre du terrain
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.outfit(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Badge Statut
                  Container(
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: statusColor, width: 1),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    child: Text(
                      statusLabel,
                      style: GoogleFonts.outfit(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Localisation & Document Type
              Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 16,
                          color: const Color(0xFF6B6B7F),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            location,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.outfit(
                              fontSize: 12,
                              color: const Color(0xFF6B6B7F),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: kPrimary.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      documentType,
                      style: GoogleFonts.outfit(
                        fontSize: 11,
                        color: kPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Client & Date d'assignation
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Client
                  Expanded(
                    child: Row(
                      children: [
                        Icon(
                          Icons.person_outline,
                          size: 16,
                          color: const Color(0xFF6B6B7F),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            clientName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.outfit(
                              fontSize: 12,
                              color: const Color(0xFF6B6B7F),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Date assignation
                  Text(
                    formattedDate,
                    style: GoogleFonts.outfit(
                      fontSize: 11,
                      color: const Color(0xFF6B6B7F),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Bouton Voir mission
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: onTap,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: kPrimary, width: 1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Text(
                    'Voir mission',
                    style: GoogleFonts.outfit(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: kPrimary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Retourne la couleur associée au statut
  Color _getStatusColor(String status) {
    switch (status) {
      case 'receptionnee':
        return Colors.blue;
      case 'pre_analyse':
        return Colors.orange;
      case 'verification_administrative':
        return Colors.purple;
      case 'verification_terrain':
        return Colors.indigo;
      case 'analyse_finale':
        return Colors.amber;
      case 'rapport_livre':
        return Colors.green;
      default:
        return const Color(0xFF6B6B7F);
    }
  }

  /// Retourne le label français du statut
  String _getStatusLabel(String status) {
    switch (status) {
      case 'receptionnee':
        return 'Reçue';
      case 'pre_analyse':
        return 'Pré-analyse';
      case 'verification_administrative':
        return 'Admin';
      case 'verification_terrain':
        return 'Terrain';
      case 'analyse_finale':
        return 'Analyse finale';
      case 'rapport_livre':
        return 'Rapport livré';
      default:
        return status;
    }
  }
}
