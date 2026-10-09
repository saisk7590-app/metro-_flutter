import 'package:flutter/material.dart';
import '../../models/checklist_model.dart';
import 'checklist_forms.dart';

/// Top navigation header for Checksheet Detail Screen
class ChecksheetNavHeader extends StatelessWidget {
  final JobPlanChecklistModel checklist;
  final VoidCallback onBack;

  const ChecksheetNavHeader({
    super.key,
    required this.checklist,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final cl = checklist;

    return Material(
      color: colors.surfaceContainerHighest,
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 10, 16, 10),
        child: Row(
          children: [
            OutlinedButton.icon(
              onPressed: onBack,
              icon: const Icon(Icons.arrow_back, size: 16),
              label: const Text('Back to List', style: TextStyle(fontSize: 12)),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                minimumSize: Size.zero,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    cl.jpcChecklistName,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    '${cl.assetCategoryCode} • ${cl.scheduleName}',
                    style: TextStyle(fontSize: 11, color: colors.onSurfaceVariant),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.add, size: 16),
              label: const Text('Add Group', style: TextStyle(fontSize: 12)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00D25B),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () {
                AddChecklistGroupDialog.show(
                  context,
                  checklistName: cl.jpcChecklistName,
                  checklistId: cl.jpcId,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// Real-time Sync & Progress Status Banner
class ChecksheetSyncBanner extends StatelessWidget {
  final String syncStatus;
  final int completedChecks;
  final int totalChecks;

  const ChecksheetSyncBanner({
    super.key,
    required this.syncStatus,
    required this.completedChecks,
    required this.totalChecks,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isDark = colors.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.green.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: Colors.green,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              syncStatus,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.green.shade300 : Colors.green.shade800,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            '$completedChecks/$totalChecks CHECKS',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Colors.green.shade800,
            ),
          ),
        ],
      ),
    );
  }
}
