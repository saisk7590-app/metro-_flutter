import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../navigation/main_navigation_screen.dart';
import '../../providers/login_provider.dart';
import '../../services/biometric_auth_service.dart';
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
          MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
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
                  // App Branding
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: primaryColor.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.directions_subway_rounded,
                      size: 40,
                      color: primaryColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'HYDERABAD METRO AMS',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                      color: Color(0xFF64748B),
                    ),
                  ),
                  if (kIsWeb) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.amber.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.amber.shade700, width: 1),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.laptop_chromebook, size: 14, color: Colors.amber.shade800),
                          const SizedBox(width: 6),
                          Text(
                            'PC Web Test Mode (Biometrics Simulated)',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Colors.amber.shade900,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 36),

                  // User Profile Avatar
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          primaryColor,
                          primaryColor.withValues(alpha: 0.75),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: primaryColor.withValues(alpha: 0.25),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        _displayName.isNotEmpty
                            ? _displayName.substring(0, 1).toUpperCase()
                            : 'U',
                        style: const TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Greeting
                  Text(
                    'Welcome back,',
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _displayName,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 48),

                  // PhonePe style Biometric Fingerprint Button
                  GestureDetector(
                    onTap: _startBiometricAuth,
                    child: ScaleTransition(
                      scale: _isAuthenticating
                          ? _pulseAnimation
                          : const AlwaysStoppedAnimation(1.0),
                      child: Container(
                        width: 110,
                        height: 110,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isDark
                              ? const Color(0xFF1E293B)
                              : Colors.white,
                          border: Border.all(
                            color: _isAuthenticating
                                ? primaryColor
                                : (isDark
                                    ? Colors.grey.shade800
                                    : Colors.grey.shade300),
                            width: 2.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: primaryColor.withValues(
                                alpha: _isAuthenticating ? 0.35 : 0.12,
                              ),
                              blurRadius: 24,
                              spreadRadius: _isAuthenticating ? 4 : 1,
                            ),
                          ],
                        ),
                        child: Center(
                          child: Icon(
                            Icons.fingerprint_rounded,
                            size: 64,
                            color: _isAuthenticating
                                ? primaryColor
                                : (isDark ? Colors.grey.shade300 : const Color(0xFF334155)),
                          ),
                        ),
                      ),
                    ),
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
