// ══════════════════════════════════════════════════════════════
//  FONCIRA — Source Detail Collector
//  Gestion détaillée d'une source avec audio, résumé, et photos
// ══════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:foncira/theme/colors.dart';
import 'package:google_fonts/google_fonts.dart';

// Import du modèle
import 'agent_sources_collection.dart';

// ──────────────────────────────────────────────────────────────
//  Écran Détail Source
// ──────────────────────────────────────────────────────────────

class SourceDetailScreen extends StatefulWidget {
  final SourceEntry source;

  const SourceDetailScreen({required this.source, super.key});

  @override
  State<SourceDetailScreen> createState() => _SourceDetailScreenState();
}

class _SourceDetailScreenState extends State<SourceDetailScreen> {
  late SourceEntry _source;
  late TextEditingController _resumeController;
  late TextEditingController _nomController;

  bool _isRecording = false;
  String? _currentAudioPath;

  final List<String> _photoCategories = [
    'terrain',
    'documents',
    'bornage',
    'quartier',
  ];

  @override
  void initState() {
    super.initState();
    _source = widget.source;
    _resumeController = TextEditingController(text: _source.resumeDiscussion);
    _nomController = TextEditingController(text: _source.nom);
  }

  @override
  void dispose() {
    _resumeController.dispose();
    _nomController.dispose();
    super.dispose();
  }

  // Simuler l'enregistrement audio
  void _toggleAudioRecording() {
    setState(() {
      _isRecording = !_isRecording;
      if (!_isRecording) {
        // Simuler un fichier audio créé
        _currentAudioPath =
            'audio_${DateTime.now().millisecondsSinceEpoch}.m4a';
      }
    });
  }

