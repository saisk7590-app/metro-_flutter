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

  const TrainsetRow({
    super.key,
    required this.serialNo,
    required this.trainset,
    required this.location,
    required this.previousDay,
    required this.previousStatus,
    required this.currentStatus,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

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
            //-------------------------------------------------
            // Trainset + Date + Edit
            //-------------------------------------------------
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
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
                    color: theme.primaryColor.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: IconButton(
                    onPressed: onEdit,
                    icon: Icon(
                      Icons.edit_square,
                      color: theme.primaryColor,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            //-------------------------------------------------
            // Location
            //-------------------------------------------------
            Text(
              location,
              style: TextStyle(
                fontSize: 14,
                color: colors.secondary,
                fontWeight: FontWeight.w500,
              ),
            ),

            const SizedBox(height: 14),

            //-------------------------------------------------
            // Heading
            //-------------------------------------------------
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

            //-------------------------------------------------
            // Status Chips
            //-------------------------------------------------
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