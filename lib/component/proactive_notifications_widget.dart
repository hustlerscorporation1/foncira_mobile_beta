import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/colors.dart';
import '../models/notification_model.dart';

// ══════════════════════════════════════════════════════════════
//  FONCIRA — Notifications Proactives (Dashboard)
// ══════════════════════════════════════════════════════════════

class ProactiveNotificationsWidget extends StatefulWidget {
  final bool hasUnread;

  const ProactiveNotificationsWidget({super.key, this.hasUnread = true});

  @override
  State<ProactiveNotificationsWidget> createState() =>
      _ProactiveNotificationsWidgetState();
}

class _ProactiveNotificationsWidgetState
    extends State<ProactiveNotificationsWidget> {
  final List<FonciraNotification> notifications = [
    FonciraNotification(
      id: 'notif_001',
      recipientId: 'user_001',
      notificationType: 'verification_update',
      title: 'Vérification mise à jour',
      message: 'Séna Amégavi a consulté le chef du quartier Adidogomé ce matin',
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      isRead: false,
    ),
    FonciraNotification(
      id: 'notif_002',
      recipientId: 'user_001',
      notificationType: 'verification_created',
      title: 'Vérification complétée',
      message: 'Kwaku Mensah a complété la vérification cadastrale du terrain',
      createdAt: DateTime.now().subtract(const Duration(hours: 4)),
      isRead: false,
    ),
    FonciraNotification(
      id: 'notif_003',
      recipientId: 'user_001',
      notificationType: 'milestone_completed',
      title: 'Étape complétée',
      message: 'Marie Dubois a visité le terrain à Adidogomé',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      isRead: false,
    ),
  ];

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inMinutes < 1) {
      return 'À l\'instant';
    } else if (diff.inHours < 1) {
      return 'Il y a ${diff.inMinutes} min';
    } else if (diff.inHours < 24) {
      return 'Il y a ${diff.inHours} h';
    } else if (diff.inDays == 1) {
      return 'Hier';
    } else {
      return 'Il y a ${diff.inDays} j';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: kDarkCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kBorderDark, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Suivi en direct',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: kTextSecondary,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Actualisations de votre dossier',
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: kTextPrimary,
                    ),
                  ),
                ],
              ),
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: kSuccess.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Icon(
                    Icons.notifications_active_rounded,
                    color: kSuccess,
                    size: 18,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Notifications timeline
          ...notifications.asMap().entries.map((entry) {
            final index = entry.key;
            final notification = entry.value;
            final isLast = index == notifications.length - 1;

            return Column(
              children: [
                _NotificationItem(
                  notification: notification,
                  formattedTime: _formatTime(notification.createdAt),
                ),
                if (!isLast)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Divider(color: kBorderDark, height: 1),
                  ),
              ],
            );
          }),
          const SizedBox(height: 16),
          // Footer CTA
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.03),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: kBorderDark, width: 1),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  color: kTextSecondary,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Vous recevrez aussi une notification WhatsApp à chaque étape',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: kTextSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NotificationItem extends StatelessWidget {
  final FonciraNotification notification;
  final String formattedTime;

  const _NotificationItem({
    required this.notification,
    required this.formattedTime,
  });

  @override
  Widget build(BuildContext context) {
    // Extract agent name from title or message
    final agentName = notification.title.split(' ').first;
    final agentInitial = agentName.isNotEmpty ? agentName.substring(0, 1) : '?';

    // Color based on type
    final resultColor = notification.notificationType == 'verification_created'
        ? kSuccess
        : notification.notificationType == 'milestone_completed'
        ? Color(0xFF10B981)
        : kWarning;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [kPrimary, kPrimaryLight],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(color: kGold, width: 1),
            ),
            child: Center(
              child: Text(
                agentInitial,
                style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: notification.title,
                        style: GoogleFonts.outfit(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: kTextPrimary,
                        ),
                      ),
                      TextSpan(
                        text: ' — ${notification.message}',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: kTextSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(
                      Icons.check_circle_rounded,
                      color: resultColor,
                      size: 14,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      notification.notificationType == 'verification_created'
                          ? 'Vérification complétée'
                          : 'Mise à jour',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: resultColor,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      formattedTime,
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: kTextSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