  // Ajouter un enregistrement audio
  void _addAudioRecording() {
    if (_currentAudioPath != null &&
        !_source.audioPaths.contains(_currentAudioPath)) {
      setState(() {
        _source.audioPaths.add(_currentAudioPath!);
        _currentAudioPath = null;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Enregistrement ajouté')));
    }
  }

  // Supprimer un enregistrement audio
  void _removeAudioRecording(String audioPath) {
    setState(() {
      _source.audioPaths.remove(audioPath);
    });
  }

  // Simuler l'ajout de photos
  void _addPhotos(String category) {
    // Simuler l'ajout de 2-3 photos
    final newPhotos = List.generate(
      (DateTime.now().millisecond % 3) + 1,
      (i) =>
          'photo_${category}_${DateTime.now().millisecondsSinceEpoch}_$i.jpg',
    );
    setState(() {
      _source.photoPaths[category]!.addAll(newPhotos);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${newPhotos.length} photo(s) ajoutée(s)')),
    );
  }

  // Supprimer une photo
  void _removePhoto(String category, String photoPath) {
    setState(() {
      _source.photoPaths[category]!.remove(photoPath);
    });
  }

  // Sauvegarder les modifications
  void _saveSource() {
    _source.nom = _nomController.text.trim();
    _source.resumeDiscussion = _resumeController.text.trim();
    Navigator.pop(context, _source);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F0F1E),
        elevation: 0,
        title: Text(
          'Éditer source',
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
        actions: [
          IconButton(
            icon: const Icon(Icons.check, color: kPrimary),
            onPressed: _saveSource,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ───────────────────────────────────────────
            // Section 1 : Informations de base
            // ───────────────────────────────────────────
            _buildSectionHeader('Informations'),
            const SizedBox(height: 12),

            // Nom
            _buildFormField(
              label: 'Nom',
              controller: _nomController,
              hint: 'Nom de la source',
            ),
            const SizedBox(height: 12),

            // Rôle (lecture seule)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E2E),
                border: Border.all(color: const Color(0xFF2D2D3F)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Rôle',
                    style: GoogleFonts.outfit(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF7A7A8E),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _source.role,
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Type (lecture seule)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E2E),
                border: Border.all(color: const Color(0xFF2D2D3F)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Type de source',
                    style: GoogleFonts.outfit(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF7A7A8E),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _source.sourceType,
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ───────────────────────────────────────────
            // Section 2 : Audio Conversation
            // ───────────────────────────────────────────
            _buildSectionHeader('Audio Conversation'),
            const SizedBox(height: 12),

            // Contrôles d'enregistrement
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E2E),
                border: Border.all(color: const Color(0xFF2D2D3F)),
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Boutons enregistrer/arrêter
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton.icon(
                        onPressed: _toggleAudioRecording,
                        icon: Icon(
                          _isRecording ? Icons.stop : Icons.mic,
                          color: Colors.white,
                        ),
                        label: Text(
                          _isRecording ? 'Arrêter' : 'Enregistrer',
                          style: GoogleFonts.outfit(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isRecording ? Colors.red : kPrimary,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                      ),
                      if (_currentAudioPath != null) ...[
                        const SizedBox(width: 12),
                        ElevatedButton.icon(
                          onPressed: _addAudioRecording,
                          icon: const Icon(Icons.add),
                          label: Text(
                            'Ajouter',
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),

                  if (_isRecording) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.fiber_manual_record,
                            size: 8,
                            color: Colors.red,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Enregistrement en cours...',
                            style: GoogleFonts.outfit(
                              fontSize: 12,
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Liste des enregistrements
            if (_source.audioPaths.isNotEmpty)
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E2E),
                  border: Border.all(color: const Color(0xFF2D2D3F)),
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Enregistrements (${_source.audioPaths.length})',
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF7A7A8E),
                      ),
                    ),
                    const SizedBox(height: 8),
                    ..._source.audioPaths.asMap().entries.map((entry) {
                      final index = entry.key;
                      final audioPath = entry.value;
                      return _AudioItem(
                        index: index + 1,
                        audioPath: audioPath,
                        onRemove: () => _removeAudioRecording(audioPath),
                      );
                    }).toList(),
                  ],
                ),
              )
            else
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E2E),
                  border: Border.all(
                    color: const Color(0xFF2D2D3F),
                    style: BorderStyle.solid,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 24,
                ),
                child: Center(
                  child: Text(
                    'Aucun enregistrement',
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      color: const Color(0xFF5A5A6E),
                    ),
                  ),
                ),
              ),

            const SizedBox(height: 24),

            // ───────────────────────────────────────────
            // Section 3 : Résumé Discussion
            // ───────────────────────────────────────────
            _buildSectionHeader('Résumé Discussion'),
            const SizedBox(height: 12),

            TextField(
              controller: _resumeController,
              maxLines: 5,
              maxLength: 800,
              style: GoogleFonts.outfit(color: Colors.white, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Résumé des informations collectées...',
                hintStyle: GoogleFonts.outfit(color: const Color(0xFF5A5A6E)),
                filled: true,
                fillColor: const Color(0xFF1E1E2E),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFF2D2D3F)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFF2D2D3F)),
                ),
                counterStyle: GoogleFonts.outfit(
                  color: const Color(0xFF5A5A6E),
                  fontSize: 10,
                ),
              ),
            ),

            const SizedBox(height: 24),

            // ───────────────────────────────────────────
            // Section 4 : Photos
            // ───────────────────────────────────────────
            _buildSectionHeader('Photos'),
            const SizedBox(height: 12),

            ..._photoCategories.map((category) {
              final photos = _source.photoPaths[category] ?? [];
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _PhotoCategorySection(
                  category: category,
                  photos: photos,
                  onAdd: () => _addPhotos(category),
                  onRemove: (photoPath) => _removePhoto(category, photoPath),
                ),
              );
            }).toList(),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  // Construire un en-tête de section
  Widget _buildSectionHeader(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.outfit(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 2,
          width: 30,
          decoration: BoxDecoration(
            color: kPrimary,
            borderRadius: BorderRadius.circular(1),
          ),
        ),
      ],
    );
  }

  // Construire un champ de formulaire
  Widget _buildFormField({
    required String label,
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.outfit(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF7A7A8E),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          style: GoogleFonts.outfit(color: Colors.white, fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.outfit(color: const Color(0xFF5A5A6E)),
            filled: true,
            fillColor: const Color(0xFF1E1E2E),
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
      ],
    );
  }
}

// ──────────────────────────────────────────────────────────────
//  Item Audio
// ──────────────────────────────────────────────────────────────

