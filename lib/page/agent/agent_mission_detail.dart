// ══════════════════════════════════════════════════════════════
//  FONCIRA — Agent Mission Detail (Improved)
//  Écran de lecture du dossier mission complet avant collecte
// ══════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:foncira/theme/colors.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:foncira/services/agent_service.dart';
import 'agent_mission_sources.dart';

class AgentMissionDetail extends StatefulWidget {
  final Map<String, dynamic> mission;
  final AgentService agentService;

  const AgentMissionDetail({
    required this.mission,
    required this.agentService,
    super.key,
  });

  @override
  State<AgentMissionDetail> createState() => _AgentMissionDetailState();
}

class _AgentMissionDetailState extends State<AgentMissionDetail> {
  late Map<String, dynamic> _mission;
  late Future<List<Map<String, dynamic>>> _documentsFuture;
  bool _isDownloading = false;

  @override
  void initState() {
    super.initState();
    _mission = widget.mission;
    _documentsFuture = widget.agentService.getDocuments(_mission['id']);
  }

  @override
  Widget build(BuildContext context) {
    // Données terrain
    final title = _mission['terrain_title'] ?? 'Sans titre';
    final location = _mission['terrain_location'] ?? '';
    final documentType = _mission['document_type'] ?? '';
    final priceFcfa = _mission['terrain_price_fcfa'] ?? 0;

    // Données client
    final clientData = _mission['users'] ?? {};
    final clientName =
        '${clientData['first_name'] ?? ''} ${clientData['last_name'] ?? ''}'
            .trim();

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F0F1E),
        elevation: 0,
        title: Text(
          'Détail mission',
          style: GoogleFonts.outfit(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFFB0B0B0)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          // Contenu scrollable
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ══════════════════════════════════════════════════════
                // SECTION 1: Informations Terrain
                // ══════════════════════════════════════════════════════
                _buildSectionTitle('Informations terrain'),
                const SizedBox(height: 12),

                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1E2E),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFF2D2D3F),
                      width: 1,
                    ),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Titre du terrain
                      Text(
                        title,
                        style: GoogleFonts.outfit(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Localisation
                      _buildInfoRow(
                        icon: Icons.location_on_outlined,
                        label: 'Localisation',
                        value: location,
                      ),
                      const SizedBox(height: 12),

                      // Ville
                      _buildInfoRow(
                        icon: Icons.location_city_outlined,
                        label: 'Ville',
                        value: location.isNotEmpty
                            ? location.split(',').last.trim()
                            : 'Non spécifiée',
                      ),
                      const SizedBox(height: 12),

                      // Quartier
                      _buildInfoRow(
                        icon: Icons.location_city_outlined,
                        label: 'Quartier',
                        value: 'À collecter',
                        valueColor: const Color(0xFF6B6B7F),
                      ),
                      const SizedBox(height: 12),

                      // Surface
                      _buildInfoRow(
                        icon: Icons.square_foot_outlined,
                        label: 'Surface',
                        value: 'À collecter',
                        valueColor: const Color(0xFF6B6B7F),
                      ),
                      const SizedBox(height: 12),

                      // Prix déclaré
                      _buildInfoRow(
                        icon: Icons.attach_money_outlined,
                        label: 'Prix déclaré',
                        value: priceFcfa > 0
                            ? '${priceFcfa.toStringAsFixed(0)} FCFA'
                            : 'Non spécifié',
                      ),
                      const SizedBox(height: 12),

                      // Type de document
                      _buildInfoRow(
                        icon: Icons.description_outlined,
                        label: 'Type de document',
                        value: documentType,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // ══════════════════════════════════════════════════════
                // SECTION 2: Informations Client
                // ══════════════════════════════════════════════════════
                _buildSectionTitle('Informations client'),
                const SizedBox(height: 12),

                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1E2E),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFF2D2D3F),
                      width: 1,
                    ),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Nom du client
                      _buildInfoRow(
                        icon: Icons.person_outline,
                        label: 'Nom du client',
                        value: clientName,
                      ),
                      const SizedBox(height: 12),

                      // Pays
                      _buildInfoRow(
                        icon: Icons.public_outlined,
                        label: 'Pays',
                        value: 'Côte d\'Ivoire',
                      ),
                      const SizedBox(height: 12),

                      // Objectif vérification
                      _buildInfoRow(
                        icon: Icons.verified_outlined,
                        label: 'Objectif vérification',
                        value: 'Valider propriété et documents',
                        isMultiline: true,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // ══════════════════════════════════════════════════════
                // SECTION 3: Instructions Mission
                // ══════════════════════════════════════════════════════
                _buildSectionTitle('Instructions mission'),
                const SizedBox(height: 12),

                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1E2E),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFF2D2D3F),
                      width: 1,
                    ),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.info_outline, size: 20, color: kPrimary),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Collectez les informations auprès des sources locales',
                          style: GoogleFonts.outfit(
                            fontSize: 13,
                            color: const Color(0xFFB0B0B0),
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // ══════════════════════════════════════════════════════
                // SECTION 4: Documents Disponibles
                // ══════════════════════════════════════════════════════
                _buildSectionTitle('Documents disponibles'),
                const SizedBox(height: 12),

                FutureBuilder<List<Map<String, dynamic>>>(
                  future: _documentsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 24),
                          child: const CircularProgressIndicator(
                            color: kPrimary,
                            strokeWidth: 2,
                          ),
                        ),
                      );
                    }

                    if (snapshot.hasError || !snapshot.hasData) {
                      return Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E1E2E),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFF2D2D3F),
                            width: 1,
                          ),
                        ),
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          'Erreur de chargement',
                          style: GoogleFonts.outfit(
                            fontSize: 12,
                            color: Colors.red.withOpacity(0.7),
                          ),
                        ),
                      );
                    }

                    final documents = snapshot.data ?? [];

                    if (documents.isEmpty) {
                      return Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E1E2E),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFF2D2D3F),
                            width: 1,
                          ),
                        ),
                        padding: const EdgeInsets.all(16),
                        child: Center(
                          child: Text(
                            'Aucun document disponible',
                            style: GoogleFonts.outfit(
                              fontSize: 12,
                              color: const Color(0xFF6B6B7F),
                            ),
                          ),
                        ),
                      );
                    }

                    return Column(
                      children: List.generate(documents.length, (index) {
                        final doc = documents[index];
                        final docType = doc['document_type'] ?? 'Document';
                        final uploadedAt = doc['created_at'] != null
                            ? DateTime.parse(doc['created_at'] as String)
                            : null;

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _buildDocumentItem(
                            docType: docType,
                            uploadedAt: uploadedAt,
                            onDownload: () => _downloadDocument(doc),
                          ),
                        );
                      }),
                    );
                  },
                ),

                // Spacing pour le bouton fixe en bas
                const SizedBox(height: 100),
              ],
            ),
          ),

          // Bouton "Commencer collecte" fixe en bas
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF0F0F1E),
                border: Border(
                  top: BorderSide(color: const Color(0xFF2D2D3F), width: 1),
                ),
              ),
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isDownloading ? null : _startCollection,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimary,
                    foregroundColor: Colors.black,
                    disabledBackgroundColor: kPrimary.withOpacity(0.5),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    'Commencer collecte',
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build section title widget
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.outfit(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );
  }

  /// Build a single info row (icon + label + value)
  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
    bool isMultiline = false,
  }) {
    return Row(
      crossAxisAlignment: isMultiline
          ? CrossAxisAlignment.start
          : CrossAxisAlignment.center,
      children: [
        Icon(icon, size: 18, color: kPrimary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.outfit(
                  fontSize: 12,
                  color: const Color(0xFF6B6B7F),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: GoogleFonts.outfit(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: valueColor ?? const Color(0xFFB0B0B0),
                ),
                maxLines: isMultiline ? 3 : 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Build a document item with download button
  Widget _buildDocumentItem({
    required String docType,
    required DateTime? uploadedAt,
    required VoidCallback onDownload,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E2E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF2D2D3F), width: 1),
      ),
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Icon(Icons.description_outlined, size: 22, color: kPrimary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  docType,
                  style: GoogleFonts.outfit(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
                if (uploadedAt != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    '${uploadedAt.day}/${uploadedAt.month}/${uploadedAt.year}',
                    style: GoogleFonts.outfit(
                      fontSize: 11,
                      color: const Color(0xFF6B6B7F),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 100,
            child: OutlinedButton.icon(
              onPressed: onDownload,
              icon: const Icon(Icons.download_outlined, size: 16),
              label: Text(
                'Télécharger',
                style: GoogleFonts.outfit(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: kPrimary,
                side: const BorderSide(color: kPrimary, width: 1),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Download document (simulation)
  Future<void> _downloadDocument(Map<String, dynamic> doc) async {
    setState(() => _isDownloading = true);

    try {
      // Simulation de téléchargement
      await Future.delayed(const Duration(seconds: 2));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Document téléchargé: ${doc['document_type']}',
              style: GoogleFonts.outfit(fontSize: 12),
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Erreur de téléchargement',
              style: GoogleFonts.outfit(fontSize: 12),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isDownloading = false);
      }
    }
  }

  /// Start data collection - navigate to sources screen
  void _startCollection() {
    if (!_isDownloading) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => AgentMissionSources(
            mission: _mission,
            agentService: widget.agentService,
          ),
        ),
      );
    }
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
