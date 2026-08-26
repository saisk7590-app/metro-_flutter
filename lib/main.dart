import 'package:flutter/material.dart';
import 'package:metro_flutter/providers/status_provider.dart';
import 'package:provider/provider.dart';
import 'package:metro_flutter/providers/maintenance_purpose_provider.dart';
import 'providers/train_provider.dart';
import 'package:metro_flutter/providers/allocation_provider.dart';
import 'package:metro_flutter/providers/maintenance_bay_provider.dart';
import 'package:metro_flutter/providers/active_trains_provider.dart';
import 'package:metro_flutter/providers/login_provider.dart';
import 'package:metro_flutter/providers/trainset_meter_reading_provider.dart';

import 'package:metro_flutter/screens/auth/login_screen.dart';
import 'theme/app_theme.dart';
import 'theme/theme_notifier.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeNotifier()),
        ChangeNotifierProvider(create: (_) => StatusProvider()),
        ChangeNotifierProvider(create: (_) => MaintenancePurposeProvider()),
        ChangeNotifierProvider(create: (_) => TrainProvider()),
        ChangeNotifierProvider(create: (_) => MaintenanceBayProvider()),
        ChangeNotifierProvider(create: (_) => ActiveTrainsProvider()),
        ChangeNotifierProvider(create: (_) => AllocationProvider()),

        // Login Provider
        ChangeNotifierProvider(create: (_) => LoginProvider()),
        // Trainset Meter Reading Provider
        ChangeNotifierProvider(create: (_) => TrainsetMeterReadingProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,

      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeNotifier.themeMode,

      home: const LoginScreen(),
    );
  }
}
