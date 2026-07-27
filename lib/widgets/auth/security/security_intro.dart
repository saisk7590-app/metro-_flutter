import 'package:flutter/material.dart';

import '../../../theme/spacing.dart';

class SecurityIntro  extends StatelessWidget {
  const SecurityIntro({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Column(
      children: [
        Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            color: theme.primaryColor,
            borderRadius: BorderRadius.circular(AppRadius.xxl),
          ),
          child: const Icon(
            Icons.shield_outlined,
            color: Colors.white,
            size: 34,
          ),
        ),

        const SizedBox(height: AppSpacing.md),

        Text(
          "Security Verification",
          textAlign: TextAlign.center,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: AppSpacing.sm),

        Text(
          "Authenticate using Biometrics or your Security Pattern.",
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(color: colors.secondary),
        ),
      ],
    );
  }
}
