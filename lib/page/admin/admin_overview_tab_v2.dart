// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
//  FONCIRA â€” Admin Dashboard Overview Tab (Real-time from Supabase)
// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•

import 'package:flutter/material.dart';
import 'package:foncira/theme/colors.dart';
import 'package:foncira/services/supabase_service.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class AdminOverviewTab extends StatefulWidget {
  const AdminOverviewTab({super.key});

  @override
  State<AdminOverviewTab> createState() => _AdminOverviewTabState();
}

class _AdminOverviewTabState extends State<AdminOverviewTab> {
  final supabase = SupabaseService().client;
  DateTime? _selectedDate;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Titre
          Text(
            'Vue d\'ensemble',
            style: GoogleFonts.outfit(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 24),

          // 4 MÃ©triques KPI en temps rÃ©el
          _buildMetricsGrid(),

          const SizedBox(height: 32),

          // Graphique vÃ©rifications par jour (30 derniers jours)
          _buildVerificationsChart(),

          const SizedBox(height: 32),

          // Liste des 5 derniÃ¨res vÃ©rifications
          _buildRecentVerificationsList(),
        ],
      ),
    );
  }

  Widget _buildMetricsGrid() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      children: [
        // VÃ©rifications actives
        _buildMetricCard(
          title: 'VÃ©rifications actives',
          future: _getActiveVerifications(),
          icon: Icons.verified_user,
          color: kPrimary,
        ),
        // Paiements du jour
        _buildMetricCard(
          title: 'Paiements (FCFA)',
          future: _getDailyPayments(),
          icon: Icons.payment,
          color: kSuccess,
          isCurrency: true,
        ),
        // VÃ©rifications en retard
        _buildMetricCardWithAlert(
          title: 'En retard',
          future: _getLateVerifications(),
          icon: Icons.warning,
          color: Colors.red,
        ),
        // Agents disponibles
        _buildMetricCard(
          title: 'Agents disponibles',
          future: _getAvailableAgents(),
          icon: Icons.people,
          color: Colors.purple,
        ),
      ],
    );
  }

  Widget _buildMetricCard({
    required String title,
    required Future<String> future,
    required IconData icon,
    required Color color,
    bool isCurrency = false,
  }) {
    return FutureBuilder<String>(
      future: future,
      builder: (context, snapshot) {
        final value = snapshot.data ?? (isCurrency ? '0 F' : '0');
        final isLoading = !snapshot.hasData;

        return Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A2E),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: color, size: 32),
              const SizedBox(height: 12),
              if (isLoading)
                SizedBox(
                  height: 28,
                  child: Center(
                    child: SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(color),
                      ),
                    ),
                  ),
                )
              else
                Text(
                  value,
                  style: GoogleFonts.outfit(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              const SizedBox(height: 4),
              Text(
                title,
                style: GoogleFonts.inter(fontSize: 12, color: Colors.grey[400]),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMetricCardWithAlert({
    required String title,
    required Future<int> future,
    required IconData icon,
    required Color color,
  }) {
    return FutureBuilder<int>(
      future: future,
      builder: (context, snapshot) {
        final count = snapshot.data ?? 0;
        final isLoading = !snapshot.hasData;

        return GestureDetector(
          onTap: count > 0
              ? () {
                  // Navigate to filter in verifications tab
                  if (Navigator.canPop(context)) {
                    // Assume parent knows about tab switching
                  }
                }
              : null,
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A2E),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: count > 0 ? color : color.withOpacity(0.3),
              ),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, color: color, size: 32),
                const SizedBox(height: 12),
                if (isLoading)
                  SizedBox(
                    height: 28,
                    child: Center(
                      child: SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(color),
                        ),
                      ),
                    ),
                  )
                else
                  Text(
                    '$count',
                    style: GoogleFonts.outfit(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: Colors.grey[400],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildVerificationsChart() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'VÃ©rifications par jour (30 derniers jours)',
          style: GoogleFonts.outfit(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A2E),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[800]!),
          ),
          padding: const EdgeInsets.all(16),
          height: 250,
          child: FutureBuilder<List<Map<String, dynamic>>>(
            future: _getVerificationsLast30Days(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: SizedBox(
                    width: 30,
                    height: 30,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(kPrimary),
                    ),
                  ),
                );
              }

              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    'Erreur de chargement',
                    style: GoogleFonts.inter(color: Colors.red[300]),
                  ),
                );
              }

              final data = snapshot.data ?? const <Map<String, dynamic>>[];
              if (data.isEmpty) {
                return Center(
                  child: Text(
                    'Aucune donnée',
                    style: GoogleFonts.inter(color: Colors.grey[500]),
                  ),
                );
              }

              final maxCount = data
                  .map((d) => (d['count'] as num?)?.toInt() ?? 0)
                  .reduce((a, b) => a > b ? a : b);

              const double chartHeight = 180;
              const double barWidth = 12;
              const double itemWidth = 34;

              return ListView.separated(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: data.length,
                separatorBuilder: (_, __) => const SizedBox(width: 2),
                itemBuilder: (context, index) {
                  final item = data[index];
                  final count = (item['count'] as num?)?.toInt() ?? 0;
                  final day = item['day'] as String? ?? '';
                  final barHeight = maxCount > 0
                      ? ((count / maxCount) * chartHeight).clamp(0.0, chartHeight)
                      : 0.0;

                  return SizedBox(
                    width: itemWidth,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          '$count',
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            color: Colors.grey[500],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          width: barWidth,
                          height: barHeight,
                          decoration: BoxDecoration(
                            color: kPrimary,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          day,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            fontSize: 9,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRecentVerificationsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'DerniÃ¨res vÃ©rifications soumises',
          style: GoogleFonts.outfit(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        FutureBuilder<List<Map<String, dynamic>>>(
          future: _getRecentVerifications(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(
                child: SizedBox(
                  width: 30,
                  height: 30,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(kPrimary),
                  ),
                ),
              );
            }

            final verifications = snapshot.data ?? [];
            if (verifications.isEmpty) {
              return Center(
                child: Text(
                  'Aucune vÃ©rification soumise',
                  style: GoogleFonts.inter(color: Colors.grey[500]),
                ),
              );
            }

            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: verifications.length,
              itemBuilder: (context, index) {
                final v = verifications[index];
                final statusColor = _getStatusColor(v['status'] ?? 'unknown');
                final isLate = v['is_late'] as bool? ?? false;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1A2E),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isLate
                            ? Colors.red.withOpacity(0.5)
                            : Colors.grey[800]!,
                      ),
                    ),
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        // Status indicator
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isLate ? Colors.red : statusColor,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                v['client_name'] ?? 'Client',
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                '${v['terrain_location'] ?? 'N/A'} â€¢ Agent: ${v['agent_name'] ?? 'N/A'}',
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  color: Colors.grey[500],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
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
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }

  // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
  // Supabase Queries
  // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•

  Future<String> _getActiveVerifications() async {
    try {
      final response = await supabase
          .from('verifications')
          .select('id')
          .not('status', 'eq', 'rapport_livre')
          .count();

      return '${response.count}';
    } catch (e) {
      return '0';
    }
  }

  Future<String> _getDailyPayments() async {
    try {
      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final response = await supabase
          .from('payments')
          .select('amount_fcfa')
          .gte('created_at', startOfDay.toIso8601String())
          .lt('created_at', endOfDay.toIso8601String());

      if (response.isEmpty) return '0 F';

      final total = response.fold<int>(
        0,
        (sum, p) => sum + (p['amount_fcfa'] as int? ?? 0),
      );

      // Format avec sÃ©parateurs
      final formatted = NumberFormat('#,##0', 'fr_FR').format(total);
      return '$formatted F';
    } catch (e) {
      return '0 F';
    }
  }

  Future<int> _getLateVerifications() async {
    try {
      final now = DateTime.now();
      final response = await supabase
          .from('verifications')
          .select('id')
          .lt('expected_delivery_at', now.toIso8601String())
          .not('status', 'eq', 'rapport_livre');

      return (response as List).length;
    } catch (e) {
      return 0;
    }
  }

  Future<String> _getAvailableAgents() async {
    try {
      final response = await supabase
          .from('users')
          .select('id')
          .eq('role', 'agent')
          .eq('is_available', true)
          .count();

      return '${response.count}';
    } catch (e) {
      return '0';
    }
  }

  Future<List<Map<String, dynamic>>> _getVerificationsLast30Days() async {
    try {
      final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));

      final response = await supabase
          .from('verifications')
          .select('submitted_at')
          .gte('submitted_at', thirtyDaysAgo.toIso8601String());

      // Group by day
      final Map<String, int> dailyCount = {};
      for (var v in response) {
        final date = DateTime.parse(v['submitted_at'] as String);
        final dayKey = DateFormat('dd/MM').format(date);
        dailyCount[dayKey] = (dailyCount[dayKey] ?? 0) + 1;
      }

      // Create list from last 30 days
      final result = <Map<String, dynamic>>[];
      for (var i = 29; i >= 0; i--) {
        final date = DateTime.now().subtract(Duration(days: i));
        final dayKey = DateFormat('dd/MM').format(date);
        result.add({'day': dayKey, 'count': dailyCount[dayKey] ?? 0});
      }

      return result;
    } catch (e) {
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> _getRecentVerifications() async {
    try {
      final response = await supabase
          .from('verifications')
          .select(
            'id, client_name, terrain_location, status, expected_delivery_at, agent_id, agents(name)',
          )
          .order('submitted_at', ascending: false)
          .limit(5);

      final now = DateTime.now();
      final verifications = (response as List).map((v) {
        final expectedDate = DateTime.tryParse(
          v['expected_delivery_at'] as String? ?? '',
        );
        final isLate = expectedDate != null && expectedDate.isBefore(now);

        return {
          'id': v['id'],
          'client_name': v['client_name'],
          'terrain_location': v['terrain_location'],
          'status': v['status'],
          'agent_name': v['agents']?['name'] ?? 'N/A',
          'is_late': isLate,
        };
      }).toList();

      return verifications;
    } catch (e) {
      return [];
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'recu':
        return Colors.blue;
      case 'visite':
        return Colors.orange;
      case 'autorites':
        return Colors.purple;
      case 'rapport_livre':
        return kSuccess;
      default:
        return Colors.grey;
    }
  }
}
