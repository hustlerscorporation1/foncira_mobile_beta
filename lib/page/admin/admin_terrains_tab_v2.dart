// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
//  FONCIRA â€” Admin Terrains Tab (Manage & Moderation)
// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•

import 'package:flutter/material.dart';
import 'package:foncira/theme/colors.dart';
import 'package:foncira/services/supabase_service.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'admin_add_terrain_dialog.dart';

class AdminTerrainsTab extends StatefulWidget {
  const AdminTerrainsTab({super.key});

  @override
  State<AdminTerrainsTab> createState() => _AdminTerrainsTabState();
}

class _AdminTerrainsTabState extends State<AdminTerrainsTab> {
  final supabase = SupabaseService().client;

  // Filtres
  String _selectedCity = 'Todos';
  String _selectedStatus = 'Tous';
  String _selectedDocType = 'Tous';
  String _selectedVerificationStatus = 'Tous';
  int _currentPage = 0;
  final int _itemsPerPage = 20;

  // Recherche
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // En-tÃªte avec titre et bouton ajouter
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Gestion des terrains',
                      style: GoogleFonts.outfit(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: _showAddTerrainDialog,
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Ajouter'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kPrimary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Barre de recherche
              TextField(
                controller: _searchController,
                style: GoogleFonts.inter(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Rechercher par titre ou vendeur...',
                  hintStyle: GoogleFonts.inter(color: Colors.grey[600]),
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  filled: true,
                  fillColor: const Color(0xFF1A1A2E),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey[800]!),
                  ),
                ),
                onChanged: (_) => setState(() => _currentPage = 0),
              ),

              const SizedBox(height: 12),

              // Filtres
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildFilterDropdown(
                      'Ville',
                      _selectedCity,
                      ['Todos', 'LomÃ©', 'Kara', 'SokodÃ©', 'AtakpamÃ©'],
                      (value) => setState(() {
                        _selectedCity = value;
                        _currentPage = 0;
                      }),
                    ),
                    const SizedBox(width: 8),
                    _buildFilterDropdown(
                      'Statut',
                      _selectedStatus,
                      [
                        'Tous',
                        'draft',
                        'publie',
                        'suspendu',
                        'vendu',
                        'archive',
                      ],
                      (value) => setState(() {
                        _selectedStatus = value;
                        _currentPage = 0;
                      }),
                    ),
                    const SizedBox(width: 8),
                    _buildFilterDropdown(
                      'Doc type',
                      _selectedDocType,
                      [
                        'Tous',
                        'titre_foncier',
                        'logement',
                        'convention',
                        'recu_vente',
                        'aucun_document',
                        'ne_sais_pas',
                      ],
                      (value) => setState(() {
                        _selectedDocType = value;
                        _currentPage = 0;
                      }),
                    ),
                    const SizedBox(width: 8),
                    _buildFilterDropdown(
                      'VÃ©rification',
                      _selectedVerificationStatus,
                      [
                        'Tous',
                        'non_verifie',
                        'verification_base_effectuee',
                        'verification_complete',
                      ],
                      (value) => setState(() {
                        _selectedVerificationStatus = value;
                        _currentPage = 0;
                      }),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Liste des terrains
        Expanded(
          child: FutureBuilder<List<Map<String, dynamic>>>(
            future: _fetchTerrains(),
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

              final terrains = snapshot.data ?? [];
              if (terrains.isEmpty) {
                return Center(
                  child: Text(
                    'Aucun terrain trouvÃ©',
                    style: GoogleFonts.inter(color: Colors.grey[500]),
                  ),
                );
              }

              return Column(
                children: [
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final width = constraints.maxWidth;
                        final crossAxisCount = width < 430
                            ? 1
                            : width < 900
                            ? 2
                            : 3;
                        final childAspectRatio = crossAxisCount == 1
                            ? 1.65
                            : crossAxisCount == 2
                            ? 0.86
                            : 0.94;

                        return GridView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: crossAxisCount,
                            mainAxisSpacing: 16,
                            crossAxisSpacing: 16,
                            childAspectRatio: childAspectRatio,
                          ),
                          itemCount: terrains.length,
                          itemBuilder: (context, index) {
                            return _buildTerrainCard(terrains[index]);
                          },
                        );
                      },
                    ),
                  ),

                  // Pagination
                  _buildPaginationControls(terrains.length),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFilterDropdown(
    String label,
    String value,
    List<String> options,
    Function(String) onChanged,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[700]!),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: DropdownButton<String>(
        value: value,
        dropdownColor: const Color(0xFF0F0F1E),
        underline: const SizedBox.shrink(),
        items: options
            .map(
              (option) => DropdownMenuItem(
                value: option,
                child: Text(
                  option,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[400],
                  ),
                ),
              ),
            )
            .toList(),
        onChanged: (newValue) {
          if (newValue != null) onChanged(newValue);
        },
        style: GoogleFonts.inter(color: Colors.white),
      ),
    );
  }

  Widget _buildTerrainCard(Map<String, dynamic> terrain) {
    final status = terrain['status']?.toString() ?? 'unknown';
    final verificationStatus =
        terrain['verification_status']?.toString() ?? 'non_verifie';
    final statusColor = _getStatusColor(status);
    final verificationColor = _getVerificationStatusColor(verificationStatus);

    final surface = terrain['surface'] ?? terrain['area_sqm'] ?? 0;
    final city =
        terrain['ville'] ?? terrain['city'] ?? terrain['location'] ?? 'Ville';
    final price = terrain['price_fcfa'] ?? terrain['price'] ?? 0;
    final imageUrl =
        terrain['main_photo_url'] ??
        terrain['featured_image'] ??
        _extractFirstPhotoUrl(terrain['additional_photos']);
    final priceFormatted = NumberFormat('#,##0', 'fr_FR').format(price);

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[800]!),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Container(
                height: 108,
                width: double.infinity,
                color: Colors.grey[900],
                child: imageUrl != null
                    ? Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (c, e, st) => Center(
                          child: Icon(
                            Icons.image_not_supported,
                            color: Colors.grey[600],
                          ),
                        ),
                      )
                    : Icon(Icons.landscape, color: Colors.grey[600], size: 40),
              ),

              Positioned(
                top: 8,
                left: 8,
                child: Container(
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  child: Text(
                    _getStatusLabel(status),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              Positioned(
                top: 8,
                right: 40,
                child: Container(
                  decoration: BoxDecoration(
                    color: verificationColor.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 3,
                  ),
                  child: Icon(
                    _getVerificationIcon(verificationStatus),
                    color: Colors.white,
                    size: 14,
                  ),
                ),
              ),

              Positioned(
                top: 4,
                right: 4,
                child: PopupMenuButton<String>(
                  color: const Color(0xFF1A1A2E),
                  onSelected: (value) {
                    _handleTerrainAction(value, terrain['id']);
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'change_status',
                      child: Row(
                        children: [
                          const Icon(Icons.edit, color: kPrimary, size: 16),
                          const SizedBox(width: 8),
                          const Text('Modifier statut'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'change_verification',
                      child: Row(
                        children: [
                          const Icon(Icons.verified, color: kPrimary, size: 16),
                          const SizedBox(width: 8),
                          const Text('Verification'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'view_verifications',
                      child: Row(
                        children: [
                          const Icon(Icons.list, color: Colors.blue, size: 16),
                          const SizedBox(width: 8),
                          const Text('Verifications liees'),
                        ],
                      ),
                    ),
                    const PopupMenuDivider(),
                    PopupMenuItem(
                      value: 'archive',
                      child: Row(
                        children: [
                          const Icon(
                            Icons.archive,
                            color: Colors.orange,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          const Text('Archiver'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    (terrain['title'] as String?) ?? 'Titre',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.outfit(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$surface m2 - $city',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      color: Colors.grey[500],
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '$priceFormatted F',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: kPrimary,
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

  String _getStatusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'draft':
        return 'DRAFT';
      case 'publie':
        return 'PUBLIE';
      case 'suspendu':
        return 'SUSPENDU';
      case 'vendu':
        return 'VENDU';
      case 'archive':
        return 'ARCHIVE';
      default:
        return status.toUpperCase();
    }
  }

  String? _extractFirstPhotoUrl(dynamic additionalPhotos) {
    if (additionalPhotos == null) return null;

    if (additionalPhotos is List && additionalPhotos.isNotEmpty) {
      final first = additionalPhotos.first;
      if (first is String && first.isNotEmpty) return first;

      if (first is Map) {
        final url = first['url'] ?? first['photo_url'];
        if (url is String && url.isNotEmpty) return url;
      }
    }

    if (additionalPhotos is Map) {
      final url = additionalPhotos['url'] ?? additionalPhotos['photo_url'];
      if (url is String && url.isNotEmpty) return url;
    }

    return null;
  }
  Widget _buildPaginationControls(int totalItems) {
    final totalPages = (totalItems / _itemsPerPage).ceil();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            onPressed: _currentPage > 0
                ? () => setState(() => _currentPage--)
                : null,
            icon: const Icon(Icons.chevron_left),
            color: _currentPage > 0 ? kPrimary : Colors.grey[600],
          ),
          Text(
            'Page ${_currentPage + 1}/$totalPages',
            style: GoogleFonts.inter(color: Colors.grey[400]),
          ),
          IconButton(
            onPressed: _currentPage < totalPages - 1
                ? () => setState(() => _currentPage++)
                : null,
            icon: const Icon(Icons.chevron_right),
            color: _currentPage < totalPages - 1 ? kPrimary : Colors.grey[600],
          ),
        ],
      ),
    );
  }

  void _handleTerrainAction(String action, String terrainId) {
    switch (action) {
      case 'change_status':
        _showChangeStatusDialog(terrainId);
        break;
      case 'change_verification':
        _showChangeVerificationDialog(terrainId);
        break;
      case 'view_verifications':
        _showLinkedVerificationsDialog(terrainId);
        break;
      case 'archive':
        _showArchiveConfirmDialog(terrainId);
        break;
    }
  }

  void _showChangeStatusDialog(String terrainId) {
    const statuses = ['draft', 'publie', 'suspendu', 'vendu'];
    String? selectedStatus;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        title: Text(
          'Modifier le statut',
          style: GoogleFonts.outfit(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        content: StatefulBuilder(
          builder: (context, setState) => Column(
            mainAxisSize: MainAxisSize.min,
            children: statuses
                .map(
                  (status) => GestureDetector(
                    onTap: () => setState(() => selectedStatus = status),
                    child: Container(
                      decoration: BoxDecoration(
                        color: selectedStatus == status
                            ? kPrimary.withOpacity(0.2)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: selectedStatus == status
                              ? kPrimary
                              : Colors.grey[700]!,
                        ),
                      ),
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: selectedStatus == status
                                    ? kPrimary
                                    : Colors.grey[600]!,
                              ),
                            ),
                            child: selectedStatus == status
                                ? const Center(
                                    child: Icon(
                                      Icons.check,
                                      color: kPrimary,
                                      size: 12,
                                    ),
                                  )
                                : null,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            status.toUpperCase(),
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (selectedStatus != null) {
                await supabase
                    .from('terrains_foncira')
                    .update({'status': selectedStatus})
                    .eq('id', terrainId);

                if (mounted) {
                  Navigator.pop(context);
                  setState(() {});
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Statut mis Ã  jour'),
                      backgroundColor: kSuccess,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: kPrimary),
            child: const Text('Appliquer'),
          ),
        ],
      ),
    );
  }

  void _showChangeVerificationDialog(String terrainId) {
    const verifications = [
      'non_verifie',
      'verification_base_effectuee',
      'verification_complete',
    ];
    String? selectedVerification;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        title: Text(
          'Statut de vÃ©rification',
          style: GoogleFonts.outfit(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        content: StatefulBuilder(
          builder: (context, setState) => Column(
            mainAxisSize: MainAxisSize.min,
            children: verifications
                .map(
                  (status) => GestureDetector(
                    onTap: () => setState(() => selectedVerification = status),
                    child: Container(
                      decoration: BoxDecoration(
                        color: selectedVerification == status
                            ? kPrimary.withOpacity(0.2)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: selectedVerification == status
                              ? kPrimary
                              : Colors.grey[700]!,
                        ),
                      ),
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        status.replaceAll('_', ' ').toUpperCase(),
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (selectedVerification != null) {
                await supabase
                    .from('terrains_foncira')
                    .update({'verification_status': selectedVerification})
                    .eq('id', terrainId);

                if (mounted) {
                  Navigator.pop(context);
                  setState(() {});
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('VÃ©rification mise Ã  jour'),
                      backgroundColor: kSuccess,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: kPrimary),
            child: const Text('Appliquer'),
          ),
        ],
      ),
    );
  }

  void _showArchiveConfirmDialog(String terrainId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        title: Text(
          'Archiver le terrain',
          style: GoogleFonts.outfit(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.red,
          ),
        ),
        content: Text(
          'Cette action marquera le terrain comme archivÃ© (deleted_at = now). ÃŠtes-vous sÃ»r?',
          style: GoogleFonts.inter(color: Colors.grey[300]),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              await supabase
                  .from('terrains_foncira')
                  .update({'deleted_at': DateTime.now().toIso8601String()})
                  .eq('id', terrainId);

              if (mounted) {
                Navigator.pop(context);
                setState(() {});
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Terrain archivÃ©'),
                    backgroundColor: Colors.orange,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Archiver'),
          ),
        ],
      ),
    );
  }

  void _showLinkedVerificationsDialog(String terrainId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        title: Text(
          'VÃ©rifications liÃ©es',
          style: GoogleFonts.outfit(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        content: FutureBuilder<List<Map<String, dynamic>>>(
          future: supabase
              .from('verifications')
              .select('id, client_name, status')
              .eq('terrain_id', terrainId),
          builder: (context, snapshot) {
            if (!snapshot.hasData)
              return SizedBox(
                width: 200,
                height: 100,
                child: Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(kPrimary),
                  ),
                ),
              );

            final verifications = snapshot.data ?? [];
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: verifications.isEmpty
                  ? [
                      Text(
                        'Aucune vÃ©rification liÃ©e',
                        style: GoogleFonts.inter(color: Colors.grey[500]),
                      ),
                    ]
                  : verifications
                        .map(
                          (v) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFF0F0F1E),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              padding: const EdgeInsets.all(8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    v['client_name'] ?? 'N/A',
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    v['status'] ?? 'N/A',
                                    style: GoogleFonts.inter(
                                      fontSize: 11,
                                      color: Colors.grey[500],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                        .toList(),
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  void _showAddTerrainDialog() {
    showDialog(
      context: context,
      builder: (context) => AdminAddTerrainDialog(
        onTerrainCreated: () {
          setState(() => _currentPage = 0);
        },
      ),
    );
  }

  Future<List<Map<String, dynamic>>> _fetchTerrains() async {
    try {
      var query = supabase
          .from('terrains_foncira')
          .select('*')
          .isFilter('deleted_at', null);

      // Appliquer filtres
      if (_selectedCity != 'Todos') {
        query = query.eq('ville', _selectedCity);
      }
      if (_selectedStatus != 'Tous') {
        query = query.eq('status', _selectedStatus);
      }
      if (_selectedDocType != 'Tous') {
        query = query.eq('document_type', _selectedDocType);
      }
      if (_selectedVerificationStatus != 'Tous') {
        query = query.eq('verification_status', _selectedVerificationStatus);
      }

      // Recherche
      if (_searchController.text.isNotEmpty) {
        query = query.or(
          'title.ilike.%${_searchController.text}%,seller_name.ilike.%${_searchController.text}%',
        );
      }

      // Pagination
      final offset = _currentPage * _itemsPerPage;
      final response = await query.range(offset, offset + _itemsPerPage - 1);

      return response as List<Map<String, dynamic>>;
    } catch (e) {
      return [];
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'draft':
        return Colors.grey;
      case 'publie':
        return kSuccess;
      case 'suspendu':
        return Colors.orange;
      case 'vendu':
        return Colors.blue;
      case 'archive':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Color _getVerificationStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'non_verifie':
        return Colors.grey;
      case 'verification_base_effectuee':
        return Colors.orange;
      case 'verification_complete':
        return kSuccess;
      default:
        return Colors.grey;
    }
  }

  IconData _getVerificationIcon(String? status) {
    switch (status?.toLowerCase()) {
      case 'non_verifie':
        return Icons.close;
      case 'verification_base_effectuee':
        return Icons.schedule;
      case 'verification_complete':
        return Icons.verified;
      default:
        return Icons.help;
    }
  }
}
