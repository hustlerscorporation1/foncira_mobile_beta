import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../theme/colors.dart';
import 'marketplace_page.dart';
import 'verification_tracking_page.dart';
import 'external_verification_page.dart';
import 'favoris_foncira.dart';
import 'settings_page.dart';
import 'help_support_page.dart';
import 'about_foncira_page.dart';

// ══════════════════════════════════════════════════════════════
//  FONCIRA — Profile Page (redesigned)
// ══════════════════════════════════════════════════════════════

class Profil extends StatefulWidget {
  const Profil({super.key});

  @override
  State<Profil> createState() => _ProfilState();
}

class _ProfilState extends State<Profil> {
  String _userName = '';
  String _email = '';
  File? _image;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final user = Supabase.instance.client.auth.currentUser;
    setState(() {
      _userName =
          prefs.getString('name') ??
          user?.email?.split('@').first ??
          'Utilisateur';
      _email = user?.email ?? '';
      final path = prefs.getString('profileImagePath');
      if (path != null) _image = File(path);
    });
  }

  Future<void> _signOut() async {
    await Supabase.instance.client.auth.signOut();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kDarkBg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 16),
              const SizedBox(height: 24),

              // ── Avatar ──
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: kGradientGold,
                ),
                child: CircleAvatar(
                  radius: 48,
                  backgroundColor: kDarkCard,
                  backgroundImage: _image != null ? FileImage(_image!) : null,
                  child: _image == null
                      ? const Icon(
                          Icons.person_rounded,
                          color: kTextMuted,
                          size: 40,
                        )
                      : null,
                ),
              ),
              const SizedBox(height: 16),

              Text(
                _userName,
                style: GoogleFonts.outfit(
                  color: kTextPrimary,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _email,
                style: GoogleFonts.inter(color: kTextMuted, fontSize: 13),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: kGoldSurface,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Membre FONCIRA',
                  style: GoogleFonts.inter(
                    color: kGold,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // ── Menu items ──
              _buildMenuItem(
                Icons.explore_rounded,
                'Explorer les terrains',
                kPrimaryLight,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const MarketplacePage()),
                ),
              ),
              _buildMenuItem(
                Icons.verified_user_rounded,
                'Vérifier un terrain externe',
                kGold,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ExternalVerificationPage(),
                  ),
                ),
              ),
              _buildMenuItem(
                Icons.assignment_rounded,
                'Mes vérifications',
                kInfo,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const VerificationTrackingPage(),
                  ),
                ),
              ),
              _buildMenuItem(
                Icons.favorite_rounded,
                'Mes favoris',
                kDanger,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const FavorisPageFoncira()),
                ),
              ),
              const SizedBox(height: 8),
              const Divider(color: kBorderDark),
              const SizedBox(height: 8),
              _buildMenuItem(
                Icons.settings_rounded,
                'Paramètres',
                kTextMuted,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SettingsPage()),
                ),
              ),
              _buildMenuItem(
                Icons.help_outline_rounded,
                'Aide & Support',
                kTextMuted,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const HelpSupportPage()),
                ),
              ),
              _buildMenuItem(
                Icons.info_outline_rounded,
                'À propos de FONCIRA',
                kTextMuted,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AboutFonciraPage()),
                ),
              ),
              const SizedBox(height: 8),
              const Divider(color: kBorderDark),
              const SizedBox(height: 8),
              _buildMenuItem(
                Icons.logout_rounded,
                'Se déconnecter',
                kDanger,
                () => _showLogoutDialog(),
              ),
              const SizedBox(height: 32),

              // ── Version ──
              Text(
                'FONCIRA v1.0.0',
                style: GoogleFonts.inter(color: kTextMuted, fontSize: 11),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    IconData icon,
    String label,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: kDarkCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: kBorderDark),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.inter(
                  color: kTextPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              color: kTextMuted,
              size: 14,
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: kDarkCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Se déconnecter',
          style: GoogleFonts.outfit(
            color: kTextPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'Voulez-vous vraiment vous déconnecter ?',
          style: GoogleFonts.inter(color: kTextSecondary, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Annuler', style: GoogleFonts.inter(color: kTextMuted)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _signOut();
            },
            child: Text(
              'Déconnexion',
              style: GoogleFonts.inter(
                color: kDanger,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
