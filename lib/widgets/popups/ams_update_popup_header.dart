import 'package:flutter/material.dart';

class AmsPopupHeader extends StatelessWidget {
  final String track;
  final String line;
  final bool hasExistingData;
  final VoidCallback onClose;

  const AmsPopupHeader({
    super.key,
    required this.track,
    required this.line,
    required this.hasExistingData,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Title & Close Button
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Text(
                'Selected - $track ---Bay Selection',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF1E293B),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close),
              splashRadius: 20,
              onPressed: onClose,
            ),
          ],
        ),

        const Divider(height: 18),

        // Subheader Info Row (Line & Status)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            RichText(
              text: TextSpan(
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.grey.shade300 : const Color(0xFF334155),
                ),
                children: [
                  const TextSpan(text: 'Line: '),
                  TextSpan(
                    text: '$line Line',
                    style: const TextStyle(
                      color: Color(0xFF2563EB),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            RichText(
              text: TextSpan(
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.grey.shade300 : const Color(0xFF334155),
                ),
                children: [
                  const TextSpan(text: 'Status: '),
                  TextSpan(
                    text: hasExistingData ? 'Edit Details' : 'Empty',
                    style: const TextStyle(
                      color: Color(0xFF2563EB),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
