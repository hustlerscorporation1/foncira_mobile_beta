import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/colors.dart';
import '../component/foncira_button.dart';
import '../component/price_row.dart';
import '../models/verification_state.dart';
import '../providers/verification_provider.dart';
import '../services/supabase_service.dart';
import './suivre_verification_page.dart';

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
  late TextEditingController sellerWhatsappController;

  // Document uploads for Screen 1
  List<DocumentUpload> uploadedDocuments = [];

  // UI states
  bool isLoadingPreAnalysis = false;
  bool isLoadingConfirmation = false;
  bool isLoadingPayment = false;
  bool isCreatingTrackingRequest = false;
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
    sellerWhatsappController = TextEditingController(
      text: state.sellerWhatsapp,
    );
  }

  @override
  void dispose() {
    localisationController.dispose();
    priceController.dispose();
    lienPartageController.dispose();
    prenomController.dispose();
    whatsappController.dispose();
    sellerWhatsappController.dispose();
    super.dispose();
  }

  void _goToStep(int step) {
    setState(() => currentStep = step);
  }

  void _submitScreen1() {
    if (!state.consentGiven) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vous devez accepter l\'audit pour continuer'),
        ),
      );
      return;
    }

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
        const SnackBar(content: Text('Le prix doit être supérieur à 0')),
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
    if (prenomController.text.isEmpty ||
        whatsappController.text.isEmpty ||
        sellerWhatsappController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Remplissez tous les champs (incluant le vendeur)'),
        ),
      );
      return;
    }

    setState(() {
      state = state.copyWith(
        prenom: prenomController.text,
        whatsapp: whatsappController.text,
        sellerWhatsapp: sellerWhatsappController.text,
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Vous devez être connecté')));
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

  Future<void> _openTrackingFromConfirmation() async {
    if (!SupabaseService().isAuthenticated) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Vous devez être connecté')));
      return;
    }

    if (isCreatingTrackingRequest) return;

    setState(() => isCreatingTrackingRequest = true);

    try {
      final provider = context.read<VerificationProvider>();

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
        success = await provider.createFromMarketplace(
          terrainId: '',
          terrainTitle: state.terrainTitre ?? state.localisation,
          terrainLocation: state.localisation,
          terrainPrice: state.prixFCFA.toDouble(),
          documentType: state.typeDocuments.isNotEmpty
              ? state.typeDocuments.map((e) => e.label).join(', ')
              : 'N/A',
          sharingLink: state.lienPartage,
        );
      }

      if (!mounted) return;

      if (success) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const SuivreVerificationPage(),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: ${provider.errorMessage}')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erreur: $e')));
    } finally {
      if (mounted) {
        setState(() => isCreatingTrackingRequest = false);
      }
    }
  }

  void _startDashboardSimulation() {
    final notifs = [
      'J1 : "Votre demande a été validée. Notre équipe prend en charge votre dossier."',
      'J3 : "La vérification administrative est en cours. Nous consultons le cadastre et les registres officiels."',
      'J5 : "Notre agent a rencontré les autorités coutumières. Résultats en cours d\'analyse."',
      'J7 : "Vérification du voisinage et du géomètre effectuée. Toutes les bornes sont conformes."',
      'J10 : "Le juriste a rendu sa décision. Votre rapport final est en cours de rédaction."',
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
    Future.delayed(const Duration(seconds: 21), () {
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
          return 'Confirmer votre identité';
        case 4:
          return 'Vos documents';
        case 5:
          return 'Confirmation';
        case 6:
          return 'Sécuriser le dossier';
        case 7:
          return 'Vérification en cours';
        case 8:
          return 'Votre rapport';
        case 9:
          return 'Quelle suite ?';
        case 10:
          return 'Parrainage';
        default:
          return '';
      }
    } else {
      switch (currentStep) {
        case 3:
          return 'Confirmer votre identité';
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
            consentGiven: state.consentGiven,
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
            onConsentChanged: (value) {
              setState(() {
                state = state.copyWith(consentGiven: value);
              });
            },
            onSubmit: _submitScreen1,
            isLoading: isLoadingPreAnalysis,
          );
        case 2:
          return _Screen2PreAnalysis(
            state: state,
            onServiceTypeSelected: (serviceType) {
              setState(() {
                state = state.copyWith(serviceType: serviceType);
              });
            },
            onContinue: () => _goToStep(3),
          );
        case 3:
          return _Screen3Client(
            prenomController: prenomController,
            whatsappController: whatsappController,
            sellerWhatsappController: sellerWhatsappController,
            onSubmit: _submitScreen3,
            isLoading: isLoadingConfirmation,
          );
        case 4:
          return _Screen4Documents(
            state: state,
            uploadedDocuments: uploadedDocuments,
            onDocumentAdded: (doc) =>
                setState(() => uploadedDocuments.add(doc)),
            onDocumentRemoved: (doc) =>
                setState(() => uploadedDocuments.remove(doc)),
            onContinue: () => _goToStep(5),
          );
        case 5:
          return _Screen4Confirmation(
            state: state,
            onTrackVerification: _openTrackingFromConfirmation,
            isLoading: isCreatingTrackingRequest,
          );
        case 6:
          return _Screen5Payment(
            state: state,
            onSubmit: _submitPayment,
            isLoading: isLoadingPayment,
          );
        case 7:
          return _Screen6Dashboard(state: state, notifications: notifications);
        case 8:
          return _Screen7Report(state: state, onContinue: () => _goToStep(9));
        case 9:
          return _Screen8Decision(onDecision: (choice) => _goToStep(10));
        case 10:
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
            sellerWhatsappController: sellerWhatsappController,
            terrainInfo: state,
            onSubmit: _submitScreen3,
            isLoading: isLoadingConfirmation,
          );
        case 4:
          return _Screen4Documents(
            state: state,
            uploadedDocuments: uploadedDocuments,
            onDocumentAdded: (doc) =>
                setState(() => uploadedDocuments.add(doc)),
            onDocumentRemoved: (doc) =>
                setState(() => uploadedDocuments.remove(doc)),
            onContinue: () => _goToStep(5),
          );
        case 5:
          return _Screen4Confirmation(
            state: state,
            onTrackVerification: _openTrackingFromConfirmation,
            isLoading: isCreatingTrackingRequest,
          );
        case 6:
          return _Screen5Payment(
            state: state,
            onSubmit: _submitPayment,
            isLoading: isLoadingPayment,
          );
        case 7:
          return _Screen6Dashboard(state: state, notifications: notifications);
        case 8:
          return _Screen7Report(state: state, onContinue: () => _goToStep(9));
        case 9:
          return _Screen8Decision(onDecision: (choice) => _goToStep(10));
        case 10:
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
  final bool consentGiven;
  final Function(TypeDocument) onDocumentTypeChanged;
  final Function(bool) onConsentChanged;
  final VoidCallback onSubmit;
  final bool isLoading;

  const _Screen1Terrain({
    required this.localisationController,
    required this.priceController,
    required this.lienPartageController,
    required this.selectedDocumentTypes,
    required this.consentGiven,
    required this.onDocumentTypeChanged,
    required this.onConsentChanged,
    required this.onSubmit,
    required this.isLoading,
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

          // ─── MANDATORY CONSENT CHECKBOX ───
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: kDarkCard,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: kBorderDark),
            ),
            child: CheckboxListTile(
              value: widget.consentGiven,
              onChanged: (value) {
                widget.onConsentChanged(value ?? false);
              },
              activeColor: kPrimary,
              checkColor: Colors.white,
              contentPadding: EdgeInsets.zero,
              title: Text(
                'Je certifie avoir l\'accord du vendeur pour effectuer cet audit foncier.',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: kTextPrimary,
                ),
              ),
            ),
          ),

          const SizedBox(height: 36),
          FonciraButton(
            label: 'Continuer →',
            onPressed: widget.isLoading || !widget.consentGiven
                ? null
                : widget.onSubmit,
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

class _Screen2PreAnalysis extends StatefulWidget {
  final VerificationState state;
  final Function(String) onServiceTypeSelected;
  final VoidCallback onContinue;

  const _Screen2PreAnalysis({
    required this.state,
    required this.onServiceTypeSelected,
    required this.onContinue,
  });

  @override
  State<_Screen2PreAnalysis> createState() => __Screen2PreAnalysisState();
}

class __Screen2PreAnalysisState extends State<_Screen2PreAnalysis> {
  @override
  Widget build(BuildContext context) {
    final riskEmoji = widget.state.niveauRisque == NiveauRisque.faible
        ? '🟢'
        : widget.state.niveauRisque == NiveauRisque.modere
        ? '🟡'
        : '🔴';

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
                  widget.state.niveauRisque.label,
                  style: GoogleFonts.outfit(
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    color: widget.state.niveauRisque.color,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // ─── SECTION: Our Verification Method ───
          Text(
            'Notre méthode de vérification',
            style: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: kPrimary,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: kPrimary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: kPrimary.withOpacity(0.3)),
            ),
            child: Text(
              'Notre vérification est indépendante. Même avec un titre foncier, nous consultons chaque source séparément pour croiser et confirmer.',
              style: GoogleFonts.inter(
                fontSize: 13,
                color: kTextSecondary,
                height: 1.6,
              ),
            ),
          ),
          const SizedBox(height: 32),

          // ─── SERVICE SELECTION CARDS ───
          Text(
            'Choisissez votre service',
            style: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: kTextPrimary,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 12),

          // Service 1: Vérification complète (preselected)
          GestureDetector(
            onTap: () {
              widget.onServiceTypeSelected('complete');
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: widget.state.serviceType == 'complete'
                    ? kPrimary.withOpacity(0.1)
                    : kDarkCard,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: widget.state.serviceType == 'complete'
                      ? kPrimary
                      : kBorderDark,
                  width: widget.state.serviceType == 'complete' ? 2 : 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Vérification complète',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: kTextPrimary,
                        ),
                      ),
                      Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: kPrimary, width: 2),
                          color: widget.state.serviceType == 'complete'
                              ? kPrimary
                              : Colors.transparent,
                        ),
                        child: widget.state.serviceType == 'complete'
                            ? const Center(
                                child: Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 12,
                                ),
                              )
                            : null,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Vérification indépendante de toutes les sources',
                    style: GoogleFonts.inter(fontSize: 12, color: kTextMuted),
                  ),
                  const SizedBox(height: 12),
                  PriceRow(
                    priceUsd: 380,
                    priceFcfa: 250000,
                    usdFontSize: 24,
                    fcfaFontSize: 12,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Service 2: Pack Vérification + Accompagnement
          GestureDetector(
            onTap: () {
              widget.onServiceTypeSelected('accompaniment');
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: widget.state.serviceType == 'accompaniment'
                    ? kPrimary.withOpacity(0.1)
                    : kDarkCard,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: widget.state.serviceType == 'accompaniment'
                      ? kPrimary
                      : kBorderDark,
                  width: widget.state.serviceType == 'accompaniment' ? 2 : 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Pack Vérification + Accompagnement',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: kTextPrimary,
                        ),
                      ),
                      Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: kPrimary, width: 2),
                          color: widget.state.serviceType == 'accompaniment'
                              ? kPrimary
                              : Colors.transparent,
                        ),
                        child: widget.state.serviceType == 'accompaniment'
                            ? const Center(
                                child: Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 12,
                                ),
                              )
                            : null,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Vérification + assistance notaire pour la finalisation',
                    style: GoogleFonts.inter(fontSize: 12, color: kTextMuted),
                  ),
                  const SizedBox(height: 12),
                  PriceRow(
                    priceUsd: 549,
                    priceFcfa: 325000,
                    usdFontSize: 24,
                    fcfaFontSize: 12,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 32),
          FonciraButton(label: 'Continuer →', onPressed: widget.onContinue),
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
  final TextEditingController sellerWhatsappController;
  final VerificationState? terrainInfo; // For marketplace display
  final VoidCallback onSubmit;
  final bool isLoading;

  const _Screen3Client({
    required this.prenomController,
    required this.whatsappController,
    required this.sellerWhatsappController,
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
            'Confirmer votre identité',
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
          const SizedBox(height: 24),

          // CHAMP 3: Numéro du vendeur (NOUVEAU)
          Text(
            'Numéro du vendeur',
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
              controller: sellerWhatsappController,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: '+XXX XX XX XX XX',
                hintStyle: GoogleFonts.inter(color: kTextMuted, fontSize: 14),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
              ),
              initialCountryCode: 'TG',
              onChanged: (phone) {
                // Country code for seller (may differ)
              },
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Nous contacterons le vendeur pour localiser le terrain et vérifier les informations.',
            style: GoogleFonts.inter(
              fontSize: 12,
              color: kTextMuted,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 32),
          FonciraButton(
            label: 'Continuer →',
            onPressed: isLoading ? null : onSubmit,
            isLoading: isLoading,
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
//  SCREEN 4 — Document Upload (NEW STEP)
//  Conditional upload based on Step 1 document selection
// ══════════════════════════════════════════════════════════════

class _Screen4Documents extends StatefulWidget {
  final VerificationState state;
  final List<DocumentUpload> uploadedDocuments;
  final Function(DocumentUpload) onDocumentAdded;
  final Function(DocumentUpload) onDocumentRemoved;
  final VoidCallback onContinue;

  const _Screen4Documents({
    required this.state,
    required this.uploadedDocuments,
    required this.onDocumentAdded,
    required this.onDocumentRemoved,
    required this.onContinue,
  });

  @override
  State<_Screen4Documents> createState() => __Screen4DocumentsState();
}

class __Screen4DocumentsState extends State<_Screen4Documents> {
  bool _hasNoDocuments() {
    return widget.state.typeDocuments.contains(TypeDocument.aucunDocument) ||
        widget.state.typeDocuments.contains(TypeDocument.neSaisPas);
  }

  @override
  Widget build(BuildContext context) {
    final noDocuments = _hasNoDocuments();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Vos documents',
            style: GoogleFonts.outfit(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: kTextPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Soumettez les documents que vous avez. Chaque document accélère et renforce notre analyse.',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: kTextSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 32),

          // IF NO DOCUMENTS SELECTED AT STEP 1
          if (noDocuments) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: kWarning.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: kWarning.withOpacity(0.3)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline_rounded, color: kWarning, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Vous n\'avez pas de document pour ce terrain. Nous allons étudier votre dossier et vous contacterons sous 24h pour vous dire si nous pouvons accepter la vérification.',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: kTextSecondary,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            // IF DOCUMENTS SELECTED - Show upload interface
            Text(
              'Documents à télécharger',
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: kTextPrimary,
              ),
            ),
            const SizedBox(height: 12),

            // Upload button
            GestureDetector(
              onTap: () {
                // In production: use file_picker or image_picker
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
                  vertical: 16,
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
            const SizedBox(height: 16),

            // Display uploaded documents
            if (widget.uploadedDocuments.isNotEmpty) ...[
              Text(
                'Documents téléchargés',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: kSuccess,
                ),
              ),
              const SizedBox(height: 12),
              ...widget.uploadedDocuments.map((doc) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
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
                        const SizedBox(width: 12),
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
              const SizedBox(height: 20),
            ],
          ],

          const SizedBox(height: 32),
          FonciraButton(
            label: 'Continuer →',
            onPressed: widget.onContinue,
            // Never blocking - always enabled
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
//  SCREEN 5 — Confirmation + Guarantee
// ══════════════════════════════════════════════════════════════

class _Screen4Confirmation extends StatelessWidget {
  final VerificationState state;
  final VoidCallback onTrackVerification;
  final bool isLoading;

  const _Screen4Confirmation({
    required this.state,
    required this.onTrackVerification,
    this.isLoading = false,
  });

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
            ('J3', 'Vérification administrative'),
            ('J5', 'Vérification coutumière'),
            ('J7', 'Vérification du voisinage & Géomètre'),
            ('J10', 'Décision du juriste & Rapport final'),
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

          // Navigation buttons (side by side)
          Row(
            children: [
              Expanded(
                child: FonciraButton(
                  label: 'Retour à l\'accueil',
                  variant: FonciraButtonVariant.outlined,
                  onPressed: () {
                    Navigator.popUntil(context, (route) => route.isFirst);
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FonciraButton(
                  label: 'Suivre ma vérification →',
                  isLoading: isLoading,
                  onPressed: isLoading ? null : onTrackVerification,
                ),
              ),
            ],
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
  @override
  void initState() {
    super.initState();
    // Mark verification as 'receptionnee' when payment screen appears
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _markAsReceptionnee();
    });
  }

  Future<void> _markAsReceptionnee() async {
    try {
      // Find and update the verification record by terrain_id
      final terrainId = widget.state.terrainId;
      if (terrainId != null) {
        // Find the verification to update
        final verifications = await SupabaseService.instance.client
            .from('verifications')
            .select('id')
            .eq('terrain_id', terrainId)
            .order('created_at', ascending: false)
            .limit(1);

        if (verifications.isNotEmpty) {
          final verificationId = verifications[0]['id'];
          await SupabaseService.instance.client
              .from('verifications')
              .update({
                'client_status': 'receptionnee',
                'updated_at': DateTime.now().toIso8601String(),
              })
              .eq('id', verificationId);
        }
      }
    } catch (e) {
      print('Erreur lors de la mise à jour du statut: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Success icon
          Center(
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: kSuccess.withOpacity(0.1),
                borderRadius: BorderRadius.circular(50),
              ),
              child: const Center(
                child: Icon(
                  Icons.check_circle_rounded,
                  size: 60,
                  color: kSuccess,
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),

          // Main message
          Center(
            child: Column(
              children: [
                Text(
                  'Votre demande est bien enregistrée',
                  style: GoogleFonts.outfit(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: kTextPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  'Un agent FONCIRA vous contactera sur WhatsApp sous 24h pour procéder au paiement et valider votre dossier.',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: kTextMuted,
                    height: 1.6,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),

          // Price summary
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: kDarkCard,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: kBorderDark),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Montant à régler',
                  style: GoogleFonts.inter(fontSize: 12, color: kTextMuted),
                ),
                const SizedBox(height: 12),
                PriceRow(
                  priceUsd: kVerificationPriceUSD.toDouble(),
                  priceFcfa: kVerificationPriceFCFA.toDouble(),
                  usdFontSize: 28,
                  fcfaFontSize: 12,
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),

          // WhatsApp CTA
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF25D366).withOpacity(0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFF25D366).withOpacity(0.3),
              ),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.phone_rounded,
                  size: 40,
                  color: Color(0xFF25D366),
                ),
                const SizedBox(height: 16),
                Text(
                  'Contacter FONCIRA',
                  style: GoogleFonts.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: kTextPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  '+228 93 43 60 02',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF25D366),
                    letterSpacing: 0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // WhatsApp button
          FonciraButton(
            label: 'Contacter sur WhatsApp →',
            onPressed: () => _openWhatsApp(context),
            icon: Icons.phone_rounded,
          ),
          const SizedBox(height: 12),

          // Info text
          Center(
            child: Text(
              '💡 Préparez votre dossier : documents, photos du terrain, identité valide.',
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

  void _openWhatsApp(BuildContext context) {
    final terrainTitle = widget.state.terrainTitre ?? 'mon terrain';
    final message = Uri.encodeComponent(
      'Bonjour FONCIRA, j\'ai soumis une demande de vérification pour $terrainTitle. Je souhaite procéder au paiement.',
    );
    final whatsappUrl = 'https://wa.me/22893436002?text=$message';

    try {
      launchUrl(Uri.parse(whatsappUrl), mode: LaunchMode.externalApplication);
    } catch (e) {
      print('Erreur lors de l\'ouverture de WhatsApp: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Erreur: impossible d\'ouvrir WhatsApp. Appelez +228 93 43 60 02',
          ),
        ),
      );
    }
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
            ('J1', 'Demande validée'),
            ('J3', 'Vérification administrative'),
            ('J5', 'Vérification coutumière'),
            ('J7', 'Vérification du voisinage & Géomètre'),
            ('J10', 'Décision du juriste & Rapport final'),
          ].map((item) {
            final index = [
              'Demande validée',
              'Vérification administrative',
              'Vérification coutumière',
              'Vérification du voisinage & Géomètre',
              'Décision du juriste & Rapport final',
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
    final emoji = state.niveauRisque == NiveauRisque.faible ? '🟢' : '🔴';
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
            ('⏰', 'Pas maintenant', 'Voir d\'autres terrains vérifiés', 'skip'),
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
                          Text('😍', style: GoogleFonts.outfit(fontSize: 32)),
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
                          Text('😐', style: GoogleFonts.outfit(fontSize: 32)),
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
                          Text('😞', style: GoogleFonts.outfit(fontSize: 32)),
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
                  const SizedBox(height: 40),
                  // Navigation buttons
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      FonciraButton(
                        label: 'Suivre ma vérification →',
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const SuivreVerificationPage(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton(
                        onPressed: () => Navigator.of(
                          context,
                        ).popUntil((route) => route.isFirst),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: kBorderDark),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Retour à l\'accueil',
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: kTextPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
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
