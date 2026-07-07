import 'package:flutter/material.dart';
import 'package:metro_flutter/providers/status_provider.dart';
//import 'package:metro_flutter/screens/ams_update_screen.dart';
//import 'package:metro_flutter/screens/ams_update_screen.dart';
//import 'package:metro_flutter/screens/api_test_screen.dart';
import 'package:provider/provider.dart';
import 'package:metro_flutter/providers/maintenance_purpose_provider.dart';
import 'providers/train_provider.dart';
import 'navigation/main_navigation_screen.dart';
//import 'screens/api_test_screen.dart';
import 'theme/app_theme.dart';
import 'theme/theme_notifier.dart';
import 'package:metro_flutter/providers/maintenance_bay_provider.dart';
import 'package:metro_flutter/providers/active_trains_provider.dart';

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

      home: const MainNavigationScreen(),
    );
  }
}
