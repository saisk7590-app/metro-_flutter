import 'package:flutter/material.dart';

import '../screens/ams/dashboard_screen.dart';
import '../screens/ams/ams_update_screen.dart';
import '../screens/ams/history_screen.dart';
import '../utils/scaffold_keys.dart';
import 'app_sidebar.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int currentIndex = 0;

  final List<Widget> screens = const [
    DashboardScreen(),
    AMSUpdateScreen(),
    HistoryScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: AppScaffoldKeys.mainKey,
      drawer: const AppSidebar(currentModule: 'ams'),
      body: IndexedStack(index: currentIndex, children: screens),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,

        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
        },

        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),

          BottomNavigationBarItem(icon: Icon(Icons.edit_note), label: 'Update'),

          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
        ],
      ),
    );
  }
}
