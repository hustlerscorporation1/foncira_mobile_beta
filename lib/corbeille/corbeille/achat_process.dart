import 'package:flutter/material.dart';
import '../../component/terrain.dart';

const kGreen = Color(0xFF16A34A);

class AchatProcessPage extends StatefulWidget {
  final Terrain terrain;

  const AchatProcessPage({super.key, required this.terrain});

  @override
  State<AchatProcessPage> createState() => _AchatProcessPageState();
}

class _AchatProcessPageState extends State<AchatProcessPage> {
  int _currentStep = 0;
  String? _paymentMethod;
  String? _country;
  bool _withOTR = false;

  final List<String> steps = [
    "Vérification",
    "Paiement",
    "Infos OTR",
    "Confirmation",
  ];

  void _nextStep() {
    if (_currentStep < steps.length - 1) {
      setState(() => _currentStep++);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Achat confirmé ✅")));
      Navigator.pop(context);
    }
  }

  void _prevStep() {
    if (_currentStep > 0) setState(() => _currentStep--);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Acheter un terrain"),
        backgroundColor: kGreen,
      ),
      body: Column(
        children: [
          // ---- Progression ----
          Padding(
            padding: const EdgeInsets.all(16),
            child: LinearProgressIndicator(
              value: (_currentStep + 1) / steps.length,
              backgroundColor: Colors.grey.shade300,
              color: kGreen,
              minHeight: 8,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          Text(
            "Étape ${_currentStep + 1}/${steps.length} : ${steps[_currentStep]}",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // ---- Contenu ----
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              child: _buildStepContent(_currentStep),
            ),
          ),
        ],
      ),

      // ✅ Boutons fixés en bas
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            if (_currentStep > 0)
              Expanded(
                child: OutlinedButton(
                  onPressed: _prevStep,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: kGreen,
                    side: const BorderSide(color: kGreen),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text("Retour"),
                ),
              ),
            if (_currentStep > 0) const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: _nextStep,
                style: ElevatedButton.styleFrom(
                  backgroundColor: kGreen,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: Text(
                  _currentStep == steps.length - 1 ? "Confirmer" : "Suivant",
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---- Étapes modernes ----
  Widget _buildStepContent(int step) {
    switch (step) {
      case 0:
        return _buildCard(
          icon: Icons.verified,
          title: "Vérification du terrain",
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Titre : ${widget.terrain.title}"),
              Text("Localisation : ${widget.terrain.location}"),
              Text("Prix : ${widget.terrain.price}"),
              Text("Surface : ${widget.terrain.surface}"),
              Text("Constructible : ${widget.terrain.isConstructible}"),
              Text("Vue : ${widget.terrain.vue}"),
              Text("Viabilisation : ${widget.terrain.isViabilise}"),
              Text("Statut : ${widget.terrain.verificationFoncira.label}"),

              
            ],
          ),
        );

      case 1:
        return _buildCard(
          icon: Icons.payment,
          title: "Choisissez un mode de paiement",
          child: Column(
            children: [
              RadioListTile<String>(
                value: "Mobile Money",
                groupValue: _paymentMethod,
                onChanged: (value) => setState(() => _paymentMethod = value),
                title: const Text("Mobile Money"),
              ),
              RadioListTile<String>(
                value: "Carte bancaire",
                groupValue: _paymentMethod,
                onChanged: (value) => setState(() => _paymentMethod = value),
                title: const Text("Carte bancaire"),
              ),
            ],
          ),
        );

      case 2:
        return _buildCard(
          icon: Icons.public,
          title: "Informations OTR",
          child: Column(
            children: [
              TextField(
                decoration: const InputDecoration(
                  labelText: "Pays de résidence",
                  border: OutlineInputBorder(),
                ),
                onChanged: (val) => _country = val,
              ),
              const SizedBox(height: 12),
              CheckboxListTile(
                value: _withOTR,
                onChanged: (value) => setState(() => _withOTR = value!),
                title: const Text("Je veux que l'équipe gère mes papiers OTR"),
              ),
            ],
          ),
        );

      case 3:
        return _buildCard(
          icon: Icons.check_circle,
          title: "Confirmation",
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Terrain : ${widget.terrain.title}"),
              Text("Prix : ${widget.terrain.price}"),
              Text("Paiement : ${_paymentMethod ?? "Non choisi"}"),
              Text("Pays : ${_country ?? "Non renseigné"}"),
              Text("OTR : ${_withOTR ? "Oui" : "Non"}"),
              const SizedBox(height: 16),
              const Text(
                "En confirmant, vous recevrez vos documents par poste ou en ligne.",
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        );

      default:
        return const SizedBox();
    }
  }

  // ---- Card générique pour chaque étape ----
  Widget _buildCard({
    required IconData icon,
    required String title,
    required Widget child,
  }) {
    return Card(
      key: ValueKey(title),
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: kGreen, size: 28),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }
}
