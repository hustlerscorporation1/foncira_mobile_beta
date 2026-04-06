import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/notification_provider.dart';
import '../theme/colors.dart';
import '../page/notifications_page.dart';

// ══════════════════════════════════════════════════════════════
//  FONCIRA — Notification Bell Button (AppBar Integration)
// ══════════════════════════════════════════════════════════════

class NotificationBellButton extends StatelessWidget {
  const NotificationBellButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<NotificationProvider>(
      builder: (context, notificationProvider, _) {
        final unreadCount = notificationProvider.unreadCount;

        return Padding(
          padding: const EdgeInsets.only(right: 16),
          child: GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const NotificationsPage(),
                ),
              );
            },
            child: Stack(
              children: [
                // Bell icon button
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: kDarkCard,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: kBorderDark, width: 1),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.notifications_rounded,
                      color: kTextPrimary,
                      size: 22,
                    ),
                  ),
                ),
                // Red dot badge if unread
                if (unreadCount > 0)
                  Positioned(
                    top: 4,
                    right: 4,
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: kDanger,
                        shape: BoxShape.circle,
                        border: Border.all(color: kDarkBg, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: kDanger.withOpacity(0.5),
                            blurRadius: 8,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          unreadCount > 9 ? '9+' : '$unreadCount',
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
