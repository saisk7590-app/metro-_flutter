import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../theme/spacing.dart';
import '../../providers/login_provider.dart';
import '../../services/api_service.dart';
import '../../models/auth/login_model.dart';
import '../../navigation/maintenance_bay_navigation_screen.dart';
import 'biometric_unlock_screen.dart';
import 'mfa_verification_screen.dart';
import 'role_selection_screen.dart';
import 'reset_password_screen.dart';
import 'forgot_password_screen.dart';
import '../../../widgets/auth/login/login_logo.dart';
import '../../../widgets/auth/login/login_header.dart';
import '../../../widgets/auth/login/login_form.dart';
import '../../../widgets/auth/login/forgot_password_link.dart';
import '../../../widgets/auth/login/security_notice.dart';
import '../../widgets/common/responsive_container.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final captchaController = TextEditingController();
  final apiService = ApiService();

  bool obscurePassword = true;
  bool showCaptcha = false;
  bool hasBiometricSession = false;
  String savedUserDisplayName = '';
  String captchaId = '';
  String captchaImage = '';

  @override
  void initState() {
    super.initState();
    _checkSavedBiometrics();
  }

  Future<void> _checkSavedBiometrics() async {
    final hasSession = await LoginProvider.hasSavedBiometricSession();
    if (hasSession && mounted) {
      final name = await LoginProvider.getSavedUserDisplayName();
      setState(() {
        hasBiometricSession = true;
        savedUserDisplayName = name;
      });
    }
  }

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    captchaController.dispose();
    super.dispose();
  }

  Future<void> _loadCaptcha() async {
    try {
      final result = await apiService.generateCaptcha();
      if (!mounted) return;
      setState(() {
        showCaptcha = true;
        captchaId = result['captchaId']?.toString() ?? '';
        captchaImage = result['captchaImage']?.toString() ?? '';
        captchaController.clear();
      });
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Unable to load CAPTCHA')));
      }
    }
  }

  Future<void> _openRoleOrDashboard(LoginModel loginData) async {
    final roles = loginData.roleNames
        .split(',')
        .map((role) => role.trim())
        .where((role) => role.isNotEmpty)
        .toList();

    if (roles.length > 1) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => RoleSelectionScreen(loginData: loginData)),
      );
    } else {
      // Save session for future biometric login - user logs in with credentials only once!
      await context.read<LoginProvider>().saveSessionForBiometrics();
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MaintenanceBayNavigationScreen()),
      );
    }
  }

  Future<void> _handleLogin() async {
    final username = usernameController.text.trim();
    final password = passwordController.text.trim();
    final captchaValue = captchaController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter username and password')),
      );
      return;
    }
    if (showCaptcha && captchaValue.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please enter the CAPTCHA')));
      return;
    }

    final success = await context.read<LoginProvider>().login(
      userName: username,
      password: password,
      timeStamp: DateTime.now().toUtc().toIso8601String(),
      captchaId: captchaId,
      captchaValue: captchaValue,
    );

    if (!mounted) return;
    if (success) {
      setState(() {
        showCaptcha = false;
        captchaId = '';
        captchaImage = '';
        captchaController.clear();
      });
      final loginData = context.read<LoginProvider>().loginData!;
      if (loginData.resetpwd == 1) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ResetPasswordScreen(loginData: loginData),
          ),
        );
      } else if (loginData.isMFARequired == 1) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => MfaVerificationScreen(loginData: loginData),
          ),
        );
      } else {
        await _openRoleOrDashboard(loginData);
      }
      return;
    }

    final loginData = context.read<LoginProvider>().loginData;
    if (loginData?.captchaImage.isNotEmpty == true) {
      setState(() {
        showCaptcha = true;
        captchaId = loginData!.captchaId;
        captchaImage = loginData.captchaImage;
        captchaController.clear();
      });
    } else {
      await _loadCaptcha();
    }

    if (mounted) {
      final error =
          context.read<LoginProvider>().errorMessage ?? 'Login failed';
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isLoading = context.watch<LoginProvider>().isLoading;

    return Scaffold(
      backgroundColor: colors.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: ResponsiveContainer(
            maxWidth: 600,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const LoginLogo(),
                const SizedBox(height: AppSpacing.xxl),
                const LoginHeader(),
                const SizedBox(height: AppSpacing.xxl),
                LoginForm(
                  usernameController: usernameController,
                  passwordController: passwordController,
                  captchaController: captchaController,
                  obscurePassword: obscurePassword,
                  isLoading: isLoading,
                  showCaptcha: showCaptcha,
                  captchaImage: captchaImage,
                  onTogglePassword: () {
                    setState(() => obscurePassword = !obscurePassword);
                  },
                  onRefreshCaptcha: _loadCaptcha,
                  onLogin: _handleLogin,
                ),
                if (hasBiometricSession) ...[
                  const SizedBox(height: AppSpacing.lg),
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: BorderSide(color: colors.primary.withValues(alpha: 0.6)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const BiometricUnlockScreen(),
                        ),
                      );
                    },
                    icon: Icon(Icons.fingerprint, color: colors.primary),
                    label: Text(
                      'Unlock with Biometrics ($savedUserDisplayName)',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: colors.primary,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: AppSpacing.md),
                ForgotPasswordLink(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ForgotPasswordScreen(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: AppSpacing.xxl),
                const SecurityNotice(),
                const SizedBox(height: AppSpacing.lg),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