class _AudioItem extends StatefulWidget {
  final int index;
  final String audioPath;
  final VoidCallback onRemove;

  const _AudioItem({
    required this.index,
    required this.audioPath,
    required this.onRemove,
  });

  @override
  State<_AudioItem> createState() => _AudioItemState();
}

class _AudioItemState extends State<_AudioItem> {
  bool _isPlaying = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF0F0F1E),
          border: Border.all(color: const Color(0xFF2D2D3F)),
          borderRadius: BorderRadius.circular(6),
        ),
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            IconButton(
              icon: Icon(
                _isPlaying ? Icons.pause : Icons.play_arrow,
                color: kPrimary,
                size: 20,
              ),
              onPressed: () {
                setState(() {
                  _isPlaying = !_isPlaying;
                });
              },
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Enregistrement ${widget.index}',
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    widget.audioPath,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.outfit(
                      fontSize: 10,
                      color: const Color(0xFF5A5A6E),
                    ),
                  ),
                  if (_isPlaying)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: LinearProgressIndicator(
                        value: 0.65,
                        backgroundColor: const Color(0xFF2D2D3F),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          kPrimary.withOpacity(0.5),
                        ),
                        minHeight: 2,
                      ),
                    ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(
                Icons.delete_outline,
                color: Colors.red,
                size: 18,
              ),
              onPressed: widget.onRemove,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            ),
          ],
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────
//  Section Catégorie Photo
// ──────────────────────────────────────────────────────────────

class _PhotoCategorySection extends StatelessWidget {
  final String category;
  final List<String> photos;
  final VoidCallback onAdd;
  final Function(String) onRemove;

  const _PhotoCategorySection({
    required this.category,
    required this.photos,
    required this.onAdd,
    required this.onRemove,
  });

  String _getCategoryLabel(String category) {
    final labels = {
      'terrain': 'Photos du terrain',
      'documents': 'Documents',
      'bornage': 'Bornage',
      'quartier': 'Vues du quartier',
    };
    return labels[category] ?? category;
  }

  IconData _getCategoryIcon(String category) {
    final icons = {
      'terrain': Icons.landscape_outlined,
      'documents': Icons.description_outlined,
      'bornage': Icons.category_outlined,
      'quartier': Icons.grid_view_outlined,
    };
    return icons[category] ?? Icons.image_outlined;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E2E),
        border: Border.all(color: const Color(0xFF2D2D3F)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          // En-tête catégorie
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(_getCategoryIcon(category), size: 18, color: kPrimary),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getCategoryLabel(category),
                          style: GoogleFonts.outfit(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          '${photos.length} photo(s)',
                          style: GoogleFonts.outfit(
                            fontSize: 10,
                            color: const Color(0xFF5A5A6E),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline, color: kPrimary),
                  onPressed: onAdd,
                  iconSize: 20,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 32,
                    minHeight: 32,
                  ),
                ),
              ],
            ),
          ),

          // Liste des photos
          if (photos.isNotEmpty)
            Container(
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: const Color(0xFF2D2D3F))),
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.all(8),
                child: Row(
                  children: photos.map((photoPath) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: _PhotoThumbnail(
                        photoPath: photoPath,
                        onDelete: () => onRemove(photoPath),
                      ),
                    );
                  }).toList(),
                ),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                'Aucune photo',
                style: GoogleFonts.outfit(
                  fontSize: 11,
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
//  Miniature Photo
// ──────────────────────────────────────────────────────────────

class _PhotoThumbnail extends StatelessWidget {
  final String photoPath;
  final VoidCallback onDelete;

  const _PhotoThumbnail({required this.photoPath, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: const Color(0xFF0F0F1E),
            border: Border.all(color: const Color(0xFF2D2D3F)),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.image_outlined,
                size: 32,
                color: kPrimary.withOpacity(0.3),
              ),
              const SizedBox(height: 4),
              Text(
                'Photo',
                style: GoogleFonts.outfit(
                  fontSize: 8,
                  color: const Color(0xFF5A5A6E),
                ),
              ),
            ],
          ),
        ),
        Positioned(
          top: 0,
          right: 0,
          child: GestureDetector(
            onTap: onDelete,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(2),
              child: const Icon(Icons.close, size: 12, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}
