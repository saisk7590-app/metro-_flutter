import 'package:flutter/material.dart';

import '../screens/auth/login_screen.dart';
import '../widgets/sidebar/sidebar_header.dart';
import '../widgets/sidebar/sidebar_module_tile.dart';
import '../widgets/sidebar/sidebar_logout.dart';

import '../data/sidebar_modules.dart';

class AppSidebar extends StatelessWidget {
  final String currentModule;

  const AppSidebar({super.key, this.currentModule = "ams"});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            //--------------------------------------------------
            // Header
            //--------------------------------------------------
            const SidebarHeader(),

            //--------------------------------------------------
            // Module Title
            //--------------------------------------------------
            const Padding(
              padding: EdgeInsets.fromLTRB(18, 18, 18, 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "MODULES",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                    color: Colors.grey,
                  ),
                ),
              ),
            ),

            //--------------------------------------------------
            // AMS Meter Checklist
            //--------------------------------------------------
            ...sidebarModules.map(
              (module) => SidebarModuleTile(
                title: module.title,
                subtitle: module.subtitle,
                icon: module.icon,
                color: module.color,
                selected: currentModule == module.id,
                onTap: () {
                  if (currentModule != module.id) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => module.page),
                    );
                  } else {
                    Navigator.pop(context);
                  }
                },
              ),
            ),

            const Spacer(),

            const Divider(),

            //--------------------------------------------------
            // Logout
            //--------------------------------------------------
            SidebarLogout(
              onTap: () async {
                final logout = await showDialog<bool>(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text("Logout"),
                      content: const Text("Are you sure you want to logout?"),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context, false);
                          },
                          child: const Text("Cancel"),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context, true);
                          },
                          child: const Text("Logout"),
                        ),
                      ],
                    );
                  },
                );
                if (!context.mounted) return;

                if (logout == true) {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (route) => false,
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
