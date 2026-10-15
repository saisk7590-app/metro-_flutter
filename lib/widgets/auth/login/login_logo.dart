import 'package:flutter/material.dart';

import '../../../../theme/tokens/spacing.dart';

class LoginLogo extends StatelessWidget {
  const LoginLogo({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Center(
          child: Image.asset(
            'assets/icons/metro-logo.png',
            height: 72,
            width: 72,
            fit: BoxFit.contain,
          ),
        ),

        const SizedBox(height: AppSpacing.sm),

        Center(
          child: Text(
            "L&T METRO RAIL",
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.primaryColor,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.1,
            ),
          ),
        ),
      ],
    );
  }
}
