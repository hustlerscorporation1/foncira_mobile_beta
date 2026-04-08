// ══════════════════════════════════════════════════════════════
//  FONCIRA — Agent Missions Tab
//  Affiche la liste des missions assignées à l'agent
// ══════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:foncira/theme/colors.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:foncira/services/agent_service.dart';
import 'agent_mission_card.dart';
import 'agent_mission_detail.dart';

class AgentMissionsTab extends StatefulWidget {
  const AgentMissionsTab({super.key});

  @override
  State<AgentMissionsTab> createState() => _AgentMissionsTabState();
}

class _AgentMissionsTabState extends State<AgentMissionsTab> {
  late AgentService _agentService;
  late Future<List<Map<String, dynamic>>> _missionsFuture;

  @override
  void initState() {
    super.initState();
    _agentService = AgentService();
    _missionsFuture = _agentService.getAgentMissions();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        setState(() {
          _missionsFuture = _agentService.getAgentMissions();
        });
      },
      color: kPrimary,
      backgroundColor: const Color(0xFF1E1E2E),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Titre
            Text(
              'Mes missions',
              style: GoogleFonts.outfit(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),

            // Sous-titre
            Text(
              'Missions assignées et à collecter',
              style: GoogleFonts.outfit(
                fontSize: 14,
                color: const Color(0xFF6B6B7F),
              ),
            ),
            const SizedBox(height: 24),

            // Liste des missions
            FutureBuilder<List<Map<String, dynamic>>>(
              future: _missionsFuture,
              builder: (context, snapshot) {
                // Chargement
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40),
                      child: Column(
                        children: [
                          const CircularProgressIndicator(
                            color: kPrimary,
                            strokeWidth: 2,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Chargement des missions...',
                            style: GoogleFonts.outfit(
                              color: const Color(0xFF6B6B7F),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                // Erreur
                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          color: Colors.red.withOpacity(0.7),
                          size: 48,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Erreur lors du chargement',
                          style: GoogleFonts.outfit(
                            fontSize: 16,
                            color: Colors.red.withOpacity(0.7),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          snapshot.error.toString(),
                          style: GoogleFonts.outfit(
                            fontSize: 12,
                            color: const Color(0xFF6B6B7F),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }

                // Pas de missions
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.assignment_outlined,
                          color: const Color(0xFF6B6B7F),
                          size: 48,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Aucune mission assignée',
                          style: GoogleFonts.outfit(
                            fontSize: 16,
                            color: const Color(0xFF6B6B7F),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Les missions vous seront assignées au fur et à mesure',
                          style: GoogleFonts.outfit(
                            fontSize: 12,
                            color: const Color(0xFF6B6B7F),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }

                // Liste des missions
                final missions = snapshot.data!;
                return Column(
                  children: List.generate(missions.length, (index) {
                    final mission = missions[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: AgentMissionCard(
                        mission: mission,
                        onTap: () {
                          _openMissionDetail(mission);
                        },
                      ),
                    );
                  }),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Ouvre le détail d'une mission
  void _openMissionDetail(Map<String, dynamic> mission) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) =>
            AgentMissionDetail(mission: mission, agentService: _agentService),
      ),
    );
  }
}
