import 'package:flutter/material.dart';

import '../../theme/spacing.dart';

class LoginHeader extends StatelessWidget {
  const LoginHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Column(
      children: [
        Text(
          "Systems Access",
          textAlign: TextAlign.center,
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: AppSpacing.sm),

        Text(
          "Enter your authorized credentials to continue.",
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(color: colors.secondary),
        ),
      ],
    );
  }
}
