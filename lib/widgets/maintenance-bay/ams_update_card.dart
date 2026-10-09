import 'package:flutter/material.dart';
import '../../models/maintenance_bay_model.dart';
import 'ams_update_details_rows.dart';
import 'ams_update_form_rows.dart';
import 'ams_update_history_widgets.dart';

/// Styled form container card containing all rows and controls for bay layout update
class AMSUpdateFormCard extends StatelessWidget {
  final String depot;
  final String track;
  final String line;
  final bool hasExistingData;
  final List<String> bayOptions;
  final int selectedTrainSet;
  final int selectedStatus;
  final int selectedPurpose;
  final List<DropdownOption> trainSetOptions;
  final List<DropdownOption> statusOptions;
  final List<DropdownOption> purposeOptions;
  final DateTime? fromDate;
  final DateTime? toDate;
  final bool isOutward;
  final TextEditingController remarksController;
  final List<Map<String, dynamic>> futureAllocations;
  final int selectedHistoryIndex;
  final bool isSaving;
  final bool isSaveDisabled;
  final bool isDark;
  final ValueChanged<String> onDepotChanged;
  final ValueChanged<String> onTrackChanged;
  final MaintenanceBayModel? Function(String) findBay;
  final ValueChanged<int?> onTrainSetChanged;
  final ValueChanged<int?> onStatusChanged;
  final ValueChanged<int?> onPurposeChanged;
  final VoidCallback onPickFromDate;
  final VoidCallback onPickToDate;
  final ValueChanged<bool?> onOutwardChanged;
  final String Function(DateTime?) formatDisplayDateTime;
  final void Function(Map<String, dynamic> item, int index) onAssignFromHistory;
  final VoidCallback onClear;
  final VoidCallback onSave;

  const AMSUpdateFormCard({
    super.key,
    required this.depot,
    required this.track,
    required this.line,
    required this.hasExistingData,
    required this.bayOptions,
    required this.selectedTrainSet,
    required this.selectedStatus,
    required this.selectedPurpose,
    required this.trainSetOptions,
    required this.statusOptions,
    required this.purposeOptions,
    required this.fromDate,
    required this.toDate,
    required this.isOutward,
    required this.remarksController,
    required this.futureAllocations,
    required this.selectedHistoryIndex,
    required this.isSaving,
    required this.isSaveDisabled,
    required this.isDark,
    required this.onDepotChanged,
    required this.onTrackChanged,
    required this.findBay,
    required this.onTrainSetChanged,
    required this.onStatusChanged,
    required this.onPurposeChanged,
    required this.onPickFromDate,
    required this.onPickToDate,
    required this.onOutwardChanged,
    required this.formatDisplayDateTime,
    required this.onAssignFromHistory,
    required this.onClear,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? Colors.grey.shade800 : Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            track.isEmpty ? 'Bay Allocation Setup' : 'Selected - $track ---Bay Selection',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF1E293B),
            ),
          ),
          const Divider(height: 18),
          if (track.isNotEmpty)
            AMSUpdateHeaderInfo(line: line, hasExistingData: hasExistingData, isDark: isDark),
          AMSUpdateDepotBayRow(
            depot: depot,
            track: track,
            bayOptions: bayOptions,
            isDark: isDark,
            onDepotChanged: onDepotChanged,
            onTrackChanged: onTrackChanged,
            findBay: findBay,
          ),
          const SizedBox(height: 14),
          AMSUpdateTrainDetailsRow(
            selectedTrainSet: selectedTrainSet,
            selectedStatus: selectedStatus,
            selectedPurpose: selectedPurpose,
            trainSetOptions: trainSetOptions,
            statusOptions: statusOptions,
            purposeOptions: purposeOptions,
            isDark: isDark,
            onTrainSetChanged: onTrainSetChanged,
            onStatusChanged: onStatusChanged,
            onPurposeChanged: onPurposeChanged,
          ),
          const SizedBox(height: 14),
          AMSUpdateDatesRow(
            fromDate: fromDate,
            toDate: toDate,
            hasExistingData: hasExistingData,
            isOutward: isOutward,
            isDark: isDark,
            onPickFromDate: onPickFromDate,
            onPickToDate: onPickToDate,
            onOutwardChanged: onOutwardChanged,
            formatDisplayDateTime: formatDisplayDateTime,
          ),
          const SizedBox(height: 14),
          AMSUpdateRemarksField(controller: remarksController, isDark: isDark),
          if (futureAllocations.isNotEmpty) ...[
            const SizedBox(height: 20),
            AMSUpdateAllocationHistoryTable(
              futureAllocations: futureAllocations,
              selectedHistoryIndex: selectedHistoryIndex,
              selectedTrainSet: selectedTrainSet,
              isDark: isDark,
              onAssign: onAssignFromHistory,
            ),
          ],
          const SizedBox(height: 24),
          AMSUpdateActionButtons(
            isSaving: isSaving,
            isSaveDisabled: isSaveDisabled,
            onClear: onClear,
            onSave: onSave,
          ),
        ],
      ),
    );
  }
}
