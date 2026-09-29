import 'package:flutter/material.dart';

import '../utils/scaffold_keys.dart';
import 'app_sidebar.dart';
import '../screens/meter/meter_dashboard_screen.dart';

class MeterNavigationScreen extends StatelessWidget {
  const MeterNavigationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: AppScaffoldKeys.meterKey,
      drawer: const AppSidebar(currentModule: 'meter'),
      body: const MeterDashboardScreen(),
    );
  }
}
