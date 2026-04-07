import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/colors.dart';
import '../services/vendor_subscription_service.dart';

// ══════════════════════════════════════════════════════════════
//  VENDOR SUBSCRIPTION PAGE — Featured Listing Management
// ══════════════════════════════════════════════════════════════

class VendorSubscriptionPage extends StatefulWidget {
  const VendorSubscriptionPage({super.key});

  @override
  State<VendorSubscriptionPage> createState() => _VendorSubscriptionPageState();
}

class _VendorSubscriptionPageState extends State<VendorSubscriptionPage> {
  final VendorSubscriptionService _subscriptionService =
      VendorSubscriptionService();
  List<Map<String, dynamic>> terrainSubscriptions = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSubscriptions();
  }

  Future<void> _loadSubscriptions() async {
    setState(() => isLoading = true);
    final subscriptions = await _subscriptionService.getTerrainSubscriptions();
    setState(() {
      terrainSubscriptions = subscriptions;
      isLoading = false;
    });
  }

  Future<void> _activateSubscription(String terrainId) async {
    _showConfirmationBottomSheet(terrainId);
  }

  void _showConfirmationBottomSheet(String terrainId) {
    showModalBottomSheet(
      context: context,
      backgroundColor: kDarkCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Mettre en avant ce terrain',
                style: GoogleFonts.outfit(
                  color: kTextPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Votre terrain apparaîtra en haut de la marketplace pendant 30 jours.',
                style: GoogleFonts.inter(color: kTextMuted, fontSize: 13),
              ),
              const SizedBox(height: 24),

              // Price breakdown
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: kBorderDark,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Mise en avant — 30 jours',
                          style: GoogleFonts.inter(
                            color: kTextPrimary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          '15 000 F',
                          style: GoogleFonts.outfit(
                            color: kPrimaryLight,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '≈ \$${VendorSubscriptionService.subscriptionPriceUSD}',
                      style: GoogleFonts.inter(color: kTextMuted, fontSize: 12),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Action buttons
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _processPayment(terrainId);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: Text(
                    'Payer et activer',
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: kTextPrimary,
                    side: BorderSide(color: kBorderDark),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: Text(
                    'Annuler',
                    style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _processPayment(String terrainId) async {
    try {
      // Process payment (integration with Mobile Money flow)
      final success = await _subscriptionService.createOrRenewSubscription(
        terrainId,
      );

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Terrain mis en avant avec succès!'),
            backgroundColor: Colors.green,
          ),
        );
        _loadSubscriptions(); // Refresh list
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erreur lors de l\'activation'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erreur: $e')));
    }
  }

  Future<void> _cancelSubscription(String terrainId) async {
    try {
      final success = await _subscriptionService.cancelSubscription(terrainId);

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Mise en avant annulée'),
            backgroundColor: Colors.green,
          ),
        );
        _loadSubscriptions();
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erreur: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kDarkBg,
      appBar: AppBar(
        backgroundColor: kDarkBg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          color: kTextPrimary,
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Mise en avant',
          style: GoogleFonts.outfit(
            color: kTextPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: kPrimary))
          : terrainSubscriptions.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.star_outline_rounded, color: kTextMuted, size: 48),
                  const SizedBox(height: 16),
                  Text(
                    'Aucun terrain',
                    style: GoogleFonts.outfit(color: kTextMuted, fontSize: 16),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: terrainSubscriptions.length,
              itemBuilder: (context, index) {
                final terrain = terrainSubscriptions[index];
                return _buildSubscriptionCard(context, terrain);
              },
            ),
    );
  }

  Widget _buildSubscriptionCard(
    BuildContext context,
    Map<String, dynamic> terrain,
  ) {
    final title = terrain['titre'] ?? 'Sans titre';
    final photoUrl = terrain['photo_url'];
    final isActive = terrain['subscription_status'] == 'active';
    final expiresAt = terrain['subscription_expires_at'];
    final canActivate = terrain['can_activate'] ?? true;

    String statusText = 'Inactive';
    Color statusColor = Colors.grey;

    if (isActive && expiresAt != null) {
      final expirationDate = DateTime.parse(expiresAt as String);
      statusText =
          'Actif jusqu\'au ${expirationDate.day}/${expirationDate.month}';
      statusColor = Colors.green;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: kDarkCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kBorderDark),
      ),
      child: Column(
        children: [
          // Header with photo and title
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Photo thumbnail
                if (photoUrl != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      photoUrl,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                    ),
                  )
                else
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: kBorderDark,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.image_outlined, color: kTextMuted),
                  ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.outfit(
                          color: kTextPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          statusText,
                          style: GoogleFonts.inter(
                            color: statusColor,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Divider(color: kBorderDark, height: 1),

          // Action button
          Padding(
            padding: const EdgeInsets.all(12),
            child: SizedBox(
              width: double.infinity,
              child: isActive && !canActivate
                  ? OutlinedButton(
                      onPressed: () =>
                          _cancelSubscription(terrain['terrain_id']),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.orange,
                        side: const BorderSide(color: Colors.orange),
                      ),
                      child: Text(
                        'Annuler l\'abonnement',
                        style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                      ),
                    )
                  : ElevatedButton(
                      onPressed: () =>
                          _activateSubscription(terrain['terrain_id']),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kPrimary,
                      ),
                      child: Text(
                        isActive ? 'Renouveler' : 'Activer',
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
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
