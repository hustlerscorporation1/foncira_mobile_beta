// ══════════════════════════════════════════════════════════════
//  FONCIRA — Add Terrain Dialog (Admin)
// ══════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:foncira/theme/colors.dart';
import 'package:foncira/services/supabase_service.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class AdminAddTerrainDialog extends StatefulWidget {
  final VoidCallback onTerrainCreated;

  const AdminAddTerrainDialog({super.key, required this.onTerrainCreated});

  @override
  State<AdminAddTerrainDialog> createState() => _AdminAddTerrainDialogState();
}

class _AdminAddTerrainDialogState extends State<AdminAddTerrainDialog> {
  final supabase = SupabaseService().client;

  // Form fields
  final _titleController = TextEditingController();
  final _priceController = TextEditingController();
  final _areaSqmController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _sellersNotesController = TextEditingController();

  String _selectedCity = 'Lomé';
  String _selectedDocumentType = 'titre_foncier';
  String _selectedStatus = 'draft';

  File? _selectedImage;
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _priceController.dispose();
    _areaSqmController.dispose();
    _descriptionController.dispose();
    _sellersNotesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF1A1A2E),
      insetPadding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Ajouter un nouveau terrain',
                style: GoogleFonts.outfit(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 24),

              // Photo upload
              _buildPhotoSection(),
              const SizedBox(height: 20),

              // Formulaire
              _buildFormSection(),

              const SizedBox(height: 24),

              // Boutons actions
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _isLoading ? null : () => Navigator.pop(context),
                    child: const Text('Annuler'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _handleSaveFromAsync,
                    style: ElevatedButton.styleFrom(backgroundColor: kPrimary),
                    child: _isLoading
                        ? SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : const Text('Créer le terrain'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPhotoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Photo principale',
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey[400],
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _pickImage,
          child: Container(
            height: 150,
            decoration: BoxDecoration(
              color: const Color(0xFF0F0F1E),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[700]!),
              image: _selectedImage != null
                  ? DecorationImage(
                      image: FileImage(_selectedImage!),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: _selectedImage == null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.image_not_supported,
                          color: Colors.grey[600],
                          size: 32,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Cliquer pour uploader une photo',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  )
                : null,
          ),
        ),
      ],
    );
  }

  Widget _buildFormSection() {
    return Column(
      children: [
        // Titre
        _buildTextField(
          label: 'Titre du terrain',
          controller: _titleController,
          hint: 'ex: Tokoin 500m² avec terrasse',
        ),
        const SizedBox(height: 16),

        // Prix
        _buildTextField(
          label: 'Prix (FCFA)',
          controller: _priceController,
          hint: 'ex: 75000000',
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 16),

        // Superficie
        _buildTextField(
          label: 'Superficie (m²)',
          controller: _areaSqmController,
          hint: 'ex: 500',
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 16),

        // Ville
        _buildDropdownField(
          label: 'Ville',
          value: _selectedCity,
          items: ['Lomé', 'Kara', 'Sokodé', 'Atakpamé', 'Dapaong'],
          onChanged: (value) => setState(() => _selectedCity = value),
        ),
        const SizedBox(height: 16),

        // Type de document
        _buildDropdownField(
          label: 'Type de document',
          value: _selectedDocumentType,
          items: [
            'titre_foncier',
            'logement',
            'convention',
            'recu_vente',
            'aucun_document',
            'ne_sais_pas',
          ],
          onChanged: (value) => setState(() => _selectedDocumentType = value),
        ),
        const SizedBox(height: 16),

        // Statut
        _buildDropdownField(
          label: 'Statut initial',
          value: _selectedStatus,
          items: ['draft', 'publie', 'suspendu'],
          onChanged: (value) => setState(() => _selectedStatus = value),
        ),
        const SizedBox(height: 16),

        // Description
        _buildTextField(
          label: 'Description',
          controller: _descriptionController,
          hint: 'Détails supplémentaires...',
          maxLines: 3,
        ),
        const SizedBox(height: 16),

        // Notes vendeur
        _buildTextField(
          label: 'Notes vendeur',
          controller: _sellersNotesController,
          hint: 'Notes privées...',
          maxLines: 2,
        ),
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey[400],
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          style: GoogleFonts.inter(color: Colors.white),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.inter(color: Colors.grey[600]),
            filled: true,
            fillColor: const Color(0xFF0F0F1E),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide(color: Colors.grey[700]!),
            ),
            contentPadding: const EdgeInsets.all(12),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String value,
    required List<String> items,
    required Function(String) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey[400],
          ),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF0F0F1E),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: Colors.grey[700]!),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: DropdownButton<String>(
            value: value,
            isExpanded: true,
            dropdownColor: const Color(0xFF1A1A2E),
            underline: const SizedBox.shrink(),
            items: items
                .map(
                  (item) => DropdownMenuItem(
                    value: item,
                    child: Text(
                      item,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: Colors.white,
                      ),
                    ),
                  ),
                )
                .toList(),
            onChanged: (newValue) {
              if (newValue != null) onChanged(newValue);
            },
            style: GoogleFonts.inter(color: Colors.white),
          ),
        ),
      ],
    );
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _handleSaveFromAsync() async {
    if (_titleController.text.isEmpty ||
        _priceController.text.isEmpty ||
        _areaSqmController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez remplir tous les champs obligatoires'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      String? imageUrl;
      bool photoUploadFailed = false;
      String? photoUploadError;
      final authUserId = supabase.auth.currentUser?.id;
      if (authUserId == null) {
        throw Exception('Utilisateur non connecté');
      }

      final profile = await supabase
          .from('users')
          .select('id')
          .or('id.eq.$authUserId,auth_id.eq.$authUserId')
          .maybeSingle();

      final sellerId = profile?['id']?.toString();
      if (sellerId == null || sellerId.isEmpty) {
        throw Exception('Profil introuvable. Reconnectez-vous puis réessayez.');
      }

      // Upload image si sélectionnée
      if (_selectedImage != null) {
        try {
          final fileName =
              'terrain_${DateTime.now().millisecondsSinceEpoch}_${authUserId.substring(0, 8)}.jpg';
          final storagePath = 'seller_terrains/$authUserId/$fileName';
          await supabase.storage
              .from('terrain_images')
              .upload(storagePath, _selectedImage!);

          imageUrl = supabase.storage
              .from('terrain_images')
              .getPublicUrl(storagePath);
        } catch (e) {
          photoUploadFailed = true;
          photoUploadError = e.toString();
        }
      }

      final parsedPrice = double.tryParse(_priceController.text.trim());
      final parsedSurface = double.tryParse(_areaSqmController.text.trim());
      if (parsedPrice == null || parsedPrice <= 0) {
        throw Exception('Prix invalide');
      }
      if (parsedSurface == null || parsedSurface <= 0) {
        throw Exception('Superficie invalide');
      }

      // Créer le terrain
      await supabase.from('terrains_foncira').insert({
        'seller_id': sellerId,
        'title': _titleController.text,
        'location': _selectedCity,
        'ville': _selectedCity,
        'surface': parsedSurface,
        'price_fcfa': parsedPrice,
        'document_type': _selectedDocumentType,
        'status': _selectedStatus,
        'verification_status': 'non_verifie',
        'main_photo_url': imageUrl,
        'description': _descriptionController.text,
        'seller_notes': _sellersNotesController.text,
        'created_at': DateTime.now().toIso8601String(),
      });

      if (mounted) {
        Navigator.pop(context);
        widget.onTerrainCreated();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              photoUploadFailed
                  ? 'Terrain créé sans photo. Upload échoué: $photoUploadError'
                  : 'Terrain créé avec succès',
            ),
            backgroundColor: photoUploadFailed ? Colors.orange : kSuccess,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
