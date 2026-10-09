import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/login_provider.dart';
import '../../providers/notification_provider.dart';
import '../../providers/profile_provider.dart';
import '../../screens/notifications/notification_screen.dart';
import '../../screens/profile/profile_screen.dart';
import '../../theme/theme_notifier.dart';
import 'header_icon.dart';

class SidebarHeader extends StatelessWidget {
  const SidebarHeader({super.key});

  String _getInitials(String name, String username) {
    final target = name.trim().isNotEmpty ? name.trim() : username.trim();
    if (target.isEmpty) return 'U';
    final parts = target.split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return target.substring(0, target.length >= 2 ? 2 : 1).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.primaryColor;
    final themeNotifier = context.watch<ThemeNotifier>();
    final loginProvider = context.watch<LoginProvider>();
    final notifProvider = context.watch<NotificationProvider>();
    final profileProvider = context.watch<ProfileProvider>();

    final loginData = loginProvider.loginData;
    final liveProfile = profileProvider.profile;

    final displayName = liveProfile?.staffName.trim().isNotEmpty == true
        ? liveProfile!.staffName.trim()
        : (loginData?.staffName.trim().isNotEmpty == true
            ? loginData!.staffName.trim()
            : (loginData?.userName.trim().isNotEmpty == true
                ? loginData!.userName.trim()
                : 'User'));

    // Role, Unit, and Location formatted exactly as the website toolbar:
    // {{displayRole}} / {{loginData.unitName}} / {{loginData.locationName}}
    // Example: supadmin / ltmrhlho / hyd
    final role = (loginProvider.selectedRoleName?.trim().isNotEmpty == true
            ? loginProvider.selectedRoleName!
            : (loginData?.roleNames.split(',').firstOrNull ?? ''))
        .replaceAll('"', '')
        .trim();

    final unit = (loginData?.unitName.trim().isNotEmpty == true
            ? loginData!.unitName.trim()
            : (liveProfile?.unitName.trim() ?? ''))
        .trim();

    final location = (loginData?.locationName.trim().isNotEmpty == true
            ? loginData!.locationName.trim()
            : (liveProfile?.locationName.trim() ?? ''))
        .trim();

    final subtitleParts = [
      if (role.isNotEmpty) role,
      if (unit.isNotEmpty) unit,
      if (location.isNotEmpty) location,
    ];
    final displaySubtitle = subtitleParts.isNotEmpty
        ? subtitleParts.join(' / ')
        : (role.isNotEmpty ? role : 'User');

    final initials = _getInitials(displayName, loginData?.userName ?? '');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primary, primary.withValues(alpha: 0.75)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          //--------------------------------
          // Avatar + Icons
          //--------------------------------
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.pop(context); // close drawer if open
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ProfileScreen()),
                  );
                },
                child: Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.20),
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: Center(
                    child: Text(
                      initials,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),

              const Spacer(),

              // Notifications
              Badge(
                isLabelVisible: notifProvider.unreadCount > 0,
                label: Text(
                  notifProvider.unreadCount > 99
                      ? '99+'
                      : notifProvider.unreadCount.toString(),
                  style: const TextStyle(fontSize: 10),
                ),
                child: HeaderIcon(
                  icon: Icons.notifications_outlined,
                  onTap: () {
                    Navigator.pop(context); // close drawer if open
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const NotificationScreen()),
                    );
                  },
                ),
              ),

              const SizedBox(width: 8),

              // Theme Switcher
              HeaderIcon(
                icon: themeNotifier.isDark
                    ? Icons.light_mode_rounded
                    : Icons.dark_mode_rounded,
                onTap: () {
                  context.read<ThemeNotifier>().toggleTheme();
                },
              ),
            ],
          ),

          const SizedBox(height: 16),

          // User Name (Navigates to Profile)
          GestureDetector(
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              );
            },
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    displayName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white70,
                  size: 14,
                ),
              ],
            ),
          ),

          const SizedBox(height: 6),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.20),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              displaySubtitle,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
