import 'package:flutter/material.dart';

/// Remarks input field with dark mode support
class AMSUpdateRemarksField extends StatelessWidget {
  final TextEditingController controller;
  final bool isDark;

  const AMSUpdateRemarksField({
    super.key,
    required this.controller,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Remarks',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.grey.shade300 : const Color(0xFF475569),
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Remarks',
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
            contentPadding: const EdgeInsets.all(12),
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
        ),
      ],
    );
  }
}

/// Table and header for Allocation History / Future Allocations
class AMSUpdateAllocationHistoryTable extends StatelessWidget {
  final List<Map<String, dynamic>> futureAllocations;
  final int selectedHistoryIndex;
  final int selectedTrainSet;
  final bool isDark;
  final void Function(Map<String, dynamic> item, int index) onAssign;

  const AMSUpdateAllocationHistoryTable({
    super.key,
    required this.futureAllocations,
    required this.selectedHistoryIndex,
    required this.selectedTrainSet,
    required this.isDark,
    required this.onAssign,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E3A8A).withValues(alpha: 0.3) : const Color(0xFFEFF6FF),
            borderRadius: BorderRadius.circular(6),
            border: const Border(
              left: BorderSide(color: Color(0xFF2563EB), width: 4),
            ),
          ),
          child: Row(
            children: [
              const Icon(Icons.history, size: 16, color: Color(0xFF2563EB)),
              const SizedBox(width: 8),
              const Text(
                'Allocation History',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E3A8A),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF2563EB),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${futureAllocations.length}',
                  style: const TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: isDark ? Colors.grey.shade700 : Colors.grey.shade300),
            borderRadius: BorderRadius.circular(6),
          ),
          constraints: const BoxConstraints(maxHeight: 180),
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowHeight: 36,
                dataRowMinHeight: 36,
                dataRowMaxHeight: 42,
                columns: const [
                  DataColumn(label: Text('Train Set', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                  DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                  DataColumn(label: Text('Purpose', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                  DataColumn(label: Text('Allocated On', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                  DataColumn(label: Text('Remarks', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                  DataColumn(label: Text('Action', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                ],
                rows: futureAllocations.asMap().entries.map((entry) {
                  final idx = entry.key;
                  final item = entry.value;

                  final tsName = item['mbaTrainSetName'] ?? item['mba_train_set_name'] ?? '—';
                  final stName = item['mbaStatusName'] ?? item['mba_status_name'] ?? '—';
                  final prName = item['mbaPurposeName'] ?? item['mba_purpose_name'] ?? '—';
                  final allocOn = item['mbaAllocatedOn'] ?? item['mba_allocated_on'] ?? '—';
                  final remarks = item['mbaRemarks'] ?? item['mba_remarks'] ?? '—';

                  final isAssigned = selectedHistoryIndex == idx;

                  return DataRow(
                    selected: isAssigned,
                    cells: [
                      DataCell(
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '$tsName',
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black87),
                          ),
                        ),
                      ),
                      DataCell(Text('$stName', style: const TextStyle(fontSize: 12))),
                      DataCell(Text('$prName', style: const TextStyle(fontSize: 12))),
                      DataCell(Text('$allocOn', style: const TextStyle(fontSize: 12))),
                      DataCell(
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 140),
                          child: Text(
                            '$remarks',
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                      ),
                      DataCell(
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: selectedTrainSet > 0
                                ? Colors.grey.shade400
                                : const Color(0xFF059669),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            visualDensity: VisualDensity.compact,
                          ),
                          onPressed: () => onAssign(item, idx),
                          icon: const Icon(Icons.arrow_downward, size: 12),
                          label: const Text('Assign', style: TextStyle(fontSize: 11)),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Action buttons for Clear and Save
class AMSUpdateActionButtons extends StatelessWidget {
  final bool isSaving;
  final bool isSaveDisabled;
  final VoidCallback onClear;
  final VoidCallback onSave;

  const AMSUpdateActionButtons({
    super.key,
    required this.isSaving,
    required this.isSaveDisabled,
    required this.onClear,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        OutlinedButton.icon(
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFFDC2626),
            side: const BorderSide(color: Color(0xFFDC2626)),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          ),
          onPressed: isSaving ? null : onClear,
          icon: const Icon(Icons.close, size: 16),
          label: const Text('Clear', style: TextStyle(fontWeight: FontWeight.w600)),
        ),
        const SizedBox(width: 12),
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF10B981),
            foregroundColor: Colors.white,
            disabledBackgroundColor: const Color(0xFF10B981).withValues(alpha: 0.5),
            disabledForegroundColor: Colors.white70,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
            elevation: 2,
          ),
          onPressed: isSaveDisabled ? null : onSave,
          icon: isSaving
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Icon(Icons.save, size: 16),
          label: Text(
            isSaving ? 'Saving...' : 'Save',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
