import 'package:flutter/material.dart';

enum NotificationFilter { all, unread, read }

class NotificationFilterBar extends StatelessWidget {
  final NotificationFilter selectedFilter;
  final ValueChanged<NotificationFilter> onFilterChanged;
  final int unreadCount;
  final VoidCallback? onMarkAllRead;

  const NotificationFilterBar({
    super.key,
    required this.selectedFilter,
    required this.onFilterChanged,
    required this.unreadCount,
    this.onMarkAllRead,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.primaryColor;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        border: Border(
          bottom: BorderSide(
            color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.06),
          ),
        ),
      ),
      child: Row(
        children: [
          _buildChip(
            context: context,
            label: 'All',
            filter: NotificationFilter.all,
            isSelected: selectedFilter == NotificationFilter.all,
          ),
          const SizedBox(width: 8),
          _buildChip(
            context: context,
            label: 'Unread',
            count: unreadCount > 0 ? unreadCount : null,
            filter: NotificationFilter.unread,
            isSelected: selectedFilter == NotificationFilter.unread,
          ),
          const SizedBox(width: 8),
          _buildChip(
            context: context,
            label: 'Read',
            filter: NotificationFilter.read,
            isSelected: selectedFilter == NotificationFilter.read,
          ),
          const Spacer(),
          if (unreadCount > 0 && onMarkAllRead != null)
            TextButton.icon(
              onPressed: onMarkAllRead,
              icon: Icon(Icons.done_all, size: 16, color: primary),
              label: Text(
                'Mark All Read',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: primary,
                ),
              ),
              style: TextButton.styleFrom(
                visualDensity: VisualDensity.compact,
                padding: const EdgeInsets.symmetric(horizontal: 8),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildChip({
    required BuildContext context,
    required String label,
    int? count,
    required NotificationFilter filter,
    required bool isSelected,
  }) {
    final theme = Theme.of(context);
    final primary = theme.primaryColor;
    final isDark = theme.brightness == Brightness.dark;

    return ChoiceChip(
      selected: isSelected,
      showCheckmark: false,
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label),
          if (count != null) ...[
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: isSelected ? Colors.white : primary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                count.toString(),
                style: TextStyle(
                  color: isSelected ? primary : Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
      labelStyle: TextStyle(
        fontSize: 13,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        color: isSelected
            ? Colors.white
            : (isDark ? Colors.white70 : Colors.black87),
      ),
      selectedColor: primary,
      backgroundColor: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.04),
      side: BorderSide(
        color: isSelected
            ? primary
            : (isDark ? Colors.white12 : Colors.black.withValues(alpha: 0.08)),
      ),
      onSelected: (_) => onFilterChanged(filter),
    );
  }
}
