import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/notification_model.dart';
import '../providers/notification_provider.dart';
import '../theme/colors.dart';

// ══════════════════════════════════════════════════════════════
//  FONCIRA — Notifications Page (Real-time Stream)
// ══════════════════════════════════════════════════════════════

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  @override
  void initState() {
    super.initState();
    // Initialize notification stream on load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationProvider>().initializeNotificationStream();
    });
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inMinutes < 1) {
      return 'À l\'instant';
    } else if (diff.inMinutes < 60) {
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kDarkBg,
      body: SafeArea(
        child: Consumer<NotificationProvider>(
          builder: (context, notificationProvider, _) {
            final notifications = notificationProvider.notifications;
            final isLoading = notificationProvider.isLoading;
            final error = notificationProvider.error;

            return CustomScrollView(
              slivers: [
                // ════════════════════════════════════════════
                // APP BAR
                // ════════════════════════════════════════════
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
                            '${notifications.length} notification${notifications.length != 1 ? 's' : ''}',
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

                // ════════════════════════════════════════════
                // CONTENT
                // ════════════════════════════════════════════
                if (isLoading)
                  SliverFillRemaining(
                    child: Center(
                      child: CircularProgressIndicator(color: kPrimary),
                    ),
                  )
                else if (error != null)
                  SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline_rounded,
                            size: 48,
                            color: kDanger,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Erreur',
                            style: GoogleFonts.outfit(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: kTextPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            error,
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
                else if (notifications.isEmpty)
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
                            'Les mises à jour de votre dossier\ns\'afficheront ici',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              color: kTextSecondary,
                              height: 1.5,
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
                          formattedTime: _formatTime(notification.createdAt),
                          provider: notificationProvider,
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
  final NotificationProvider provider;
  final bool isLast;

  const _NotificationListItem({
    required this.notification,
    required this.formattedTime,
    required this.provider,
    this.isLast = false,
  });

  void _handleNotificationTap(BuildContext context) {
    // Mark as read
    provider.markAsRead(notification.id);

    // Navigate if verification ID is present
    if (notification.relatedVerificationId != null) {
      // Navigate to verification detail page
      // Using verification provider to load the verification
      // This will be implemented based on your existing verification flow
      // For now, just close and mark as read
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final iconColor = provider.getNotificationIconColor(
      notification.notificationType,
    );
    final icon = provider.getNotificationIcon(notification.notificationType);

    return Column(
      children: [
        GestureDetector(
          onTap: () => _handleNotificationTap(context),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: notification.isRead
                  ? Colors.transparent
                  : Colors.white.withOpacity(0.03),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: notification.isRead
                    ? kBorderDark
                    : kGold.withOpacity(0.4),
                width: notification.isRead ? 1 : 1.5,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Notification Icon
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: iconColor.withOpacity(0.25),
                      width: 1,
                    ),
                  ),
                  child: Center(child: Icon(icon, color: iconColor, size: 22)),
                ),
                const SizedBox(width: 12),

                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title + Time
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              notification.title,
                              style: GoogleFonts.outfit(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: kTextPrimary,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            formattedTime,
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              color: kTextMuted,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),

                      // Message
                      Text(
                        notification.message,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: kTextSecondary,
                          height: 1.4,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),

                      // Unread indicator
                      if (!notification.isRead)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Row(
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(
                                  color: kGold,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Non lue',
                                style: GoogleFonts.inter(
                                  fontSize: 10,
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
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Divider(color: kBorderDark, height: 1, thickness: 0.5),
          ),
      ],
    );
  }
}
