import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../test_https.dart';
import '../../theme/spacing.dart';

import 'forgot_password_screen.dart';
//import 'security_verification_screen.dart';

import '../../../widgets/auth/login/login_logo.dart';
import '../../../widgets/auth/login/login_header.dart';
import '../../../widgets/auth/login/login_form.dart';
import '../../../widgets/auth/login/forgot_password_link.dart';
import '../../../widgets/auth/login/security_notice.dart';
import '../../widgets/common/responsive_container.dart';

import '../../providers/login_provider.dart';
//import '../../utils/password_encryption.dart';

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

  Future<void> _handleLogin() async {
    await testHttpsConnection();
  }

  

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

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
                  obscurePassword: obscurePassword,
                  isLoading: context.watch<LoginProvider>().isLoading,
                  onTogglePassword: () {
                    setState(() {
                      obscurePassword = !obscurePassword;
                    });
                  },
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
