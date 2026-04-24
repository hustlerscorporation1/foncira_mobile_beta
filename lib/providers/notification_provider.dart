import 'package:flutter/material.dart';
import '../models/notification_model.dart';
import '../services/notification_service.dart';

// ══════════════════════════════════════════════════════════════
//  FONCIRA — Notification Provider (Real-time Stream)
// ══════════════════════════════════════════════════════════════

class NotificationProvider extends ChangeNotifier {
  final NotificationService _notificationService = NotificationService();

  final List<FonciraNotification> _notifications = [];
  bool _isLoading = true;
  String? _error;

  List<FonciraNotification> get notifications {
    return [..._notifications];
  }

  int get unreadCount {
    return _notifications.where((notif) => !notif.isRead).length;
  }

  bool get isLoading => _isLoading;
  String? get error => _error;

  // ── Initialize real-time stream ────────────────────────────
  void initializeNotificationStream() {
    _notificationService.getNotificationStream().listen(
      (jsonList) {
        _notifications.clear();
        _notifications.addAll(
          jsonList.map((json) => FonciraNotification.fromJson(json)).toList(),
        );
        _isLoading = false;
        _error = null;
        notifyListeners();
      },
      onError: (error) {
        _isLoading = false;
        _error = 'Erreur lors du chargement des notifications: $error';
        notifyListeners();
      },
    );
  }

  // ── Mark notification as read ──────────────────────────────
  Future<void> markAsRead(String notificationId) async {
    try {
      await _notificationService.markAsRead(notificationId);
      // Update local state
      final index = _notifications.indexWhere(
        (notif) => notif.id == notificationId,
      );
      if (index != -1) {
        _notifications[index] = _notifications[index].copyWith(
          isRead: true,
          readAt: DateTime.now(),
        );
        notifyListeners();
      }
    } catch (e) {
      _error = 'Erreur: $e';
      notifyListeners();
    }
  }

  // ── Mark all notifications as read ─────────────────────────
  Future<void> markAllAsRead() async {
    try {
      await _notificationService.markAllAsRead();
      // Update local state
      for (int i = 0; i < _notifications.length; i++) {
        _notifications[i] = _notifications[i].copyWith(
          isRead: true,
          readAt: DateTime.now(),
        );
      }
      notifyListeners();
    } catch (e) {
      _error = 'Erreur: $e';
      notifyListeners();
    }
  }

  // ── Delete notification ────────────────────────────────────
  Future<void> deleteNotification(String notificationId) async {
    try {
      await _notificationService.deleteNotification(notificationId);
      _notifications.removeWhere((notif) => notif.id == notificationId);
      notifyListeners();
    } catch (e) {
      _error = 'Erreur: $e';
      notifyListeners();
    }
  }

  // ── Get notification type label ────────────────────────────
  String getNotificationTypeLabel(String type) {
    return _notificationService.getNotificationTypeLabel(type);
  }

  // ── Get notification icon ──────────────────────────────────
  IconData getNotificationIcon(String type) {
    switch (type) {
      case 'verification_created':
        return Icons.verified_rounded;
      case 'verification_update':
        return Icons.edit_note_rounded;
      case 'payment_received':
        return Icons.payment_rounded;
      case 'report_ready':
        return Icons.description_rounded;
      case 'milestone_completed':
        return Icons.check_circle_rounded;
      case 'system_message':
        return Icons.info_rounded;
      default:
        return Icons.notifications_rounded;
    }
  }

  // ── Get notification icon color ────────────────────────────
  Color getNotificationIconColor(String type) {
    switch (type) {
      case 'verification_created':
        return const Color(0xFF10B981);
      case 'verification_update':
        return const Color(0xFF3B82F6);
      case 'payment_received':
        return const Color(0xFFF59E0B);
      case 'report_ready':
        return const Color(0xFF8B5CF6);
      case 'milestone_completed':
        return const Color(0xFF06B6D4);
      case 'system_message':
        return const Color(0xFF6B7280);
      default:
        return const Color(0xFF3B82F6);
    }
  }
}
