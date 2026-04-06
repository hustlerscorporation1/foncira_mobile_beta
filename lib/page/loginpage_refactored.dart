import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/colors.dart';
import '../component/foncira_button.dart';
import '../adapters/user_adapter.dart';
import 'registerpage.dart';

// ══════════════════════════════════════════════════════════════
//  FONCIRA — Login Page (premium dark design)
// ══════════════════════════════════════════════════════════════

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool _isLoading = false;
  bool _isPasswordVisible = false;
  final userAdapter = UserAdapter();

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await userAdapter.signIn(
        emailController.text.trim(),
        passwordController.text.trim(),
      );

      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/home');
    } on AuthException catch (e) {
      _showError(e.message);
    } catch (e) {
      _showError('Erreur de connexion: $e');
    }

    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _signInWithSocial(Future<bool> Function() callback) async {
    setState(() => _isLoading = true);
    final success = await callback();
    if (!mounted) return;
    if (success) Navigator.pushReplacementNamed(context, '/home');
    if (mounted) setState(() => _isLoading = false);
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: kDanger,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kDarkBg,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ── Logo ──
                  Image.asset('assets/Image/FONCIRA.png', width: 80)
                      .animate()
                      .fade(duration: 600.ms)
                      .scale(begin: const Offset(0.8, 0.8)),
                  const SizedBox(height: 32),

                  // ── Title ──
                  Text(
                    'Content de vous revoir',
                    style: GoogleFonts.outfit(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      color: kTextPrimary,
                    ),
                  ).animate().fade(duration: 600.ms, delay: 200.ms),
                  const SizedBox(height: 8),
                  Text(
                    'Connectez-vous à votre compte FONCIRA',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: kTextSecondary,
                    ),
                  ).animate().fade(duration: 600.ms, delay: 300.ms),
                  const SizedBox(height: 40),

                  // ── Card ──
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: kDarkCard,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: kBorderDark),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Email field
                        _buildLabel('Adresse e-mail'),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: emailController,
                          style: GoogleFonts.inter(color: kTextPrimary, fontSize: 14),
                          keyboardType: TextInputType.emailAddress,
                          decoration: _inputDecoration(
                            'vous@exemple.com',
                            Icons.email_outlined,
                          ),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return 'Adresse e-mail requise';
                            }
                            if (!RegExp(r'\S+@\S+\.\S+').hasMatch(v)) {
                              return 'Adresse e-mail invalide';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),

                        // Password field
                        _buildLabel('Mot de passe'),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: passwordController,
                          obscureText: !_isPasswordVisible,
                          style: GoogleFonts.inter(color: kTextPrimary, fontSize: 14),
                          decoration: _inputDecoration(
                            '••••••••',
                            Icons.lock_outline_rounded,
                          ).copyWith(
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isPasswordVisible
                                    ? Icons.visibility_off_rounded
                                    : Icons.visibility_rounded,
                                color: kTextMuted,
                                size: 20,
                              ),
                              onPressed: () {
                                setState(() {
                                  _isPasswordVisible = !_isPasswordVisible;
                                });
                              },
                            ),
                          ),
                          validator: (v) {
                            if (v == null || v.isEmpty) {
                              return 'Mot de passe requis';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),

                        Align(
                          alignment: Alignment.centerRight,
                          child: GestureDetector(
                            onTap: () {},
                            child: Text(
                              'Mot de passe oublié ?',
                              style: GoogleFonts.inter(
                                color: kPrimaryLight,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 28),

                        // Login button
                        FonciraButton(
                          label: 'Se connecter',
                          icon: Icons.login_rounded,
                          isLoading: _isLoading,
                          onPressed: _isLoading ? null : _signIn,
                        ),
                      ],
                    ),
                  ).animate().fade(duration: 600.ms, delay: 400.ms).slideY(begin: 0.1),

                  const SizedBox(height: 28),

                  // ── Social login ──
                  Row(
                    children: [
                      const Expanded(child: Divider(color: kBorderDark)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'Ou continuer avec',
                          style: GoogleFonts.inter(
                            color: kTextMuted,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      const Expanded(child: Divider(color: kBorderDark)),
                    ],
                  ).animate().fade(duration: 600.ms, delay: 500.ms),
                  const SizedBox(height: 20),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildSocialBtn(
                        FontAwesomeIcons.google,
                        () => _signInWithSocial(userAdapter.signInWithGoogle),
                      ),
                      const SizedBox(width: 20),
                      _buildSocialBtn(
                        FontAwesomeIcons.apple,
                        () => _signInWithSocial(userAdapter.signInWithApple),
                      ),
                    ],
                  ).animate().fade(duration: 600.ms, delay: 600.ms),
                  const SizedBox(height: 32),

                  // ── Register link ──
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const Registration(),
                        ),
                      );
                    },
                    child: RichText(
                      text: TextSpan(
                        style: GoogleFonts.inter(
                          color: kTextSecondary,
                          fontSize: 14,
                        ),
                        children: [
                          const TextSpan(text: 'Pas encore de compte ? '),
                          TextSpan(
                            text: 'Créer un compte',
                            style: TextStyle(
                              color: kPrimaryLight,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ).animate().fade(duration: 600.ms, delay: 700.ms),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.inter(
        color: kTextSecondary,
        fontSize: 13,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  InputDecoration _inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.inter(color: kTextMuted, fontSize: 14),
      prefixIcon: Icon(icon, color: kTextMuted, size: 18),
      filled: true,
      fillColor: kDarkCardLight,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: kBorderDark),
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
    );
  }

  Widget _buildSocialBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: _isLoading ? null : onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: kDarkCard,
          shape: BoxShape.circle,
          border: Border.all(color: kBorderDark),
        ),
        child: FaIcon(icon, color: kTextPrimary, size: 20),
      ),
    );
  }
}
