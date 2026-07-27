import 'package:flutter/material.dart';

import '../../../theme/spacing.dart';
import '../../common/custom_button.dart';

class BiometricCard extends StatelessWidget {
  final VoidCallback onBiometricPressed;

  const BiometricCard({super.key, required this.onBiometricPressed});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Card(
      elevation: 0,
      color: colors.surfaceContainerHighest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.xxl),
        side: BorderSide(color: colors.outline),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          children: [
            Icon(Icons.fingerprint, size: 60, color: theme.primaryColor),

            const SizedBox(height: AppSpacing.md),

            Text(
              "Biometric Authentication",
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: AppSpacing.sm),

            Text(
              "Use your fingerprint for quick and secure authentication.",
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colors.secondary,
              ),
            ),

            const SizedBox(height: AppSpacing.lg),

            CustomButton(
              title: "SIGN IN WITH BIOMETRICS",
              icon: Icons.fingerprint,
              onPressed: onBiometricPressed,
            ),
          ],
        ),
      ),
    );
  }
}
