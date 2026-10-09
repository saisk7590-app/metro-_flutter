import 'package:flutter/material.dart';

import 'status_chip.dart';

class TrainsetRow extends StatelessWidget {
  final int serialNo;
  final String trainset;
  final String location;
  final String previousDay;
  final String previousStatus;
  final String currentStatus;
  final VoidCallback onEdit;
  final bool isMobile;

  const TrainsetRow({
    super.key,
    required this.serialNo,
    required this.trainset,
    required this.location,
    required this.previousDay,
    required this.previousStatus,
    required this.currentStatus,
    required this.onEdit,
    this.isMobile = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final canEdit = previousStatus.trim().toLowerCase() == 'green';

    // ----------------------------------------------------
    // Desktop / Tablet Table Row
    // ----------------------------------------------------
    if (!isMobile) {
      return Container(
        decoration: BoxDecoration(
          color: serialNo.isEven
              ? (theme.brightness == Brightness.dark
                  ? const Color(0xFF1E293B).withValues(alpha: 0.5)
                  : const Color(0xFFF8FAFC))
              : Colors.transparent,
          border: Border(
            bottom: BorderSide(
              color: colors.outline.withValues(alpha: 0.15),
            ),
          ),
        ),
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            // No (flex 1)
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  serialNo.toString(),
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: colors.secondary,
                  ),
                ),
              ),
            ),

            // Trainset (flex 2)
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  trainset,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),

            // Location (flex 2)
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  location.isNotEmpty ? location : '-',
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ),
            ),

            // Previous Day (flex 2)
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  previousDay.isNotEmpty ? previousDay : '-',
                  style: TextStyle(
                    fontSize: 13,
                    color: colors.secondary,
                  ),
                ),
              ),
            ),

            // Previous Day Status (flex 3)
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: StatusChip(status: previousStatus),
              ),
            ),

            // Current Day Status (flex 3)
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: StatusChip(status: currentStatus),
              ),
            ),

            // Action (flex 1)
            Expanded(
              flex: 1,
              child: Center(
                child: IconButton(
                  icon: const Icon(Icons.edit_square, size: 20),
                  color: canEdit ? theme.primaryColor : colors.primary.withValues(alpha: 0.6),
                  tooltip: canEdit
                      ? "Edit meter readings"
                      : "Previous status: $previousStatus (Click to view/enter readings)",
                  onPressed: onEdit,
                ),
              ),
            ),
          ],
        ),
      );
    }

    // ----------------------------------------------------
    // Mobile Card View
    // ----------------------------------------------------
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: theme.brightness == Brightness.dark
              ? const Color(0xFF1E293B)
              : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: colors.outline.withValues(alpha: 0.35),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Trainset + Serial + Date + Edit
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: colors.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          "#$serialNo",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: colors.secondary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        trainset,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        previousDay,
                        style: TextStyle(
                          fontSize: 13,
                          color: colors.secondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: canEdit
                        ? theme.primaryColor.withValues(alpha: 0.10)
                        : colors.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: IconButton(
                    onPressed: onEdit,
                    tooltip: canEdit
                        ? "Edit meter readings"
                        : "Previous status: $previousStatus (Click to view/enter readings)",
                    icon: Icon(
                      Icons.edit_square,
                      color: canEdit ? theme.primaryColor : colors.primary.withValues(alpha: 0.6),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Location
            Row(
              children: [
                Icon(
                  Icons.location_on_outlined,
                  size: 16,
                  color: colors.secondary,
                ),
                const SizedBox(width: 4),
                Text(
                  location.isNotEmpty ? location : '-',
                  style: TextStyle(
                    fontSize: 14,
                    color: colors.secondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Heading
            Row(
              children: [
                Expanded(
                  child: Text(
                    "Pre. Day Status",
                    style: TextStyle(
                      fontSize: 11,
                      color: colors.secondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    "Current Day Status",
                    style: TextStyle(
                      fontSize: 11,
                      color: colors.secondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),

            // Status Chips
            Row(
              children: [
                Expanded(
                  child: StatusChip(
                    status: previousStatus,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: StatusChip(
                    status: currentStatus,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}