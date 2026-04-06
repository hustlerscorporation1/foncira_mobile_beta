import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'corbeille/accueil_acheteur.dart';
import '../page/accueil_vendeur.dart';

// Réutilisons notre palette de couleurs pour la cohérence
const Color darkBackground = Color(0xFF101C17);
const Color cardBackground = Color(0xFF1B2B24);
const Color primaryGreen = Color(0xFF00C853);
const Color textColor = Colors.white;
const Color hintColor = Colors.white70;

class ChooseRolePage extends StatefulWidget {
  const ChooseRolePage({super.key});

  @override
  State<ChooseRolePage> createState() => _ChooseRolePageState();
}

class _ChooseRolePageState extends State<ChooseRolePage> {
  String? _isLoadingRole;

  Future<void> _setRole(BuildContext context, String role) async {
    setState(() {
      _isLoadingRole = role;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString("role", role);

      if (!mounted) return;

      final pageRoute = MaterialPageRoute(
        builder: (_) =>
            role == "buyer" ? const HomePage() : const SellerHomePage(),
      );

      Navigator.pushReplacement(context, pageRoute);
    } catch (e) {
      // En cas d'erreur, cache l'indicateur et affiche un message
      setState(() {
        _isLoadingRole = null;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Une erreur est survenue: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkBackground,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                "Quel est votre rôle ?",
                textAlign: TextAlign.center,
                style: GoogleFonts.playfairDisplay(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ).animate().fade(duration: 600.ms).slideY(begin: -0.2),

              const SizedBox(height: 16),

              Text(
                "Sélectionnez comment vous souhaitez utiliser l'application.",
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(fontSize: 16, color: hintColor),
              ).animate().fade(duration: 600.ms, delay: 200.ms),

              const SizedBox(height: 48),

              _buildRoleCard(
                context: context,
                icon: Icons.shopping_cart_outlined,
                title: "Je suis Acheteur",
                subtitle:
                    "Parcourez, découvrez et achetez des terrains en toute sécurité.",
                role: "buyer",
              ).animate().fade(duration: 600.ms, delay: 400.ms).slideX(begin: -0.5),

              const SizedBox(height: 24),

              _buildRoleCard(
                context: context,
                icon: Icons.sell_outlined,
                title: "Je suis Vendeur",
                subtitle:
                    "Mettez en vente vos propriétés et trouvez des acquéreurs fiables.",
                role: "seller",
              ).animate().fade(duration: 600.ms, delay: 600.ms).slideX(begin: 0.5),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required String role,
  }) {
    final bool isLoading = _isLoadingRole == role;

    return GestureDetector(
      onTap: isLoading ? null : () => _setRole(context, role),
      child: Container(
        padding: const EdgeInsets.all(24.0),
        decoration: BoxDecoration(
          color: cardBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Column(
          children: [
            if (isLoading)
              const SizedBox(
                height: 48,
                width: 48,
                child: CircularProgressIndicator(color: primaryGreen),
              )
            else
              Icon(icon, size: 48, color: primaryGreen),

            const SizedBox(height: 16),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: hintColor,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
