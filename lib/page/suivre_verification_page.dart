import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../theme/colors.dart';
import '../component/foncira_button.dart';
import '../providers/auth_provider.dart';
import '../services/supabase_service.dart';

// ══════════════════════════════════════════════════════════════
//  Suivi Vérification — Real-time Verification Tracking
// ══════════════════════════════════════════════════════════════

class SuivreVerificationPage extends StatefulWidget {
  const SuivreVerificationPage({super.key});

  @override
  State<SuivreVerificationPage> createState() => _SuivreVerificationPageState();
}

class _SuivreVerificationPageState extends State<SuivreVerificationPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kDarkBg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Suivi de vérification',
          style: GoogleFonts.outfit(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: kTextPrimary,
          ),
        ),
      ),
      backgroundColor: kDarkBg,
      body: SafeArea(
        child: Consumer<AuthProvider>(
          builder: (context, authProvider, _) {
            final userId = authProvider.currentUser?.id;

            if (userId == null) {
              return Center(
                child: Text(
                  'Non authentifié',
                  style: GoogleFonts.inter(color: kTextMuted),
                ),
              );
            }

            return StreamBuilder<List<Map<String, dynamic>>>(
              stream: SupabaseService.instance.client
                  .from('verifications')
                  .stream(primaryKey: ['id'])
                  .eq('user_id', userId)
                  .order('submitted_at', ascending: false),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Erreur: ${snapshot.error}',
                      style: GoogleFonts.inter(color: kDanger),
                    ),
                  );
                }

                final verifications =
                    snapshot.data ?? const <Map<String, dynamic>>[];

                // Filter active verifications (not completed)
                final activeVerifications = verifications
                    .where(
                      (v) =>
                          (v['client_status'] ?? v['status']) !=
                          'rapport_livre',
                    )
                    .toList();

                if (activeVerifications.isEmpty) {
                  return _EmptyState();
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(24),
                  itemCount: activeVerifications.length,
                  itemBuilder: (context, index) => _VerificationCard(
                    verification: activeVerifications[index],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _VerificationCard extends StatelessWidget {
  final Map<String, dynamic> verification;

  const _VerificationCard({required this.verification});

  @override
  Widget build(BuildContext context) {
    final status =
        verification['client_status'] as String? ??
        verification['status'] as String? ??
        'en_attente';
    final terrainTitre =
        verification['terrain_titre'] as String? ??
        verification['terrain_title'] as String? ??
        'Terrain';
    final createdAt =
        verification['created_at'] as String? ??
        verification['submitted_at'] as String? ??
        '';
    final verificationId = verification['id'] as String?;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: kDarkCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kBorderDark),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Terrain title
          Text(
            terrainTitre,
            style: GoogleFonts.outfit(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: kTextPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Soumise le ${_formatDate(createdAt)}',
            style: GoogleFonts.inter(fontSize: 12, color: kTextMuted),
          ),
          const SizedBox(height: 24),

          // Milestones timeline
          _MilestonesTimeline(verificationId: verificationId),
          const SizedBox(height: 24),

          // Status badge
          Row(
            children: [
              _StatusBadge(status),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _getStatusLabel(status),
                  style: GoogleFonts.inter(fontSize: 13, color: kTextSecondary),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(String dateStr) {
    if (dateStr.isEmpty) return 'Date inconnue';
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return 'Date inconnue';
    }
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'receptionnee':
        return 'Demande reçue. Attente de traitement';
      case 'pre_analyse':
        return 'Pré-analyse en cours';
      case 'verification_administrative':
        return 'Vérification administrative en cours';
      case 'verification_terrain':
        return 'Collecte terrain en cours';
      case 'analyse_finale':
        return 'Analyse finale en cours';
      case 'en_attente':
        return 'En attente de validation';
      case 'acceptee':
        return 'Vérification en cours';
      case 'rapport_livre':
        return 'Rapport personnalisé livré';
      default:
        return 'Statut inconnu';
    }
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge(this.status);

  @override
  Widget build(BuildContext context) {
    final color = _getStatusColor();
    final icon = _getStatusIcon();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            _getStatusBadgeLabel(),
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor() {
    switch (status) {
      case 'receptionnee':
        return const Color(0xFFFFB84D);
      case 'acceptee':
        return kSuccess;
      case 'rapport_livre':
        return kSuccess;
      default:
        return kTextMuted;
    }
  }

  IconData _getStatusIcon() {
    switch (status) {
      case 'receptionnee':
        return Icons.hourglass_top_rounded;
      case 'acceptee':
        return Icons.check_circle_rounded;
      case 'rapport_livre':
        return Icons.task_alt_rounded;
      default:
        return Icons.info_outline_rounded;
    }
  }

  String _getStatusBadgeLabel() {
    switch (status) {
      case 'receptionnee':
        return 'En cours';
      case 'pre_analyse':
      case 'verification_administrative':
      case 'verification_terrain':
      case 'analyse_finale':
        return 'Vérification';
      case 'acceptee':
        return 'Vérification';
      case 'rapport_livre':
        return 'Terminée';
      default:
        return 'Inconnu';
    }
  }
}

class _MilestonesTimeline extends StatelessWidget {
  final String? verificationId;

  const _MilestonesTimeline({this.verificationId});

  @override
  Widget build(BuildContext context) {
    if (verificationId == null) {
      return const SizedBox.shrink();
    }

    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: SupabaseService.instance.client
          .from('verification_milestones')
          .stream(primaryKey: ['id'])
          .eq('verification_id', verificationId!),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: CircularProgressIndicator(),
          );
        }

        if (snapshot.hasError) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              'Impossible de charger les événements',
              style: GoogleFonts.inter(fontSize: 12, color: kTextMuted),
            ),
          );
        }

        final milestones =
            List<Map<String, dynamic>>.from(
              snapshot.data ?? const <Map<String, dynamic>>[],
            )..sort((a, b) {
              final aOrder = _milestoneOrder(a);
              final bOrder = _milestoneOrder(b);
              return aOrder.compareTo(bOrder);
            });
        if (milestones.isEmpty) {
          const defaults = [
            'Demande validée',
            'Vérification administrative',
            'Vérification coutumière',
            'Vérification du voisinage & Géomètre',
            'Décision du juriste & Rapport final',
          ];

          return Column(
            children: [
              for (int i = 0; i < defaults.length; i++)
                _MilestoneItem(
                  milestone: {'milestone_description': defaults[i]},
                  isLast: i == defaults.length - 1,
                ),
            ],
          );
        }

        return Column(
          children: [
            for (int i = 0; i < milestones.length; i++)
              _MilestoneItem(
                milestone: milestones[i],
                isLast: i == milestones.length - 1,
              ),
          ],
        );
      },
    );
  }

  int _milestoneOrder(Map<String, dynamic> milestone) {
    final position = milestone['position'];
    if (position is int) return position;

    final dayNumber = milestone['milestone_day'];
    if (dayNumber is int) return dayNumber;

    final day = (dayNumber as String? ?? '').toUpperCase();
    switch (day) {
      case 'J1':
        return 1;
      case 'J3':
        return 3;
      case 'J5':
        return 5;
      case 'J7':
        return 7;
      case 'J10':
        return 10;
      default:
        return 999;
    }
  }
}

