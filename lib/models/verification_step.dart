// ══════════════════════════════════════════════════════════════
//  FONCIRA — Verification Step Model
// ══════════════════════════════════════════════════════════════

enum StepStatus {
  enAttente,
  enCours,
  termine,
}

extension StepStatusExtension on StepStatus {
  String get label {
    switch (this) {
      case StepStatus.enAttente:
        return 'En attente';
      case StepStatus.enCours:
        return 'En cours';
      case StepStatus.termine:
        return 'Terminé';
    }
  }
}

class VerificationStep {
  final String stepName;
  final String description;
  final StepStatus status;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final String? notes;
  final String icon;

  VerificationStep({
    required this.stepName,
    required this.description,
    required this.status,
    this.startedAt,
    this.completedAt,
    this.notes,
    this.icon = '📋',
  });

  bool get isCompleted => status == StepStatus.termine;
  bool get isInProgress => status == StepStatus.enCours;
  bool get isPending => status == StepStatus.enAttente;
}
