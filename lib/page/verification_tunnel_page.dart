import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:provider/provider.dart';
import '../theme/colors.dart';
import '../component/foncira_button.dart';
import '../models/verification_state.dart';
import '../providers/verification_provider.dart';
import '../services/supabase_service.dart';

const String kGuaranteeText =
    'On garantit un rapport complet, honnête et livré en 10 jours. Si on ne livre pas, vous êtes remboursé.';

// ══════════════════════════════════════════════════════════════
//  FONCIRA — Verification Tunnel (Supabase-backed)
// ══════════════════════════════════════════════════════════════

class VerificationTunnelPage extends StatefulWidget {
  final bool isExternalTerrain;
  final VerificationState? initialState; // For marketplace terrain

  const VerificationTunnelPage({
    super.key,
    this.isExternalTerrain = false,
    this.initialState,
  });

  @override
  State<VerificationTunnelPage> createState() => _VerificationTunnelPageState();
}

class _VerificationTunnelPageState extends State<VerificationTunnelPage> {
  late int currentStep;
  late VerificationState state;

  // Form controllers
  late TextEditingController localisationController;
  late TextEditingController priceController;
  late TextEditingController lienPartageController;
  late TextEditingController prenomController;
  late TextEditingController whatsappController;

  // Document uploads for Screen 1
  List<DocumentUpload> uploadedDocuments = [];

  // UI states
  bool isLoadingPreAnalysis = false;
  bool isLoadingConfirmation = false;
  bool isLoadingPayment = false;
  List<String> notifications = [];

  @override
  void initState() {
    super.initState();
    // Initialize based on terrain type
    currentStep = widget.isExternalTerrain ? 1 : 3;
    state =
        widget.initialState ??
        VerificationState(
          localisation: '',
          typeDocuments: const [],
          prixFCFA: 0,
          niveauRisque: NiveauRisque.faible,
        );

    localisationController = TextEditingController(text: state.localisation);
    priceController = TextEditingController();
    lienPartageController = TextEditingController(text: state.lienPartage);
    prenomController = TextEditingController(text: state.prenom);
    whatsappController = TextEditingController(text: state.whatsapp);
  }

  @override
  void dispose() {
    localisationController.dispose();
    priceController.dispose();
    lienPartageController.dispose();
    prenomController.dispose();
    whatsappController.dispose();
    super.dispose();
  }

  void _goToStep(int step) {
    setState(() => currentStep = step);
  }

