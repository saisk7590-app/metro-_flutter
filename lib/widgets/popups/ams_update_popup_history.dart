import 'package:flutter/material.dart';

class AmsPopupAllocationHistory extends StatelessWidget {
  final List<Map<String, dynamic>> allocations;
  final int selectedHistoryIndex;
  final int selectedTrainSet;
  final void Function(Map<String, dynamic> item, int index) onAssign;

  const AmsPopupAllocationHistory({
    super.key,
    required this.allocations,
    required this.selectedHistoryIndex,
    required this.selectedTrainSet,
    required this.onAssign,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isDark
                ? const Color(0xFF1E3A8A).withValues(alpha: 0.3)
                : const Color(0xFFEFF6FF),
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
                  '${allocations.length}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
            ),
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
                  DataColumn(
                    label: Text(
                      'Train Set',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Status',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Purpose',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Allocated On',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Remarks',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Action',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ),
                ],
                rows: allocations.asMap().entries.map((entry) {
                  final idx = entry.key;
                  final item = entry.value;

                  final tsName = item['mbaTrainSetName'] ??
                      item['mba_train_set_name'] ??
                      '—';
                  final stName =
                      item['mbaStatusName'] ?? item['mba_status_name'] ?? '—';
                  final prName = item['mbaPurposeName'] ??
                      item['mba_purpose_name'] ??
                      '—';
                  final allocOn = item['mbaAllocatedOn'] ??
                      item['mba_allocated_on'] ??
                      '—';
                  final remarks =
                      item['mbaRemarks'] ?? item['mba_remarks'] ?? '—';

                  final isAssigned = selectedHistoryIndex == idx;

                  return DataRow(
                    selected: isAssigned,
                    cells: [
                      DataCell(
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '$tsName',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ),
                      DataCell(
                        Text('$stName', style: const TextStyle(fontSize: 12)),
                      ),
                      DataCell(
                        Text('$prName', style: const TextStyle(fontSize: 12)),
                      ),
                      DataCell(
                        Text('$allocOn', style: const TextStyle(fontSize: 12)),
                      ),
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
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            visualDensity: VisualDensity.compact,
                          ),
                          onPressed: () => onAssign(item, idx),
                          icon: const Icon(Icons.arrow_downward, size: 12),
                          label: const Text(
                            'Assign',
                            style: TextStyle(fontSize: 11),
                          ),
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
