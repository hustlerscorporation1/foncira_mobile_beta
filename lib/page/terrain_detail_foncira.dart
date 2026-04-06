import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_map/flutter_map.dart';
import '../theme/colors.dart';
import '../models/terrain.dart';
import '../providers/terrain_provider.dart';
import '../providers/verification_provider.dart';
import '../component/price_display.dart';
import '../component/social_proof_banner.dart';
import 'verification_tunnel_page.dart';

const _kOsmUserAgentPackageName = 'com.foncira';

// ══════════════════════════════════════════════════════════════
//  FONCIRA — Fiche Terrain (Redesigned)
//  Structure: Header → Statut → Infos clés → Vérification de base
//  → Description → Vendeur → Carte → Alerte → CTA
// ══════════════════════════════════════════════════════════════

class TerrainDetailFoncira extends StatefulWidget {
  final Terrain terrain;
  const TerrainDetailFoncira({super.key, required this.terrain});

  @override
  State<TerrainDetailFoncira> createState() => _TerrainDetailFonciraState();
}

class _TerrainDetailFonciraState extends State<TerrainDetailFoncira> {
  final PageController _imgCtrl = PageController();
  int _currentImg = 0;

  @override
  void dispose() {
    _imgCtrl.dispose();
    super.dispose();
  }

  Terrain get t => widget.terrain;

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<TerrainProvider>();
    final isFav = prov.isFavorite(t.id);
    final safeBottom = MediaQuery.of(context).padding.bottom;
    final ctaBottomPadding = safeBottom + 12;

