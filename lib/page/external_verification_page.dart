import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../theme/colors.dart';
import '../component/foncira_button.dart';
import '../providers/verification_provider.dart';

// ══════════════════════════════════════════════════════════════
//  FONCIRA — External Verification Page
// ══════════════════════════════════════════════════════════════

class ExternalVerificationPage extends StatefulWidget {
  const ExternalVerificationPage({super.key});

  @override
  State<ExternalVerificationPage> createState() =>
      _ExternalVerificationPageState();
}

class _ExternalVerificationPageState extends State<ExternalVerificationPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _locationController = TextEditingController();
  final _priceController = TextEditingController();
  final _sellerController = TextEditingController();
  final _descriptionController = TextEditingController();

  String _selectedSource = 'Réseaux sociaux';
  bool _isSubmitting = false;

  final List<String> _sources = [
    'Réseaux sociaux',
    'Bouche-à-oreille',
    'Agence externe',
    'Pancarte sur site',
    'Autre',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _locationController.dispose();
    _priceController.dispose();
    _sellerController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    // Simulate delay
    await Future.delayed(const Duration(milliseconds: 800));

    if (!mounted) return;

    final verifProv = context.read<VerificationProvider>();
    verifProv.createFromExternal(
      title: _titleController.text.trim(),
      location: _locationController.text.trim(),
      price: double.tryParse(_priceController.text.trim()),
      sellerContact: _sellerController.text.trim(),
      description: _descriptionController.text.trim(),
      source: _selectedSource,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('✅ Demande de vérification envoyée !'),
        backgroundColor: kSuccess,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kDarkBg,
      appBar: AppBar(
        backgroundColor: kDarkBg,
        title: Text(
          'Vérifier un terrain externe',
          style: GoogleFonts.outfit(fontWeight: FontWeight.w700, fontSize: 18),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Info banner ──
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: kGold.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: kGold.withOpacity(0.2)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline_rounded, color: kGold, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Soumettez les informations du terrain que vous avez trouvé et FONCIRA le vérifiera pour vous.',
                        style: GoogleFonts.inter(
                          color: kGoldLight,
                          fontSize: 12,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // ── Source ──
              _fieldLabel('D\'où provient ce terrain ?'),
              const SizedBox(height: 10),
              SizedBox(
                height: 38,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _sources.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final source = _sources[index];
                    final isSelected = source == _selectedSource;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedSource = source),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected ? kPrimarySurface : kDarkCard,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isSelected
                                ? kPrimary.withOpacity(0.5)
                                : kBorderDark,
                          ),
                        ),
                        child: Text(
                          source,
                          style: GoogleFonts.inter(
                            color:
                                isSelected ? kPrimaryLight : kTextSecondary,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),

              // ── Title ──
              _fieldLabel('Titre ou description courte'),
              const SizedBox(height: 8),
              _buildField(
                _titleController,
                'Ex: Terrain de 500m² à Kégué',
                validator: (v) =>
                    v?.trim().isEmpty == true ? 'Ce champ est requis' : null,
              ),
              const SizedBox(height: 20),

              // ── Location ──
              _fieldLabel('Localisation'),
              const SizedBox(height: 8),
              _buildField(
                _locationController,
                'Ex: Kégué, près du CEG, Lomé',
                prefixIcon: Icons.location_on_outlined,
                validator: (v) =>
                    v?.trim().isEmpty == true ? 'Ce champ est requis' : null,
              ),
              const SizedBox(height: 20),

              // ── Price ──
              _fieldLabel('Prix annoncé (FCFA)'),
              const SizedBox(height: 8),
              _buildField(
                _priceController,
                'Ex: 15000000',
                keyboardType: TextInputType.number,
                prefixIcon: Icons.payments_outlined,
              ),
              const SizedBox(height: 20),

              // ── Seller contact ──
              _fieldLabel('Coordonnées du vendeur'),
              const SizedBox(height: 8),
              _buildField(
                _sellerController,
                'Ex: +228 90 00 11 22 ou nom du vendeur',
                prefixIcon: Icons.person_outline_rounded,
              ),
              const SizedBox(height: 20),

              // ── Description ──
              _fieldLabel('Informations supplémentaires'),
              const SizedBox(height: 8),
              _buildField(
                _descriptionController,
                'Documents disponibles, détails du terrain, etc.',
                maxLines: 4,
              ),
              const SizedBox(height: 36),

              // ── Submit ──
              FonciraButton(
                label: 'Soumettre la demande',
                icon: Icons.send_rounded,
                variant: FonciraButtonVariant.gold,
                isLoading: _isSubmitting,
                onPressed: _isSubmitting ? null : _submit,
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _fieldLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.inter(
        color: kTextSecondary,
        fontSize: 13,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildField(
    TextEditingController controller,
    String hint, {
    int maxLines = 1,
    IconData? prefixIcon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: GoogleFonts.inter(color: kTextPrimary, fontSize: 14),
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.inter(color: kTextMuted, fontSize: 13),
        prefixIcon: prefixIcon != null
            ? Icon(prefixIcon, color: kTextMuted, size: 18)
            : null,
        filled: true,
        fillColor: kDarkCard,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: kBorderDark),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: kPrimary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: kDanger),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: kDanger, width: 1.5),
        ),
      ),
    );
  }
}
