import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../test_https.dart';
import '../../theme/spacing.dart';

import 'forgot_password_screen.dart';
import 'security_verification_screen.dart';

import '../../../widgets/auth/login/login_logo.dart';
import '../../../widgets/auth/login/login_header.dart';
import '../../../widgets/auth/login/login_form.dart';
import '../../../widgets/auth/login/forgot_password_link.dart';
import '../../../widgets/auth/login/security_notice.dart';
import '../../widgets/common/responsive_container.dart';

import '../../providers/login_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool obscurePassword = true;

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  // ============================================================
  // TEMPORARY HTTPS TEST
  // ============================================================

  Future<void> _testHttps() async {
    final result = await testHttpsConnection();

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('HTTPS Test Result'),
          content: SingleChildScrollView(
            child: SelectableText(result),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // ACTUAL LOGIN
  // ============================================================

  Future<void> _handleLogin() async {
    final username = usernameController.text.trim();
    final password = passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter username and password'),
        ),
      );
      return;
    }

    final timeStamp = DateTime.now().toUtc().toIso8601String();

    final success = await context.read<LoginProvider>().login(
          userName: username,
          password: password,
          timeStamp: timeStamp,
        );

    if (!mounted) return;

    if (success) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const SecurityVerificationScreen(),
        ),
      );
    } else {
      final error =
          context.read<LoginProvider>().errorMessage ?? 'Login failed';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colors.surface,

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
          ),

          child: ResponsiveContainer(
            maxWidth: 600,

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,

              children: [
                const LoginLogo(),

                const SizedBox(
                  height: AppSpacing.xxl,
                ),

                const LoginHeader(),

                const SizedBox(
                  height: AppSpacing.xxl,
                ),

                LoginForm(
                  usernameController: usernameController,
                  passwordController: passwordController,
                  obscurePassword: obscurePassword,

                  isLoading: context
                      .watch<LoginProvider>()
                      .isLoading,

                  onTogglePassword: () {
                    setState(() {
                      obscurePassword = !obscurePassword;
                    });
                  },

                  onLogin: _handleLogin,
                ),

                const SizedBox(
                  height: AppSpacing.md,
                ),

                ForgotPasswordLink(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            const ForgotPasswordScreen(),
                      ),
                    );
                  },
                ),

                const SizedBox(
                  height: AppSpacing.xxl,
                ),

                const SecurityNotice(),

                const SizedBox(
                  height: AppSpacing.lg,
                ),

                // TEMPORARY DEBUG BUTTON
                OutlinedButton(
                  onPressed: _testHttps,
                  child: const Text(
                    'Test HTTPS Connection',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}