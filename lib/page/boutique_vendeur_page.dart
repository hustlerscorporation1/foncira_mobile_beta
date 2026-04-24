import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/colors.dart';
import '../services/supabase_service.dart';
import '../component/price_row.dart';

/// Public vendor boutique page - accessible via referral code
/// URL: /boutique/[referral_code]
/// No authentication required
class BoutiqueVendeurPage extends StatefulWidget {
  final String referralCode;

  const BoutiqueVendeurPage({Key? key, required this.referralCode})
    : super(key: key);

  @override
  State<BoutiqueVendeurPage> createState() => _BoutiqueVendeurPageState();
}

class _BoutiqueVendeurPageState extends State<BoutiqueVendeurPage> {
  final supabase = SupabaseService().client;
  Map<String, dynamic>? vendor;
  List<Map<String, dynamic>> terrains = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadVendorData();
  }

  Future<void> _loadVendorData() async {
    try {
      setState(() => isLoading = true);

      // Get vendor by referral code
      final vendorData = await supabase
          .from('users')
          .select('*')
          .eq('referral_code', widget.referralCode)
          .maybeSingle();

      if (vendorData == null) {
        throw Exception('Vendeur non trouvé');
      }

      // Get vendor's published terrains
      final vendorTerrains = await supabase
          .from('terrains_foncira')
          .select('*')
          .eq('seller_id', vendorData['id'])
          .eq('status', 'publie')
          .isFilter('deleted_at', null)
          .order('created_at', ascending: false);

      setState(() {
        vendor = vendorData as Map<String, dynamic>;
        terrains = (vendorTerrains as List).cast<Map<String, dynamic>>();
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erreur: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context);
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.black87,
        appBar: AppBar(
          backgroundColor: Colors.black87,
          title: Text(
            'Boutique Vendeur',
            style: GoogleFonts.outfit(
              fontWeight: FontWeight.w700,
              fontSize: 20,
            ),
          ),
          elevation: 0,
        ),
        body: isLoading
            ? Center(child: CircularProgressIndicator(color: kPrimary))
            : vendor == null
            ? _buildNotFoundWidget()
            : _buildBoutiqueView(),
      ),
    );
  }

  Widget _buildNotFoundWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.person_off_rounded, size: 64, color: kTextMuted),
          const SizedBox(height: 16),
          Text(
            'Vendeur non trouvé',
            style: GoogleFonts.outfit(
              color: kTextPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Le code de parrainage est invalide ou expiré',
            style: GoogleFonts.inter(color: kTextMuted, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildBoutiqueView() {
    final vendorName =
        '${vendor?['first_name'] ?? ''} ${vendor?['last_name'] ?? ''}';
    const vendorPhone = vendor?['phone_number'];

    return RefreshIndicator(
      onRefresh: _loadVendorData,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Vendor info card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: kDarkCard,
                border: Border.all(color: kBorderDark),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Informations du vendeur',
                    style: GoogleFonts.outfit(
                      color: kTextPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Avatar placeholder
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: kPrimary.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Icon(
                          Icons.person_rounded,
                          color: kPrimary,
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              vendorName.trim(),
                              style: GoogleFonts.outfit(
                                color: kTextPrimary,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            if (vendor?['email'] != null)
                              Text(
                                vendor!['email'] as String? ?? '',
                                style: GoogleFonts.inter(
                                  color: kTextMuted,
                                  fontSize: 12,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            const SizedBox(height: 4),
                            if (vendor?['phone_number'] != null)
                              Text(
                                vendor!['phone_number'] as String? ?? '',
                                style: GoogleFonts.inter(
                                  color: kTextMuted,
                                  fontSize: 12,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Download/Share button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _shareVendorBoutique,
                      icon: const Icon(Icons.share_rounded),
                      label: const Text('Partager cette boutique'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kPrimary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Terrains section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Terrains disponibles',
                  style: GoogleFonts.outfit(
                    color: kTextPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: kPrimary.withOpacity(0.2),
                    border: Border.all(color: kPrimary),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${terrains.length}',
                    style: GoogleFonts.outfit(
                      color: kPrimary,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Terrains list
            if (terrains.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  child: Column(
                    children: [
                      Icon(
                        Icons.landscape_rounded,
                        size: 48,
                        color: kTextMuted,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Aucun terrain disponible',
                        style: GoogleFonts.inter(color: kTextMuted),
                      ),
                    ],
                  ),
                ),
              )
            else
              Column(
                children: terrains.map((terrain) {
                  return _buildTerrainItem(terrain);
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTerrainItem(Map<String, dynamic> terrain) {
    final title = terrain['title'] as String? ?? 'Sans titre';
    final location =
        (terrain['location'] ?? terrain['ville'] ?? 'Localisation inconnue')
            as String?;
    final priceUsd = (terrain['price_usd'] ?? 0) is num
        ? (terrain['price_usd'] as num).toDouble()
        : 0.0;
    final priceFcfa = (terrain['price_fcfa'] ?? 0) is num
        ? (terrain['price_fcfa'] as num).toDouble()
        : 0.0;
    final areaSqm = terrain['area_sqm'] ?? 'N/A';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: kDarkCardLight,
        border: Border.all(color: kBorderDark),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
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
            // Location
            Row(
              children: [
                Icon(Icons.location_on_rounded, size: 14, color: kTextMuted),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    location ?? 'Localisation inconnue',
                    style: GoogleFonts.inter(color: kTextMuted, fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Area and price row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Area
                if (areaSqm != 'N/A')
                  Row(
                    children: [
                      Icon(
                        Icons.square_foot_rounded,
                        size: 14,
                        color: kTextMuted,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '$areaSqm m²',
                        style: GoogleFonts.inter(
                          color: kTextMuted,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                // Price
                PriceRow(
                  priceUsd: priceUsd,
                  priceFcfa: priceFcfa,
                  usdFontSize: 14,
                  fcfaFontSize: 10,
                  spacing: 6,
                ),
              ],
            ),
            const SizedBox(height: 12),
            // View details button
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () {
                  // TODO: Navigate to terrain details
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Navigation en cours...')),
                  );
                },
                child: const Text('Voir les détails'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _shareVendorBoutique() async {
    final shareText =
        'Retrouvez ${vendor?['first_name']} sur FONCIRA Boutique\n\nVisitez leurs terrains disponibles';

    try {
      // Note: Share plugin would be needed for native share
      // For now, just copy to clipboard or show a dialog
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Partager cette boutique'),
          content: Text('Lien: /boutique/${widget.referralCode}\n\n$shareText'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Fermer'),
            ),
          ],
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erreur: $e')));
    }
  }
}
