import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/notification_model.dart';
import '../providers/notification_provider.dart';
import '../theme/colors.dart';

// ══════════════════════════════════════════════════════════════
//  FONCIRA — Notifications Page (Fil de messages)
// ══════════════════════════════════════════════════════════════

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
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
    } else if (diff.inDays == 2) {
      return 'Avant-hier';
    } else {
      return 'Il y a ${diff.inDays} j';
    }
  }

  @override
  void initState() {
    super.initState();
    // Mark all as read when opening page
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationProvider>().markAllAsRead();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kDarkBg,
      body: SafeArea(
        child: Consumer<NotificationProvider>(
          builder: (context, notificationProvider, _) {
            final notifications = notificationProvider.notifications;

            return CustomScrollView(
              slivers: [
                // App Bar with title
                SliverAppBar(
                  pinned: true,
                  backgroundColor: kDarkBg,
                  elevation: 0,
                  expandedHeight: 100,
                  flexibleSpace: FlexibleSpaceBar(
                    title: Padding(
                      padding: const EdgeInsets.only(left: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            'Notifications',
                            style: GoogleFonts.outfit(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: kTextPrimary,
                            ),
                          ),
                          Text(
                            '${notifications.length} messages',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              color: kTextSecondary,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    titlePadding: const EdgeInsets.only(bottom: 16),
                  ),
                  leading: Padding(
                    padding: const EdgeInsets.all(12),
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        decoration: BoxDecoration(
                          color: kDarkCard,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: kBorderDark, width: 1),
                        ),
                        child: const Center(
                          child: Icon(Icons.arrow_back_ios_rounded, size: 16),
                        ),
                      ),
                    ),
                  ),
                ),
                // Notifications list
                if (notifications.isEmpty)
                  SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Icon(
                              Icons.notifications_none_rounded,
                              size: 40,
                              color: kTextSecondary,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Aucune notification',
                            style: GoogleFonts.outfit(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: kTextPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Les mises à jour de votre dossier s\'afficheront ici',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              color: kTextSecondary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final notification = notifications[index];
                        final isLast = index == notifications.length - 1;

                        return _NotificationListItem(
                          notification: notification,
                          formattedTime: _formatTime(notification.timestamp),
                          onMarkAsRead: () {
                            context.read<NotificationProvider>().markAsRead(
                              notification.id,
                            );
                          },
                          isLast: isLast,
                        );
                      }, childCount: notifications.length),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _NotificationListItem extends StatelessWidget {
  final FonciraNotification notification;
  final String formattedTime;
  final VoidCallback onMarkAsRead;
  final bool isLast;

  const _NotificationListItem({
    required this.notification,
    required this.formattedTime,
    required this.onMarkAsRead,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    final resultColor = notification.isPositive ? kSuccess : kWarning;

    return Column(
      children: [
        GestureDetector(
          onTap: onMarkAsRead,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: notification.isRead
                  ? Colors.transparent
                  : Colors.white.withOpacity(0.03),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: notification.isRead
                    ? kBorderDark
                    : kGold.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [kPrimary, kPrimaryLight],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    border: Border.all(color: kGold, width: 1.5),
                  ),
                  child: Center(
                    child: Text(
                      notification.agentInitial,
                      style: GoogleFonts.outfit(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Agent name + time
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  notification.agentName,
                                  style: GoogleFonts.outfit(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: kTextPrimary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  notification.message,
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    color: kTextSecondary,
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            formattedTime,
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              color: kTextSecondary,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      // Result badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: resultColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: resultColor.withOpacity(0.4),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.check_circle_rounded,
                              color: resultColor,
                              size: 14,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              notification.result,
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: resultColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Unread indicator
                      if (!notification.isRead)
                        Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: kGold,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Nouveau',
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  color: kGold,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        if (!isLast)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Divider(color: kBorderDark, height: 1),
          ),
      ],
    );
  }
}
