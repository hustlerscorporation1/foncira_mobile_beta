// ══════════════════════════════════════════════════════════════
//  FONCIRA — Agent Sources Collection
//  Collecte de données auprès des sources humaines terrain
// ══════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:foncira/theme/colors.dart';
import 'package:google_fonts/google_fonts.dart';
import 'source_detail_screen.dart';

// ──────────────────────────────────────────────────────────────
//  Modèle de données Source
// ──────────────────────────────────────────────────────────────

class SourceEntry {
  final String id;
  final String sourceType; // Chef coutumier, Vendeur, Voisin, Géomètre, Autre
  String nom; // Modifiable localement pour édition
  String role; // Auto-rempli selon type
  String resumeDiscussion;
  final List<String> audioPaths;
  final Map<String, List<String>> photoPaths; // type: [paths]
  DateTime createdAt;

  SourceEntry({
    required this.id,
    required this.sourceType,
    required this.nom,
    this.role = '',
    this.resumeDiscussion = '',
    List<String>? audioPaths,
    Map<String, List<String>>? photoPaths,
  }) : audioPaths = audioPaths ?? [],
       photoPaths =
           photoPaths ??
           {'terrain': [], 'documents': [], 'bornage': [], 'quartier': []},
       createdAt = DateTime.now();

  // Auto-remplir le rôle selon le type
  void updateRoleFromType() {
    final roleMap = {
      'Chef coutumier': 'Autorité coutumière',
      'Vendeur': 'Vendeur du terrain',
      'Voisin': 'Voisin proche',
      'Géomètre': 'Expert géomètre',
      'Autre': 'Source locale',
    };
    role = roleMap[sourceType] ?? 'Source';
  }
}

// ──────────────────────────────────────────────────────────────
//  Écran Principal
// ──────────────────────────────────────────────────────────────

class AgentSourcesCollection extends StatefulWidget {
  final Map<String, dynamic> mission;

  const AgentSourcesCollection({required this.mission, super.key});

  @override
  State<AgentSourcesCollection> createState() => _AgentSourcesCollectionState();
}

class _AgentSourcesCollectionState extends State<AgentSourcesCollection> {
  late List<SourceEntry> _sources = [];
  late bool _isSubmitted = false;
  final List<String> _sourceTypes = [
    'Chef coutumier',
    'Vendeur',
    'Voisin',
    'Géomètre',
    'Autre',
  ];

  @override
  void initState() {
    super.initState();
    // Initialiser avec une liste vide
    _sources = [];
    _isSubmitted = false;
  }