    return Scaffold(
      backgroundColor: kDarkBg,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              // ════════════════════════════════════════════
              // 1. HEADER — Image + Badge FONCIRA
              // ════════════════════════════════════════════
              SliverAppBar(
                expandedHeight: 280,
                pinned: true,
                backgroundColor: kDarkBg,
                leading: _circleBtn(
                  Icons.arrow_back_rounded,
                  () => Navigator.pop(context),
                ),
                actions: [
                  _circleBtn(
                    isFav
                        ? Icons.favorite_rounded
                        : Icons.favorite_border_rounded,
                    () => prov.toggleFavorite(t.id),
                    color: isFav ? kDanger : Colors.white,
                  ),
                  const SizedBox(width: 4),
                  _circleBtn(Icons.share_rounded, () {}),
                  const SizedBox(width: 8),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: _buildImageCarousel(),
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 6),

                      // ── Badge FONCIRA ──
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: kPrimarySurface,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: kPrimaryLight.withValues(alpha: 0.25),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.verified_rounded,
                              color: kPrimaryLight,
                              size: 15,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Publié sur ',
                              style: GoogleFonts.inter(
                                color: kTextSecondary,
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              'FONCIRA',
                              style: GoogleFonts.inter(
                                color: kPrimaryLight,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              ' – Vérification de base effectuée',
                              style: GoogleFonts.inter(
                                color: kTextSecondary,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // ── Titre ──
                      Text(
                        t.title,
                        style: GoogleFonts.outfit(
                          color: kTextPrimary,
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.location_on, color: kGold, size: 15),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              t.fullLocation,
                              style: GoogleFonts.inter(
                                color: kTextSecondary,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // ── Prix ──
                      // ── Prix (FONCIRA diaspora format) ──
                      PriceDisplay(fcfaAmount: t.price.toDouble()),
                      const SizedBox(height: 20),

                      // ════════════════════════════════════════
                      // 2. INDICATEUR STATUT
                      // ════════════════════════════════════════
                      Row(
                        children: [
                          _statusChip(
                            Icons.check_circle_rounded,
                            'Vérification de base : OK',
                            kSuccess,
                          ),
                          const SizedBox(width: 8),
                          _statusChip(
                            Icons.warning_amber_rounded,
                            'Analyse approfondie :  Non effectuée',
                            kWarning,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Message statut
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: kDarkCard,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: kBorderDark),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.edit_note_rounded,
                              color: kGold,
                              size: 18,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: RichText(
                                text: TextSpan(
                                  style: GoogleFonts.inter(
                                    color: kTextSecondary,
                                    fontSize: 12,
                                    height: 1.5,
                                  ),
                                  children: [
                                    const TextSpan(
                                      text: 'Ce terrain a passé une ',
                                    ),
                                    TextSpan(
                                      text: 'vérification initiale',
                                      style: GoogleFonts.inter(
                                        color: kTextPrimary,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 12,
                                      ),
                                    ),
                                    const TextSpan(text: '. Une '),
                                    TextSpan(
                                      text: 'analyse approfondie',
                                      style: GoogleFonts.inter(
                                        color: kGold,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 12,
                                      ),
                                    ),
                                    const TextSpan(text: ' est recommandée '),
                                    TextSpan(
                                      text: 'avant',
                                      style: GoogleFonts.inter(
                                        color: kTextPrimary,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 12,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                    const TextSpan(text: ' achat.'),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            GestureDetector(
                              onTap: () => _showInfoDialog(),
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: kDarkCardLight,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.info_outline_rounded,
                                  color: kTextMuted,
                                  size: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 28),

                      // ════════════════════════════════════════
                      // 2. SOCIAL PROOF — Trust Signals
                      // ════════════════════════════════════════
                      const SocialProofBanner(),
                      const SizedBox(height: 24),

                      // ════════════════════════════════════════
                      // 3. INFORMATIONS CLÉS
                      // ════════════════════════════════════════
                      _sectionTitle('Informations clés'),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: kDarkCard,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: kBorderDark),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                _infoTile(
                                  Icons.straighten_rounded,
                                  'Superficie',
                                  t.formattedSurface,
                                ),
                                _infoTile(
                                  Icons.water_drop_rounded,
                                  'Viabilisé',
                                  t.isViabilise ? 'Oui' : 'Non',
                                ),
                                _infoTile(
                                  Icons.home_work_rounded,
                                  'Constructible',
                                  t.isConstructible ? 'Oui' : 'Non',
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            Row(
                              children: [
                                _infoTile(
                                  Icons.route_rounded,
                                  'Accès Route',
                                  'Bitumée à 50m',
                                ),
                                _infoTile(
                                  Icons.location_city_rounded,
                                  'Quartier',
                                  t.quartier.isNotEmpty
                                      ? t.quartier
                                      : 'Calme & desservi',
                                ),
                                _infoTile(
                                  Icons.map_rounded,
                                  'Zone',
                                  t.zone.isNotEmpty
                                      ? t.zone
                                      : 'Calme & desservi',
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 28),

                      // ════════════════════════════════════════
                      // 4. VÉRIFICATION DE BASE EFFECTUÉE
                      // ════════════════════════════════════════
                      _sectionTitle('Vérification de base effectuée'),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: kDarkCard,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: kBorderDark),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Verified items
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      _verifItem(
                                        true,
                                        'Existence vendeur confirmée',
                                      ),
                                      _verifItem(
                                        true,
                                        'Localisation terrain confirmée',
                                      ),
                                      _verifItem(
                                        true,
                                        'Cohérence informations vérifiée',
                                      ),
                                      _verifItem(
                                        true,
                                        'Photos terrain vérifiées',
                                      ),
                                      _verifItem(
                                        true,
                                        'Disponibilité confirmée',
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      _verifItem(false, 'Cadastre'),
                                      _verifItem(false, 'Coutumier'),
                                      _verifItem(false, 'Géomètre'),
                                      _verifItem(false, 'Litige'),
                                      _verifItem(false, 'Double vente'),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            // Warning note
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: kWarningSurface,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(
                                    Icons.arrow_downward_rounded,
                                    color: kWarning,
                                    size: 14,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Une vérification approfondie est recommandée pour s\'assurer de l\'absence de litige, double vente, conflit coutumier, ou autre anomalie.',
                                      style: GoogleFonts.inter(
                                        color: kWarning,
                                        fontSize: 11,
                                        height: 1.4,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 28),

                      // ════════════════════════════════════════
                      // 5. DESCRIPTION
                      // ════════════════════════════════════════
                      if (t.description != null &&
                          t.description!.isNotEmpty) ...[
                        _sectionTitle('Description'),
                        const SizedBox(height: 10),
                        Text(
                          t.description!,
                          style: GoogleFonts.inter(
                            color: kTextSecondary,
                            fontSize: 13,
                            height: 1.7,
                          ),
                        ),
                        const SizedBox(height: 28),
                      ],

                      // ════════════════════════════════════════
                      // 6. INFORMATIONS VENDEUR
                      // ════════════════════════════════════════
                      _sectionTitle('Informations vendeur'),
                      const SizedBox(height: 12),
                      _buildSellerSection(),
                      const SizedBox(height: 28),

                      // ════════════════════════════════════════
                      // 10. SECTION CONVERSION — Pourquoi vérifier
                      // ════════════════════════════════════════
                      if (t.coordinates != null)
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final isNarrow = constraints.maxWidth < 560;
                            if (isNarrow) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  _buildMapSmall(),
                                  const SizedBox(height: 12),
                                  _buildWhyVerify(),
                                ],
                              );
                            }
                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(child: _buildWhyVerify()),
                                const SizedBox(width: 12),
                                // 7. LOCALISATION (carte)
                                Expanded(child: _buildMapSmall()),
                              ],
                            );
                          },
                        )
                      else
                        _buildWhyVerify(),
                      if (t.coordinates != null) ...[
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on_rounded,
                              color: kPrimaryLight,
                              size: 14,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Publié ${t.timeAgo}',
                              style: GoogleFonts.inter(
                                color: kTextMuted,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 28),

                      // ════════════════════════════════════════
                      // 8. ALERTE FONCIRA
                      // ════════════════════════════════════════
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: kWarningSurface,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: kWarning.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.warning_rounded,
                              color: kWarning,
                              size: 22,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: RichText(
                                text: TextSpan(
                                  style: GoogleFonts.inter(
                                    color: kTextSecondary,
                                    fontSize: 13,
                                    height: 1.4,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: 'FONCIRA',
                                      style: GoogleFonts.inter(
                                        color: kTextPrimary,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 13,
                                      ),
                                    ),
                                    const TextSpan(text: ' recommande une '),
                                    TextSpan(
                                      text: 'vérification approfondie',
                                      style: GoogleFonts.inter(
                                        color: kTextPrimary,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                    const TextSpan(
                                      text: ' avant tout paiement.',
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Bottom spacing for CTA
                      SizedBox(height: 120 + safeBottom),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // ════════════════════════════════════════════
          // 9. CTA PRINCIPAL (fixed bottom)
          // ════════════════════════════════════════════
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.fromLTRB(20, 12, 20, ctaBottomPadding),
              decoration: BoxDecoration(
                color: kDarkBg,
                border: Border(top: BorderSide(color: kBorderDark)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.4),
                    blurRadius: 20,
                    offset: const Offset(0, -6),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Contacter vendeur
                  Expanded(
                    flex: 2,
                    child: OutlinedButton(
                      onPressed: () => _showContact(),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: kTextPrimary,
                        side: const BorderSide(color: kBorderDark),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Contacter vendeur',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Demander vérification approfondie
                  Expanded(
                    flex: 3,
                    child: ElevatedButton.icon(
                      onPressed: () => _requestVerification(),
                      icon: const Icon(Icons.verified_user_rounded, size: 18),
                      label: Text(
                        'Demander une vérification approfondie',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kPrimary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════
  //  WIDGETS
  // ══════════════════════════════════════════════════════════

  Widget _buildImageCarousel() {
    final imgs = t.imageUrls
        .where((img) => img.trim().isNotEmpty)
        .toList(growable: false);
    final imageSources = imgs.isNotEmpty
        ? imgs
        : const ['assets/Image/terrain1.jpg'];
    return Stack(
      fit: StackFit.expand,
      children: [
        PageView.builder(
          controller: _imgCtrl,
          itemCount: imageSources.length,
          onPageChanged: (i) => setState(() => _currentImg = i),
          itemBuilder: (_, i) => _buildTerrainImage(imageSources[i]),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          height: 100,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, kDarkBg],
              ),
            ),
          ),
        ),
        if (imageSources.length > 1)
          Positioned(
            bottom: 14,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${_currentImg + 1}/${imageSources.length}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildTerrainImage(String source) {
    final normalizedSource = source.trim();
    if (_isNetworkImage(normalizedSource)) {
      return Image.network(
        normalizedSource,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _imageFallback(),
      );
    }
    return Image.asset(
      normalizedSource,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => _imageFallback(),
    );
  }

  bool _isNetworkImage(String source) =>
      source.startsWith('http://') || source.startsWith('https://');

  Widget _imageFallback() {
    return Container(
      color: kDarkCardLight,
      child: const Icon(Icons.landscape_rounded, color: kTextMuted, size: 60),
    );
  }

  Widget _buildSellerSection() {
    final isAgency = t.sellerType == SellerType.agence;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kDarkCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kBorderDark),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isAgency ? kGoldSurface : kPrimarySurface,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  isAgency ? Icons.business_rounded : Icons.person_rounded,
                  color: isAgency ? kGold : kPrimaryLight,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t.sellerName,
                      style: GoogleFonts.inter(
                        color: kTextPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isAgency
                          ? (t.sellerAgencyName ?? 'Agence immobilière')
                          : 'Particulier',
                      style: GoogleFonts.inter(color: kTextMuted, fontSize: 12),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: kPrimarySurface,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'Compte vérifié',
                      style: GoogleFonts.inter(
                        color: kPrimaryLight,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '3 biens publiés',
                    style: GoogleFonts.inter(color: kTextMuted, fontSize: 10),
                  ),
                ],
              ),
            ],
          ),
          if (t.sellerPhone != null && t.sellerPhone!.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: kDarkCardLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.phone_rounded,
                    color: kPrimaryLight,
                    size: 16,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    t.sellerPhone!,
                    style: GoogleFonts.inter(
                      color: kTextPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => _showContact(),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: kPrimarySurface,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'Appeler',
                        style: GoogleFonts.inter(
                          color: kPrimaryLight,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: kGoldSurface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: kGold.withValues(alpha: 0.2)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.verified_rounded, color: kGold, size: 14),
                const SizedBox(width: 6),
                Text(
                  'Vendeur identifié FONCIRA',
                  style: GoogleFonts.inter(
                    color: kGold,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWhyVerify() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: kPrimarySurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: kPrimaryLight.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Pourquoi vérifier ce terrain ?',
            style: GoogleFonts.inter(
              color: kPrimaryLight,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          _whyItem(Icons.gavel_rounded, 'Éviter litige'),
          _whyItem(Icons.savings_rounded, 'Sécuriser votre argent'),
          _whyItem(Icons.content_copy_rounded, 'Éviter double vente'),
          _whyItem(Icons.person_search_rounded, 'Confirmer propriétaire'),
          _whyItem(Icons.description_rounded, 'Vérifier documents'),
          _whyItem(Icons.straighten_rounded, 'Vérifier limites'),
          _whyItem(Icons.account_balance_rounded, 'Vérifier domaine État'),
        ],
      ),
    );
  }

  Widget _buildMapSmall() {
    return SizedBox(
      height: 220,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: kBorderDark),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: FlutterMap(
            options: MapOptions(initialCenter: t.coordinates!, initialZoom: 14),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: _kOsmUserAgentPackageName,
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: t.coordinates!,
                    width: 36,
                    height: 36,
                    child: Container(
                      decoration: BoxDecoration(
                        color: kPrimary,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                        boxShadow: [
                          BoxShadow(
                            color: kPrimary.withValues(alpha: 0.4),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.location_on_rounded,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Helpers ──

  Widget _circleBtn(
    IconData icon,
    VoidCallback onTap, {
    Color color = Colors.white,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.all(8),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black45,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color, size: 20),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.outfit(
        color: kTextPrimary,
        fontSize: 16,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  Widget _statusChip(IconData icon, String text, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: 0.25)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 14),
            const SizedBox(width: 5),
            Flexible(
              child: Text(
                text,
                style: GoogleFonts.inter(
                  color: color,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoTile(IconData icon, String label, String value) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: kPrimaryLight, size: 20),
          const SizedBox(height: 6),
          Text(
            label,
            style: GoogleFonts.inter(color: kTextMuted, fontSize: 10),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: GoogleFonts.inter(
              color: kTextPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _verifItem(bool ok, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(
            ok ? Icons.check_rounded : Icons.close_rounded,
            color: ok ? kSuccess : kDanger,
            size: 16,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.inter(
                color: ok ? kTextSecondary : kDanger,
                fontSize: 12,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _whyItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(icon, color: kPrimaryLight.withValues(alpha: 0.7), size: 14),
          const SizedBox(width: 8),
          Text(
            text,
            style: GoogleFonts.inter(color: kTextSecondary, fontSize: 12),
          ),
        ],
      ),
    );
  }

  void _showInfoDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: kDarkCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Niveaux de vérification',
          style: GoogleFonts.outfit(
            color: kTextPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _infoRow(
              kSuccess,
              'Vérification de base',
              'Identité vendeur, localisation, photos, cohérence des informations.',
            ),
            const SizedBox(height: 14),
            _infoRow(
              kGold,
              'Analyse approfondie',
              'Cadastre, coutumier, géomètre, vérification de litige, double vente, domaine État.',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Compris',
              style: GoogleFonts.inter(
                color: kPrimaryLight,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(Color color, String title, String desc) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 4,
          height: 40,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.inter(
                  color: kTextPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                desc,
                style: GoogleFonts.inter(
                  color: kTextMuted,
                  fontSize: 11,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showContact() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Contact: ${t.sellerPhone ?? "Non disponible"}',
          style: GoogleFonts.inter(fontSize: 13),
        ),
        backgroundColor: kDarkCard,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _requestVerification() {
    // Create verification entry in provider (for tracking)
    final verifProv = context.read<VerificationProvider>();
    verifProv.createFromMarketplace(
      terrainId: t.id,
      terrainTitle: t.title,
      terrainLocation: t.fullLocation,
      terrainPrice: t.price,
      terrainImageUrl: t.imageUrl,
    );

    // Navigate to verification tunnel
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const VerificationTunnelPage()),
    );
  }
}
