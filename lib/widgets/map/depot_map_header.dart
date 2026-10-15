import 'package:flutter/material.dart';

class DepotMapHeader extends StatelessWidget {
  final String depot;
  final String selectedSection;
  final bool isMobile;
  final VoidCallback onReset;

  const DepotMapHeader({
    super.key,
    required this.depot,
    required this.selectedSection,
    this.isMobile = false,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final title = selectedSection.isNotEmpty
        ? "${depot.toUpperCase()} – $selectedSection Section"
        : "${depot.toUpperCase()} – Depot Layout";

    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFEAF4FF),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
        border: Border(bottom: BorderSide(color: colors.outline)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.map,
            color: isDark ? Colors.blue.shade300 : const Color(0xFF1E3A8A),
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: isMobile ? 13 : 15,
                color: isDark ? Colors.white : const Color(0xFF1E3A8A),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          TextButton.icon(
            onPressed: onReset,
            icon: Icon(Icons.refresh, color: theme.primaryColor, size: 16),
            label: Text(
              "Reset",
              style: TextStyle(
                color: theme.primaryColor,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}