import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Top header for Biometric Screen with Metro AMS branding and avatar
class BiometricHeaderProfile extends StatelessWidget {
  final String displayName;
  final Color primaryColor;
  final bool isDark;

  const BiometricHeaderProfile({
    super.key,
    required this.displayName,
    required this.primaryColor,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // App Branding
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: primaryColor.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.directions_subway_rounded,
            size: 40,
            color: primaryColor,
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'HYDERABAD METRO AMS',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
            color: Color(0xFF64748B),
          ),
        ),
        if (kIsWeb) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.amber.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.amber.shade700, width: 1),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.laptop_chromebook, size: 14, color: Colors.amber.shade800),
                const SizedBox(width: 6),
                Text(
                  'PC Web Test Mode (Biometrics Simulated)',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.amber.shade900,
                  ),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 36),

        // User Profile Avatar
        Container(
          width: 90,
          height: 90,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                primaryColor,
                primaryColor.withValues(alpha: 0.75),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: primaryColor.withValues(alpha: 0.25),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Center(
            child: Text(
              displayName.isNotEmpty
                  ? displayName.substring(0, 1).toUpperCase()
                  : 'U',
              style: const TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Greeting
        Text(
          'Welcome back,',
          style: TextStyle(
            fontSize: 14,
            color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          displayName,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : const Color(0xFF1E293B),
          ),
        ),
      ],
    );
  }
}

/// PhonePe style animated pulsating fingerprint sensor button
class BiometricFingerprintButton extends StatelessWidget {
  final bool isAuthenticating;
  final Animation<double> pulseAnimation;
  final VoidCallback onTap;
  final Color primaryColor;
  final bool isDark;

  const BiometricFingerprintButton({
    super.key,
    required this.isAuthenticating,
    required this.pulseAnimation,
    required this.onTap,
    required this.primaryColor,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ScaleTransition(
        scale: isAuthenticating
            ? pulseAnimation
            : const AlwaysStoppedAnimation(1.0),
        child: Container(
          width: 110,
          height: 110,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            border: Border.all(
              color: isAuthenticating
                  ? primaryColor
                  : (isDark ? Colors.grey.shade800 : Colors.grey.shade300),
              width: 2.5,
            ),
            boxShadow: [
              BoxShadow(
                color: primaryColor.withValues(
                  alpha: isAuthenticating ? 0.35 : 0.12,
                ),
                blurRadius: 24,
                spreadRadius: isAuthenticating ? 4 : 1,
              ),
            ],
          ),
          child: Center(
            child: Icon(
              Icons.fingerprint_rounded,
              size: 64,
              color: isAuthenticating
                  ? primaryColor
                  : (isDark ? Colors.grey.shade300 : const Color(0xFF334155)),
            ),
          ),
        ),
      ),
    );
  }
}
