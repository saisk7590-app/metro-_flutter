import 'package:flutter/material.dart';

import '../../../theme/spacing.dart';
import '../../../widgets/common/custom_button.dart';
import '../../../widgets/common/custom_input.dart';

class LoginForm extends StatelessWidget {
  final TextEditingController usernameController;
  final TextEditingController passwordController;
  final TextEditingController captchaController;
  final bool obscurePassword;
  final bool isLoading;
  final bool showCaptcha;
  final String captchaImage;
  final VoidCallback onTogglePassword;
  final VoidCallback onRefreshCaptcha;
  final VoidCallback onLogin;

  const LoginForm({
    super.key,
    required this.usernameController,
    required this.passwordController,
    required this.captchaController,
    required this.obscurePassword,
    required this.isLoading,
    required this.showCaptcha,
    required this.captchaImage,
    required this.onTogglePassword,
    required this.onRefreshCaptcha,
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
            onPressed: isLoading ? null : onTogglePassword,
          ),
        ),
        if (showCaptcha) ...[
          const SizedBox(height: AppSpacing.md),
          if (captchaImage.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.memory(
                Uri.parse(
                  'data:image/png;base64,$captchaImage',
                ).data!.contentAsBytes(),
                height: 70,
                width: double.infinity,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) =>
                    const SizedBox.shrink(),
              ),
            ),
          TextField(
            controller: captchaController,
            textCapitalization: TextCapitalization.characters,
            decoration: InputDecoration(
              labelText: 'CAPTCHA',
              hintText: 'Enter the characters shown',
              suffixIcon: IconButton(
                tooltip: 'Refresh CAPTCHA',
                onPressed: isLoading ? null : onRefreshCaptcha,
                icon: const Icon(Icons.refresh),
              ),
            ),
          ),
        ],
        const SizedBox(height: AppSpacing.md),
        CustomButton(
          title: isLoading ? "SIGNING IN..." : "SECURE LOGIN",
          icon: Icons.arrow_forward,
          isLoading: isLoading,
          onPressed: isLoading ? null : onLogin,
        ),
      ],
    );
  }
}
