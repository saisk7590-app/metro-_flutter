import 'package:flutter/material.dart';

import '../utils/scaffold_keys.dart';
import 'app_sidebar.dart';

import '../screens/CheckList/work_orders_screen.dart';
import '../screens/CheckList/checklist_screen.dart';
import '../screens/CheckList/work_order_history_screen.dart';

class ChecklistNavigationScreen extends StatefulWidget {
  const ChecklistNavigationScreen({super.key});

  @override
  State<ChecklistNavigationScreen> createState() =>
      _ChecklistNavigationScreenState();
}

class _ChecklistNavigationScreenState
    extends State<ChecklistNavigationScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    WorkOrdersScreen(),
    ChecklistScreen(),
    WorkOrderHistoryScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: AppScaffoldKeys.checklistKey,
      drawer: const AppSidebar(currentModule: 'checklist'),

      body: _screens[_currentIndex],

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        selectedItemColor: Theme.of(context).primaryColor,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment_outlined),
            activeIcon: Icon(Icons.assignment),
            label: 'Work Orders',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.fact_check_outlined),
            activeIcon: Icon(Icons.fact_check),
            label: 'Checklist',
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