// ignore_for_file: deprecated_member_use

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:country_picker/country_picker.dart';

// --- PAGE D'INSCRIPTION MULTI-ÉTAPES ---

class Registration extends StatefulWidget {
  const Registration({super.key});

  @override
  State<Registration> createState() => _RegistrationState();
}

class _RegistrationState extends State<Registration> {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  bool _isLoading = false;

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final fullNameController = TextEditingController();
  final phoneController = TextEditingController();
  final countryController = TextEditingController();
  String _selectedCountryCode = 'TG';

  final _formKeyStep1 = GlobalKey<FormState>();
  final _formKeyStep2 = GlobalKey<FormState>();

  @override
  void dispose() {
    _pageController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    fullNameController.dispose();
    phoneController.dispose();
    countryController.dispose();
    super.dispose();
  }

  void _nextPage(GlobalKey<FormState>? formKey) {
    if (formKey != null && !formKey.currentState!.validate()) return;

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

  Future<void> _register() async {
    if (passwordController.text != confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Les mots de passe ne correspondent pas")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final fullName = fullNameController.text.trim();
      final firstName = fullName.isEmpty ? null : fullName.split(' ').first;
      final lastName = fullName.contains(' ')
          ? fullName.split(' ').skip(1).join(' ')
          : null;

      final AuthResponse res = await Supabase.instance.client.auth.signUp(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
        data: {
          'first_name': firstName,
          'last_name': lastName,
          'full_name': fullName,
          'phone_number': phoneController.text.trim(),
          'country_code': _selectedCountryCode,
        },
      );

      if (!mounted) return;

      final newUser = res.user;
      if (newUser != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString("name", fullNameController.text.trim());

        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const RegistrationSuccessPage(),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Échec de l'inscription. L'utilisateur existe peut-être déjà.",
            ),
          ),
        );
      }
    } on AuthException catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Erreur: ${e.message}")));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Une erreur inattendue est survenue: $e")),
      );
    }

    if (mounted) setState(() => _isLoading = false);
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

  // --- Étapes ---

  Widget _buildStep1() {
    return _buildStepContainer(
      title: "Création du Compte",
      child: Form(
        key: _formKeyStep1,
        child: Column(
          children: [
            _buildTextFormField(
              controller: emailController,
              label: "Adresse e-mail",
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return "L'e-mail est requis";
                }
                if (!RegExp(r'\S+@\S+\.\S+').hasMatch(value)) {
                  return "Veuillez entrer un e-mail valide";
                }
                return null;
              },
            ),
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
      ),
      onNext: () => _nextPage(_formKeyStep1),
    );
  }

  Widget _buildStep2() {
    return _buildStepContainer(
      title: "Informations Personnelles",
      child: Form(
        key: _formKeyStep2,
        child: Column(
          children: [
            _buildTextFormField(
              controller: fullNameController,
              label: "Nom complet",
              icon: Icons.person_outline,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return "Le nom complet est requis";
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            _buildTextFormField(
              controller: phoneController,
              label: "Numéro de téléphone",
              icon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return "Le numéro de téléphone est requis";
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            _buildTextFormField(
              controller: countryController,
              label: "Pays de résidence",
              icon: Icons.flag,
              readOnly: true,
              onTap: () {
                showCountryPicker(
                  context: context,
                  onSelect: (Country country) {
                    setState(() {
                      countryController.text = country.name;
                      _selectedCountryCode = country.countryCode;
                    });
                  },
                );
              },
            ),
          ],
        ),
      ),
      onNext: () => _nextPage(_formKeyStep2),
    );
  }

  Widget _buildStep3() {
    return _buildStepContainer(
      title: "Que faire après l'inscription",
      child: const Center(
        child: Text(
          "Ajoutez votre photo de profil et votre pièce d’identité. "
          "Cela nous permet de mieux vous accompagner et de remplir automatiquement "
          "vos informations lors de vos ventes ou achats.",
          style: TextStyle(color: Colors.white70),
          textAlign: TextAlign.center,
        ),
      ),
      onNext: () => _nextPage(null),
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
            "Pour garantir des transactions 100% sécurisées, veuillez vérifier votre identité et votre email.",
            style: TextStyle(color: Colors.white.withOpacity(0.8), height: 1.5),
            textAlign: TextAlign.center,
          ),
        ],
      ),
      onNext: _register,
      buttonText: "Terminer l'inscription",
    );
  }

  // --- Widgets réutilisables ---

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
            backgroundColor: _isLoading ? Colors.grey : Colors.green.shade400,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: _isLoading && _currentStep == 3
              ? const SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 3,
                  ),
                )
              : Text(buttonText),
        ),
      ],
    );
  }

  TextFormField _buildTextFormField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool readOnly = false,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    VoidCallback? onTap,
  }) {
    return TextFormField(
      controller: controller,
      readOnly: readOnly,
      onTap: onTap,
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
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
        ),
      ),
      validator: validator,
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
  }) {
    bool isVisible = false;

    return StatefulBuilder(
      builder: (context, setState) {
        return TextFormField(
          controller: controller,
          obscureText: !isVisible,
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
                isVisible ? Icons.visibility : Icons.visibility_off,
                color: Colors.white.withOpacity(0.7),
              ),
              onPressed: () {
                setState(() {
                  isVisible = !isVisible;
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
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.redAccent),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return "Le mot de passe est requis";
            }
            if (value.length < 6) {
              return "Le mot de passe doit contenir au moins 6 caractères";
            }
            return null;
          },
        );
      },
    );
  }
}

// --- PAGE DE SUCCÈS ---

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
                  "Votre compte a été créé avec succès. Pour finaliser, veuillez vérifier votre boîte de réception et cliquer sur le lien de confirmation.",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 16,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                ElevatedButton(
                  onPressed: () async {
                    final user = Supabase.instance.client.auth.currentUser;

                    if (user != null && user.emailConfirmedAt != null) {
                      Navigator.of(
                        context,
                      ).pushNamedAndRemoveUntil('/home', (route) => false);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            "Veuillez vérifier votre email avant d'accéder à la communauté.",
                          ),
                        ),
                      );
                    }
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
                  child: const Text("Accéder à la communauté"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
