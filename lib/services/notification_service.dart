import 'supabase_service.dart';

// ══════════════════════════════════════════════════════════════
//  FONCIRA — Notification Service
// ══════════════════════════════════════════════════════════════

class NotificationService {
  final SupabaseService _supabase = SupabaseService();

  // ── Get notifications (stream - real-time) ────────────────
  Stream<List<Map<String, dynamic>>> getNotificationStream() {
    try {
      if (_supabase.currentUserId == null) {
        return Stream.error('User not authenticated');
      }

      return _supabase.client
          .from('notifications')
          .stream(primaryKey: ['id'])
          .eq('recipient_id', _supabase.currentUserId!)
          .order('created_at', ascending: false)
          .map((maps) => List<Map<String, dynamic>>.from(maps));
    } catch (e) {
      return Stream.error('Failed to stream notifications: $e');
    }
  }

  // ── Get all notifications ───────────────────────────────────
  Future<List<Map<String, dynamic>>> getNotifications({
    bool unreadOnly = false,
    int limit = 50,
  }) async {
    try {
      if (_supabase.currentUserId == null) {
        throw Exception('User not authenticated');
      }

      var query = _supabase.client
          .from('notifications')
          .select('*')
          .eq('recipient_id', _supabase.currentUserId!);

      if (unreadOnly) {
        query = query.eq('is_read', false);
      }

      final response = await query
          .order('created_at', ascending: false)
          .limit(limit);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Failed to get notifications: $e');
    }
  }

  // ── Get unread count ────────────────────────────────────────
  Future<int> getUnreadCount() async {
    try {
      if (_supabase.currentUserId == null) {
        throw Exception('User not authenticated');
      }

      final response = await _supabase.client
          .from('notifications')
          .select('id')
          .eq('recipient_id', _supabase.currentUserId!)
          .eq('is_read', false);

      return response.length;
    } catch (e) {
      return 0;
    }
  }

  // ── Mark notification as read ───────────────────────────────
  Future<bool> markAsRead(String notificationId) async {
    try {
      await _supabase.client
          .from('notifications')
          .update({'is_read': true})
          .eq('id', notificationId);
      return true;
    } catch (e) {
      throw Exception('Failed to mark notification as read: $e');
    }
  }

  // ── Mark all notifications as read ──────────────────────────
  Future<bool> markAllAsRead() async {
    try {
      if (_supabase.currentUserId == null) {
        throw Exception('User not authenticated');
      }

      await _supabase.client
          .from('notifications')
          .update({'is_read': true})
          .eq('recipient_id', _supabase.currentUserId!)
          .eq('is_read', false);

      return true;
    } catch (e) {
      throw Exception('Failed to mark all as read: $e');
    }
  }

  // ── Create notification (admin/agent) ───────────────────────
  Future<String?> createNotification({
    required String recipientId,
    required String notificationType,
    required String title,
    required String message,
    String? relatedVerificationId,
  }) async {
    try {
      final response = await _supabase.client
          .from('notifications')
          .insert({
            'recipient_id': recipientId,
            'notification_type': notificationType,
            'title': title,
            'message': message,
            if (relatedVerificationId != null)
              'related_verification_id': relatedVerificationId,
            'is_read': false,
            'created_at': DateTime.now().toIso8601String(),
          })
          .select()
          .single();

      return response['id'];
    } catch (e) {
      throw Exception('Failed to create notification: $e');
    }
  }

  // ── Delete notification ────────────────────────────────────
  Future<bool> deleteNotification(String notificationId) async {
    try {
      await _supabase.client
          .from('notifications')
          .delete()
          .eq('id', notificationId);
      return true;
    } catch (e) {
      throw Exception('Failed to delete notification: $e');
    }
  }

  // ── Get notification types ────────────────────────────────
  List<String> getNotificationTypes() {
    return [
      'verification_created',
      'verification_update',
      'payment_received',
      'report_ready',
      'milestone_completed',
      'system_message',
    ];
  }

  // ── Get notification type label ────────────────────────────
  String getNotificationTypeLabel(String type) {
    switch (type) {
      case 'verification_created':
        return 'Vérification créée';
      case 'verification_update':
        return 'Mise à jour de vérification';
      case 'payment_received':
        return 'Paiement reçu';
      case 'report_ready':
        return 'Rapport prêt';
      case 'milestone_completed':
        return 'Étape complétée';
      case 'system_message':
        return 'Message système';
      default:
        return type;
    }
  }

  // ── Get notification icon ──────────────────────────────────
  String getNotificationIcon(String type) {
    switch (type) {
      case 'verification_created':
        return '✅';
      case 'verification_update':
        return '📝';
      case 'payment_received':
        return '💰';
      case 'report_ready':
        return '📄';
      case 'milestone_completed':
        return '🎯';
      case 'system_message':
        return 'ℹ️';
      default:
        return '🔔';
    }
  }
}
