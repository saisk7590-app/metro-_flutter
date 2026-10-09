import 'package:flutter/material.dart';
import '../../models/notification_model.dart';

class NotificationItemCard extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback onTap;
  final VoidCallback onMarkAsRead;

  const NotificationItemCard({
    super.key,
    required this.notification,
    required this.onTap,
    required this.onMarkAsRead,
  });

  String _formatDate(DateTime? date) {
    if (date == null) return 'Recent';
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 60) {
      final mins = difference.inMinutes;
      return mins <= 1 ? 'Just now' : '$mins mins ago';
    } else if (difference.inHours < 24) {
      final hours = difference.inHours;
      return '$hours hr${hours > 1 ? "s" : ""} ago';
    } else if (difference.inDays < 7) {
      final days = difference.inDays;
      return '$days day${days > 1 ? "s" : ""} ago';
    } else {
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primary = theme.primaryColor;
    final isUnread = !notification.isRead;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: isUnread
            ? (isDark
                ? primary.withValues(alpha: 0.12)
                : primary.withValues(alpha: 0.05))
            : theme.cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isUnread
              ? primary.withValues(alpha: 0.35)
              : (isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.06)),
          width: isUnread ? 1.4 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon / Unread indicator
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isUnread
                        ? primary.withValues(alpha: 0.2)
                        : (isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.04)),
                  ),
                  child: Icon(
                    isUnread
                        ? Icons.notifications_active
                        : Icons.notifications_none,
                    size: 20,
                    color: isUnread
                        ? primary
                        : (isDark ? Colors.white60 : Colors.black54),
                  ),
                ),
                const SizedBox(width: 14),

                // Message & Timestamp
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              _formatDate(notification.date),
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: isUnread ? FontWeight.bold : FontWeight.w500,
                                color: isUnread
                                    ? primary
                                    : (isDark ? Colors.white54 : Colors.black45),
                              ),
                            ),
                          ),
                          if (isUnread)
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: primary,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        notification.message.isNotEmpty
                            ? notification.message
                            : 'No message content',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: isUnread ? FontWeight.w600 : FontWeight.normal,
                          color: isDark ? Colors.white : Colors.black87,
                          height: 1.35,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
