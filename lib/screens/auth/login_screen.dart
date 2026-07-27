import 'package:flutter/material.dart';

import '../../theme/spacing.dart';

import 'forgot_password_screen.dart';
import 'security_verification_screen.dart';

import '../../../widgets/auth/login/login_logo.dart';
import '../../../widgets/auth/login/login_header.dart';
import '../../../widgets/auth/login/login_form.dart';
import '../../../widgets/auth/login/forgot_password_link.dart';
import '../../../widgets/auth/login/security_notice.dart';

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

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colors.surface,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
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
                  obscurePassword: obscurePassword,
                  onTogglePassword: () {
                    setState(() {
                      obscurePassword = !obscurePassword;
                    });
                  },
                  onLogin: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const SecurityVerificationScreen(),
                      ),
                    );
                  },
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
