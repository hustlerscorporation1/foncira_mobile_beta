// ══════════════════════════════════════════════════════════════
//  FONCIRA — Notification Model
// ══════════════════════════════════════════════════════════════

class FonciraNotification {
  final String id;
  final String agentName;
  final String agentInitial;
  final String message;
  final String result;
  final DateTime timestamp;
  final bool isPositive;
  bool isRead;

  FonciraNotification({
    required this.id,
    required this.agentName,
    required this.agentInitial,
    required this.message,
    required this.result,
    required this.timestamp,
    this.isPositive = true,
    this.isRead = false,
  });

  // Copy with modifications
  FonciraNotification copyWith({
    String? id,
    String? agentName,
    String? agentInitial,
    String? message,
    String? result,
    DateTime? timestamp,
    bool? isPositive,
    bool? isRead,
  }) {
    return FonciraNotification(
      id: id ?? this.id,
      agentName: agentName ?? this.agentName,
      agentInitial: agentInitial ?? this.agentInitial,
      message: message ?? this.message,
      result: result ?? this.result,
      timestamp: timestamp ?? this.timestamp,
      isPositive: isPositive ?? this.isPositive,
      isRead: isRead ?? this.isRead,
    );
  }
}
