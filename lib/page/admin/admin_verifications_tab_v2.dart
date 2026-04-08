// ══════════════════════════════════════════════════════════════
//  FONCIRA — Admin Verifications Tab (Real-time with Filters & Details)
// ══════════════════════════════════════════════════════════════

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:foncira/theme/colors.dart';
import 'package:foncira/services/supabase_service.dart';
import 'package:foncira/page/admin/admin_verification_detail.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class AdminVerificationsTab extends StatefulWidget {
  const AdminVerificationsTab({super.key});

  @override
  State<AdminVerificationsTab> createState() => _AdminVerificationsTabState();
}

class _AdminVerificationsTabState extends State<AdminVerificationsTab> {
  final supabase = SupabaseService().client;

  // Filtres
  String _selectedStatus = 'Tous';
  String? _selectedAgent;
  String? _selectedRiskLevel;
  String _selectedSource = 'Tous';
  DateTime? _startDate;
  DateTime? _endDate;
  late Future<List<Map<String, dynamic>>> _verificationsFuture;

  final statusOptions = [
    'Tous',
    'receptionnee',
    'pre_analyse',
    'verification_administrative',
    'verification_terrain',
    'analyse_finale',
    'rapport_livre',
    'rapport_rejete',
  ];
  final riskLevelOptions = ['Tous', 'faible', 'modere', 'eleve', 'critique'];
  final sourceOptions = ['Tous', 'externe', 'foncira_marketplace'];

