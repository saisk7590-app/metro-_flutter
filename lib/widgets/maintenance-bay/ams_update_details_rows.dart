import 'package:flutter/material.dart';
import 'ams_update_form_rows.dart';

/// Subheader row displaying Line and Allocation Status (e.g., 'Edit Details' or 'Empty')
class AMSUpdateHeaderInfo extends StatelessWidget {
  final String line;
  final bool hasExistingData;
  final bool isDark;

  const AMSUpdateHeaderInfo({
    super.key,
    required this.line,
    required this.hasExistingData,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
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
        const SizedBox(height: 16),
      ],
    );
  }
}

/// Row 2: Train Set, Status, and Purpose dropdowns
class AMSUpdateTrainDetailsRow extends StatelessWidget {
  final int selectedTrainSet;
  final int selectedStatus;
  final int selectedPurpose;
  final List<DropdownOption> trainSetOptions;
  final List<DropdownOption> statusOptions;
  final List<DropdownOption> purposeOptions;
  final bool isDark;
  final ValueChanged<int?> onTrainSetChanged;
  final ValueChanged<int?> onStatusChanged;
  final ValueChanged<int?> onPurposeChanged;

  const AMSUpdateTrainDetailsRow({
    super.key,
    required this.selectedTrainSet,
    required this.selectedStatus,
    required this.selectedPurpose,
    required this.trainSetOptions,
    required this.statusOptions,
    required this.purposeOptions,
    required this.isDark,
    required this.onTrainSetChanged,
    required this.onStatusChanged,
    required this.onPurposeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 650;

        final trainSetField = AmsDropdownField(
          label: 'Train Set',
          value: selectedTrainSet,
          options: trainSetOptions,
          onChanged: onTrainSetChanged,
          isDark: isDark,
        );

        final statusField = AmsDropdownField(
          label: 'Status',
          value: selectedStatus,
          options: statusOptions,
          onChanged: onStatusChanged,
          isDark: isDark,
        );

        final purposeField = AmsDropdownField(
          label: 'Purpose',
          value: selectedPurpose,
          options: purposeOptions,
          onChanged: onPurposeChanged,
          isDark: isDark,
        );

        if (isNarrow) {
          return Column(
            children: [
              trainSetField,
              const SizedBox(height: 12),
              statusField,
              const SizedBox(height: 12),
              purposeField,
            ],
          );
        }

        return Row(
          children: [
            Expanded(child: trainSetField),
            const SizedBox(width: 14),
            Expanded(child: statusField),
            const SizedBox(width: 14),
            Expanded(child: purposeField),
          ],
        );
      },
    );
  }
}

/// Row 3: From Date, To Date, and Outward Checkbox
class AMSUpdateDatesRow extends StatelessWidget {
  final DateTime? fromDate;
  final DateTime? toDate;
  final bool hasExistingData;
  final bool isOutward;
  final bool isDark;
  final VoidCallback onPickFromDate;
  final VoidCallback onPickToDate;
  final ValueChanged<bool?> onOutwardChanged;
  final String Function(DateTime?) formatDisplayDateTime;

  const AMSUpdateDatesRow({
    super.key,
    required this.fromDate,
    required this.toDate,
    required this.hasExistingData,
    required this.isOutward,
    required this.isDark,
    required this.onPickFromDate,
    required this.onPickToDate,
    required this.onOutwardChanged,
    required this.formatDisplayDateTime,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 650;

        final fromDateField = AmsDateTimePickerField(
          label: 'From Date *',
          value: fromDate,
          enabled: true,
          onTap: onPickFromDate,
          isDark: isDark,
          formatDisplayDateTime: formatDisplayDateTime,
        );

        final toDateField = AmsDateTimePickerField(
          label: 'To Date',
          value: toDate,
          enabled: hasExistingData,
          onTap: hasExistingData ? onPickToDate : null,
          isDark: isDark,
          formatDisplayDateTime: formatDisplayDateTime,
        );

        final outwardCheckbox = Padding(
          padding: const EdgeInsets.only(top: 22),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Checkbox(
                value: isOutward,
                onChanged: hasExistingData ? onOutwardChanged : null,
              ),
              Text(
                'Outward',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: hasExistingData
                      ? (isDark ? Colors.white : const Color(0xFF475569))
                      : Colors.grey.shade400,
                ),
              ),
            ],
          ),
        );

        if (isNarrow) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              fromDateField,
              const SizedBox(height: 12),
              toDateField,
              const SizedBox(height: 4),
              outwardCheckbox,
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: fromDateField),
            const SizedBox(width: 14),
            Expanded(child: toDateField),
            const SizedBox(width: 14),
            outwardCheckbox,
          ],
        );
      },
    );
  }
}
