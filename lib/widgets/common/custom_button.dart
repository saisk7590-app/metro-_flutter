import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String title;
  final VoidCallback? onPressed;
  final bool isSecondary;
  final Color? backgroundColor;
  final IconData? icon;
  final bool enabled;

  const CustomButton({
    super.key,
    required this.title,
    required this.onPressed,
    this.isSecondary = false,
    this.backgroundColor,
    this.icon,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;

    final Color buttonColor = enabled
        ? (backgroundColor ?? primaryColor)
        : Colors.grey.shade400;

    final Color textColor = enabled
        ? (isSecondary ? primaryColor : Colors.white)
        : Colors.white70;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: enabled ? onPressed : null,
        style: ElevatedButton.styleFrom(
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 14),
          backgroundColor: isSecondary
              ? Colors.transparent
              : buttonColor,
          foregroundColor: textColor,
          disabledBackgroundColor: Colors.grey.shade400,
          disabledForegroundColor: Colors.white70,
          side: isSecondary
              ? BorderSide(color: primaryColor)
              : BorderSide.none,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
            if (icon != null) ...[
              const SizedBox(width: 8),
              Icon(icon, size: 18),
            ],
          ],
        ),
      ),
    );
  }
}