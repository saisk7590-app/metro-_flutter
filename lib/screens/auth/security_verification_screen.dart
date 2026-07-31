import 'package:flutter/material.dart';

import '../../navigation/main_navigation_screen.dart';
import '../../theme/spacing.dart';

import '../../widgets/common/custom_button.dart';

import '../../widgets/auth/security/biometric_card.dart';
import '../../widgets/auth/security/pattern_divider.dart';
import '../../widgets/auth/security/pattern_lock_widget.dart';
import '../../widgets/auth/security/security_intro.dart';
import '../../widgets/auth/security/security_app_header.dart';
import '../../widgets/common/responsive_container.dart';

class SecurityVerificationScreen extends StatefulWidget {
  const SecurityVerificationScreen({super.key});

  @override
  State<SecurityVerificationScreen> createState() =>
      _SecurityVerificationScreenState();
}

class _SecurityVerificationScreenState
    extends State<SecurityVerificationScreen> {
  List<int> pattern = [];

  bool get canConfirm => pattern.length >= 4;

  void _onPatternComplete(List<int> value) {
    setState(() {
      pattern = value;
    });
  }

  void _goToDashboard() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colors.surface,

      body: Column(
        children: [
          /// Top Header
          const SecurityAppHeader(),

          /// Scrollable Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: ResponsiveContainer(
                maxWidth: 600,
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    /// Shield + Title + Description
                    const SecurityIntro(),

                    const SizedBox(height: AppSpacing.xl),

                    /// Biometrics
                    BiometricCard(onBiometricPressed: _goToDashboard),

                    const SizedBox(height: AppSpacing.xl),

                    const PatternDivider(),

                    const SizedBox(height: AppSpacing.xl),

                    /// Pattern Lock
                    PatternLockWidget(onPatternComplete: _onPatternComplete),

                    const SizedBox(height: AppSpacing.xl),

                    /// Confirm
                    CustomButton(
                      title: "CONFIRM PATTERN",
                      icon: Icons.verified_user_outlined,
                      enabled: canConfirm,
                      onPressed: canConfirm ? _goToDashboard : null,
                    ),

                    const SizedBox(height: AppSpacing.md),

                    /// Back
                    CustomButton(
                      title: "BACK TO LOGIN",
                      icon: Icons.arrow_back,
                      isSecondary: true,
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
