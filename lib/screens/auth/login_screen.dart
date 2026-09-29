import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../theme/spacing.dart';
import '../../providers/login_provider.dart';
import '../../services/api_service.dart';
import '../../models/auth/login_model.dart';
import 'mfa_verification_screen.dart';
import 'role_selection_screen.dart';
import 'reset_password_screen.dart';
import 'forgot_password_screen.dart';
import 'security_verification_screen.dart';
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
  String captchaId = '';
  String captchaImage = '';

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

  void _openRoleOrSecurity(LoginModel loginData) {
    final roles = loginData.roleNames
        .split(',')
        .map((role) => role.trim())
        .where((role) => role.isNotEmpty)
        .toList();
    final destination = roles.length > 1
        ? RoleSelectionScreen(loginData: loginData)
        : const SecurityVerificationScreen();
    Navigator.push(context, MaterialPageRoute(builder: (_) => destination));
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
        _openRoleOrSecurity(loginData);
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
