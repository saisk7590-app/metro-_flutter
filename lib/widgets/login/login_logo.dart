import 'package:flutter/material.dart';

import '../../theme/spacing.dart';

class LoginLogo extends StatelessWidget {
  const LoginLogo({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Center(
          child: Container(
            height: 65,
            width: 65,
            decoration: BoxDecoration(
              color: theme.primaryColor,
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
            child: const Icon(Icons.train, color: Colors.white, size: 34),
          ),
        ),

        const SizedBox(height: AppSpacing.sm),

        Center(
          child: Text(
            "L&T METRO RAIL",
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
