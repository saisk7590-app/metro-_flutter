import 'package:flutter/material.dart';

import '../maintenance_bay/ams_update_controller.dart';
import '../maintenance_bay/ams_update_form_rows.dart';

export '../maintenance_bay/ams_update_form_rows.dart' show DropdownOption;

class AmsPopupDropdown extends StatelessWidget {
  final String label;
  final int value;
  final List<DropdownOption> options;
  final ValueChanged<int?> onChanged;

  const AmsPopupDropdown({
    super.key,
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final seen = <int>{};
    final uniqueOptions = options.where((o) => seen.add(o.value)).toList();
    final effectiveValue = uniqueOptions.any((o) => o.value == value)
        ? value
        : (uniqueOptions.isNotEmpty ? uniqueOptions.first.value : null);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.grey.shade300 : const Color(0xFF475569),
          ),
        ),
        const SizedBox(height: 6),
        DropdownButtonFormField<int>(
          key: ValueKey('${label}_${uniqueOptions.length}_$effectiveValue'),
          initialValue: effectiveValue,
          isExpanded: true,
          decoration: InputDecoration(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide(
                color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
              ),
            ),
          ),
          items: uniqueOptions.map((opt) {
            return DropdownMenuItem<int>(
              value: opt.value,
              child: Text(
                opt.label,
                style: TextStyle(
                  fontSize: 13,
                  color: opt.value == 0
                      ? Colors.grey.shade500
                      : (isDark ? Colors.white : Colors.black87),
                ),
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }
}

class AmsPopupDatePicker extends StatelessWidget {
  final String label;
  final DateTime? value;
  final bool enabled;
  final VoidCallback? onTap;

  const AmsPopupDatePicker({
    super.key,
    required this.label,
    required this.value,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: enabled
                ? (isDark ? Colors.grey.shade300 : const Color(0xFF475569))
                : Colors.grey.shade400,
          ),
        ),
        const SizedBox(height: 6),
        InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: BorderRadius.circular(6),
          child: InputDecorator(
            decoration: InputDecoration(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              suffixIcon: Icon(
                Icons.calendar_today,
                size: 16,
                color: enabled ? const Color(0xFF2563EB) : Colors.grey.shade400,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: BorderSide(
                  color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
                ),
              ),
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: BorderSide(
                  color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                ),
              ),
            ),
            child: Text(
              value != null
                  ? AmsUpdateService.formatDisplayDateTime(value)
                  : 'Select date & time',
              style: TextStyle(
                fontSize: 13,
                color: enabled
                    ? (isDark ? Colors.white : Colors.black87)
                    : Colors.grey.shade400,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
