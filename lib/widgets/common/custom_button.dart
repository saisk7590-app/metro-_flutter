import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String title;
  final VoidCallback? onPressed;
  final bool isSecondary;
  final Color? backgroundColor;
  final IconData? icon;
  final bool enabled;
  final bool expanded;
  final bool isLoading;

  const CustomButton({
    super.key,
    required this.title,
    required this.onPressed,
    this.isSecondary = false,
    this.backgroundColor,
    this.icon,
    this.enabled = true,
    this.expanded = true,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;

    final bool buttonEnabled = enabled && !isLoading;

    final Color buttonColor = buttonEnabled
        ? (backgroundColor ?? primaryColor)
        : Colors.grey.shade400;

    final Color textColor = buttonEnabled
        ? (isSecondary ? primaryColor : Colors.white)
        : Colors.white70;

    return SizedBox(
      width: expanded ? double.infinity : null,
      child: ElevatedButton(
        onPressed: buttonEnabled ? onPressed : null,
        style: ElevatedButton.styleFrom(
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 14),
          backgroundColor:
              isSecondary ? Colors.transparent : buttonColor,
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
            if (isLoading) ...[
              const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Colors.white70,
                  ),
                ),
              ),
              const SizedBox(width: 10),
            ],

            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),

            if (!isLoading && icon != null) ...[
              const SizedBox(width: 8),
              Icon(icon, size: 18),
            ],
          ],
        ),
      ),
    );
  }
}