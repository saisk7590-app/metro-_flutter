import 'package:flutter/material.dart';

import '../../widgets/drawer_menu_button.dart';
import '../../widgets/coming_soon_screen.dart';

class WorkOrderHistoryScreen extends StatelessWidget {
  const WorkOrderHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: colors.surface,

      appBar: AppBar(
        elevation: 0,
        backgroundColor:
            isDark ? const Color(0xFF1E293B) : Colors.white,
        centerTitle: false,

        leading: DrawerMenuButton(),

        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "WORK ORDER HISTORY",
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 18,
                color: theme.primaryColor,
                letterSpacing: 0.5,
              ),
            ),
            Text(
              "Completed Work Orders",
              style: TextStyle(
                fontSize: 12,
                color: colors.secondary,
              ),
            ),
          ],
        ),
      ),

      body: const ComingSoonScreen(
        moduleName: "CHECKLIST MODULE",
        title: "Work Order History",
        description:
            "Completed work orders and maintenance history will be available here.",
        icon: Icons.history_outlined,
      ),
    );
  }
}

  