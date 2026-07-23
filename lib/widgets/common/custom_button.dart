import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String title;
  final VoidCallback onPressed;
  final bool isSecondary;
  final Color? backgroundColor;
  final IconData? icon;

  const CustomButton({
    super.key,
    required this.title,
    required this.onPressed,
    this.isSecondary = false,
    this.backgroundColor,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 14),
          backgroundColor: isSecondary
              ? Colors.transparent
              : (backgroundColor ?? primaryColor),
          foregroundColor: isSecondary ? primaryColor : Colors.white,
          side: isSecondary ? BorderSide(color: primaryColor) : BorderSide.none,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
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
