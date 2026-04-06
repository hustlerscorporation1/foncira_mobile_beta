import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/colors.dart';
import '../component/foncira_button.dart';

// ══════════════════════════════════════════════════════════════
//  FONCIRA — Admin Support / Accompaniment Page
// ══════════════════════════════════════════════════════════════

class AdminSupportPage extends StatefulWidget {
  final String verificationId;

  const AdminSupportPage({super.key, required this.verificationId});

  @override
  State<AdminSupportPage> createState() => _AdminSupportPageState();
}

class _AdminSupportPageState extends State<AdminSupportPage> {
  String _selectedType = 'Mutation de titre foncier';
  final _notesController = TextEditingController();
  bool _isSubmitting = false;

  final List<_AccompanimentType> _types = [
    _AccompanimentType(
      title: 'Mutation de titre foncier',
      description: 'Transfert du titre de propriété à votre nom.',
      icon: Icons.description_rounded,
    ),
    _AccompanimentType(
      title: 'Bornage du terrain',
      description: 'Délimitation officielle des bornes du terrain.',
      icon: Icons.crop_free_rounded,
    ),
    _AccompanimentType(
      title: 'Acte de vente',
      description: 'Rédaction et signature de l\'acte de vente notarié.',
      icon: Icons.edit_document,
    ),
    _AccompanimentType(
      title: 'Accompagnement complet',
      description: 'Prise en charge de toutes les démarches de A à Z.',
      icon: Icons.all_inclusive_rounded,
    ),
  ];

  Future<void> _submit() async {
    setState(() => _isSubmitting = true);
    await Future.delayed(const Duration(milliseconds: 1000));

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          '✅ Demande d\'accompagnement envoyée ! Un conseiller vous contactera.',
        ),
        backgroundColor: kSuccess,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );

    Navigator.pop(context);
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kDarkBg,
      appBar: AppBar(
        backgroundColor: kDarkBg,
        title: Text(
          'Accompagnement',
          style: GoogleFonts.outfit(fontWeight: FontWeight.w700, fontSize: 18),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──
            Text(
              'De quoi avez-vous besoin ?',
              style: GoogleFonts.outfit(
                color: kTextPrimary,
                fontSize: 24,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Choisissez le type d\'accompagnement administratif que vous souhaitez pour votre terrain.',
              style: GoogleFonts.inter(
                color: kTextSecondary,
                fontSize: 14,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 28),

            // ── Type selection ──
            ...List.generate(_types.length, (index) {
              final type = _types[index];
              final isSelected = type.title == _selectedType;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: GestureDetector(
                  onTap: () => setState(() => _selectedType = type.title),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? kPrimary.withOpacity(0.08)
                          : kDarkCard,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected
                            ? kPrimary.withOpacity(0.4)
                            : kBorderDark,
                        width: isSelected ? 1.5 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? kPrimary.withOpacity(0.15)
                                : kDarkCardLight,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            type.icon,
                            color: isSelected ? kPrimaryLight : kTextMuted,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                type.title,
                                style: GoogleFonts.inter(
                                  color: isSelected
                                      ? kTextPrimary
                                      : kTextSecondary,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                type.description,
                                style: GoogleFonts.inter(
                                  color: kTextMuted,
                                  fontSize: 11,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (isSelected)
                          const Icon(
                            Icons.check_circle_rounded,
                            color: kPrimaryLight,
                            size: 22,
                          ),
                      ],
                    ),
                  ),
                ),
              );
            }),
            const SizedBox(height: 24),

            // ── Notes ──
            Text(
              'Notes supplémentaires',
              style: GoogleFonts.inter(
                color: kTextSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _notesController,
              maxLines: 3,
              style: GoogleFonts.inter(color: kTextPrimary, fontSize: 14),
              decoration: InputDecoration(
                hintText:
                    'Précisions ou demandes particulières...',
                hintStyle:
                    GoogleFonts.inter(color: kTextMuted, fontSize: 13),
                filled: true,
                fillColor: kDarkCard,
                contentPadding: const EdgeInsets.all(16),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: kBorderDark),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide:
                      const BorderSide(color: kPrimary, width: 1.5),
                ),
              ),
            ),
            const SizedBox(height: 36),

            // ── Submit ──
            FonciraButton(
              label: 'Envoyer la demande',
              icon: Icons.send_rounded,
              isLoading: _isSubmitting,
              onPressed: _isSubmitting ? null : _submit,
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class _AccompanimentType {
  final String title;
  final String description;
  final IconData icon;

  _AccompanimentType({
    required this.title,
    required this.description,
    required this.icon,
  });
}