  // Soumettre la collecte
  Future<void> _submitCollection() async {
    if (_isSubmitted || _sources.isEmpty) return;

    try {
      // Afficher un dialogue de confirmation
      final confirmed =
          await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              backgroundColor: const Color(0xFF1E1E2E),
              title: Text(
                'Soumettre la collecte',
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: Text(
                'Vous êtes sur le point de soumettre ${_sources.length} source(s) pour analyse. Vous ne pourrez plus les modifier après envoi.',
                style: GoogleFonts.outfit(color: const Color(0xFFB0B0B0)),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: Text(
                    'Annuler',
                    style: GoogleFonts.outfit(color: Colors.white),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: Text(
                    'Soumettre',
                    style: GoogleFonts.outfit(color: kPrimary),
                  ),
                ),
              ],
            ),
          ) ??
          false;

      if (!confirmed) return;

      // Marquer comme soumis
      setState(() {
        _isSubmitted = true;
      });

      // TODO: Sauvegarder les sources + changer statut mission à "Collecte envoyée"
      // Les sources contiennent:
      // - nom, sourceType, role, resumeDiscussion
      // - audioPaths (liste de fichiers audio)
      // - photoPaths (dict par catégorie: terrain, documents, bornage, quartier)
      // Pour cette MVP: on simule l'envoi

      // Afficher message de succès
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Vos données ont été envoyées à l\'équipe FONCIRA pour analyse.',
              style: GoogleFonts.outfit(color: Colors.white),
            ),
            backgroundColor: Colors.green[700],
            duration: const Duration(seconds: 2),
          ),
        );

        // Attendre et retourner au dashboard
        await Future.delayed(const Duration(seconds: 2));
        if (mounted) {
          Navigator.pop(context);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: Colors.red[700],
          ),
        );
        setState(() {
          _isSubmitted = false;
        });
      }
    }
  }

  // Ajouter une nouvelle source
  void _addSource() {
    if (_isSubmitted) return; // Lecture seule après soumission
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E2E),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => _AddSourceForm(
        sourceTypes: _sourceTypes,
        onAdd: (sourceType, nom) {
          final newSource = SourceEntry(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            sourceType: sourceType,
            nom: nom,
          );
          newSource.updateRoleFromType();

          setState(() {
            _sources.add(newSource);
          });
          Navigator.pop(context);
        },
      ),
    );
  }

  // Modifier une source
  void _editSource(SourceEntry source) {
    if (_isSubmitted) return; // Lecture seule après soumission
    Navigator.push<SourceEntry>(
      context,
      MaterialPageRoute(
        builder: (context) => SourceDetailScreen(source: source),
      ),
    ).then((updatedSource) {
      if (updatedSource != null) {
        setState(() {
          final index = _sources.indexWhere((s) => s.id == updatedSource.id);
          if (index != -1) {
            _sources[index] = updatedSource;
          }
        });
      }
    });
  }

  // Supprimer une source
  void _deleteSource(String sourceId) {
    if (_isSubmitted) return; // Lecture seule après soumission
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E2E),
        title: Text(
          'Supprimer la source',
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Êtes-vous sûr de vouloir supprimer cette source ?',
          style: GoogleFonts.outfit(color: const Color(0xFFB0B0B0)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Annuler',
              style: GoogleFonts.outfit(color: Colors.white),
            ),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _sources.removeWhere((s) => s.id == sourceId);
              });
              Navigator.pop(context);
            },
            child: Text(
              'Supprimer',
              style: GoogleFonts.outfit(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.mission['terrain_title'] ?? 'Collecte de sources';

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F0F1E),
        elevation: 0,
        title: Text(
          'Sources collectées',
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
          // Contenu principal
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
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Sources: ${_sources.length}',
                              style: GoogleFonts.outfit(
                                fontSize: 12,
                                color: const Color(0xFF7A7A8E),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Liste des sources
                if (_sources.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 32),
                      child: Column(
                        children: [
                          Icon(
                            Icons.people_outline,
                            size: 48,
                            color: const Color(0xFF4A4A5E),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Aucune source collectée',
                            style: GoogleFonts.outfit(
                              fontSize: 14,
                              color: const Color(0xFF7A7A8E),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  Column(
                    children: _sources.map((source) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _SourceCard(
                          source: source,
                          onEdit: () => _editSource(source),
                          onDelete: () => _deleteSource(source.id),
                          readOnly: _isSubmitted,
                        ),
                      );
                    }).toList(),
                  ),

                const SizedBox(height: 80), // Espace pour le bouton flottant
              ],
            ),
          ),

          // Bouton d'action flottant (bas)
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: Column(
              children: [
                // Bouton "Ajouter une source"
                if (!_isSubmitted)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _addSource,
                      icon: const Icon(Icons.add),
                      label: Text(
                        'Ajouter une source',
                        style: GoogleFonts.outfit(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kPrimary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                if (!_isSubmitted) const SizedBox(height: 8),

                // Bouton "Soumettre la collecte"
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: (_sources.isEmpty || _isSubmitted)
                        ? null
                        : _submitCollection,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isSubmitted
                          ? Colors.grey[700]
                          : kPrimary,
                      disabledBackgroundColor: Colors.grey[800],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      _isSubmitted
                          ? 'Collecte envoyée'
                          : 'Soumettre la collecte',
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
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────
//  Carte Source
// ──────────────────────────────────────────────────────────────

class _SourceCard extends StatelessWidget {
  final SourceEntry source;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final bool readOnly;

  const _SourceCard({
    required this.source,
    required this.onEdit,
    required this.onDelete,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E2E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF2D2D3F), width: 1),
      ),
      child: Column(
        children: [
          // En-tête carte
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          source.nom,
                          style: GoogleFonts.outfit(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: kPrimary.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            source.sourceType,
                            style: GoogleFonts.outfit(
                              fontSize: 11,
                              color: kPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (!readOnly)
                      PopupMenuButton(
                        color: const Color(0xFF1E1E2E),
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            onTap: onEdit,
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.edit,
                                  size: 18,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Modifier',
                                  style: GoogleFonts.outfit(
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            onTap: onDelete,
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.delete,
                                  size: 18,
                                  color: Colors.red,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Supprimer',
                                  style: GoogleFonts.outfit(color: Colors.red),
                                ),
                              ],
                            ),
                          ),
                        ],
                        child: Icon(
                          Icons.more_vert,
                          color: const Color(0xFF7A7A8E),
                        ),
                      )
                    else
                      Icon(
                        Icons.lock_outline,
                        color: const Color(0xFF5A5A6E),
                        size: 20,
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Rôle: ${source.role}',
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    color: const Color(0xFF7A7A8E),
                  ),
                ),
              ],
            ),
          ),

          // Sections de contenu
          if (source.audioPaths.isNotEmpty)
            _SourceSection(
              title: 'Audio conversations',
              count: source.audioPaths.length,
              icon: Icons.mic_none,
            ),

          if (source.resumeDiscussion.isNotEmpty)
            _SourceSection(
              title: 'Résumé discussion',
              icon: Icons.description_outlined,
              preview: source.resumeDiscussion.substring(
                0,
                (source.resumeDiscussion.length > 50
                    ? 50
                    : source.resumeDiscussion.length),
              ),
            ),

          if (source.photoPaths.values.any((photos) => photos.isNotEmpty))
            _SourceSection(
              title: 'Photos',
              count: source.photoPaths.values.fold(
                0,
                (sum, photos) => (sum as int) + photos.length,
              ),
              icon: Icons.image_outlined,
            ),

          // Pied de page
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Text(
              'Ajoutée: ${source.createdAt.day}/${source.createdAt.month}/${source.createdAt.year}',
              style: GoogleFonts.outfit(
                fontSize: 10,
                color: const Color(0xFF5A5A6E),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────
//  Section Source (pour afficher les sous-éléments)
// ──────────────────────────────────────────────────────────────

class _SourceSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final int? count;
  final String? preview;

  const _SourceSection({
    required this.title,
    required this.icon,
    this.count,
    this.preview,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: const Color(0xFF2D2D3F), width: 1),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Icon(icon, size: 16, color: const Color(0xFF7A7A8E)),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF7A7A8E),
                  ),
                ),
                if (preview != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    preview!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.outfit(
                      fontSize: 11,
                      color: const Color(0xFF5A5A6E),
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (count != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: kPrimary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                count.toString(),
                style: GoogleFonts.outfit(
                  fontSize: 10,
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

// ──────────────────────────────────────────────────────────────
//  Formulaire Ajouter Source
// ──────────────────────────────────────────────────────────────

class _AddSourceForm extends StatefulWidget {
  final List<String> sourceTypes;
  final Function(String, String) onAdd;

  const _AddSourceForm({required this.sourceTypes, required this.onAdd});

  @override
  State<_AddSourceForm> createState() => _AddSourceFormState();
}

class _AddSourceFormState extends State<_AddSourceForm> {
  String? _selectedType;
  final _nomController = TextEditingController();

  @override
  void dispose() {
    _nomController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ajouter une source',
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),

            // Type de source
            Text(
              'Type de source',
              style: GoogleFonts.outfit(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF7A7A8E),
              ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedType,
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFF0F0F1E),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFF2D2D3F)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFF2D2D3F)),
                ),
              ),
              dropdownColor: const Color(0xFF1E1E2E),
              items: widget.sourceTypes
                  .map(
                    (type) => DropdownMenuItem(
                      value: type,
                      child: Text(
                        type,
                        style: GoogleFonts.outfit(color: Colors.white),
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedType = value;
                });
              },
              style: GoogleFonts.outfit(color: Colors.white, fontSize: 14),
            ),
            const SizedBox(height: 20),

            // Nom
            Text(
              'Nom de la source',
              style: GoogleFonts.outfit(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF7A7A8E),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _nomController,
              style: GoogleFonts.outfit(color: Colors.white, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Entrez le nom de la source',
                hintStyle: GoogleFonts.outfit(color: const Color(0xFF5A5A6E)),
                filled: true,
                fillColor: const Color(0xFF0F0F1E),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFF2D2D3F)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFF2D2D3F)),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Boutons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: const BorderSide(color: Color(0xFF2D2D3F)),
                    ),
                    child: Text(
                      'Annuler',
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed:
                        _selectedType == null || _nomController.text.isEmpty
                        ? null
                        : () {
                            widget.onAdd(
                              _selectedType!,
                              _nomController.text.trim(),
                            );
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kPrimary,
                      disabledBackgroundColor: Colors.grey[700],
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(
                      'Ajouter',
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
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
}
