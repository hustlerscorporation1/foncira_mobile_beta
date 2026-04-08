// ══════════════════════════════════════════════════════════════
//  FONCIRA — Admin Dashboard Settings Tab
// ══════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:foncira/theme/colors.dart';
import 'package:google_fonts/google_fonts.dart';

class AdminSettingsTab extends StatefulWidget {
  const AdminSettingsTab({super.key});

  @override
  State<AdminSettingsTab> createState() => _AdminSettingsTabState();
}

class _AdminSettingsTabState extends State<AdminSettingsTab> {
  bool _notificationsEnabled = true;
  bool _maintenanceMode = false;
  String _verificationDays = '10';

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Titre
          Text(
            'Paramètres système',
            style: GoogleFonts.outfit(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 24),

          // Section Notifications
          _buildSection(
            title: 'Notifications',
            children: [
              _buildSettingTile(
                title: 'Activer les notifications',
                subtitle: 'Recevoir les alertes du système',
                isSwitch: true,
                value: _notificationsEnabled,
                onChanged: (value) {
                  setState(() {
                    _notificationsEnabled = value;
                  });
                },
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Section Vérification
          _buildSection(
            title: 'Flux de vérification',
            children: [
              _buildSettingTile(
                title: 'Délai de vérification',
                subtitle: 'Nombre de jours pour une vérification complète',
                isDropdown: true,
                dropdownValue: _verificationDays,
                dropdownItems: ['5', '7', '10', '14', '21'],
                onDropdownChanged: (value) {
                  setState(() {
                    _verificationDays = value!;
                  });
                },
              ),
              _buildSettingTile(
                title: 'Envoyer rappels automatiques',
                subtitle: 'Rappels aux agents à J3, J7, J10',
                isSwitch: true,
                value: true,
                onChanged: (value) {},
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Section Maintenance
          _buildSection(
            title: 'Maintenance',
            children: [
              _buildSettingTile(
                title: 'Mode maintenance',
                subtitle: 'Désactiver la marketplace pour les utilisateurs',
                isSwitch: true,
                value: _maintenanceMode,
                onChanged: (value) {
                  setState(() {
                    _maintenanceMode = value;
                  });
                },
              ),
              _buildSettingTile(
                title: 'Message de maintenance',
                subtitle: 'Message affiché aux utilisateurs',
                isTextField: true,
                onPressed: () {
                  _showMaintenanceMessageDialog(context);
                },
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Section Commissions
          _buildSection(
            title: 'Configuration des frais',
            children: [
              _buildSettingTile(
                title: 'Commission vendeur',
                subtitle: '3% des ventes',
                onPressed: () {
                  _showCommissionEditDialog(context, 'Commission vendeur');
                },
              ),
              _buildSettingTile(
                title: 'Commission agent',
                subtitle: '5% des frais de vérification',
                onPressed: () {
                  _showCommissionEditDialog(context, 'Commission agent');
                },
              ),
              _buildSettingTile(
                title: 'Frais de vérification',
                subtitle: '25,000 FCFA par vérification',
                onPressed: () {
                  _showCommissionEditDialog(context, 'Frais de vérification');
                },
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Section Paquets
          _buildSection(
            title: 'Packages de service',
            children: [
              _buildPackageCard(
                name: 'Standard',
                price: '25,000 FCFA',
                features: [
                  'Vérification J1-J3-J7-J10',
                  'Photos géolocalisées',
                  'Rapport PDF',
                ],
              ),
              _buildPackageCard(
                name: 'Premium',
                price: '50,000 FCFA',
                features: [
                  'Standard +',
                  'Priorité vérification',
                  'Support prioritaire',
                  'Données cadastrales',
                ],
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Section Danger
          _buildSection(
            title: 'Danger',
            children: [
              _buildSettingTile(
                title: 'Réinitialiser les données',
                subtitle: 'Supprimer toutes les données de la démo',
                color: Colors.red,
                onPressed: () {
                  _showDangerDialog(
                    context,
                    'Réinitialiser les données',
                    'Cette action est irréversible!',
                  );
                },
              ),
            ],
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.outfit(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A2E),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[800]!),
          ),
          child: Column(
            children: List.generate(
              children.length,
              (index) => Column(
                children: [
                  children[index],
                  if (index < children.length - 1)
                    Divider(color: Colors.grey[800], height: 1),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSettingTile({
    required String title,
    required String subtitle,
    bool isSwitch = false,
    bool isDropdown = false,
    bool isTextField = false,
    bool value = false,
    String dropdownValue = '',
    List<String> dropdownItems = const [],
    Function(bool)? onChanged,
    Function(String?)? onDropdownChanged,
    VoidCallback? onPressed,
    Color? color,
  }) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: color ?? Colors.white,
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          if (isSwitch)
            Switch(value: value, activeColor: kPrimary, onChanged: onChanged)
          else if (isDropdown)
            DropdownButton<String>(
              value: dropdownValue,
              dropdownColor: const Color(0xFF0F0F1E),
              items: dropdownItems
                  .map(
                    (item) => DropdownMenuItem(
                      value: item,
                      child: Text(
                        item,
                        style: GoogleFonts.inter(color: Colors.white),
                      ),
                    ),
                  )
                  .toList(),
              onChanged: onDropdownChanged,
              style: GoogleFonts.inter(color: Colors.white),
            )
          else if (isTextField)
            Icon(Icons.edit, color: kPrimary, size: 20)
          else
            Icon(Icons.chevron_right, color: Colors.grey[600]),
        ],
      ),
    );
  }

  Widget _buildPackageCard({
    required String name,
    required String price,
    required List<String> features,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0F0F1E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[800]!),
      ),
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                name,
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                price,
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: kPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...features
              .map(
                (feature) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    children: [
                      Icon(Icons.check, color: kSuccess, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        feature,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: Colors.grey[400],
                        ),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
        ],
      ),
    );
  }

  void _showMaintenanceMessageDialog(BuildContext context) {
    final controller = TextEditingController(
      text: 'Maintenance en cours. Nous serons bientôt de retour!',
    );
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        title: Text(
          'Message de maintenance',
          style: GoogleFonts.outfit(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        content: TextField(
          controller: controller,
          maxLines: 3,
          style: GoogleFonts.inter(color: Colors.white),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey[900],
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Message mis à jour'),
                  backgroundColor: kSuccess,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: kPrimary),
            child: const Text('Enregistrer'),
          ),
        ],
      ),
    );
  }

  void _showCommissionEditDialog(BuildContext context, String title) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        title: Text(
          title,
          style: GoogleFonts.outfit(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        content: TextField(
          controller: controller,
          style: GoogleFonts.inter(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Entrez la valeur...',
            hintStyle: GoogleFonts.inter(color: Colors.grey[600]),
            filled: true,
            fillColor: Colors.grey[900],
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Valeur mise à jour'),
                  backgroundColor: kSuccess,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: kPrimary),
            child: const Text('Enregistrer'),
          ),
        ],
      ),
    );
  }

  void _showDangerDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        title: Text(
          title,
          style: GoogleFonts.outfit(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.red,
          ),
        ),
        content: Text(
          message,
          style: GoogleFonts.inter(color: Colors.grey[300]),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Opération effectuée'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Confirmer'),
          ),
        ],
      ),
    );
  }
}
