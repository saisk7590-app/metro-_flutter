import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/notification_model.dart';
import '../../providers/login_provider.dart';
import '../../providers/notification_provider.dart';
import '../../widgets/notifications/notification_filter_bar.dart';
import '../../widgets/notifications/notification_item_card.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  NotificationFilter _selectedFilter = NotificationFilter.all;
  String _searchQuery = '';
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadNotifications());
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _loadNotifications() {
    final login = context.read<LoginProvider>();
    final roleId = login.selectedRoleId ??
        login.loginData?.roleIds.split(',').first.trim();
    final unitId = login.loginData?.unitId.toString();
    final userId = login.loginData?.id.toString();

    context.read<NotificationProvider>().fetchNotifications(
          unitId: unitId,
          roleId: roleId,
          userId: userId,
        );
  }

  List<NotificationModel> _filterItems(List<NotificationModel> items) {
    var result = items;
    if (_selectedFilter == NotificationFilter.unread) {
      result = result.where((n) => !n.isRead).toList();
    } else if (_selectedFilter == NotificationFilter.read) {
      result = result.where((n) => n.isRead).toList();
    }

    if (_searchQuery.trim().isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      result = result.where((n) => n.message.toLowerCase().contains(query)).toList();
    }
    return result;
  }

  void _showDetailDialog(NotificationModel notification) {
    if (!notification.isRead) {
      context.read<NotificationProvider>().markAsRead(notification.id);
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.notifications_active, color: Color(0xFF4F46E5), size: 22),
            SizedBox(width: 8),
            Text('Notification Detail'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (notification.date != null) ...[
              Text(
                'Date: ${notification.date!.toLocal().toString().split('.')[0]}',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 12),
            ],
            Text(
              notification.message,
              style: const TextStyle(fontSize: 14, height: 1.4),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final notifProvider = context.watch<NotificationProvider>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final filtered = _filterItems(notifProvider.notifications);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: _loadNotifications,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                hintText: 'Search notifications...',
                prefixIcon: const Icon(Icons.search, size: 20),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          _searchCtrl.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                isDense: true,
                filled: true,
                fillColor: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.04),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              ),
              onChanged: (val) => setState(() => _searchQuery = val),
            ),
          ),

          // Filter Bar
          NotificationFilterBar(
            selectedFilter: _selectedFilter,
            unreadCount: notifProvider.unreadCount,
            onFilterChanged: (f) => setState(() => _selectedFilter = f),
            onMarkAllRead: () => notifProvider.markAllAsReadLocally(),
          ),

          // List or Empty
          Expanded(
            child: notifProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: () async => _loadNotifications(),
                    child: filtered.isEmpty
                        ? ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            children: [
                              SizedBox(height: MediaQuery.of(context).size.height * 0.18),
                              Icon(
                                Icons.notifications_off_outlined,
                                size: 64,
                                color: isDark ? Colors.white24 : Colors.black26,
                              ),
                              const SizedBox(height: 12),
                              Center(
                                child: Text(
                                  _searchQuery.isNotEmpty
                                      ? 'No notifications matching search'
                                      : 'No notifications available',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                    color: isDark ? Colors.white54 : Colors.black45,
                                  ),
                                ),
                              ),
                            ],
                          )
                        : ListView.builder(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            itemCount: filtered.length,
                            itemBuilder: (context, index) {
                              final item = filtered[index];
                              return NotificationItemCard(
                                notification: item,
                                onTap: () => _showDetailDialog(item),
                                onMarkAsRead: () => notifProvider.markAsRead(item.id),
                              );
                            },
                          ),
                  ),
          ),
        ],
      ),
    );
  }
}
