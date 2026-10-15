import 'package:flutter/material.dart';

import '../../widgets/common/custom_header.dart';

class WorkOrderHistoryScreen extends StatefulWidget {
  const WorkOrderHistoryScreen({super.key});

  @override
  State<WorkOrderHistoryScreen> createState() => _WorkOrderHistoryScreenState();
}

class _WorkOrderHistoryScreenState extends State<WorkOrderHistoryScreen> {
  final List<Map<String, dynamic>> _historyItems = [
    {
      'woNo': 'WO-2024-0099',
      'trainset': 'TS-04',
      'schedule': 'Fortnightly PM Routine',
      'date': '2026-10-07 16:30',
      'inspector': 'Depot Tech (Shift A)',
      'total': 15,
      'passed': 15,
      'defects': 0,
      'status': 'Closed & Synced',
    },
    {
      'woNo': 'WO-2024-0095',
      'trainset': 'TS-02',
      'schedule': 'Weekly Bogie & Brake Check',
      'date': '2026-10-06 14:15',
      'inspector': 'Depot Tech (Shift B)',
      'total': 22,
      'passed': 21,
      'defects': 1,
      'status': 'Defect Corrected',
    },
    {
      'woNo': 'WO-2024-0091',
      'trainset': 'TS-11',
      'schedule': 'Daily Pre-Service Inspection',
      'date': '2026-10-05 07:45',
      'inspector': 'Depot Tech (Shift A)',
      'total': 18,
      'passed': 18,
      'defects': 0,
      'status': 'Closed & Synced',
    },
    {
      'woNo': 'WO-2024-0088',
      'trainset': 'TS-08',
      'schedule': 'Monthly High Voltage & HVAC',
      'date': '2026-10-04 18:20',
      'inspector': 'Depot Tech (Electrical Team)',
      'total': 20,
      'passed': 19,
      'defects': 1,
      'status': 'Defect Corrected',
    },
    {
      'woNo': 'WO-2024-0082',
      'trainset': 'TS-06',
      'schedule': 'Fortnightly PM Routine',
      'date': '2026-10-03 11:30',
      'inspector': 'Depot Tech (Shift C)',
      'total': 15,
      'passed': 15,
      'defects': 0,
      'status': 'Closed & Synced',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return ColoredBox(
      color: colors.surface,
      child: Column(
        children: [
          const CustomHeader(
            title: "INSPECTION HISTORY",
            subtitle: "Completed Checks & Audit Trail",
          ),

          // Summary Metrics Banner
          Container(
            margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: colors.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.5)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildHistoryMetric('Inspected', '57 Trains', Colors.blue, colors),
                _buildVerticalDivider(colors),
                _buildHistoryMetric('Compliance', '97.2%', Colors.green, colors),
                _buildVerticalDivider(colors),
                _buildHistoryMetric('Defects Cleared', '100%', Colors.amber.shade800, colors),
              ],
            ),
          ),

          // Audit List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.only(bottom: 24, top: 4),
              itemCount: _historyItems.length,
              itemBuilder: (context, index) {
                final item = _historyItems[index];
                final hasDefect = item['defects'] > 0;

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: colors.outlineVariant.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: colors.primary,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                item['trainset'],
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              item['woNo'],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: Colors.green.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                item['status'],
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green.shade800,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          item['schedule'],
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: colors.onSurface,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(Icons.schedule, size: 13, color: colors.outline),
                            const SizedBox(width: 4),
                            Text(
                              item['date'],
                              style: TextStyle(
                                fontSize: 11,
                                color: colors.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Icon(Icons.person_outline, size: 13, color: colors.outline),
                            const SizedBox(width: 4),
                            Text(
                              item['inspector'],
                              style: TextStyle(
                                fontSize: 11,
                                color: colors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Text(
                              'Audit Result: ${item['passed']}/${item['total']} Checks Compliant',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: colors.primary,
                              ),
                            ),
                            if (hasDefect) ...[
                              const SizedBox(width: 8),
                              Text(
                                '(1 Defect Resolved)',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.amber.shade900,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryMetric(
      String label, String value, Color color, ColorScheme colors) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(fontSize: 11, color: colors.onSurfaceVariant),
        ),
      ],
    );
  }

  Widget _buildVerticalDivider(ColorScheme colors) {
    return Container(
      height: 30,
      width: 1,
      color: colors.outlineVariant.withValues(alpha: 0.5),
    );
  }
}
