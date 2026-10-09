import 'package:flutter/material.dart';
import '../../models/checklist_model.dart';

class WorkOrderCard extends StatelessWidget {
  final ChecklistWorkOrder workOrder;
  final bool isSelected;
  final VoidCallback onTap;

  const WorkOrderCard({
    super.key,
    required this.workOrder,
    this.isSelected = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final wo = workOrder;

    Color statusColor = Colors.blue;
    if (wo.status.toLowerCase().contains('progress')) {
      statusColor = Colors.orange.shade800;
    } else if (wo.status.toLowerCase().contains('complete') ||
        wo.status.toLowerCase().contains('closed')) {
      statusColor = Colors.green.shade700;
    }

    Color priorityColor = Colors.grey;
    if (wo.priority.toLowerCase().contains('urgent')) {
      priorityColor = Colors.red.shade700;
    } else if (wo.priority.toLowerCase().contains('high')) {
      priorityColor = Colors.deepOrange;
    } else if (wo.priority.toLowerCase().contains('medium')) {
      priorityColor = Colors.blue.shade700;
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
      elevation: isSelected ? 3 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: isSelected
              ? colors.primary
              : colors.outlineVariant.withValues(alpha: 0.5),
          width: isSelected ? 2.0 : 1.0,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ----------------------------------------------------
              // Trainset badge + WO# + Status Tag
              // ----------------------------------------------------
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: colors.primary,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.train_rounded, size: 14, color: Colors.white),
                        const SizedBox(width: 4),
                        Text(
                          wo.assetDetails,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    wo.no,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: statusColor.withValues(alpha: 0.3)),
                    ),
                    child: Text(
                      wo.status,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // ----------------------------------------------------
              // Description
              // ----------------------------------------------------
              Text(
                wo.description,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: colors.onSurface,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 8),

              // ----------------------------------------------------
              // Location & Priority
              // ----------------------------------------------------
              Row(
                children: [
                  Icon(Icons.location_on_outlined, size: 13, color: colors.outline),
                  const SizedBox(width: 4),
                  Text(
                    wo.location,
                    style: TextStyle(fontSize: 11, color: colors.onSurfaceVariant),
                  ),
                  const SizedBox(width: 12),
                  Icon(Icons.flag_outlined, size: 13, color: priorityColor),
                  const SizedBox(width: 4),
                  Text(
                    wo.priority,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: priorityColor,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // ----------------------------------------------------
              // Progress Bar & Action
              // ----------------------------------------------------
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Checklist',
                              style: TextStyle(
                                fontSize: 10,
                                color: colors.onSurfaceVariant,
                              ),
                            ),
                            Text(
                              '${wo.completedChecks}/${wo.totalChecks} Done',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: colors.primary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: wo.progressPercentage,
                            minHeight: 6,
                            backgroundColor: colors.surfaceContainerHighest,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              wo.progressPercentage >= 1.0
                                  ? Colors.green
                                  : colors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  FilledButton.tonalIcon(
                    onPressed: onTap,
                    icon: const Icon(Icons.checklist_rounded, size: 16),
                    label: const Text('Inspect', style: TextStyle(fontSize: 12)),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
