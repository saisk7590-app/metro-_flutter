import 'package:flutter/material.dart';
import '../../widgets/drawer_menu_button.dart';
import '../../widgets/coming_soon_screen.dart';

class WorkOrdersScreen extends StatelessWidget {
  const WorkOrdersScreen({super.key});

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
              "CHECKLIST WORK ORDERS",
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 18,
                color: theme.primaryColor,
                letterSpacing: 0.5,
              ),
            ),
            Text(
              "Assigned Work Orders",
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
        title: "Work Orders",
        description:
            "Assigned work orders will appear here for technicians.",
        icon: Icons.assignment_outlined,
      ),
    );
  }
}