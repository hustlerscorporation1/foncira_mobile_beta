import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/notification_provider.dart';
import '../theme/colors.dart';
import '../page/notifications_page.dart';

// ══════════════════════════════════════════════════════════════
//  FONCIRA — Notification Bell Button (Real-time with Animation)
// ══════════════════════════════════════════════════════════════

class NotificationBellButton extends StatefulWidget {
  const NotificationBellButton({super.key});

  @override
  State<NotificationBellButton> createState() => _NotificationBellButtonState();
}

class _NotificationBellButtonState extends State<NotificationBellButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // Initialize notification stream when button is created
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationProvider>().initializeNotificationStream();
      _startAnimation();
    });
  }

  void _startAnimation() {
    if (mounted) {
      _animationController.repeat();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<NotificationProvider>(
      builder: (context, notificationProvider, _) {
        final unreadCount = notificationProvider.unreadCount;
        final hasUnread = unreadCount > 0;

        // Control animation based on unread count
        if (hasUnread && !_animationController.isAnimating) {
          _startAnimation();
        } else if (!hasUnread && _animationController.isAnimating) {
          _animationController.stop();
        }

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

                // Animated green dot if unread
                if (hasUnread)
                  Positioned(
                    top: 6,
                    right: 6,
                    child: ScaleTransition(
                      scale: Tween<double>(begin: 0.8, end: 1.1).animate(
                        CurvedAnimation(
                          parent: _animationController,
                          curve: Curves.easeInOut,
                        ),
                      ),
                      child: Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981),
                          shape: BoxShape.circle,
                          border: Border.all(color: kDarkBg, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF10B981).withOpacity(0.6),
                              blurRadius: 8,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Center(
                          child: Container(
                            width: 4,
                            height: 4,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                // Badge count if needed (optional)
                if (unreadCount > 0 && unreadCount <= 99)
                  Positioned(
                    top: 0,
                    right: 0,
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
                            fontSize: 9,
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
