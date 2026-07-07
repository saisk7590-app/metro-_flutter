import 'package:flutter/material.dart';

import '../../widgets/drawer_menu_button.dart';
import '../../widgets/coming_soon_screen.dart';

class ChecklistScreen extends StatelessWidget {
  const ChecklistScreen({super.key});

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
              "CHECKLIST",
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 18,
                color: theme.primaryColor,
                letterSpacing: 0.5,
              ),
            ),
            Text(
              "Maintenance Checklist",
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
        title: "Checklist",
        description:
            "Technicians will be able to complete assigned maintenance checklists from this screen.",
        icon: Icons.fact_check_outlined,
      ),
    );
  }
}