import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../navigation/maintenance_bay_navigation_screen.dart';
import '../../providers/login_provider.dart';
import '../../services/biometric_auth_service.dart';
import '../../widgets/auth/biometric_widgets.dart';
import 'login_screen.dart';

class BiometricUnlockScreen extends StatefulWidget {
  const BiometricUnlockScreen({super.key});

  @override
  State<BiometricUnlockScreen> createState() => _BiometricUnlockScreenState();
}

class _BiometricUnlockScreenState extends State<BiometricUnlockScreen>
    with SingleTickerProviderStateMixin {
  final BiometricAuthService _biometricService = BiometricAuthService();

  bool _isAuthenticating = false;
  String _displayName = 'User';
  String? _statusMessage;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _loadUserData();

    // Automatically trigger biometrics like PhonePe on app launch
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startBiometricAuth();
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    final name = await LoginProvider.getSavedUserDisplayName();
    if (mounted) {
      setState(() {
        _displayName = name;
      });
    }
  }

  Future<void> _startBiometricAuth() async {
    if (_isAuthenticating) return;

    setState(() {
      _isAuthenticating = true;
      _statusMessage = 'Waiting for fingerprint or face scan...';
    });

    final success = await _biometricService.authenticate(
      reason: 'Authenticate to access Hyderabad Metro AMS',
    );

    if (!mounted) return;

    if (success) {
      final restored =
          await context.read<LoginProvider>().restoreSavedSession();

      if (!mounted) return;

      if (restored) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MaintenanceBayNavigationScreen()),
        );
        return;
      } else {
        setState(() {
          _statusMessage = 'Session expired. Please log in with your password.';
          _isAuthenticating = false;
        });
      }
    } else {
      setState(() {
        _isAuthenticating = false;
        _statusMessage = 'Authentication cancelled. Tap fingerprint to retry.';
      });
    }
  }

  void _switchToPasswordLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  BiometricHeaderProfile(
                    displayName: _displayName,
                    primaryColor: primaryColor,
                    isDark: isDark,
                  ),
                  const SizedBox(height: 48),

                  BiometricFingerprintButton(
                    isAuthenticating: _isAuthenticating,
                    pulseAnimation: _pulseAnimation,
                    onTap: _startBiometricAuth,
                    primaryColor: primaryColor,
                    isDark: isDark,
                  ),
                  const SizedBox(height: 20),

                  // Status / Hint Text
                  Text(
                    _statusMessage ?? 'Touch sensor or use Face / PIN',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: _isAuthenticating
                          ? primaryColor
                          : (isDark ? Colors.grey.shade400 : Colors.grey.shade600),
                    ),
                  ),
                  const SizedBox(height: 36),

                  // Unlock Button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 1,
                      ),
                      onPressed: _isAuthenticating ? null : _startBiometricAuth,
                      icon: const Icon(Icons.fingerprint, size: 20),
                      label: Text(
                        _isAuthenticating ? 'VERIFYING...' : 'UNLOCK WITH BIOMETRICS',
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Use Password / Switch Account
                  TextButton.icon(
                    style: TextButton.styleFrom(
                      foregroundColor: isDark ? Colors.grey.shade300 : const Color(0xFF475569),
                    ),
                    onPressed: _switchToPasswordLogin,
                    icon: const Icon(Icons.lock_outline, size: 18),
                    label: const Text(
                      'Use Password / Login with different account',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