  @override
  void initState() {
    super.initState();
    _verificationsFuture = _fetchVerifications();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // En-tête avec titre
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Vérifications',
                style: GoogleFonts.outfit(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),

              // Filtres horizontaux
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildFilterDropdown(
                      'Statut',
                      _selectedStatus,
                      statusOptions,
                      (value) {
                        setState(() {
                          _selectedStatus = value;
                          _verificationsFuture = _fetchVerifications();
                        });
                      },
                    ),
                    const SizedBox(width: 8),
                    _buildFilterDropdown(
                      'Risque',
                      _selectedRiskLevel ?? 'Tous',
                      riskLevelOptions,
                      (value) {
                        setState(() {
                          _selectedRiskLevel = value == 'Tous' ? null : value;
                          _verificationsFuture = _fetchVerifications();
                        });
                      },
                    ),
                    const SizedBox(width: 8),
                    _buildFilterDropdown(
                      'Source',
                      _selectedSource,
                      sourceOptions,
                      (value) {
                        setState(() {
                          _selectedSource = value;
                          _verificationsFuture = _fetchVerifications();
                        });
                      },
                    ),
                    const SizedBox(width: 8),
                    // Bouton date range
                    GestureDetector(
                      onTap: _showDateRangePicker,
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF1A1A2E),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey[700]!),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.date_range,
                              color: Colors.grey,
                              size: 16,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              _startDate != null
                                  ? DateFormat('dd/MM').format(_startDate!)
                                  : 'Dates',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[400],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Liste des vérifications (stream temps réel)
        Expanded(
          child: FutureBuilder<List<Map<String, dynamic>>>(
            future: _verificationsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
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

              if (snapshot.hasError) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: Colors.red[400],
                        size: 42,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Erreur de chargement',
                        style: GoogleFonts.inter(
                          color: Colors.red[300],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Text(
                          snapshot.error.toString(),
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            color: Colors.grey[500],
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _verificationsFuture = _fetchVerifications();
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kPrimary,
                        ),
                        child: const Text('Réessayer'),
                      ),
                    ],
                  ),
                );
              }

              final verifications = snapshot.data ?? [];
              if (verifications.isEmpty) {
                return Center(
                  child: Text(
                    'Aucune vérification trouvée',
                    style: GoogleFonts.inter(color: Colors.grey[500]),
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: verifications.length,
                itemBuilder: (context, index) {
                  final v = verifications[index];
                  return _buildVerificationCard(context, v);
                },
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
          if (newValue != null) {
            onChanged(newValue);
          }
        },
        style: GoogleFonts.inter(color: Colors.white),
      ),
    );
  }

  Widget _buildVerificationCard(BuildContext context, Map<String, dynamic> v) {
    final statusColor = _getStatusColor(v['status'] ?? 'unknown');
    final submittedAt = DateTime.tryParse(v['submitted_at'] as String? ?? '');
    final expectedAt = DateTime.tryParse(
      v['expected_delivery_at'] as String? ?? '',
    );
    final isLate = expectedAt != null && expectedAt.isBefore(DateTime.now());

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                AdminVerificationDetailPage(verificationId: v['id']),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A2E),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isLate ? Colors.red.withOpacity(0.5) : Colors.grey[800]!,
            ),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // En-tête: Client + Status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          v['client_name'] ?? 'N/A',
                          style: GoogleFonts.outfit(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          v['terrain_location'] ?? 'N/A',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: Colors.grey[400],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: statusColor, width: 1),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    child: Text(
                      v['status'] ?? 'Inconnu',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: statusColor,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Infos secondaires
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInfoBadge(
                          'Agent',
                          v['agent_name'] ?? 'Non assigné',
                          Colors.blue,
                        ),
                        const SizedBox(height: 6),
                        _buildInfoBadge(
                          'Soumise',
                          submittedAt != null
                              ? DateFormat('dd/MM HH:mm').format(submittedAt)
                              : 'N/A',
                          Colors.grey,
                        ),
                      ],
                    ),
                  ),
                  if (isLate)
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Colors.red),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.warning,
                            color: Colors.red,
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'RETARD',
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    _buildInfoBadge(
                      'Livraison',
                      expectedAt != null
                          ? DateFormat('dd/MM').format(expectedAt)
                          : 'N/A',
                      Colors.green,
                    ),
                ],
              ),

              const SizedBox(height: 12),

              // Barre de progression (jour N/10)
              _buildProgressBar(v),

              const SizedBox(height: 12),

              // Bouton détail
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AdminVerificationDetailPage(
                          verificationId: v['id'],
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.remove_red_eye, size: 16),
                  label: const Text('Voir détail'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimary,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoBadge(String label, String value, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Text(
        '$label: $value',
        style: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: color,
        ),
      ),
    );
  }

  Widget _buildProgressBar(Map<String, dynamic> v) {
    final createdAt = DateTime.tryParse(v['submitted_at'] as String? ?? '');
    final daysPassed = createdAt != null
        ? DateTime.now().difference(createdAt).inDays + 1
        : 1;
    final totalDays = 10;
    final progress = (daysPassed / totalDays).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 6,
            backgroundColor: Colors.grey[800],
            valueColor: AlwaysStoppedAnimation<Color>(
              daysPassed > 10 ? Colors.red : kPrimary,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Jour $daysPassed / $totalDays',
          style: GoogleFonts.inter(fontSize: 11, color: Colors.grey[500]),
        ),
      ],
    );
  }

  void _showDateRangePicker() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2024),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: kPrimary,
              onPrimary: Colors.white,
              surface: Color(0xFF1A1A2E),
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
        _verificationsFuture = _fetchVerifications();
      });
    }
  }

  // ══════════════════════════════════════════════════════════════
  // Supabase Stream
  // ══════════════════════════════════════════════════════════════

  Future<List<Map<String, dynamic>>> _fetchVerifications() async {
    // Construire la requête avec filtres
    var query = supabase.from('verifications').select('''
          id,
          user_id,
          terrain_title,
          terrain_location,
          submitted_at,
          expected_delivery_at,
          source,
          status:client_status,
          risk_level:client_risk_level,
          agent_id:assigned_agent_id,
          users!user_id(id, first_name, last_name, full_name),
          agents!assigned_agent_id(id, full_name)
          ''');

    // Appliquer les filtres
    if (_selectedStatus != 'Tous') {
      query = query.eq('client_status', _selectedStatus);
    }

    final selectedRiskLevel = _selectedRiskLevel;
    if (selectedRiskLevel != null) {
      query = query.eq('client_risk_level', selectedRiskLevel);
    }

    if (_selectedSource != 'Tous') {
      query = query.eq('source', _selectedSource);
    }

    if (_startDate != null) {
      query = query.gte('submitted_at', _startDate!.toIso8601String());
    }

    if (_endDate != null) {
      query = query.lte('submitted_at', _endDate!.toIso8601String());
    }

    final data = await query
        .order('submitted_at', ascending: false)
        .timeout(const Duration(seconds: 15));

    return (data as List).map<Map<String, dynamic>>((v) {
      final row = Map<String, dynamic>.from(v as Map);
      final agent = row['agents'];
      final user = row['users'];

      final agentName = agent is Map ? (agent['full_name'] ?? 'N/A') : 'N/A';
      final userName = user is Map
          ? (user['full_name'] ??
                    '${user['first_name'] ?? ''} ${user['last_name'] ?? ''}')
                .toString()
                .trim()
          : 'N/A';

      return {
        ...row,
        'agent_name': agentName,
        'client_name': userName.isEmpty ? 'N/A' : userName,
      };
    }).toList();
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'receptionnee':
        return Colors.blue;
      case 'pre_analyse':
        return Colors.orange;
      case 'verification_administrative':
        return Colors.purple;
      case 'verification_terrain':
        return Colors.indigo;
      case 'analyse_finale':
        return Colors.amber;
      case 'rapport_livre':
        return kSuccess;
      case 'rapport_rejete':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
