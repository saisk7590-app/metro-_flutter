import 'package:flutter/material.dart';

import '../../../theme/spacing.dart';

class PatternDivider extends StatelessWidget {
  const PatternDivider({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Row(
      children: [
        Expanded(
          child: Divider(
            color: colors.outline,
          ),
        ),

        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
          ),
          child: Text(
            "OR USE PATTERN",
            style: theme.textTheme.labelMedium?.copyWith(
              color: colors.secondary,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
        ),

        Expanded(
          child: Divider(
            color: colors.outline,
          ),
        ),
      ],
    );
  }
}