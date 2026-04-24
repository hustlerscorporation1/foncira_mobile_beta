// ══════════════════════════════════════════════════════════════
//  FONCIRA — Admin Verification Detail Page
// ══════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:foncira/theme/colors.dart';
import 'package:foncira/services/supabase_service.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class AdminVerificationDetailPage extends StatefulWidget {
  final String verificationId;

  const AdminVerificationDetailPage({super.key, required this.verificationId});

  @override
  State<AdminVerificationDetailPage> createState() =>
      _AdminVerificationDetailPageState();
}

class _AdminVerificationDetailPageState
    extends State<AdminVerificationDetailPage> {
  final supabase = SupabaseService().client;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F0F1E),
        elevation: 0,
        title: Text(
          'Détail de la vérification',
          style: GoogleFonts.outfit(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _fetchVerificationDetail(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
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
          }

          final v = snapshot.data!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Infos principales
                _buildMainInfoCard(v),

                const SizedBox(height: 24),

                // Jalons de la vérification
                _buildMilestonesSection(v),

                const SizedBox(height: 24),

                // Documents uploadés
                _buildDocumentsSection(v),

                const SizedBox(height: 24),

                // Actions admin
                _buildAdminActionsSection(v),

                const SizedBox(height: 24),

                // Rapport (si status = analyse_finale)
                if (v['status'] == 'analyse_finale') ...[
                  _buildReportSection(v),
                  const SizedBox(height: 24),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMainInfoCard(Map<String, dynamic> v) {
    final statusColor = _getStatusColor(v['status'] ?? 'unknown');
    final submittedAt = DateTime.tryParse(v['submitted_at'] as String? ?? '');
    final expectedAt = DateTime.tryParse(
      v['expected_delivery_at'] as String? ?? '',
    );
    final isLate = expectedAt != null && expectedAt.isBefore(DateTime.now());

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[800]!),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Client et terrain
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    v['client_name'] ?? 'N/A',
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    v['terrain_location'] ?? 'N/A',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: Colors.grey[400],
                    ),
                  ),
                ],
              ),
              Container(
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: statusColor, width: 1.5),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                child: Text(
                  v['status'] ?? 'Inconnu',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Dates
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildInfoItem(
                'Soumise le',
                submittedAt != null
                    ? DateFormat('dd/MM/yyyy HH:mm').format(submittedAt)
                    : 'N/A',
                Icons.calendar_today,
              ),
              _buildInfoItem(
                isLate ? 'EN RETARD' : 'Livraison prévue',
                expectedAt != null
                    ? DateFormat('dd/MM/yyyy').format(expectedAt)
                    : 'N/A',
                Icons.schedule,
                color: isLate ? Colors.red : null,
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Agent
          _buildInfoItem(
            'Agent assigné',
            v['agent_name'] ?? 'Non assigné',
            Icons.person,
          ),

          if (v['source'] != null) ...[
            const SizedBox(height: 12),
            _buildInfoItem(
              'Source',
              v['source'] == 'external'
                  ? 'Vérification externe'
                  : 'Marketplace',
              Icons.source,
            ),
          ],

          if (v['risk_level'] != null) ...[
            const SizedBox(height: 12),
            _buildInfoItem('Niveau de risque', v['risk_level'], Icons.warning),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoItem(
    String label,
    String value,
    IconData icon, {
    Color? color,
  }) {
    return Row(
      children: [
        Icon(icon, color: color ?? Colors.grey[500], size: 18),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: GoogleFonts.inter(fontSize: 11, color: Colors.grey[500]),
            ),
            Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: color ?? Colors.white,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMilestonesSection(Map<String, dynamic> v) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Jalons de vérification',
          style: GoogleFonts.outfit(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        ...[
          'J1 Validée',
          'J3 Admin',
          'J5 Coutumière',
          'J7 Voisinage',
          'J10 Rapport',
        ].map(
          (milestone) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A2E),
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: kPrimary.withOpacity(0.2),
                      border: Border.all(color: kPrimary),
                    ),
                    child: Icon(Icons.check, color: kPrimary, size: 14),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    milestone,
                    style: GoogleFonts.inter(fontSize: 13, color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDocumentsSection(Map<String, dynamic> v) {
    final documents = v['documents'] as List? ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Documents uploadés',
          style: GoogleFonts.outfit(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        if (documents.isEmpty)
          Center(
            child: Text(
              'Aucun document',
              style: GoogleFonts.inter(color: Colors.grey[500]),
            ),
          )
        else
          ...documents.map(
            (doc) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A2E),
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Icon(Icons.description, color: kPrimary, size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            doc['name'] ?? 'Document',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            doc['type'] ?? 'Type',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.download, color: kPrimary, size: 20),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildAdminActionsSection(Map<String, dynamic> v) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Actions admin',
          style: GoogleFonts.outfit(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),

        // Réassigner agent
        _buildActionCard(
          title: 'Réassigner un agent',
          subtitle: 'Agent actuel: ${v['agent_name'] ?? 'Non assigné'}',
          icon: Icons.person_add,
          onTap: () => _showReassignAgentDialog(v['id']),
        ),

        const SizedBox(height: 12),

        // Forcer changement de statut
        _buildActionCard(
          title: 'Forcer le changement de statut',
          subtitle: 'Statut actuel: ${v['status'] ?? 'Inconnu'}',
          icon: Icons.edit_note,
          onTap: () => _showChangeStatusDialog(v['id'], v['status']),
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A2E),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[800]!),
        ),
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                color: kPrimary.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.all(8),
              child: Icon(icon, color: kPrimary, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildReportSection(Map<String, dynamic> v) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Saisie du rapport de vérification',
          style: GoogleFonts.outfit(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A2E),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.amber, width: 1.5),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.info, color: Colors.amber, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Aucun rapport disponible. Cliquez pour saisir le rapport final.',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Colors.amber,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _showReportFormDialog(v['id']),
                  icon: const Icon(Icons.add),
                  label: const Text('Saisir le rapport'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                    foregroundColor: Colors.black,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ══════════════════════════════════════════════════════════════
  // Dialogs
  // ══════════════════════════════════════════════════════════════

  void _showReportFormDialog(String verificationId) {
    String? riskLevel;
    final verdictController = TextEditingController();
    final pointsPositivesController = TextEditingController();
    final pointsToVerifyController = TextEditingController();
    final terrain1Controller = TextEditingController();
    final terrain2Controller = TextEditingController();
    final terrain3Controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: const Color(0xFF1A1A2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: StatefulBuilder(
            builder: (context, setState) => Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Titre
                Text(
                  'Saisir le rapport final',
                  style: GoogleFonts.outfit(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),

                // Niveau de risque
                Text(
                  'Niveau de risque',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _buildRiskPill(
                        'Faible',
                        Colors.green,
                        () => setState(() => riskLevel = 'faible'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildRiskPill(
                        'Modéré',
                        Colors.orange,
                        () => setState(() => riskLevel = 'modere'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildRiskPill(
                        'Élevé',
                        Colors.red,
                        () => setState(() => riskLevel = 'eleve'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Verdict
                Text(
                  'Verdict (max 255 caractères)',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: verdictController,
                  maxLength: 255,
                  maxLines: 2,
                  style: GoogleFonts.inter(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Décrivez le verdict en une phrase...',
                    hintStyle: GoogleFonts.inter(color: Colors.grey[600]),
                    filled: true,
                    fillColor: Colors.grey[900],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    counterStyle: GoogleFonts.inter(color: Colors.grey[500]),
                  ),
                ),
                const SizedBox(height: 16),

                // Points positifs
                Text(
                  'Points positifs (une ligne = un point)',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: pointsPositivesController,
                  maxLines: 4,
                  style: GoogleFonts.inter(color: Colors.white),
                  decoration: InputDecoration(
                    hintText:
                        'Ex: Documents authentiques\nVisite terrain ok\nAucune objection...',
                    hintStyle: GoogleFonts.inter(color: Colors.grey[600]),
                    filled: true,
                    fillColor: Colors.grey[900],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Points à vérifier
                Text(
                  'Points à vérifier (une ligne = un point)',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: pointsToVerifyController,
                  maxLines: 4,
                  style: GoogleFonts.inter(color: Colors.white),
                  decoration: InputDecoration(
                    hintText:
                        'Ex: Signature du maire en attente\nCertificat d\'habitation...',
                    hintStyle: GoogleFonts.inter(color: Colors.grey[600]),
                    filled: true,
                    fillColor: Colors.grey[900],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Terrains alternatifs (si risque élevé)
                if (riskLevel == 'eleve') ...[
                  Text(
                    'Terrains alternatifs (jusqu\'à 3)',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: terrain1Controller,
                    style: GoogleFonts.inter(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Terrain alternatif 1 (optionnel)',
                      hintStyle: GoogleFonts.inter(color: Colors.grey[600]),
                      filled: true,
                      fillColor: Colors.grey[900],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: terrain2Controller,
                    style: GoogleFonts.inter(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Terrain alternatif 2 (optionnel)',
                      hintStyle: GoogleFonts.inter(color: Colors.grey[600]),
                      filled: true,
                      fillColor: Colors.grey[900],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: terrain3Controller,
                    style: GoogleFonts.inter(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Terrain alternatif 3 (optionnel)',
                      hintStyle: GoogleFonts.inter(color: Colors.grey[600]),
                      filled: true,
                      fillColor: Colors.grey[900],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Actions
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Annuler'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () async {
                        if (riskLevel == null ||
                            verdictController.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Veuillez remplir les champs obligatoires',
                              ),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }

                        try {
                          // Préparer les points positifs
                          final positivePoints = pointsPositivesController.text
                              .split('\n')
                              .where((p) => p.isNotEmpty)
                              .toList();

                          // Préparer les points à vérifier
                          final pointsToVerify = pointsToVerifyController.text
                              .split('\n')
                              .where((p) => p.isNotEmpty)
                              .toList();

                          // Préparer les terrains alternatifs
                          final alternativeTerrains = riskLevel == 'eleve'
                              ? [
                                  if (terrain1Controller.text.isNotEmpty)
                                    {'name': terrain1Controller.text},
                                  if (terrain2Controller.text.isNotEmpty)
                                    {'name': terrain2Controller.text},
                                  if (terrain3Controller.text.isNotEmpty)
                                    {'name': terrain3Controller.text},
                                ]
                              : [];

                          // Créer le rapport
                          await supabase.from('verification_reports').insert({
                            'verification_id': verificationId,
                            'risk_level': riskLevel,
                            'verdict': verdictController.text,
                            'positive_points': positivePoints,
                            'points_to_verify': pointsToVerify,
                            'alternative_terrains': alternativeTerrains,
                          });

                          // Mettre à jour la vérification
                          await supabase
                              .from('verifications')
                              .update({
                                'status': 'rapport_livre',
                                'risk_level': riskLevel,
                                'actual_delivery_at': DateTime.now()
                                    .toIso8601String(),
                              })
                              .eq('id', verificationId);

                          // Créer une notification pour le client
                          final verification = await supabase
                              .from('verifications')
                              .select('client_id')
                              .eq('id', verificationId)
                              .single();

                          await supabase.from('notifications').insert({
                            'user_id': verification['client_id'],
                            'title': 'Rapport disponible',
                            'message':
                                'Votre rapport de vérification est disponible.',
                            'type': 'report_delivered',
                            'related_id': verificationId,
                          });

                          if (mounted) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Rapport créé avec succès'),
                                backgroundColor: kSuccess,
                              ),
                            );
                            setState(() {});
                          }
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Erreur: $e'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kPrimary,
                      ),
                      child: const Text('Valider le rapport'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRiskPill(String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.2),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: color),
        ),
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ),
      ),
    );
  }

  void _showReassignAgentDialog(String verificationId) async {
    try {
      final agents = await supabase
          .from('users')
          .select('id, name')
          .eq('role', 'agent')
          .eq('is_available', true);

      if (!mounted) return;

      String? selectedAgentId;

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: const Color(0xFF1A1A2E),
          title: Text(
            'Réassigner un agent',
            style: GoogleFonts.outfit(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          content: StatefulBuilder(
            builder: (context, setState) => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Sélectionnez un agent disponible:',
                  style: GoogleFonts.inter(color: Colors.grey[300]),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.grey[900],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  dropdownColor: const Color(0xFF1A1A2E),
                  items: (agents as List)
                      .map<DropdownMenuItem<String>>((agent) {
                        final row = Map<String, dynamic>.from(agent as Map);
                        final agentId = row['id']?.toString() ?? '';
                        return DropdownMenuItem<String>(
                          value: agentId,
                          child: Text(
                            row['name']?.toString() ?? 'Inconnu',
                            style: GoogleFonts.inter(color: Colors.white),
                          ),
                        );
                      })
                      .where((item) => (item.value ?? '').isNotEmpty)
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedAgentId = value;
                    });
                  },
                  style: GoogleFonts.inter(color: Colors.white),
                  isExpanded: true,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (selectedAgentId != null) {
                  await supabase
                      .from('verifications')
                      .update({'agent_id': selectedAgentId})
                      .eq('id', verificationId);

                  if (mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Agent réassigné'),
                        backgroundColor: kSuccess,
                      ),
                    );
                    setState(() {});
                  }
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: kPrimary),
              child: const Text('Appliquer'),
            ),
          ],
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
      );
    }
  }

  void _showChangeStatusDialog(String verificationId, String currentStatus) {
    const statuses = ['recu', 'visite', 'autorites', 'rapport_livre'];
    String? selectedStatus = currentStatus;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        title: Text(
          'Forcer le statut',
          style: GoogleFonts.outfit(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        content: StatefulBuilder(
          builder: (context, setState) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Sélectionnez le nouveau statut:',
                style: GoogleFonts.inter(color: Colors.grey[300]),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: statuses
                    .map(
                      (status) => GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedStatus = status;
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: selectedStatus == status
                                ? kPrimary
                                : Colors.grey[800],
                            borderRadius: BorderRadius.circular(6),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          child: Text(
                            status.toUpperCase(),
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (selectedStatus != null && selectedStatus != currentStatus) {
                await supabase
                    .from('verifications')
                    .update({'status': selectedStatus})
                    .eq('id', verificationId);

                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Statut mis à jour'),
                      backgroundColor: kSuccess,
                    ),
                  );
                  setState(() {});
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: kPrimary),
            child: const Text('Confirmer'),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  // Supabase Queries
  // ══════════════════════════════════════════════════════════════

  Future<Map<String, dynamic>> _fetchVerificationDetail() async {
    try {
      final response = await supabase
          .from('verifications')
          .select(
            'id, client_name, terrain_location, status, submitted_at, expected_delivery_at, agent_id, source, risk_level, agents(name)',
          )
          .eq('id', widget.verificationId)
          .single();

      // Fetcher des documents liés
      final documents = await supabase
          .from('verification_documents')
          .select('id, name, type, file_url')
          .eq('verification_id', widget.verificationId);

      return {
        ...response,
        'agent_name': response['agents']?['name'] ?? 'N/A',
        'documents': documents,
      };
    } catch (e) {
      return {};
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'recu':
        return Colors.blue;
      case 'visite':
        return Colors.orange;
      case 'autorites':
        return Colors.purple;
      case 'rapport_livre':
        return kSuccess;
      default:
        return Colors.grey;
    }
  }
}
