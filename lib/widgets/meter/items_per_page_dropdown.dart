import 'package:flutter/material.dart';

class ItemsPerPageDropdown extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;

  const ItemsPerPageDropdown({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    const allowed = [10, 20, 50, 75, 100];
    final effectiveValue = allowed.contains(value) ? value : allowed.first;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isDark ? colors.surfaceContainerHighest : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: 0.6),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "Rows:",
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: colors.onSurfaceVariant,
            ),
          ),
          const SizedBox(width: 4),
          DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              value: effectiveValue,
              borderRadius: BorderRadius.circular(10),
              isDense: true,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: colors.primary,
              ),
              icon: Icon(
                Icons.arrow_drop_down,
                size: 18,
                color: colors.primary,
              ),
              items: allowed
                  .map((v) => DropdownMenuItem(
                        value: v,
                        child: Text("$v"),
                      ))
                  .toList(),
              onChanged: (newValue) {
                if (newValue != null) {
                  onChanged(newValue);
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
