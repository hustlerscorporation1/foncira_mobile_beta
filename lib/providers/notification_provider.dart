import 'package:flutter/material.dart';
import '../models/notification_model.dart';

// ══════════════════════════════════════════════════════════════
//  FONCIRA — Notification Provider
// ══════════════════════════════════════════════════════════════

class NotificationProvider extends ChangeNotifier {
  final List<FonciraNotification> _notifications = [
    FonciraNotification(
      id: 'notif_001',
      agentName: 'Séna Amégavi',
      agentInitial: 'S',
      message: 'a consulté le chef du quartier Adidogomé ce matin',
      result: 'Résultat favorable',
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      isPositive: true,
      isRead: false,
    ),
    FonciraNotification(
      id: 'notif_002',
      agentName: 'Kwaku Mensah',
      agentInitial: 'K',
      message: 'a complété la vérification cadastrale du terrain',
      result: 'Titre foncier confirmé',
      timestamp: DateTime.now().subtract(const Duration(hours: 4)),
      isPositive: true,
      isRead: false,
    ),
    FonciraNotification(
      id: 'notif_003',
      agentName: 'Marie Dubois',
      agentInitial: 'M',
      message: 'a visité le terrain à Adidogomé',
      result: 'Borne GPS horodatée',
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
      isPositive: true,
      isRead: false,
    ),
    FonciraNotification(
      id: 'notif_004',
      agentName: 'Kofi Assimbe',
      agentInitial: 'K',
      message: 'a reçu le rapport du géomètre agréé',
      result: 'Rapport signé & scanné',
      timestamp: DateTime.now().subtract(const Duration(days: 2)),
      isPositive: true,
      isRead: true,
    ),
    FonciraNotification(
      id: 'notif_005',
      agentName: 'Ama Poku',
      agentInitial: 'A',
      message: 'a lancé la vérification de votre dossier',
      result: 'Analyse en cours',
      timestamp: DateTime.now().subtract(const Duration(days: 3)),
      isPositive: true,
      isRead: true,
    ),
  ];

  List<FonciraNotification> get notifications {
    return [..._notifications];
  }

  int get unreadCount {
    return _notifications.where((notif) => !notif.isRead).length;
  }

  void markAsRead(String notificationId) {
    final index = _notifications.indexWhere(
      (notif) => notif.id == notificationId,
    );
    if (index != -1) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
      notifyListeners();
    }
  }

  void markAllAsRead() {
    for (int i = 0; i < _notifications.length; i++) {
      _notifications[i] = _notifications[i].copyWith(isRead: true);
    }
    notifyListeners();
  }

  void addNotification(FonciraNotification newNotification) {
    _notifications.insert(0, newNotification);
    notifyListeners();
  }

  void deleteNotification(String notificationId) {
    _notifications.removeWhere((notif) => notif.id == notificationId);
    notifyListeners();
  }

  // Simulate incoming notification (for testing)
  void simulateIncomingNotification(
    String agentName,
    String message,
    String result,
    bool isPositive,
  ) {
    final newId = 'notif_${DateTime.now().millisecondsSinceEpoch}';
    addNotification(
      FonciraNotification(
        id: newId,
        agentName: agentName,
        agentInitial: agentName.substring(0, 1),
        message: message,
        result: result,
        timestamp: DateTime.now(),
        isPositive: isPositive,
        isRead: false,
      ),
    );
  }
}
