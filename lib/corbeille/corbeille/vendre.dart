import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';

const Color darkBackground = Color(0xFF101C17);
const Color cardBackground = Color(0xFF1B2B24);
const Color primaryGreen = Color(0xFF00C853);
const Color textColor = Colors.white;
const Color hintColor = Colors.white70;

class VendrePage extends StatefulWidget {
  const VendrePage({super.key});

  @override
  State<VendrePage> createState() => _VendrePageState();
}

class _VendrePageState extends State<VendrePage> {
  int _currentStep = 0;

  final int _totalSteps = 4;

  final _formKeyStep1 = GlobalKey<FormState>();
  final _formKeyStep2 = GlobalKey<FormState>();
  final _formKeyStep3 = GlobalKey<FormState>();

  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _priceController;
  late final TextEditingController _superficieController;
  late final TextEditingController _locationTextController;

  List<File> _images = [];
  File? _video;
  List<File> _documents = [];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _descriptionController = TextEditingController();
    _priceController = TextEditingController();
    _superficieController = TextEditingController();
    _locationTextController = TextEditingController();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _superficieController.dispose();
    _locationTextController.dispose();
    super.dispose();
  }

  void _nextStep() {
    final formKeys = [_formKeyStep1, _formKeyStep2, _formKeyStep3];
    if (_currentStep < formKeys.length) {
      if (!(formKeys[_currentStep].currentState?.validate() ?? true)) {
        return;
      }
    }

    if (_currentStep < _totalSteps - 1) {
      setState(() => _currentStep++);
    } else {
      _submitForVerification();
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  Future<void> _submitForVerification() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirmer la soumission"),
        content: const Text(
          "Votre annonce va être soumise à notre équipe pour vérification. Des frais de vérification s'appliqueront. Continuer ?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Annuler"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Soumettre"),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ Terrain soumis pour vérification !")),
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkBackground,
      appBar: AppBar(
        title: Text(
          "Vendre un terrain",
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        backgroundColor: darkBackground,
        foregroundColor: textColor,
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Row(
              children: List.generate(_totalSteps, (index) {
                return Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    height: 6,
                    decoration: BoxDecoration(
                      color: index <= _currentStep
                          ? primaryGreen
                          : Colors.white24,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                );
              }),
            ),
          ),
          Expanded(
            child: Animate(
              key: ValueKey(_currentStep),
              effects: const [
                FadeEffect(),
                SlideEffect(begin: Offset(0.1, 0)),
              ],
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: _buildStepContent(),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildNavigationButtons(),
    );
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0:
        return _buildStepContainer(
          key: _formKeyStep1,
          title: "Informations Essentielles",
          subtitle: "Décrivez précisément le bien que vous mettez en vente.",
          children: [
            _buildTextFormField(
              controller: _titleController,
              label: "Titre de l'annonce",
              validator: (v) => v!.isEmpty ? "Champs requis" : null,
            ),
            _buildTextFormField(
              controller: _descriptionController,
              label: "Description détaillée",
              maxLines: 4,
            ),
            _buildTextFormField(
              controller: _priceController,
              label: "Prix (FCFA)",
              keyboardType: TextInputType.number,
              validator: (v) => v!.isEmpty ? "Champs requis" : null,
            ),
            _buildTextFormField(
              controller: _superficieController,
              label: "Superficie (m²)",
              keyboardType: TextInputType.number,
              validator: (v) => v!.isEmpty ? "Champs requis" : null,
            ),
          ],
        );
      case 1:
        return _buildStepContainer(
          key: _formKeyStep2,
          title: "Photos & Vidéos",
          subtitle:
              "Des médias de qualité sont essentiels. Montrez au moins 5 photos.",
          children: [
            _buildFileUploadButton(
              label: "Ajouter des photos (${_images.length})",
              icon: Icons.photo_library_outlined,
              onPressed: () async {},
            ),
            _buildFileUploadButton(
              label: _video == null
                  ? "Ajouter une vidéo (optionnel)"
                  : "Vidéo ajoutée",
              icon: Icons.videocam_outlined,
              onPressed: () async {},
            ),
          ],
        );
      case 2:
        return _buildStepContainer(
          key: _formKeyStep3,
          title: "Localisation & Documents",
          subtitle: "Aidez-nous à vérifier la légitimité de votre bien.",
          children: [
            _buildFileUploadButton(
              label: "Localisation GPS précise",
              icon: Icons.map_outlined,
              onPressed: () {},
            ),
            _buildFileUploadButton(
              label: "Documents de propriété (${_documents.length})",
              icon: Icons.document_scanner_outlined,
              onPressed: () async {},
            ),
            _buildFileUploadButton(
              label: "Votre pièce d'identité",
              icon: Icons.badge_outlined,
              onPressed: () async {},
            ),
          ],
        );
      case 3:
        return _buildStepContainer(
          title: "Récapitulatif & Soumission",
          subtitle:
              "Veuillez vérifier toutes les informations avant de soumettre.",
          children: [
            _buildRecapItem("Titre", _titleController.text),
            _buildRecapItem("Prix", "${_priceController.text} FCFA"),
            _buildRecapItem("Superficie", "${_superficieController.text} m²"),
            _buildRecapItem("Photos", "${_images.length} image(s)"),
            _buildRecapItem("Documents", "${_documents.length} document(s)"),
            const SizedBox(height: 20),
            Text(
              "En validant, vous acceptez de payer les frais de vérification et vous vous engagez sur l'honneur quant à l'exactitude des informations fournies.",
              style: TextStyle(color: hintColor, fontStyle: FontStyle.italic),
            ),
          ],
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildStepContainer({
    Key? key,
    required String title,
    required String subtitle,
    required List<Widget> children,
  }) {
    return Form(
      key: key,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: GoogleFonts.poppins(fontSize: 15, color: hintColor),
          ),
          const SizedBox(height: 32),
          ...children,
        ],
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        style: const TextStyle(color: textColor),
        maxLines: maxLines,
        keyboardType: keyboardType,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: hintColor),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.white24),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: primaryGreen),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.redAccent),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.redAccent, width: 1.5),
          ),
        ),
      ),
    );
  }

  Widget _buildFileUploadButton({
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: OutlinedButton.icon(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: textColor,
          side: const BorderSide(color: Colors.white24),
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        icon: Icon(icon, color: hintColor),
        label: Text(label),
      ),
    );
  }

  Widget _buildRecapItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("$label :", style: TextStyle(color: hintColor)),
          Text(
            value.isNotEmpty ? value : "Non renseigné",
            style: const TextStyle(
              color: textColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            if (_currentStep > 0)
              IconButton(
                onPressed: _prevStep,
                icon: const Icon(Icons.arrow_back, color: textColor),
                style: IconButton.styleFrom(
                  side: const BorderSide(color: Colors.white24),
                ),
              ),
            if (_currentStep > 0) const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: _nextStep,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryGreen,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  _currentStep == _totalSteps - 1
                      ? "Soumettre pour vérification"
                      : "Suivant",
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
