import 'package:flutter/material.dart';

import '../models/sidebar_module.dart';

import '../navigation/main_navigation_screen.dart';
import '../navigation/meter_navigation_screen.dart';
import '../navigation/checklist_navigation_screen.dart';

const List<SidebarModule> sidebarModules = [
  SidebarModule(
    id: 'ams',
    title: 'BAY LAYOUT',
    subtitle: 'Manage train allocation in depot bays',
    icon: Icons.train_rounded,
    color: Colors.blue,
    page: MainNavigationScreen(),
  ),
  SidebarModule(
    id: 'meter',
    title: 'Meter Module',
    subtitle: 'Energy Monitoring',
    icon: Icons.electric_meter,
    color: Colors.teal,
    page: MeterNavigationScreen(),
  ),
  SidebarModule(
    id: 'checklist',
    title: 'Checklist Module',
    subtitle: 'Inspection Checklist',
    icon: Icons.fact_check,
    color: Colors.deepOrange,
    page: ChecklistNavigationScreen(),
  ),
];
