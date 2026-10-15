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
            errorBuilder: (context, error, stackTrace) => Container(
              height: 65,
              width: 65,
              decoration: BoxDecoration(
                color: theme.primaryColor,
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
              child: const Icon(Icons.train, color: Colors.white, size: 34),
            ),
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

        const SizedBox(height: 2),

        Center(
          child: Text(
            "Asset Management System",
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.70),
              fontWeight: FontWeight.w500,
              letterSpacing: 0.3,
            ),
          ),
        ),
      ],
    );
  }
}
