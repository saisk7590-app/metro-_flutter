import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/checklist_provider.dart';
import '../../models/checklist_model.dart';

class ChecklistProgressHeader extends StatelessWidget {
  final VoidCallback onSwitchWorkOrder;

  const ChecklistProgressHeader({
    super.key,
    required this.onSwitchWorkOrder,
  });

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ChecklistProvider>();
    final colors = Theme.of(context).colorScheme;
    final wo = provider.selectedWorkOrder;

    final total = provider.totalChecks;
    final full = provider.fullChecks;
    final partial = provider.partialChecks;
    final no = provider.noChecks;
    final progress = provider.completionPercentage;
    final percentInt = (progress * 100).toInt();

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: 0.6),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ----------------------------------------------------
          // Top Row: Trainset Badge + WO# + Switch Button
          // ----------------------------------------------------
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: colors.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.train_rounded, size: 16, color: Colors.white),
                    const SizedBox(width: 5),
                    Text(
                      wo?.assetDetails.isNotEmpty == true ? wo!.assetDetails : 'TS-01',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      wo?.no ?? 'WO-NEW',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: colors.onSurface,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      wo?.schedule ?? 'Depot Inspection',
                      style: TextStyle(
                        fontSize: 11,
                        color: colors.onSurfaceVariant,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              OutlinedButton.icon(
                onPressed: onSwitchWorkOrder,
                icon: const Icon(Icons.swap_horiz_rounded, size: 16),
                label: const Text('Switch WO', style: TextStyle(fontSize: 12)),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // ----------------------------------------------------
          // Live Sync Status Banner
          // ----------------------------------------------------
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
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
                    provider.syncStatus,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: colors.brightness == Brightness.dark
                          ? Colors.green.shade300
                          : Colors.green.shade800,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  'REAL-TIME SYNC',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                    color: Colors.green.shade700,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // ----------------------------------------------------
          // Progress Bar & Percentage
          // ----------------------------------------------------
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Inspection Progress',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: colors.onSurfaceVariant,
                ),
              ),
              Text(
                '$percentInt% Completed ($full/$total)',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: colors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: colors.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation<Color>(
                no > 0 ? Colors.amber.shade700 : colors.primary,
              ),
            ),
          ),

          const SizedBox(height: 12),

          // ----------------------------------------------------
          // Metric Badges (Full, Partial, No, Quick Action)
          // ----------------------------------------------------
          Row(
            children: [
              _buildMetricChip(
                label: 'Full (Passed)',
                count: full,
                color: Colors.green,
                icon: Icons.check_circle_rounded,
              ),
              const SizedBox(width: 8),
              _buildMetricChip(
                label: 'Partial',
                count: partial,
                color: Colors.amber.shade800,
                icon: Icons.warning_rounded,
              ),
              const SizedBox(width: 8),
              _buildMetricChip(
                label: 'Defects',
                count: no,
                color: Colors.red.shade700,
                icon: Icons.cancel_rounded,
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: () {
                  _showQuickClearanceDialog(context, provider);
                },
                icon: const Icon(Icons.done_all_rounded, size: 16),
                label: const Text('Pass All', style: TextStyle(fontSize: 11)),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricChip({
    required String label,
    required int count,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 4),
          Text(
            '$count',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  void _showQuickClearanceDialog(BuildContext context, ChecklistProvider provider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle_outline, color: Colors.green),
            SizedBox(width: 8),
            Text('Quick Clearance'),
          ],
        ),
        content: const Text(
          'Mark all uninspected items as FULL (Compliant) and sync immediately to NxAMS DB?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              provider.markAllRemainingCompliant();
            },
            child: const Text('Confirm & Pass All'),
          ),
        ],
      ),
    );
  }
}
