import 'package:flutter/material.dart';

class DepotMapHeader extends StatelessWidget {
  final String depot;
  final VoidCallback onReset;

  const DepotMapHeader({
    super.key,
    required this.depot,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF1E293B)
            : const Color(0xFFEAF4FF),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
        border: Border(
          bottom: BorderSide(color: colors.outline),
        ),
      ),
      child: Row(
        children: [
          Text(
            "$depot Layout",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: isDark
                  ? Colors.white
                  : const Color(0xFF1E3A8A),
            ),
          ),

          const Spacer(),

          TextButton.icon(
            onPressed: onReset,
            icon: Icon(
              Icons.refresh,
              color: theme.primaryColor,
            ),
            label: Text(
              "Reset",
              style: TextStyle(
                color: theme.primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}