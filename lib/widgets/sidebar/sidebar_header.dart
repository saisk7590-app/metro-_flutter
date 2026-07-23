import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../theme/theme_notifier.dart';
import 'header_icon.dart';

class SidebarHeader extends StatelessWidget {
  const SidebarHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.primaryColor;
    final themeNotifier = context.watch<ThemeNotifier>();

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
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.20),
                  border: Border.all(color: Colors.white54, width: 2),
                ),
                child: const Center(
                  child: Text(
                    "SK",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const Spacer(),

              HeaderIcon(icon: Icons.notifications_outlined, onTap: () {}),

              const SizedBox(width: 8),

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

          const Text(
            "Sai Kiran",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 6),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.20),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              "Administrator",
              style: TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
