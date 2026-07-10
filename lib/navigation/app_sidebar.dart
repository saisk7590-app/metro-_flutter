import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/theme_notifier.dart';

import 'main_navigation_screen.dart';
import 'meter_navigation_screen.dart';
import 'checklist_navigation_screen.dart';

class AppSidebar extends StatelessWidget {
  final String currentModule;

  const AppSidebar({super.key, this.currentModule = "ams"});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final primary = theme.primaryColor;

    //final isDark = theme.brightness == Brightness.dark;

    final themeNotifier = context.watch<ThemeNotifier>();

    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            //--------------------------------------------------
            // HEADER
            //--------------------------------------------------
            Container(
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
                  //------------------------------------------------
                  // Avatar + Icons
                  //------------------------------------------------
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

                      _HeaderIcon(
                        icon: Icons.notifications_outlined,
                        onTap: () {},
                      ),

                      const SizedBox(width: 8),

                      _HeaderIcon(
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
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),

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
            ),

            //--------------------------------------------------
            // MODULE TITLE
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
            // AMS
            //--------------------------------------------------
            _ModuleTile(
              currentModule: currentModule,
              id: "ams",
              title: "BAY LAYOUT",
              subtitle: "Manage train allocation in depot bays",
              color: primary,
              icon: Icons.train_rounded,
              onTap: () {
                if (currentModule != "ams") {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const MainNavigationScreen(),
                    ),
                  );
                } else {
                  Navigator.pop(context);
                }
              },
            ),

            //--------------------------------------------------
            // Meter
            //--------------------------------------------------
            _ModuleTile(
              currentModule: currentModule,
              id: "meter",
              title: "Meter Module",
              subtitle: "Energy Monitoring",
              color: Colors.teal,
              icon: Icons.electric_meter,
              onTap: () {
                if (currentModule != "meter") {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const MeterNavigationScreen(),
                    ),
                  );
                } else {
                  Navigator.pop(context);
                }
              },
            ),

            //--------------------------------------------------
            // Checklist
            //--------------------------------------------------
            _ModuleTile(
              currentModule: currentModule,
              id: "checklist",
              title: "Checklist Module",
              subtitle: "Inspection Checklist",
              color: Colors.deepOrange,
              icon: Icons.fact_check,
              onTap: () {
                if (currentModule != "checklist") {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ChecklistNavigationScreen(),
                    ),
                  );
                } else {
                  Navigator.pop(context);
                }
              },
            ),

            const Spacer(),

            const Divider(),

            //--------------------------------------------------
            // Logout
            //--------------------------------------------------
            Padding(
              padding: const EdgeInsets.all(12),

              child: InkWell(
                borderRadius: BorderRadius.circular(14),

                onTap: () {},

                child: Container(
                  padding: const EdgeInsets.all(14),

                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.08),

                    borderRadius: BorderRadius.circular(14),

                    border: Border.all(
                      color: Colors.red.withValues(alpha: 0.25),
                    ),
                  ),

                  child: const Row(
                    children: [
                      Icon(Icons.logout, color: Colors.red),

                      SizedBox(width: 12),

                      Expanded(
                        child: Text(
                          "Logout",
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      Icon(Icons.chevron_right, color: Colors.red),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _HeaderIcon({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),

      onTap: onTap,

      child: Container(
        width: 40,
        height: 40,

        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.20),
          borderRadius: BorderRadius.circular(12),
        ),

        child: Icon(icon, color: Colors.white),
      ),
    );
  }
}

class _ModuleTile extends StatelessWidget {
  final String currentModule;
  final String id;
  final String title;
  final String subtitle;
  final Color color;
  final IconData icon;
  final VoidCallback onTap;

  const _ModuleTile({
    required this.currentModule,
    required this.id,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final selected = currentModule == id;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),

      child: Material(
        color: Colors.transparent,

        child: InkWell(
          borderRadius: BorderRadius.circular(14),

          onTap: onTap,

          child: Container(
            padding: const EdgeInsets.all(14),

            decoration: BoxDecoration(
              color: selected
                  ? color.withValues(alpha: 0.10)
                  : Colors.transparent,

              borderRadius: BorderRadius.circular(14),

              border: Border.all(
                color: selected ? color : Colors.grey.shade300,
              ),
            ),

            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,

                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),

                    borderRadius: BorderRadius.circular(12),
                  ),

                  child: Icon(icon, color: color),
                ),

                const SizedBox(width: 14),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      Text(
                        title,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),

                      const SizedBox(height: 2),

                      Text(
                        subtitle,
                        style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),

                Icon(Icons.chevron_right, color: color),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
