// ══════════════════════════════════════════════════════════════
//  FONCIRA — Agent Mission Sources Collection
//  Écran de démarrage de la collecte auprès des sources locales
// ══════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:foncira/theme/colors.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:foncira/services/agent_service.dart';

class AgentMissionSources extends StatefulWidget {
  final Map<String, dynamic> mission;
  final AgentService agentService;

  const AgentMissionSources({
    required this.mission,
    required this.agentService,
    super.key,
  });

  @override
  State<AgentMissionSources> createState() => _AgentMissionSourcesState();
}

class _AgentMissionSourcesState extends State<AgentMissionSources> {
  late Map<String, dynamic> _mission;
  int _currentStep = 0; // 0: Permissions, 1: Sources, 2: Evidence
  bool _isLoading = false;

  // Source data
  final List<bool> _sourceSelected = [false, false, false, false];
  final List<String> _sourceTypes = [
    'Propriétaire du terrain',
    'Voisins proches',
    'Autorités locales',
    'Autres',
  ];

  // Evidence photo paths
  final List<String> _photoPaths = [];

  @override
  void initState() {
    super.initState();
    _mission = widget.mission;
  }

  @override
  Widget build(BuildContext context) {
    final title = _mission['terrain_title'] ?? 'Mission de collecte';

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F0F1E),
        elevation: 0,
        title: Text(
          'Collecte mission',
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
          // Contenu scrollable avec étapes
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // En-tête mission
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
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 24,
                        color: kPrimary,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: GoogleFonts.outfit(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Prêt à collecter les données',
                              style: GoogleFonts.outfit(
                                fontSize: 12,
                                color: const Color(0xFF6B6B7F),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Indicateur de progression (steps)
                _buildProgressIndicator(),
                const SizedBox(height: 24),

                // Contenu selon l'étape actuelle
                if (_currentStep == 0)
                  _buildStep0Permissions()
                else if (_currentStep == 1)
                  _buildStep1Sources()
                else if (_currentStep == 2)
                  _buildStep2Evidence(),

                // Spacing pour le bouton fixe en bas
                const SizedBox(height: 100),
              ],
            ),
          ),

