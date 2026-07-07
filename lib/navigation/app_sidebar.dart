import 'package:flutter/material.dart';
import 'main_navigation_screen.dart';
import 'meter_navigation_screen.dart';
import 'checklist_navigation_screen.dart';

class AppSidebar extends StatelessWidget {
  final String currentModule;
  const AppSidebar({super.key, this.currentModule = 'ams'});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).primaryColor;

    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            //--------------------------------------------------
            // Header
            //--------------------------------------------------
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: primary),
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 32,
                    backgroundColor: Colors.white,
                    child: Text(
                      "SK",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  const Text(
                    "Sai Kiran",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    "Administrator",
                    style: TextStyle(color: Colors.white.withOpacity(.9)),
                  ),
                ],
              ),
            ),

            //--------------------------------------------------
            // Module Title
            //--------------------------------------------------
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 20, 16, 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "MODULES",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),

            //--------------------------------------------------
            // AMS Module
            //--------------------------------------------------
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
              child: ListTile(
                leading: const Icon(Icons.train),
                title: const Text("AMS Module"),
                trailing: const Icon(Icons.chevron_right),
                selected: currentModule == 'ams',
                selectedTileColor: primary.withOpacity(.10),
                selectedColor: primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                onTap: () {
                  if (currentModule != 'ams') {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const MainNavigationScreen()),
                    );
                  } else {
                    Navigator.pop(context);
                  }
                },
              ),
            ),

            //--------------------------------------------------
            // Meter Module
            //--------------------------------------------------
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
              child: ListTile(
                leading: const Icon(Icons.electric_meter),
                title: const Text("Meter Module"),
                trailing: const Icon(Icons.chevron_right),
                selected: currentModule == 'meter',
                selectedTileColor: primary.withOpacity(.10),
                selectedColor: primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                onTap: () {
                  if (currentModule != 'meter') {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const MeterNavigationScreen()),
                    );
                  } else {
                    Navigator.pop(context);
                  }
                },
              ),
            ),

            //--------------------------------------------------
            // Checklist Module
            //--------------------------------------------------
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
              child: ListTile(
                leading: const Icon(Icons.fact_check),
                title: const Text("Checklist Module"),
                trailing: const Icon(Icons.chevron_right),
                selected: currentModule == 'checklist',
                selectedTileColor: primary.withOpacity(.10),
                selectedColor: primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                onTap: () {
                  if (currentModule != 'checklist') {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const ChecklistNavigationScreen()),
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
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text("Logout", style: TextStyle(color: Colors.red)),
              onTap: () {},
            ),

            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
