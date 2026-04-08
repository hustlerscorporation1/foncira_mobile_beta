// ══════════════════════════════════════════════════════════════
//  FONCIRA — Admin Settings Tab (Services, Taux, Stats, Agents)
// ══════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:foncira/theme/colors.dart';
import 'package:foncira/services/supabase_service.dart';
import 'package:google_fonts/google_fonts.dart';

class AdminSettingsTab extends StatefulWidget {
  const AdminSettingsTab({super.key});

  @override
  State<AdminSettingsTab> createState() => _AdminSettingsTabState();
}

class _AdminSettingsTabState extends State<AdminSettingsTab> {
  final supabase = SupabaseService().client;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // En-tête
          Text(
            'Paramètres',
            style: GoogleFonts.outfit(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 24),

          // Section: Services
          _buildServiceSection(),
          const SizedBox(height: 24),

          // Section: Taux de conversion
          _buildExchangeRateSection(),
          const SizedBox(height: 24),

          // Section: Statistiques globales
          _buildStatisticsSection(),
          const SizedBox(height: 24),

          // Section: Agents
          _buildAgentSection(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  // Services Section
  // ══════════════════════════════════════════════════════════════

  Widget _buildServiceSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Offres de service',
          style: GoogleFonts.outfit(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        FutureBuilder<List<Map<String, dynamic>>>(
          future: _fetchServices(),
          builder: (context, snapshot) {
            if (!snapshot.hasData)
              return Center(
                child: SizedBox(
                  width: 40,
                  height: 40,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(kPrimary),
                  ),
                ),
              );

            final services = snapshot.data ?? [];
            return Column(
              children: services
                  .map((service) => _buildServiceCard(service))
                  .toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildServiceCard(Map<String, dynamic> service) {
    final labelController = TextEditingController(text: service['label']);
    final priceFcfaController = TextEditingController(
      text: '${service['price_fcfa']}',
    );
    final priceUsdController = TextEditingController(
      text: '${service['price_usd']}',
    );
    bool isActive = service['is_active'] as bool? ?? true;

    return StatefulBuilder(
      builder: (context, setState) => Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A2E),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[800]!),
        ),
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.only(bottom: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Label
            Text(
              'Label',
              style: GoogleFonts.inter(fontSize: 11, color: Colors.grey[500]),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: labelController,
              style: GoogleFonts.inter(color: Colors.white),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey[900],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Prices
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Prix (FCFA)',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: Colors.grey[500],
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: priceFcfaController,
                        keyboardType: TextInputType.number,
                        style: GoogleFonts.inter(color: Colors.white),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.grey[900],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Prix (USD)',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: Colors.grey[500],
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: priceUsdController,
                        keyboardType: TextInputType.number,
                        style: GoogleFonts.inter(color: Colors.white),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.grey[900],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Toggle + Save
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      'Actif',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Switch(
                      value: isActive,
                      activeColor: kPrimary,
                      onChanged: (value) => setState(() => isActive = value),
                    ),
                  ],
                ),
                ElevatedButton(
                  onPressed: () async {
                    try {
                      await supabase
                          .from('services')
                          .update({
                            'label': labelController.text,
                            'price_fcfa': int.parse(priceFcfaController.text),
                            'price_usd': double.parse(priceUsdController.text),
                            'is_active': isActive,
                          })
                          .eq('id', service['id']);

                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Service mis à jour'),
                            backgroundColor: kSuccess,
                          ),
                        );
                        setState(() {});
                      }
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Erreur: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: kPrimary),
                  child: const Text('Enregistrer'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  // Exchange Rate Section
  // ══════════════════════════════════════════════════════════════

  Widget _buildExchangeRateSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Taux de conversion',
          style: GoogleFonts.outfit(
            fontSize: 18,
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
          padding: const EdgeInsets.all(16),
          child: FutureBuilder<double>(
            future: _getExchangeRate(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const SizedBox.shrink();

              final rate = snapshot.data ?? 655.957;
              final rateController = TextEditingController(text: '$rate');

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Taux FCFA / USD',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: Colors.grey[400],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: rateController,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          style: GoogleFonts.inter(color: Colors.white),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.grey[900],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: () async {
                          try {
                            await supabase
                                .from('app_config')
                                .upsert({
                                  'key': 'fcfa_to_usd_rate',
                                  'value': rateController.text,
                                })
                                .eq('key', 'fcfa_to_usd_rate');

                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Taux mis à jour'),
                                  backgroundColor: kSuccess,
                                ),
                              );
                            }
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Erreur: $e'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kPrimary,
                        ),
                        child: const Text('Enregistrer'),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  // ══════════════════════════════════════════════════════════════
  // Statistics Section
  // ══════════════════════════════════════════════════════════════

  Widget _buildStatisticsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Statistiques globales (Preuve sociale)',
          style: GoogleFonts.outfit(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        FutureBuilder<Map<String, String>>(
          future: _getStatistics(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(
                child: SizedBox(
                  width: 40,
                  height: 40,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(kPrimary),
                  ),
                ),
              );
            }

            final stats = snapshot.data ?? {};
            final verifiesTerrainController = TextEditingController(
              text: stats['terrains_verified'] ?? '0',
            );
            final disputesAvoidedController = TextEditingController(
              text: stats['disputes_avoided'] ?? '0',
            );
            final amountProtectedController = TextEditingController(
              text: stats['amount_protected_usd'] ?? '0',
            );

            return StatefulBuilder(
              builder: (context, setState) => Column(
                children: [
                  _buildStatField(
                    'Terrains vérifiés',
                    verifiesTerrainController,
                    Colors.blue,
                  ),
                  const SizedBox(height: 12),
                  _buildStatField(
                    'Litiges évités',
                    disputesAvoidedController,
                    Colors.green,
                  ),
                  const SizedBox(height: 12),
                  _buildStatField(
                    'Montant protégé (USD)',
                    amountProtectedController,
                    Colors.purple,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () async {
                      try {
                        await Future.wait([
                          supabase
                              .from('app_config')
                              .upsert({
                                'key': 'stat_terrains_verified',
                                'value': verifiesTerrainController.text,
                              })
                              .eq('key', 'stat_terrains_verified'),
                          supabase
                              .from('app_config')
                              .upsert({
                                'key': 'stat_disputes_avoided',
                                'value': disputesAvoidedController.text,
                              })
                              .eq('key', 'stat_disputes_avoided'),
                          supabase
                              .from('app_config')
                              .upsert({
                                'key': 'stat_amount_protected_usd',
                                'value': amountProtectedController.text,
                              })
                              .eq('key', 'stat_amount_protected_usd'),
                        ]);

                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Statistiques mises à jour'),
                              backgroundColor: kSuccess,
                            ),
                          );
                        }
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Erreur: $e'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.save),
                    label: const Text('Enregistrer tout'),
                    style: ElevatedButton.styleFrom(backgroundColor: kPrimary),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildStatField(
    String label,
    TextEditingController controller,
    Color color,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[800]!),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(fontSize: 13, color: Colors.grey[400]),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            style: GoogleFonts.inter(color: Colors.white, fontSize: 16),
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.grey[900],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              prefixIcon: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(Icons.assessment, color: color, size: 20),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  // Agents Section
  // ══════════════════════════════════════════════════════════════

  Widget _buildAgentSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Gestion des agents',
          style: GoogleFonts.outfit(
            fontSize: 18,
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
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Text(
                'Créer un nouvel agent',
                style: GoogleFonts.inter(fontSize: 14, color: Colors.grey[300]),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _showCreateAgentDialog(),
                  icon: const Icon(Icons.person_add),
                  label: const Text('Créer un agent'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showCreateAgentDialog() {
    final emailController = TextEditingController();
    final firstNameController = TextEditingController();
    final specializationController = TextEditingController();
    bool isCreating = false;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: const Color(0xFF1A1A2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: StatefulBuilder(
            builder: (context, setState) => Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Créer un nouvel agent',
                  style: GoogleFonts.outfit(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),

                // Email
                Text(
                  'Email',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: emailController,
                  style: GoogleFonts.inter(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'agent@example.com',
                    hintStyle: GoogleFonts.inter(color: Colors.grey[600]),
                    filled: true,
                    fillColor: Colors.grey[900],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Prénom
                Text(
                  'Prénom',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: firstNameController,
                  style: GoogleFonts.inter(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Jean',
                    hintStyle: GoogleFonts.inter(color: Colors.grey[600]),
                    filled: true,
                    fillColor: Colors.grey[900],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Spécialisation
                Text(
                  'Spécialisation',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: specializationController,
                  style: GoogleFonts.inter(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Ex: Terrains urbains',
                    hintStyle: GoogleFonts.inter(color: Colors.grey[600]),
                    filled: true,
                    fillColor: Colors.grey[900],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Actions
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Annuler'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: isCreating
                          ? null
                          : () async {
                              if (emailController.text.isEmpty ||
                                  firstNameController.text.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Veuillez remplir les champs obligatoires',
                                    ),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                                return;
                              }

                              setState(() => isCreating = true);

                              try {
                                // Appeler l'Edge Function pour créer l'agent
                                final response = await supabase.functions
                                    .invoke(
                                      'create-agent',
                                      body: {
                                        'email': emailController.text,
                                        'firstName': firstNameController.text,
                                        'specialization':
                                            specializationController.text,
                                      },
                                    );

                                if (mounted) {
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Agent créé avec succès'),
                                      backgroundColor: kSuccess,
                                    ),
                                  );
                                }
                              } catch (e) {
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Erreur: $e'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                  setState(() => isCreating = false);
                                }
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kPrimary,
                      ),
                      child: isCreating
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : const Text('Créer'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  // Supabase Queries
  // ══════════════════════════════════════════════════════════════

  Future<List<Map<String, dynamic>>> _fetchServices() async {
    try {
      final response = await supabase.from('services').select('*');
      return response as List<Map<String, dynamic>>;
    } catch (e) {
      return [];
    }
  }

  Future<double> _getExchangeRate() async {
    try {
      final response = await supabase
          .from('app_config')
          .select('value')
          .eq('key', 'fcfa_to_usd_rate')
          .single();

      return double.parse(response['value'] ?? '655.957');
    } catch (e) {
      return 655.957;
    }
  }

  Future<Map<String, String>> _getStatistics() async {
    try {
      final response = await supabase
          .from('app_config')
          .select('key, value')
          .inFilter('key', [
            'stat_terrains_verified',
            'stat_disputes_avoided',
            'stat_amount_protected_usd',
          ]);

      final map = <String, String>{};
      for (var item in response) {
        if (item['key'] == 'stat_terrains_verified') {
          map['terrains_verified'] = item['value'];
        } else if (item['key'] == 'stat_disputes_avoided') {
          map['disputes_avoided'] = item['value'];
        } else if (item['key'] == 'stat_amount_protected_usd') {
          map['amount_protected_usd'] = item['value'];
        }
      }
      return map;
    } catch (e) {
      return {};
    }
  }
}
