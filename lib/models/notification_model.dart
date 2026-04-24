// ══════════════════════════════════════════════════════════════
//  FONCIRA — Notification Model (Supabase)
// ══════════════════════════════════════════════════════════════

class FonciraNotification {
  final String id;
  final String recipientId;
  final String notificationType;
  final String title;
  final String message;
  final String? relatedVerificationId;
  final bool isRead;
  final DateTime? readAt;
  final String? actionUrl;
  final DateTime createdAt;

  FonciraNotification({
    required this.id,
    required this.recipientId,
    required this.notificationType,
    required this.title,
    required this.message,
    this.relatedVerificationId,
    this.isRead = false,
    this.readAt,
    this.actionUrl,
    required this.createdAt,
  });

  // Factory constructor from Supabase JSON
  factory FonciraNotification.fromJson(Map<String, dynamic> json) {
    return FonciraNotification(
      id: json['id'],
      recipientId: json['recipient_id'],
      notificationType: json['notification_type'],
      title: json['title'],
      message: json['message'],
      relatedVerificationId: json['related_verification_id'],
      isRead: json['is_read'] ?? false,
      readAt: json['read_at'] != null ? DateTime.parse(json['read_at']) : null,
      actionUrl: json['action_url'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'recipient_id': recipientId,
      'notification_type': notificationType,
      'title': title,
      'message': message,
      'related_verification_id': relatedVerificationId,
      'is_read': isRead,
      'read_at': readAt?.toIso8601String(),
      'action_url': actionUrl,
      'created_at': createdAt.toIso8601String(),
    };
  }

  // Copy with modifications
  FonciraNotification copyWith({
    String? id,
    String? recipientId,
    String? notificationType,
    String? title,
    String? message,
    String? relatedVerificationId,
    bool? isRead,
    DateTime? readAt,
    String? actionUrl,
    DateTime? createdAt,
  }) {
    return FonciraNotification(
      id: id ?? this.id,
      recipientId: recipientId ?? this.recipientId,
      notificationType: notificationType ?? this.notificationType,
      title: title ?? this.title,
      message: message ?? this.message,
      relatedVerificationId:
          relatedVerificationId ?? this.relatedVerificationId,
      isRead: isRead ?? this.isRead,
      readAt: readAt ?? this.readAt,
      actionUrl: actionUrl ?? this.actionUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
