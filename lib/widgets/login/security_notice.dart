import 'package:flutter/material.dart';

import '../../theme/spacing.dart';

class SecurityNotice extends StatelessWidget {
  const SecurityNotice({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Column(
      children: [
        Divider(color: colors.outline),

        const SizedBox(height: AppSpacing.md),

        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.shield_outlined,
              color: theme.primaryColor,
              size: 18,
            ),

            const SizedBox(width: AppSpacing.sm),

            Expanded(
              child: Text(
                "This is a restricted-access terminal. All activity is logged and monitored for security compliance. Unauthorized access attempts are subject to disciplinary and legal action.",
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colors.secondary,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}