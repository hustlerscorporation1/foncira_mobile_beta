import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:country_picker/country_picker.dart';
import 'corbeille/accueil_acheteur.dart';

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({super.key});

  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final PageController _pageController = PageController();
  final confirmPasswordController = TextEditingController();
  TextEditingController countryController = TextEditingController();
  int _currentStep = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentStep < 3) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousPage() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _register(String email, String password) async {
    try {
      final res = await Supabase.instance.client.auth.signUp(
        password: password,
        email: email,
      );

      if (!mounted) return;
      if (res.user != null) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const RegistrationSuccessPage(),
          ),
        );
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Echec de l'inscription ")));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("erreur: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF0D1F17), Color(0xFF1B4332)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: _buildGlassmorphismContainer(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildProgressIndicator(),
                    const SizedBox(height: 24),
                    SizedBox(
                      height: 420,
                      child: PageView(
                        controller: _pageController,
                        physics: const NeverScrollableScrollPhysics(),
                        onPageChanged: (index) {
                          setState(() {
                            _currentStep = index;
                          });
                        },
                        children: [
                          _buildStep1(),
                          _buildStep2(),
                          _buildStep3(),
                          _buildStep4(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          if (_currentStep > 0)
            Positioned(
              top: 50,
              left: 15,
              child: IconButton(
                icon: const Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                  size: 30,
                ),
                onPressed: _previousPage,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStep1() {
    return _buildStepContainer(
      title: "Création du Compte",
      child: Column(
        children: [
          _buildTextField(label: "Adresse e-mail", icon: Icons.email_outlined),
          const SizedBox(height: 16),
          _buildPasswordField(
            controller: passwordController,
            label: "Mot de passe",
          ),
          const SizedBox(height: 16),
          _buildPasswordField(
            controller: confirmPasswordController,
            label: "Confirmer le mot de passe",
          ),
        ],
      ),
      onNext: _nextPage,
    );
  }

  Widget _buildStep2() {
    return _buildStepContainer(
      title: "Informations Personnelles",
      child: Column(
        children: [
          _buildTextField(label: "Nom complet", icon: Icons.person_outline),
          const SizedBox(height: 16),
          _buildTextField(
            label: "Numéro de téléphone",
            icon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: () {
              print("Chargement de la photo de profil...");
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withOpacity(0.4)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.camera_alt_outlined,
                    color: Colors.white.withOpacity(0.7),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    "Charger une photo de profil",
                    style: TextStyle(color: Colors.white.withOpacity(0.7)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      onNext: _nextPage,
    );
  }

  Widget _buildStep3() {
    return _buildStepContainer(
      title: "Votre Localisation",
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Ces informations nous aideront à vous envoyer les documents officiels (titre foncier, etc.) en toute sécurité.",
            style: TextStyle(color: Colors.white.withOpacity(0.8), height: 1.5),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          TextField(
            controller: countryController,
            readOnly: true,
            style: const TextStyle(color: Colors.white),
            onTap: () {
              showCountryPicker(
                context: context,
                showPhoneCode: true,
                onSelect: (Country country) {
                  countryController.text = country.name;
                  print(
                    'Pays sélectionné : ${country.name}, code : ${country.countryCode}',
                  );
                },
              );
            },
            decoration: InputDecoration(
              fillColor: Colors.white,
              labelText: "Pays de résidence",
              labelStyle: TextStyle(color: Colors.white),
              prefixIcon: const Icon(Icons.flag, color: Colors.white),
              suffixIcon: const Icon(Icons.arrow_drop_down),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),

          const SizedBox(height: 20),
          GestureDetector(
            onTap: () {
              print("Récupération de la position actuelle...");
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withOpacity(0.4)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.location_on_outlined,
                    color: Colors.white.withOpacity(0.7),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    "Utiliser ma position actuelle",
                    style: TextStyle(color: Colors.white.withOpacity(0.7)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      onNext: _nextPage,
    );
  }

  Widget _buildStep4() {
    return _buildStepContainer(
      title: "Devenez un Membre Vérifié",
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shield_outlined, color: Colors.green.shade200, size: 60),
          const SizedBox(height: 16),
          const Text(
            "Une Plateforme de Confiance",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            "Chez FONCIRA, la sécurité est notre priorité. Pour garantir des transactions 100% sécurisées et construire une communauté d'utilisateurs sérieux, nous vous invitons à vérifier votre identité.\n\nCe badge 'Vérifié' rassurera les autres membres et accélérera vos futures transactions.",
            style: TextStyle(color: Colors.white.withOpacity(0.8), height: 1.5),
            textAlign: TextAlign.center,
          ),
        ],
      ),
      onNext: () async {
        if (passwordController.text != confirmPasswordController.text) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Les mots de passe ne correspondent pas"),
            ),
          );
          return;
        }

        _register(emailController.text, passwordController.text);
      },
      buttonText: "Terminer l'inscription",
    );
  }

  Widget _buildProgressIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(4, (index) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: _currentStep == index ? 50 : 30,
          height: 6,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: _currentStep >= index
                ? Colors.green.shade300
                : Colors.white.withOpacity(0.3),
            borderRadius: BorderRadius.circular(5),
          ),
        );
      }),
    );
  }

  Widget _buildGlassmorphismContainer({required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(25.0),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(24.0),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(25.0),
            border: Border.all(
              color: Colors.white.withOpacity(0.1),
              width: 1.5,
            ),
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _buildStepContainer({
    required String title,
    required Widget child,
    required VoidCallback onNext,
    String buttonText = "Suivant",
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 24),
        Expanded(child: SingleChildScrollView(child: child)),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: onNext,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green.shade400,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(buttonText),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    required IconData icon,
    bool obscureText = false,
    TextInputType? keyboardType,
  }) {
    return TextField(
      obscureText: obscureText,
      style: const TextStyle(color: Colors.white),
      keyboardType: keyboardType,

      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
        prefixIcon: Icon(icon, color: Colors.white.withOpacity(0.7)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.4)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.green.shade300),
        ),
      ),
    );
  }
}

Widget _buildPasswordField({
  required TextEditingController controller,
  required String label,
}) {
  bool _isVisible = false;

  return StatefulBuilder(
    builder: (context, setState) {
      return TextField(
        controller: controller,
        obscureText: !_isVisible,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
          prefixIcon: Icon(
            Icons.lock_outline,
            color: Colors.white.withOpacity(0.7),
          ),
          suffixIcon: IconButton(
            icon: Icon(
              _isVisible ? Icons.visibility : Icons.visibility_off,
              color: Colors.white.withOpacity(0.7),
            ),
            onPressed: () {
              setState(() {
                _isVisible = !_isVisible;
              });
            },
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.white.withOpacity(0.4)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.green.shade300),
          ),
        ),
      );
    },
  );
}

class RegistrationSuccessPage extends StatelessWidget {
  const RegistrationSuccessPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0D1F17), Color(0xFF1B4332)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.check_circle_outline,
                  color: Colors.greenAccent,
                  size: 100,
                ),
                const SizedBox(height: 24),
                const Text(
                  "Félicitations !",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  "Votre compte a été créé avec succès. Bienvenue dans la communauté FONCIRA !",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 16,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (context) => HomePage()),
                      (route) => false,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade400,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 32,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text("Commencer l'exploration"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
