import 'package:flutter/material.dart';

import '../../../theme/spacing.dart';
import '../../../widgets/common/custom_button.dart';
import '../../../widgets/common/custom_input.dart';

class LoginForm extends StatelessWidget {
  final TextEditingController usernameController;
  final TextEditingController passwordController;
  final bool obscurePassword;
  final VoidCallback onTogglePassword;
  final VoidCallback onLogin;

  const LoginForm({
    super.key,
    required this.usernameController,
    required this.passwordController,
    required this.obscurePassword,
    required this.onTogglePassword,
    required this.onLogin,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CustomInput(
          label: "USERNAME / EMPLOYEE ID",
          controller: usernameController,
          placeholder: "e.g. M88-4209",
          prefixIcon: const Icon(Icons.person_outline),
        ),

        CustomInput(
          label: "ACCESS KEY",
          controller: passwordController,
          placeholder: "Enter Password",
          obscureText: obscurePassword,
          prefixIcon: const Icon(Icons.lock_outline),
          suffixIcon: IconButton(
            icon: Icon(
              obscurePassword
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
            ),
            onPressed: onTogglePassword,
          ),
        ),

        const SizedBox(height: AppSpacing.md),

        CustomButton(
          title: "SECURE LOGIN",
          icon: Icons.arrow_forward,
          onPressed: onLogin,
        ),
      ],
    );
  }
}