class _MilestoneItem extends StatelessWidget {
  final Map<String, dynamic> milestone;
  final bool isLast;

  const _MilestoneItem({required this.milestone, required this.isLast});

  @override
  Widget build(BuildContext context) {
    final isCompleted = milestone['completed_at'] != null;
    final description =
        milestone['milestone_description'] as String? ??
        milestone['description'] as String? ??
        milestone['milestone_name'] as String? ??
        'Jalons';
    final completedAt = milestone['completed_at'] as String?;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Timeline circle
        Column(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isCompleted ? kSuccess.withOpacity(0.1) : kBorderDark,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isCompleted ? kSuccess : kBorderDark,
                  width: 2,
                ),
              ),
              child: Center(
                child: Icon(
                  isCompleted ? Icons.check_rounded : Icons.schedule_rounded,
                  size: 18,
                  color: isCompleted ? kSuccess : kTextMuted,
                ),
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 32,
                color: isCompleted ? kSuccess : kBorderDark,
                margin: const EdgeInsets.symmetric(vertical: 4),
              ),
          ],
        ),
        const SizedBox(width: 16),

        // Content
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(top: isCompleted ? 0 : 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  description,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isCompleted ? kSuccess : kTextPrimary,
                  ),
                ),
                if (isCompleted && completedAt != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      'Complété le ${_formatDate(completedAt)}',
                      style: GoogleFonts.inter(fontSize: 11, color: kTextMuted),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _formatDate(String dateStr) {
    if (dateStr.isEmpty) return '';
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return '';
    }
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: kBorderDark,
                borderRadius: BorderRadius.circular(50),
              ),
              child: const Center(
                child: Icon(
                  Icons.document_scanner_rounded,
                  size: 50,
                  color: kTextMuted,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Aucune vérification en cours',
              style: GoogleFonts.outfit(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: kTextPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Soumettez un nouveau terrain pour commencer une vérification',
              style: GoogleFonts.inter(
                fontSize: 13,
                color: kTextMuted,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            FonciraButton(
              label: 'Vérifier un terrain →',
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
}
