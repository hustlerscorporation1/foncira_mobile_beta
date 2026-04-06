import 'package:flutter/material.dart';

const kLightBackgroundColor = Color(
  0xFFF7F8FC,
);
const kPrimaryColor = Color(
  0xFF16A34A,
);
const kCardColor = Colors.white; 
const kFontColor = Color(0xFF2D3748); 
const kHintColor = Color(
  0xFF718096,
); 

class DemandeServicePremiumPage extends StatefulWidget {
  const DemandeServicePremiumPage({super.key});

  @override
  State<DemandeServicePremiumPage> createState() =>
      _DemandeServicePremiumLightPageState();
}

class _DemandeServicePremiumLightPageState
    extends State<DemandeServicePremiumPage> {
  final _formKey = GlobalKey<FormState>();
  final _sujetController = TextEditingController();
  final _descriptionController = TextEditingController();

  final List<String> _categories = [
    'Litige',
    'Paiement',
    'Technique',
    'Suggestion',
  ];
  String _selectedCategory = 'Litige';

  bool _isLoading = false;

  @override
  void dispose() {
    _sujetController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submitRequest() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isLoading = true);
      await Future.delayed(const Duration(seconds: 2));
      // ... Logique de soumission ...
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Votre demande a été envoyée.'),
            backgroundColor: kPrimaryColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kLightBackgroundColor,
      appBar: AppBar(
        title: const Text(
          "Contacter le support",
          style: TextStyle(fontWeight: FontWeight.bold, color: kFontColor),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: kFontColor),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle("De quel type de service s'agit-il ?"),
              const SizedBox(height: 16),
              SizedBox(
                height: 40,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _categories.length,
                  itemBuilder: (context, index) {
                    final category = _categories[index];
                    final isSelected = category == _selectedCategory;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedCategory = category),
                      child: Chip(
                        label: Text(category),
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : kFontColor,
                          fontWeight: FontWeight.bold,
                        ),
                        backgroundColor: isSelected
                            ? kPrimaryColor
                            : kCardColor,
                        side: BorderSide(
                          color: isSelected
                              ? kPrimaryColor
                              : Colors.grey.shade300,
                        ),
                      ),
                    );
                  },
                  separatorBuilder: (context, index) =>
                      const SizedBox(width: 12),
                ),
              ),
              const SizedBox(height: 32),

              _buildSectionTitle("Quel est le sujet ?"),
              const SizedBox(height: 16),
              // --- CHAMP SUJET AVEC OMBRE ---
              _buildTextField(
                controller: _sujetController,
                hintText: "Ex: Je veux acheter un terrain d'un hectare à Lomé",
                validator: (value) => (value?.trim().isEmpty ?? true)
                    ? 'Veuillez entrer un sujet.'
                    : null,
              ),
              const SizedBox(height: 32),

              _buildSectionTitle("Pouvez-vous nous en dire plus ?"),
              const SizedBox(height: 16),
              // --- CHAMP DESCRIPTION AVEC OMBRE ---
              _buildTextField(
                controller: _descriptionController,
                hintText: "Décrivez votre problème en détail ici...",
                maxLines: 5,
                validator: (value) {
                  if (value?.trim().isEmpty ?? true)
                    return 'Veuillez décrire votre problème.';
                  if (value!.length < 20)
                    return 'Veuillez fournir plus de détails.';
                  return null;
                },
              ),
              const SizedBox(height: 40),

              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  // Widget pour les titres de section
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: kFontColor,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required FormFieldValidator<String> validator,
    int maxLines = 1,
  }) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        style: const TextStyle(color: kFontColor),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(color: kHintColor),
          filled: true,
          fillColor: kCardColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
        ),
        maxLines: maxLines,
        validator: validator,
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [kPrimaryColor, Color(0xFF1BD760)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: kPrimaryColor.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _isLoading ? null : _submitRequest,
          borderRadius: BorderRadius.circular(30),
          child: Container(
            height: 56,
            alignment: Alignment.center,
            child: _isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 3,
                    ),
                  )
                : const Text(
                    "Envoyer ma demande",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
