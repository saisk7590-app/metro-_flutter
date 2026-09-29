import 'package:flutter/material.dart';

class StatusChip extends StatelessWidget {
  final String status;

  const StatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final raw = status.trim();
    final normalized = raw.toLowerCase();

    Color background;
    Color textColor;
    IconData icon;
    String displayText = raw;

    switch (normalized) {
      case 'green':
      case 'completed':
        background = const Color(0xFFDCFCE7); // Light green
        textColor = const Color(0xFF166534); // Dark green
        icon = Icons.check_circle_rounded;
        displayText = 'Completed';
        break;
      case 'orange':
      case 'yellow':
      case 'partial':
        background = const Color(0xFFFEF3C7); // Light amber
        textColor = const Color(0xFFB45309); // Dark amber
        icon = Icons.timelapse_rounded;
        displayText = 'Partial';
        break;
      case 'red':
      case 'validation error':
        background = const Color(0xFFFEE2E2); // Light red
        textColor = const Color(0xFF991B1B); // Dark red
        icon = Icons.error_outline_rounded;
        displayText = 'Error';
        break;
      case 'gray':
      case 'grey':
      case 'not started':
      case '':
        background = const Color(0xFFF1F5F9); // Slate 100
        textColor = const Color(0xFF64748B); // Slate 500
        icon = Icons.radio_button_unchecked_rounded;
        displayText = 'Not Started';
        break;
      default:
        background = const Color(0xFFF1F5F9);
        textColor = const Color(0xFF475569);
        icon = Icons.circle_outlined;
        displayText = raw;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: textColor.withValues(alpha: 0.25),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 14, color: textColor),
          const SizedBox(width: 5),
          Text(
            displayText,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

