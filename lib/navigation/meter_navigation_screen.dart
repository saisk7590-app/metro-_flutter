import 'package:flutter/material.dart';

import '../utils/scaffold_keys.dart';
import 'app_sidebar.dart';
//import '../screens/meter/coming_soon_screen.dart';
import '../screens/meter/meter_dashboard_screen.dart';
import '../screens/meter/meter_reading_screen.dart';
import '../screens/meter/meter_history_screen.dart';

class MeterNavigationScreen extends StatefulWidget {
  const MeterNavigationScreen({super.key});

  @override
  State<MeterNavigationScreen> createState() =>
      _MeterNavigationScreenState();
}

class _MeterNavigationScreenState extends State<MeterNavigationScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    MeterDashboardScreen(),
    MeterReadingScreen(),
    MeterHistoryScreen(),
  ];
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // GlobalKey lets DrawerMenuButton open this drawer from any nested Scaffold.
      key: AppScaffoldKeys.meterKey,
      drawer: const AppSidebar(currentModule: 'meter'),
      
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        selectedItemColor: Theme.of(context).primaryColor,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.edit_note_outlined),
            activeIcon: Icon(Icons.edit_note),
            label: 'Update',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history_outlined),
            activeIcon: Icon(Icons.history),
            label: 'History',
          ),
        ],
      ),
    );
  }
}
