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
import 'package:metro_flutter/providers/checklist_provider.dart';
import 'package:metro_flutter/providers/notification_provider.dart';
import 'package:metro_flutter/providers/profile_provider.dart';

import 'package:metro_flutter/screens/auth/login_screen.dart';
import 'package:metro_flutter/screens/auth/biometric_unlock_screen.dart';
import 'http_client_runner.dart';
import 'theme/app_theme.dart';
import 'theme/theme_notifier.dart';

void main() async {
  initHttpClient();
  WidgetsFlutterBinding.ensureInitialized();
  final hasBiometricSession = await LoginProvider.hasSavedBiometricSession();

  final app = MultiProvider(
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
      // Checklist Provider (Technician Mobile Direct Entry & Real-time Sync)
      ChangeNotifierProvider(create: (_) => ChecklistProvider()),
      // Notification Provider (Real-time live notifications from messaging API)
      ChangeNotifierProvider(create: (_) => NotificationProvider()),
      // Profile Provider (Live staff profile details from admin API)
      ChangeNotifierProvider(create: (_) => ProfileProvider()),
    ],
    child: MyApp(hasBiometricSession: hasBiometricSession),
  );

  runAppWithHttpClient(app);
}

class MyApp extends StatelessWidget {
  final bool hasBiometricSession;
  const MyApp({super.key, this.hasBiometricSession = false});

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,

      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeNotifier.themeMode,

      home: hasBiometricSession
          ? const BiometricUnlockScreen()
          : const LoginScreen(),
    );
  }
}

