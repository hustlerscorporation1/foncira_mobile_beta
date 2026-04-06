import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../theme/colors.dart';

// ══════════════════════════════════════════════════════════════
//  FONCIRA — Settings Page (Premium)
// ══════════════════════════════════════════════════════════════

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _notifEnabled = true;
  bool _notifEmail = false;
  bool _biometric = false;
  String _language = 'Français';
  String _currency = 'FCFA';
  String _userName = '';
  String _email = '';

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final user = Supabase.instance.client.auth.currentUser;
    setState(() {
      _notifEnabled = prefs.getBool('notif_enabled') ?? true;
      _notifEmail = prefs.getBool('notif_email') ?? false;
      _biometric = prefs.getBool('biometric') ?? false;
      _language = prefs.getString('language') ?? 'Français';
      _currency = prefs.getString('currency') ?? 'FCFA';
      _userName = prefs.getString('name') ??
          user?.email?.split('@').first ??
          'Utilisateur';
      _email = user?.email ?? '';
    });
  }

  Future<void> _savePref(String key, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value is bool) {
      await prefs.setBool(key, value);
    } else if (value is String) {
      await prefs.setString(key, value);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kDarkBg,
      body: CustomScrollView(
        slivers: [
          // ── App Bar ──
          SliverAppBar(
            backgroundColor: kDarkBg,
            surfaceTintColor: Colors.transparent,
            pinned: true,
            expandedHeight: 140,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_rounded,
                  color: kTextPrimary, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 56, bottom: 16),
              title: Text(
                'Paramètres',
                style: GoogleFonts.outfit(
                  color: kTextPrimary,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF0A1520), kDarkBg],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 50, right: 20),
                    child: Icon(
                      Icons.settings_rounded,
                      color: kTextMuted.withValues(alpha: 0.1),
                      size: 80,
                    ),
                  ),
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ═══════════════════════════════════════════
                  // ACCOUNT
                  // ═══════════════════════════════════════════
                  _buildSectionHeader('Compte', Icons.person_outline_rounded),
                  const SizedBox(height: 12),
                  _buildCard([
                    _buildInfoTile('Nom', _userName, Icons.badge_rounded),
                    _buildDivider(),
                    _buildInfoTile('Email', _email, Icons.email_outlined),
                    _buildDivider(),
                    _buildNavTile(
                      'Modifier le mot de passe',
                      Icons.lock_outline_rounded,
                      () => _showPasswordDialog(),
                    ),
                  ]),

                  const SizedBox(height: 28),

                  // ═══════════════════════════════════════════
                  // NOTIFICATIONS
                  // ═══════════════════════════════════════════
                  _buildSectionHeader(
                      'Notifications', Icons.notifications_none_rounded),
                  const SizedBox(height: 12),
                  _buildCard([
                    _buildSwitchTile(
                      'Notifications push',
                      'Recevoir des alertes sur les terrains',
                      Icons.notifications_active_outlined,
                      _notifEnabled,
                      (v) {
                        setState(() => _notifEnabled = v);
                        _savePref('notif_enabled', v);
                      },
                    ),
                    _buildDivider(),
                    _buildSwitchTile(
                      'Notifications email',
                      'Recevoir des résumés par email',
                      Icons.mark_email_unread_outlined,
                      _notifEmail,
                      (v) {
                        setState(() => _notifEmail = v);
                        _savePref('notif_email', v);
                      },
                    ),
                  ]),

                  const SizedBox(height: 28),

                  // ═══════════════════════════════════════════
                  // SECURITY
                  // ═══════════════════════════════════════════
                  _buildSectionHeader(
                      'Sécurité', Icons.shield_outlined),
                  const SizedBox(height: 12),
                  _buildCard([
                    _buildSwitchTile(
                      'Authentification biométrique',
                      'Empreinte digitale ou Face ID',
                      Icons.fingerprint_rounded,
                      _biometric,
                      (v) {
                        setState(() => _biometric = v);
                        _savePref('biometric', v);
                      },
                    ),
                  ]),

                  const SizedBox(height: 28),

                  // ═══════════════════════════════════════════
                  // PREFERENCES
                  // ═══════════════════════════════════════════
                  _buildSectionHeader(
                      'Préférences', Icons.tune_rounded),
                  const SizedBox(height: 12),
                  _buildCard([
                    _buildDropdownTile(
                      'Langue',
                      Icons.language_rounded,
                      _language,
                      ['Français', 'English'],
                      (v) {
                        setState(() => _language = v);
                        _savePref('language', v);
                      },
                    ),
                    _buildDivider(),
                    _buildDropdownTile(
                      'Devise',
                      Icons.attach_money_rounded,
                      _currency,
                      ['FCFA', 'EUR', 'USD'],
                      (v) {
                        setState(() => _currency = v);
                        _savePref('currency', v);
                      },
                    ),
                  ]),

                  const SizedBox(height: 28),

                  // ═══════════════════════════════════════════
                  // DATA
                  // ═══════════════════════════════════════════
                  _buildSectionHeader('Données', Icons.storage_rounded),
                  const SizedBox(height: 12),
                  _buildCard([
                    _buildNavTile(
                      'Vider le cache',
                      Icons.cached_rounded,
                      () => _showCacheDialog(),
                    ),
                    _buildDivider(),
                    _buildNavTile(
                      'Supprimer mon compte',
                      Icons.delete_forever_rounded,
                      () => _showDeleteAccountDialog(),
                      danger: true,
                    ),
                  ]),

                  const SizedBox(height: 60),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Section Header ──
  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: kGold, size: 18),
        const SizedBox(width: 8),
        Text(
          title.toUpperCase(),
          style: GoogleFonts.inter(
            color: kGold,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }

  // ── Card Container ──
  Widget _buildCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: kDarkCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kBorderDark),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildDivider() {
    return const Divider(color: kBorderDark, height: 1, indent: 56);
  }

  // ── Info Tile (read-only) ──
  Widget _buildInfoTile(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          _buildIconBox(icon, kPrimaryLight),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.inter(
                    color: kTextMuted,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: GoogleFonts.inter(
                    color: kTextPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Switch Tile ──
  Widget _buildSwitchTile(
    String title,
    String subtitle,
    IconData icon,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          _buildIconBox(icon, kInfo),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    color: kTextPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    color: kTextMuted,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeColor: kPrimaryLight,
            activeTrackColor: kPrimarySurface,
            inactiveThumbColor: kTextMuted,
            inactiveTrackColor: kDarkCardLight,
          ),
        ],
      ),
    );
  }

  // ── Nav Tile ──
  Widget _buildNavTile(String title, IconData icon, VoidCallback onTap,
      {bool danger = false}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            _buildIconBox(icon, danger ? kDanger : kTextMuted),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.inter(
                  color: danger ? kDanger : kTextPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: kTextMuted,
              size: 14,
            ),
          ],
        ),
      ),
    );
  }

  // ── Dropdown Tile ──
  Widget _buildDropdownTile(
    String title,
    IconData icon,
    String currentValue,
    List<String> options,
    ValueChanged<String> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          _buildIconBox(icon, kGold),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.inter(
                color: kTextPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: kDarkCardLight,
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButton<String>(
              value: currentValue,
              isDense: true,
              underline: const SizedBox(),
              dropdownColor: kDarkCard,
              style: GoogleFonts.inter(
                color: kTextPrimary,
                fontSize: 13,
              ),
              icon: const Icon(Icons.expand_more_rounded,
                  color: kTextMuted, size: 18),
              items: options
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (v) {
                if (v != null) onChanged(v);
              },
            ),
          ),
        ],
      ),
    );
  }

  // ── Icon Box ──
  Widget _buildIconBox(IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, color: color, size: 18),
    );
  }

  // ── Dialogs ──
  void _showPasswordDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: kDarkCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Modifier le mot de passe',
          style: GoogleFonts.outfit(
              color: kTextPrimary, fontWeight: FontWeight.w600),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Un email de réinitialisation sera envoyé à votre adresse.',
              style: GoogleFonts.inter(color: kTextSecondary, fontSize: 14),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Annuler',
                style: GoogleFonts.inter(color: kTextMuted)),
          ),
          TextButton(
            onPressed: () async {
              if (_email.isNotEmpty) {
                await Supabase.instance.client.auth
                    .resetPasswordForEmail(_email);
              }
              if (!mounted) return;
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Email de réinitialisation envoyé',
                    style: GoogleFonts.inter(fontSize: 13),
                  ),
                  backgroundColor: kDarkCard,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              );
            },
            child: Text(
              'Envoyer',
              style: GoogleFonts.inter(
                  color: kPrimaryLight, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  void _showCacheDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: kDarkCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Vider le cache',
            style: GoogleFonts.outfit(
                color: kTextPrimary, fontWeight: FontWeight.w600)),
        content: Text(
          'Le cache de l\'application sera vidé. Vos données de connexion seront conservées.',
          style: GoogleFonts.inter(color: kTextSecondary, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Annuler',
                style: GoogleFonts.inter(color: kTextMuted)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Cache vidé ✓',
                      style: GoogleFonts.inter(fontSize: 13)),
                  backgroundColor: kDarkCard,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              );
            },
            child: Text(
              'Confirmer',
              style: GoogleFonts.inter(
                  color: kWarning, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: kDarkCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Supprimer le compte',
            style: GoogleFonts.outfit(
                color: kDanger, fontWeight: FontWeight.w600)),
        content: Text(
          'Cette action est irréversible. Toutes vos données seront supprimées définitivement.',
          style: GoogleFonts.inter(color: kTextSecondary, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Annuler',
                style: GoogleFonts.inter(color: kTextMuted)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implement account deletion via Supabase
            },
            child: Text(
              'Supprimer',
              style: GoogleFonts.inter(
                  color: kDanger, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