  void _submitScreen1() {
    if (localisationController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Indiquez la localisation')));
      return;
    }

    if (state.typeDocuments.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sélectionnez au moins un type de document'),
        ),
      );
      return;
    }

    if (priceController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Indiquez le prix')));
      return;
    }

    final prixFCFA =
        int.tryParse(priceController.text.replaceAll(' ', '')) ?? 0;
    if (prixFCFA == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Le prix doit être supérieur à 0'),
        ),
      );
      return;
    }

    setState(() {
      state = state.copyWith(
        localisation: localisationController.text,
        prixFCFA: prixFCFA,
        prixUSD: VerificationState.convertToUSD(prixFCFA),
        niveauRisque: VerificationState.calculateRisk(state.typeDocuments),
        lienPartage: lienPartageController.text,
        documents: uploadedDocuments,
      );
      isLoadingPreAnalysis = true;
    });

    // Simulate loading, then go to pre-analysis
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() => isLoadingPreAnalysis = false);
        _goToStep(2);
      }
    });
  }

  void _submitScreen3() {
    if (prenomController.text.isEmpty || whatsappController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Remplissez tous les champs')),
      );
      return;
    }

    setState(() {
      state = state.copyWith(
        prenom: prenomController.text,
        whatsapp: whatsappController.text,
        dateLivraison: DateTime.now().add(const Duration(days: 10)),
      );
      isLoadingConfirmation = true;
    });

    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() => isLoadingConfirmation = false);
        _goToStep(4);
      }
    });
  }

  void _submitPayment(String method) async {
    if (!SupabaseService().isAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vous devez être connecté')),
      );
      return;
    }

    setState(() => isLoadingPayment = true);

    try {
      final provider = context.read<VerificationProvider>();

      // Create verification based on terrain type
      bool success;
      if (widget.isExternalTerrain) {
        success = await provider.createFromExternal(
          title: state.localisation,
          location: state.localisation,
          price: state.prixFCFA.toDouble(),
          documentType: state.typeDocuments.isNotEmpty
              ? state.typeDocuments.map((e) => e.label).join(', ')
              : 'N/A',
          sharingLink: state.lienPartage,
        );
      } else {
        // Marketplace verification (requires terrainTitle from initialState)
        success = await provider.createFromMarketplace(
          terrainId: '', // From marketplace, would be in terrain data
          terrainTitle: state.terrainTitre ?? state.localisation,
          terrainLocation: state.localisation,
          terrainPrice: state.prixFCFA.toDouble(),
          documentType: state.typeDocuments.isNotEmpty
              ? state.typeDocuments.map((e) => e.label).join(', ')
              : 'N/A',
          sharingLink: state.lienPartage,
        );
      }

      if (mounted) {
        setState(() => isLoadingPayment = false);

        if (success) {
          _goToStep(6);
          _startDashboardSimulation();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erreur: ${provider.errorMessage}')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => isLoadingPayment = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erreur: $e')));
      }
    }
  }

  void _startDashboardSimulation() {
    final notifs = [
      'J1 : "On a commencé la vérification cadastrale de votre terrain."',
      'J3 : "Notre agent est allé sur le terrain ce matin. Voici 3 photos."',
      'J7 : "La vérification coutumière est terminée. Tout se passe bien."',
    ];

    for (int i = 0; i < notifs.length; i++) {
      Future.delayed(Duration(seconds: 3 + (i * 3)), () {
        if (mounted) {
          setState(() {
            notifications.add(notifs[i]);
          });
        }
      });
    }

    // Auto-advance to report after all notifications
    Future.delayed(const Duration(seconds: 15), () {
      if (mounted) {
        _goToStep(7);
      }
    });
  }

  String _getAppBarTitle() {
    if (widget.isExternalTerrain) {
      switch (currentStep) {
        case 1:
          return 'Parle-nous du terrain';
        case 2:
          return 'Préanalyse';
        case 3:
          return 'C\'est toi ?';
        case 4:
          return 'Confirmation';
        case 5:
          return 'Sécuriser le dossier';
        case 6:
          return 'Vérification en cours';
        case 7:
          return 'Votre rapport';
        case 8:
          return 'Quelle suite ?';
        case 9:
          return 'Parrainage';
        default:
          return '';
      }
    } else {
      switch (currentStep) {
        case 3:
          return 'C\'est toi ?';
        case 4:
          return 'Confirmation';
        case 5:
          return 'Sécuriser le dossier';
        case 6:
          return 'Vérification en cours';
        case 7:
          return 'Votre rapport';
        case 8:
          return 'Quelle suite ?';
        case 9:
          return 'Parrainage';
        default:
          return '';
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (currentStep > (widget.isExternalTerrain ? 1 : 3)) {
          _goToStep(currentStep - 1);
          return false;
        }
        return true;
      },
      child: Scaffold(
        backgroundColor: kDarkBg,
        appBar: AppBar(
          backgroundColor: kDarkBg,
          elevation: 0,
          leading: currentStep > (widget.isExternalTerrain ? 1 : 3)
              ? IconButton(
                  icon: const Icon(Icons.arrow_back_ios_rounded),
                  onPressed: () => _goToStep(currentStep - 1),
                )
              : null,
          title: Text(
            _getAppBarTitle(),
            style: GoogleFonts.outfit(
              fontWeight: FontWeight.w700,
              fontSize: 18,
            ),
          ),
        ),
        body: SafeArea(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, animation) =>
                FadeTransition(opacity: animation, child: child),
            child: _buildCurrentStep(),
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentStep() {
    if (widget.isExternalTerrain) {
      switch (currentStep) {
        case 1:
          return _Screen1Terrain(
            localisationController: localisationController,
            priceController: priceController,
            lienPartageController: lienPartageController,
            selectedDocumentTypes: state.typeDocuments,
            onDocumentTypeChanged: (type) {
              setState(() {
                final list = List<TypeDocument>.from(state.typeDocuments);
                if (list.contains(type)) {
                  list.remove(type);
                } else {
                  list.add(type);
                }
                state = state.copyWith(typeDocuments: list);
              });
            },
            onSubmit: _submitScreen1,
            isLoading: isLoadingPreAnalysis,
            uploadedDocuments: uploadedDocuments,
            onDocumentAdded: (doc) =>
                setState(() => uploadedDocuments.add(doc)),
            onDocumentRemoved: (doc) =>
                setState(() => uploadedDocuments.remove(doc)),
          );
        case 2:
          return _Screen2PreAnalysis(
            state: state,
            onContinue: () => _goToStep(3),
          );
        case 3:
          return _Screen3Client(
            prenomController: prenomController,
            whatsappController: whatsappController,
            onSubmit: _submitScreen3,
            isLoading: isLoadingConfirmation,
          );
        case 4:
          return _Screen4Confirmation(state: state);
        case 5:
          return _Screen5Payment(
            state: state,
            onSubmit: _submitPayment,
            isLoading: isLoadingPayment,
          );
        case 6:
          return _Screen6Dashboard(state: state, notifications: notifications);
        case 7:
          return _Screen7Report(state: state, onContinue: () => _goToStep(8));
        case 8:
          return _Screen8Decision(onDecision: (choice) => _goToStep(9));
        case 9:
          return _Screen9Referral(prenom: state.prenom);
        default:
          return const SizedBox.shrink();
      }
    } else {
      // MARKETPLACE PATH
      switch (currentStep) {
        case 3:
          return _Screen3Client(
            prenomController: prenomController,
            whatsappController: whatsappController,
            terrainInfo: state,
            onSubmit: _submitScreen3,
            isLoading: isLoadingConfirmation,
          );
        case 4:
          return _Screen4Confirmation(state: state);
        case 5:
          return _Screen5Payment(
            state: state,
            onSubmit: _submitPayment,
            isLoading: isLoadingPayment,
          );
        case 6:
          return _Screen6Dashboard(state: state, notifications: notifications);
        case 7:
          return _Screen7Report(state: state, onContinue: () => _goToStep(8));
        case 8:
          return _Screen8Decision(onDecision: (choice) => _goToStep(9));
        case 9:
          return _Screen9Referral(prenom: state.prenom);
        default:
          return const SizedBox.shrink();
      }
    }
  }
}

// ══════════════════════════════════════════════════════════════
//  SCREEN 1 — Terrain (External Only)
// ══════════════════════════════════════════════════════════════

class _Screen1Terrain extends StatefulWidget {
  final TextEditingController localisationController;
  final TextEditingController priceController;
  final TextEditingController lienPartageController;
  final List<TypeDocument> selectedDocumentTypes;
  final Function(TypeDocument) onDocumentTypeChanged;
  final VoidCallback onSubmit;
  final bool isLoading;
  final List<DocumentUpload> uploadedDocuments;
  final Function(DocumentUpload) onDocumentAdded;
  final Function(DocumentUpload) onDocumentRemoved;

  const _Screen1Terrain({
    required this.localisationController,
    required this.priceController,
    required this.lienPartageController,
    required this.selectedDocumentTypes,
    required this.onDocumentTypeChanged,
    required this.onSubmit,
    required this.isLoading,
    required this.uploadedDocuments,
    required this.onDocumentAdded,
    required this.onDocumentRemoved,
  });

  @override
  State<_Screen1Terrain> createState() => __Screen1TerrainState();
}

class __Screen1TerrainState extends State<_Screen1Terrain> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── FONCIRA Terrain Identification Card (if from marketplace) ───
          if (widget.uploadedDocuments.isNotEmpty ||
              // This is a placeholder - in a real scenario, check initialState from parent
              false) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: kPrimaryLight.withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: kPrimaryLight.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Terrain identifié',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: kPrimaryLight,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Placeholder for terrain image
                  Container(
                    width: double.infinity,
                    height: 120,
                    decoration: BoxDecoration(
                      color: kDarkCard,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: kBorderDark),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.image_outlined,
                        color: kTextMuted,
                        size: 40,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Terrain details
                  Text(
                    'Titre du bien',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: kTextPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Localisation',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              color: kTextMuted,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Lomé',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: kTextPrimary,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Surface',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              color: kTextMuted,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '500 m²',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: kTextPrimary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],

          Text(
            'Parle-nous du terrain',
            style: GoogleFonts.outfit(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: kTextPrimary,
            ),
          ),
          const SizedBox(height: 24),

          // CHAMP 1: Localisation
          Text(
            'Localisation',
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: kTextPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: kDarkCard,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: kBorderDark),
            ),
            child: TextField(
              controller: widget.localisationController,
              cursorColor: kPrimary,
              style: GoogleFonts.inter(color: kTextPrimary, fontSize: 14),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'Ex : Derrière le marché de Bè, Lomé',
                hintStyle: GoogleFonts.inter(color: kTextMuted, fontSize: 14),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // CHAMP 2: Type de Document (Pills)
          Text(
            'Type de document',
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: kTextPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: TypeDocument.values.map((doc) {
              final isSelected = widget.selectedDocumentTypes.contains(doc);
              return GestureDetector(
                onTap: () => widget.onDocumentTypeChanged(doc),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? kPrimary : kDarkCard,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? kPrimary : kBorderDark,
                    ),
                  ),
                  child: Text(
                    doc.label,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.white : kTextSecondary,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          // Warning banner if risky document selected
          if (widget.selectedDocumentTypes.contains(
                TypeDocument.aucunDocument,
              ) ||
              widget.selectedDocumentTypes.contains(TypeDocument.neSaisPas))
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: kWarning.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: kWarning.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline_rounded, color: kWarning, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Vérification renforcée nécessaire — on s\'en occupe.',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: kTextSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 24),

          // CHAMP 3: Prix avec conversion temps réel
          Text(
            'Prix demandé',
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: kTextPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                flex: 3,
                child: Container(
                  decoration: BoxDecoration(
                    color: kDarkCard,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: kBorderDark),
                  ),
                  child: TextField(
                    controller: widget.priceController,
                    cursorColor: kPrimary,
                    keyboardType: TextInputType.number,
                    style: GoogleFonts.inter(color: kTextPrimary, fontSize: 14),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Ex : 12 500 000',
                      hintStyle: GoogleFonts.inter(
                        color: kTextMuted,
                        fontSize: 14,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                    ),
                    onChanged: (_) {
                      setState(() {});
                    },
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: kDarkCard,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: kBorderDark),
                ),
                child: Text(
                  'FCFA',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: kTextPrimary,
                  ),
                ),
              ),
            ],
          ),

          // Affichage conversion temps réel
          if (widget.priceController.text.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                '≈ \$${VerificationState.convertToUSD(int.tryParse(widget.priceController.text.replaceAll(' ', '')) ?? 0)}',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: kGold,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

          const SizedBox(height: 36),

          // ─── OPTIONAL FIELD 1: Lien de partage ───
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'Lien de partage',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: kTextPrimary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: kTextMuted.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'Optionnel',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: kTextMuted,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: kDarkCard,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: kBorderDark),
                ),
                child: TextField(
                  controller: widget.lienPartageController,
                  cursorColor: kPrimary,
                  style: GoogleFonts.inter(color: kTextPrimary, fontSize: 14),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText:
                        'Colle ici le lien Facebook, WhatsApp ou tout autre lien du terrain',
                    hintStyle: GoogleFonts.inter(
                      color: kTextMuted,
                      fontSize: 14,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // ─── OPTIONAL FIELD 2: Documents disponibles ───
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'Documents disponibles',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: kTextPrimary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: kTextMuted.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'Optionnel',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: kTextMuted,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Ajoute les documents que tu as — titre, convention, reçu, photo du terrain. Tout aide.',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: kTextSecondary,
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 12),

              // Upload button
              GestureDetector(
                onTap: () {
                  // Simulate document upload
                  // In a real app, use file_picker or image_picker
                  final dummyDoc = DocumentUpload(
                    fileName:
                        'document_${DateTime.now().millisecondsSinceEpoch}.pdf',
                    filePath: 'assets/document.pdf',
                    fileType: 'PDF',
                    uploadedAt: DateTime.now(),
                  );
                  widget.onDocumentAdded(dummyDoc);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 14,
                    horizontal: 16,
                  ),
                  decoration: BoxDecoration(
                    color: kDarkCard,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: kBorderDark, width: 1.5),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.cloud_upload_outlined,
                        color: kPrimary,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Importer un document (PDF, JPG, PNG)',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: kPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Display uploaded documents
              if (widget.uploadedDocuments.isNotEmpty) ...[
                const SizedBox(height: 12),
                ...widget.uploadedDocuments.map((doc) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: kSuccess.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: kSuccess.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.description_outlined,
                            color: kSuccess,
                            size: 18,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  doc.fileName,
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: kTextPrimary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  doc.fileType,
                                  style: GoogleFonts.inter(
                                    fontSize: 10,
                                    color: kTextMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: () => widget.onDocumentRemoved(doc),
                            child: Icon(
                              Icons.close_rounded,
                              color: kDanger.withOpacity(0.7),
                              size: 18,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ],
            ],
          ),

          const SizedBox(height: 36),
          FonciraButton(
            label: 'Continuer →',
            onPressed: widget.isLoading ? null : widget.onSubmit,
            isLoading: widget.isLoading,
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
//  SCREEN 2 — Pre-Analysis (External Only)
//  Structured analysis: what's confirmed + what needs verification
// ══════════════════════════════════════════════════════════════

class _Screen2PreAnalysis extends StatelessWidget {
  final VerificationState state;
  final VoidCallback onContinue;

  const _Screen2PreAnalysis({required this.state, required this.onContinue});

  List<String> _getPositivePoints() {
    final points = <String>[];

    // Based on document type
    if ((state.typeDocuments.isNotEmpty ? state.typeDocuments.first : null) ==
        TypeDocument.titreFoncier) {
      points.add(
        'Un titre foncier est présent — c\'est le document le plus solide qui existe au Togo.',
      );
    } else if ((state.typeDocuments.isNotEmpty
            ? state.typeDocuments.first
            : null) ==
        TypeDocument.convention) {
      points.add(
        'La convention signée prouve une intention d\'achat formalisée.',
      );
    } else if ((state.typeDocuments.isNotEmpty
            ? state.typeDocuments.first
            : null) ==
        TypeDocument.recuVente) {
      points.add(
        'Un reçu de vente documenta une transaction antérieure.',
      );
    }

    // Based on documents uploaded
    if (state.documents.isNotEmpty) {
      points.add(
        'Documents supplémentaires fournis — ${state.documents.length} fichier${state.documents.length > 1 ? 's' : ''} permettront une préanalyse plus précise.',
      );
    }

    // Based on sharing link
    if (state.lienPartage.isNotEmpty) {
      points.add(
        'Source identifiée — le lien de partage facilite la traçabilité du bien.',
      );
    }

    // Default positive point
    if (points.isEmpty) {
      points.add('Les informations basiques du terrain sont documentées.');
    }

    return points;
  }

  List<String> _getPointsToVerify() {
    final points = <String>[];

    // Based on document type
    if ((state.typeDocuments.isNotEmpty ? state.typeDocuments.first : null) ==
            TypeDocument.aucunDocument ||
        (state.typeDocuments.isNotEmpty ? state.typeDocuments.first : null) ==
            TypeDocument.neSaisPas) {
      points.add(
        'L\'absence de document officiel expose à un risque important.',
      );
      points.add(
        'Une vérification terrains et coutumière est essentielle.',
      );
    } else if ((state.typeDocuments.isNotEmpty
            ? state.typeDocuments.first
            : null) ==
        TypeDocument.convention) {
      points.add(
        'Une convention sans enregistrement notarial n\'a pas de valeur juridique pleine.',
      );
      points.add('L\'absence de titre foncier doit être clarifiée.');
    } else if ((state.typeDocuments.isNotEmpty
                ? state.typeDocuments.first
                : null) ==
            TypeDocument.logement ||
        (state.typeDocuments.isNotEmpty ? state.typeDocuments.first : null) ==
            TypeDocument.recuVente) {
      points.add(
        'Le statut d\'enregistrement auprès des autorités cadastrales doit être confirmé.',
      );
    }

    // Additional verification points
    if ((state.typeDocuments.isNotEmpty ? state.typeDocuments.first : null) !=
        TypeDocument.titreFoncier) {
      points.add(
        'L\'absence de bornage officiel expose à des litiges de délimitation.',
      );
    }

    // Based on geolocation
    points.add(
      'Vérification coutumière sur le terrain : statut auprès des autorités locales.',
    );

    return points;
  }

  @override
  Widget build(BuildContext context) {
    final riskEmoji = state.niveauRisque == NiveauRisque.faible
        ? '🟢'
        : state.niveauRisque == NiveauRisque.modere
        ? '🟡'
        : '🔴';

    final positivePoints = _getPositivePoints();
    final pointsToVerify = _getPointsToVerify();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Risk level header
          Center(
            child: Column(
              children: [
                Text(
                  riskEmoji,
                  style: const TextStyle(fontSize: 64),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  state.niveauRisque.label,
                  style: GoogleFonts.outfit(
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    color: state.niveauRisque.color,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // ─── BLOCK 1: What documents confirm ───
          Text(
            'Ce que les documents confirment',
            style: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: kSuccess,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: kSuccess.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: kSuccess.withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: positivePoints.map((point) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Icon(
                          Icons.check_circle_rounded,
                          color: kSuccess,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          point,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: kTextSecondary,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 24),

          // ─── BLOCK 2: What needs verification ───
          Text(
            'Ce qui reste à vérifier',
            style: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: kWarning,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: kWarning.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: kWarning.withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: pointsToVerify.map((point) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Icon(
                          Icons.info_outline_rounded,
                          color: kWarning,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          point,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: kTextSecondary,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 24),

          // ─── Risk-based testimonials (if high risk) ───
          if (state.niveauRisque == NiveauRisque.eleve) ...[
            Text(
              'Pourquoi cette prudence ?',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: kTextPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: kDarkCard,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: kBorderDark),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ama a évité 25M FCFA',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: kTextPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '"Sans une vérification approfondie, j\'aurais signé sur un terrain en litige."',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: kTextSecondary,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: kDarkCard,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: kBorderDark),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Kofi a évité 13M FCFA',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: kTextPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '"J\'aurais accépté une fausse quittance. Merci pour la vérification."',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: kTextSecondary,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Pricing info
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: kSuccess.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: kSuccess.withOpacity(0.3)),
            ),
            child: Text(
              'Cette vérification complète coûte \$$kVerificationPriceUSD (≈${kVerificationPriceFCFA ~/ 1000}k FCFA) et elle est basée sur les documents que tu as fournis.',
              style: GoogleFonts.inter(
                fontSize: 13,
                color: kSuccess,
                fontWeight: FontWeight.w600,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          const SizedBox(height: 32),
          FonciraButton(
            label: 'Lancer la vérification complète →',
            onPressed: onContinue,
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
//  SCREEN 3 — Client Info (Prenom + WhatsApp)
// ══════════════════════════════════════════════════════════════

class _Screen3Client extends StatelessWidget {
  final TextEditingController prenomController;
  final TextEditingController whatsappController;
  final VerificationState? terrainInfo; // For marketplace display
  final VoidCallback onSubmit;
  final bool isLoading;

  const _Screen3Client({
    required this.prenomController,
    required this.whatsappController,
    required this.onSubmit,
    required this.isLoading,
    this.terrainInfo,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // If marketplace: show terrain info readonly
          if (terrainInfo != null) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: kDarkCard,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: kBorderDark),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Terrain sélectionné',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: kTextMuted,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    terrainInfo!.localisation,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: kTextPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '\$${terrainInfo!.prixUSD} (~${terrainInfo!.prixFCFA} FCFA)',
                    style: GoogleFonts.inter(fontSize: 12, color: kGold),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],

          Text(
            'C\'est toi ?',
            style: GoogleFonts.outfit(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: kTextPrimary,
            ),
          ),
          const SizedBox(height: 24),

          // CHAMP 1: Prénom
          Text(
            'Prénom',
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: kTextPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: kDarkCard,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: kBorderDark),
            ),
            child: TextField(
              controller: prenomController,
              cursorColor: kPrimary,
              style: GoogleFonts.inter(color: kTextPrimary, fontSize: 14),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'Ex : Ama',
                hintStyle: GoogleFonts.inter(color: kTextMuted, fontSize: 14),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // CHAMP 2: WhatsApp avec indicatif auto
          Text(
            'Ton numéro WhatsApp',
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: kTextPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: kDarkCard,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: kBorderDark),
            ),
            child: IntlPhoneField(
              controller: whatsappController,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: '+228 XX XX XX XX',
                hintStyle: GoogleFonts.inter(color: kTextMuted, fontSize: 14),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
              ),
              initialCountryCode: 'TG',
              onChanged: (phone) {
                // Country code is deduced automatically
              },
            ),
          ),
          const SizedBox(height: 32),
          FonciraButton(
            label: 'Recevoir ma confirmation →',
            onPressed: isLoading ? null : onSubmit,
            isLoading: isLoading,
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
//  SCREEN 4 — Confirmation + Guarantee
// ══════════════════════════════════════════════════════════════

class _Screen4Confirmation extends StatelessWidget {
  final VerificationState state;

  const _Screen4Confirmation({required this.state});

  String _formatDate(DateTime date) {
    final months = [
      'janvier',
      'février',
      'mars',
      'avril',
      'mai',
      'juin',
      'juillet',
      'août',
      'septembre',
      'octobre',
      'novembre',
      'décembre',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Success checkmark
          Center(
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: kSuccess.withOpacity(0.1),
                borderRadius: BorderRadius.circular(40),
              ),
              child: Center(
                child: Icon(
                  Icons.check_circle_outline_rounded,
                  size: 48,
                  color: kSuccess,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Client prenom en grand
          Center(
            child: Column(
              children: [
                Text(
                  'Merci, ${state.prenom.capitalize()}!',
                  style: GoogleFonts.outfit(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: kTextPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  '\$$kVerificationPriceUSD',
                  style: GoogleFonts.outfit(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: kGold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Agent card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: kDarkCard,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: kBorderDark),
            ),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: kPrimary.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.person_rounded,
                      color: kPrimary,
                      size: 28,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      state.agentNom,
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: kTextPrimary,
                      ),
                    ),
                    Text(
                      'Expert vérification',
                      style: GoogleFonts.inter(fontSize: 12, color: kTextMuted),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Exact delivery date
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: kGold.withOpacity(0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: kGold.withOpacity(0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.calendar_today_rounded, color: kGold, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Date de livraison',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: kTextPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  state.dateLivraison != null
                      ? _formatDate(state.dateLivraison!)
                      : '10 jours',
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: kGold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Guarantee
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: kSuccess.withOpacity(0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: kSuccess.withOpacity(0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.shield_rounded, color: kSuccess, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Notre garantie',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: kTextPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  kGuaranteeText,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: kTextSecondary,
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Timeline
          Text(
            'Voici ce qui va se passer :',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: kTextPrimary,
            ),
          ),
          const SizedBox(height: 16),
          ...[
            ('J1', 'Demande validée'),
            ('J3', 'Visite terrain'),
            ('J7', 'Vérification coutumière'),
            ('J10', 'Rapport final'),
          ].map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: kPrimary.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: Text(
                        item.$1,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: kPrimary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    item.$2,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: kTextSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
//  SCREEN 5 — Payment
// ══════════════════════════════════════════════════════════════

class _Screen5Payment extends StatefulWidget {
  final VerificationState state;
  final Function(String) onSubmit;
  final bool isLoading;

  const _Screen5Payment({
    required this.state,
    required this.onSubmit,
    required this.isLoading,
  });

  @override
  State<_Screen5Payment> createState() => __Screen5PaymentState();
}

class __Screen5PaymentState extends State<_Screen5Payment> {
  String selectedMethod = '';

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: kDarkCard,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: kBorderDark),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Vérification complète du terrain',
                  style: GoogleFonts.inter(fontSize: 12, color: kTextMuted),
                ),
                const SizedBox(height: 12),
                Text(
                  '\$$kVerificationPriceUSD',
                  style: GoogleFonts.outfit(
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    color: kGold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '≈ ${kVerificationPriceFCFA ~/ 1000}k FCFA',
                  style: GoogleFonts.inter(fontSize: 11, color: kTextMuted),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Payment methods
          Text(
            'Choisir une méthode de paiement',
            style: GoogleFonts.outfit(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: kTextPrimary,
            ),
          ),
          const SizedBox(height: 16),

          // Mobile Money
          _PaymentOption(
            icon: Icons.phone_iphone_rounded,
            title: 'Mobile Money',
            subtitle: 'MTN Mobile Money / Moov Money',
            isSelected: selectedMethod == 'mobile',
            onTap: () => setState(() => selectedMethod = 'mobile'),
          ),
          const SizedBox(height: 12),

          // Card
          _PaymentOption(
            icon: Icons.credit_card_rounded,
            title: 'Carte bancaire',
            subtitle: 'Visa / Mastercard',
            isSelected: selectedMethod == 'card',
            onTap: () => setState(() => selectedMethod = 'card'),
          ),
          const SizedBox(height: 40),

          // CTA
          FonciraButton(
            label: widget.isLoading
                ? 'Traitement en cours...'
                : 'Payer \$$kVerificationPriceUSD →',
            onPressed: selectedMethod.isEmpty
                ? null
                : () => widget.onSubmit(selectedMethod),
            isLoading: widget.isLoading,
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              'Votre paiement est sécurisé. $kGuaranteeText',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: kTextMuted,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  const _PaymentOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? kPrimary.withOpacity(0.1) : kDarkCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? kPrimary : kBorderDark,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isSelected ? kPrimary.withOpacity(0.15) : kBorderDark,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Icon(
                  icon,
                  color: isSelected ? kPrimary : kTextSecondary,
                  size: 24,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: kTextPrimary,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(fontSize: 12, color: kTextMuted),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle_rounded, color: kPrimary, size: 24),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
//  SCREEN 6 — Dashboard (Live Progress)
// ══════════════════════════════════════════════════════════════

class _Screen6Dashboard extends StatelessWidget {
  final VerificationState state;
  final List<String> notifications;

  const _Screen6Dashboard({required this.state, required this.notifications});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Agent card sticky
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: kDarkCard,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: kBorderDark),
            ),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: kPrimary.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.person_rounded,
                      color: kPrimary,
                      size: 28,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      state.agentNom,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: kTextPrimary,
                      ),
                    ),
                    Text(
                      'Verifie ton terrain',
                      style: GoogleFonts.inter(fontSize: 11, color: kTextMuted),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Progress bar
          Text(
            'Progression',
            style: GoogleFonts.inter(
              fontSize: 12,
              color: kTextMuted,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: (notifications.length + 1) / 4,
              minHeight: 6,
              backgroundColor: kBorderDark,
              valueColor: const AlwaysStoppedAnimation(kPrimary),
            ),
          ),
          const SizedBox(height: 24),

          // Timeline
          ...[
            ('J1', 'Vérification cadastrale'),
            ('J3', 'Visite terrain'),
            ('J7', 'Vérification coutumière'),
            ('J10', 'Rapport final'),
          ].map((item) {
            final index = [
              'Vérification cadastrale',
              'Visite terrain',
              'Vérification coutumière',
              'Rapport final',
            ].indexOf(item.$2);
            final isDone = index < notifications.length;
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDone ? kSuccess.withOpacity(0.08) : kDarkCard,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDone ? kSuccess.withOpacity(0.3) : kBorderDark,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: isDone ? kSuccess.withOpacity(0.2) : kBorderDark,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Center(
                        child: isDone
                            ? Icon(
                                Icons.check_rounded,
                                color: kSuccess,
                                size: 20,
                              )
                            : Text(
                                item.$1,
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: kTextMuted,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        item.$2,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isDone ? kSuccess : kTextPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),

          const SizedBox(height: 24),

          // Notifications
          if (notifications.isNotEmpty) ...[
            Text(
              'Mises à jour',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: kTextPrimary,
              ),
            ),
            const SizedBox(height: 12),
            ...notifications.map(
              (notif) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: kPrimaryLight.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: kPrimaryLight.withOpacity(0.2)),
                  ),
                  child: Text(
                    notif,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: kTextSecondary,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
//  SCREEN 7 — Report
// ══════════════════════════════════════════════════════════════

class _Screen7Report extends StatelessWidget {
  final VerificationState state;
  final VoidCallback onContinue;

  const _Screen7Report({required this.state, required this.onContinue});

  @override
  Widget build(BuildContext context) {
    final emoji = state.niveauRisque == NiveauRisque.faible
        ? '🟢'
        : '🔴';
    final verdict = state.niveauRisque == NiveauRisque.faible
        ? 'Risque faible — Tu peux y aller'
        : 'Risque élevé — On t\'explique pourquoi';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 24),
          Text(
            emoji,
            style: const TextStyle(fontSize: 80),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Text(
            verdict,
            style: GoogleFonts.outfit(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: state.niveauRisque.color,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),

          // If high risk: alternatives
          if (state.niveauRisque == NiveauRisque.eleve) ...[
            Text(
              'Voici 3 terrains vérifiés dans ta zone :',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: kTextPrimary,
              ),
            ),
            const SizedBox(height: 16),
            ...[
              ('Lot 234A', '45M FCFA'),
              ('Lot 567B', '52M FCFA'),
              ('Lot 890C', '48M FCFA'),
            ].map(
              (terrain) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: kDarkCard,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: kBorderDark),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: kSuccess.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Icon(
                            Icons.check_circle_outline_rounded,
                            color: kSuccess,
                            size: 20,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              terrain.$1,
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: kTextPrimary,
                              ),
                            ),
                            Text(
                              'Risque faible',
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                color: kSuccess,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        terrain.$2,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: kGold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],

          FonciraButton(label: 'Continuer →', onPressed: onContinue),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
//  SCREEN 8 — Decision
// ══════════════════════════════════════════════════════════════

class _Screen8Decision extends StatelessWidget {
  final Function(String) onDecision;

  const _Screen8Decision({required this.onDecision});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quelle est ta\nprochaine étape ?',
            style: GoogleFonts.outfit(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: kTextPrimary,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 24),
          ...[
            ('✅', 'Acheter', 'Ajoute procuration et notaire', 'buy'),
            (
              '📋',
              'Accompagnement',
              'Aide Administrative avec notaire',
              'support',
            ),
            (
              '⏰',
              'Pas maintenant',
              'Voir d\'autres terrains vérifiés',
              'skip',
            ),
          ].map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: GestureDetector(
                onTap: () => onDecision(item.$4),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: kDarkCard,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: kBorderDark),
                  ),
                  child: Row(
                    children: [
                      Text(item.$1, style: const TextStyle(fontSize: 28)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.$2,
                              style: GoogleFonts.inter(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: kTextPrimary,
                              ),
                            ),
                            Text(
                              item.$3,
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: kTextMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        color: kPrimaryLight,
                        size: 16,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
//  SCREEN 9 — Referral
// ══════════════════════════════════════════════════════════════

class _Screen9Referral extends StatefulWidget {
  final String prenom;

  const _Screen9Referral({required this.prenom});

  @override
  State<_Screen9Referral> createState() => __Screen9ReferralState();
}

class __Screen9ReferralState extends State<_Screen9Referral> {
  String? selectedFeedback;
  String? referralCode;

  @override
  Widget build(BuildContext context) {
    if (referralCode == null) {
      // Form stage
      return SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Es-tu content ?',
              style: GoogleFonts.outfit(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: kTextPrimary,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => selectedFeedback = 'yes'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: selectedFeedback == 'yes'
                            ? kSuccess.withOpacity(0.1)
                            : kDarkCard,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: selectedFeedback == 'yes'
                              ? kSuccess
                              : kBorderDark,
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            '😍',
                            style: GoogleFonts.outfit(fontSize: 32),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Ravi',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: kTextPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => selectedFeedback = 'maybe'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: selectedFeedback == 'maybe'
                            ? kWarning.withOpacity(0.1)
                            : kDarkCard,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: selectedFeedback == 'maybe'
                              ? kWarning
                              : kBorderDark,
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            '😐',
                            style: GoogleFonts.outfit(fontSize: 32),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Moyen',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: kTextPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => selectedFeedback = 'no'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: selectedFeedback == 'no'
                            ? kDanger.withOpacity(0.1)
                            : kDarkCard,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: selectedFeedback == 'no'
                              ? kDanger
                              : kBorderDark,
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            '😞',
                            style: GoogleFonts.outfit(fontSize: 32),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Non',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: kTextPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            FonciraButton(
              label: 'Continuer →',
              onPressed: selectedFeedback == null
                  ? null
                  : () {
                      // Generate referral code
                      final code =
                          'FON${DateTime.now().millisecondsSinceEpoch.toString().substring(4, 10)}';
                      setState(() => referralCode = code);
                    },
            ),
          ],
        ),
      );
    } else {
      // Referral code display
      return SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 32),
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: kSuccess.withOpacity(0.1),
                borderRadius: BorderRadius.circular(40),
              ),
              child: Center(
                child: Icon(
                  Icons.check_circle_outline_rounded,
                  size: 48,
                  color: kSuccess,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Center(
              child: Column(
                children: [
                  Text(
                    'Merci, ${widget.prenom.capitalize()}!',
                    style: GoogleFonts.outfit(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: kTextPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '\$$kVerificationPriceUSD payés',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: kGold,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: kGold.withOpacity(0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: kGold.withOpacity(0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Partage ton code',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: kTextPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: kDarkCard,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      referralCode ?? '',
                      style: GoogleFonts.outfit(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: kGold,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Partage ce code ! Chaque ami qui utilise ton code bénéficie aussi de \$$kVerificationPriceUSD pour sa première vérification.',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: kTextSecondary,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  FonciraButton(
                    label: 'Partager sur WhatsApp →',
                    onPressed: () {
                      // Share logic
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }
  }
}

extension on String {
  String capitalize() =>
      isNotEmpty ? '${this[0].toUpperCase()}${substring(1)}' : '';
}