          // Boutons d'action en bas
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
              child: Column(
                children: [
                  // Navigation buttons
                  if (_currentStep > 0)
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () =>
                            setState(() => _currentStep = _currentStep - 1),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(
                            color: Color(0xFF2D2D3F),
                            width: 1,
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          'Précédent',
                          style: GoogleFonts.outfit(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFFB0B0B0),
                          ),
                        ),
                      ),
                    ),
                  if (_currentStep > 0) const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleNextStep,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kPrimary,
                        foregroundColor: Colors.black,
                        disabledBackgroundColor: kPrimary.withOpacity(0.5),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: _isLoading
                          ? SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.black,
                                ),
                              ),
                            )
                          : Text(
                              _currentStep == 2
                                  ? 'Terminer la collecte'
                                  : 'Continuer',
                              style: GoogleFonts.outfit(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build progress indicator
  Widget _buildProgressIndicator() {
    return Row(
      children: List.generate(3, (index) {
        final isActive = index == _currentStep;
        final isCompleted = index < _currentStep;

        return Expanded(
          child: Column(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isActive || isCompleted
                      ? kPrimary
                      : const Color(0xFF2D2D3F),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isActive ? kPrimary : const Color(0xFF2D2D3F),
                    width: 2,
                  ),
                ),
                child: Center(
                  child: isCompleted
                      ? Icon(Icons.check, size: 20, color: Colors.black)
                      : Text(
                          '${index + 1}',
                          style: GoogleFonts.outfit(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isActive || isCompleted
                                ? Colors.black
                                : const Color(0xFF6B6B7F),
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _getStepTitle(index),
                style: GoogleFonts.outfit(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: isActive || isCompleted
                      ? kPrimary
                      : const Color(0xFF6B6B7F),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      }),
    );
  }

  /// Get step title
  String _getStepTitle(int index) {
    switch (index) {
      case 0:
        return 'Autorisations';
      case 1:
        return 'Sources';
      case 2:
        return 'Preuves';
      default:
        return '';
    }
  }

  /// Build step 0 - Permissions
  Widget _buildStep0Permissions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E2E),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF2D2D3F), width: 1),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.info_outline, size: 20, color: Colors.blue),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Autorisations nécessaires',
                      style: GoogleFonts.outfit(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildPermissionCheckItem(
                title: 'Accès à la localisation',
                description: 'Pour enregistrer les coordonnées GPS',
                icon: Icons.location_on_outlined,
              ),
              const SizedBox(height: 12),
              _buildPermissionCheckItem(
                title: 'Accès à la caméra',
                description: 'Pour prendre des photos des preuves',
                icon: Icons.camera_alt_outlined,
              ),
              const SizedBox(height: 12),
              _buildPermissionCheckItem(
                title: 'Accès aux contacts',
                description: 'Pour noter les informations des sources',
                icon: Icons.contacts_outlined,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.green.withOpacity(0.3), width: 1),
          ),
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(
                Icons.check_circle_outline,
                size: 20,
                color: Colors.green.withOpacity(0.7),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Tous les autorisations sont accordées',
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    color: Colors.green.withOpacity(0.7),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Build step 1 - Sources
  Widget _buildStep1Sources() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Sélectionnez les sources consultées',
          style: GoogleFonts.outfit(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        Column(
          children: List.generate(_sourceTypes.length, (index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: GestureDetector(
                onTap: () {
                  setState(
                    () => _sourceSelected[index] = !_sourceSelected[index],
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1E2E),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _sourceSelected[index]
                          ? kPrimary
                          : const Color(0xFF2D2D3F),
                      width: 2,
                    ),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: _sourceSelected[index]
                              ? kPrimary
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: _sourceSelected[index]
                                ? kPrimary
                                : const Color(0xFF2D2D3F),
                            width: 2,
                          ),
                        ),
                        child: _sourceSelected[index]
                            ? Icon(Icons.check, size: 16, color: Colors.black)
                            : null,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _sourceTypes[index],
                          style: GoogleFonts.outfit(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  /// Build step 2 - Evidence
  Widget _buildStep2Evidence() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Collectez les preuves (photos)',
          style: GoogleFonts.outfit(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: _isLoading ? null : _addPhoto,
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E2E),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: kPrimary,
                width: 2,
                style: BorderStyle.solid,
              ),
            ),
            padding: const EdgeInsets.all(32),
            child: Column(
              children: [
                Icon(Icons.add_a_photo_outlined, size: 40, color: kPrimary),
                const SizedBox(height: 12),
                Text(
                  'Ajouter une photo',
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: kPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${_photoPaths.length} photo(s) ajoutée(s)',
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    color: const Color(0xFF6B6B7F),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (_photoPaths.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text(
            'Photos ajoutées',
            style: GoogleFonts.outfit(
              fontSize: 12,
              color: const Color(0xFF6B6B7F),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _photoPaths.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Container(
                    width: 100,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1E2E),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: const Color(0xFF2D2D3F),
                        width: 1,
                      ),
                    ),
                    child: Stack(
                      children: [
                        Center(
                          child: Icon(
                            Icons.image_outlined,
                            size: 40,
                            color: const Color(0xFF6B6B7F),
                          ),
                        ),
                        Positioned(
                          top: 4,
                          right: 4,
                          child: GestureDetector(
                            onTap: () {
                              setState(() => _photoPaths.removeAt(index));
                            },
                            child: Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.close,
                                size: 14,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ],
    );
  }

  /// Build permission check item
  Widget _buildPermissionCheckItem({
    required String title,
    required String description,
    required IconData icon,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: kPrimary.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 20, color: kPrimary),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.outfit(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: GoogleFonts.outfit(
                  fontSize: 11,
                  color: const Color(0xFF6B6B7F),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Icon(Icons.check_circle, size: 20, color: Colors.green),
      ],
    );
  }

  /// Handle next step button
  void _handleNextStep() async {
    setState(() => _isLoading = true);

    try {
      // Simulate processing
      await Future.delayed(const Duration(seconds: 1));

      if (_currentStep == 2) {
        // Final submission
        if (mounted) {
          _showSubmitDialog();
        }
      } else {
        // Move to next step
        if (mounted) {
          setState(() => _currentStep = _currentStep + 1);
        }
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  /// Add photo simulated action
  void _addPhoto() {
    setState(() => _photoPaths.add('photo_${_photoPaths.length + 1}.jpg'));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Photo ajoutée', style: GoogleFonts.outfit(fontSize: 12)),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  /// Show submit dialog
  void _showSubmitDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E2E),
        title: Text(
          'Confirmation',
          style: GoogleFonts.outfit(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        content: Text(
          'Collecte des données terminée avec succès.\n\n'
          'Vos données seront envoyées pour vérification.',
          style: GoogleFonts.outfit(
            fontSize: 13,
            color: const Color(0xFFB0B0B0),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Continuer',
              style: GoogleFonts.outfit(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: kPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
