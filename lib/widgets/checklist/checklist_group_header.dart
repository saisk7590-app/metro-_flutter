import 'package:flutter/material.dart';
import '../../models/checklist_model.dart';

class ChecklistGroupHeader extends StatelessWidget {
  final CheckGroupModel group;
  final VoidCallback onToggle;
  final VoidCallback? onAddItem;
  final VoidCallback? onEditGroup;

  const ChecklistGroupHeader({
    super.key,
    required this.group,
    required this.onToggle,
    this.onAddItem,
    this.onEditGroup,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final total = group.totalCount;
    final full = group.fullCount;
    final partial = group.partialCount;
    final no = group.noCount;
    final completed = full + partial + no;
    final isAllPassed = full == total && total > 0;
    final hasDefect = no > 0;

    return InkWell(
      onTap: onToggle,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: colors.surfaceContainerHighest.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: hasDefect
                ? Colors.red.withValues(alpha: 0.5)
                : colors.outlineVariant.withValues(alpha: 0.5),
          ),
        ),
        child: Row(
          children: [
            Icon(
              group.expand
                  ? Icons.keyboard_arrow_down_rounded
                  : Icons.keyboard_arrow_right_rounded,
              color: colors.primary,
              size: 24,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InkWell(
                    onTap: onEditGroup,
                    borderRadius: BorderRadius.circular(4),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            child: Text(
                              group.group,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).brightness == Brightness.dark
                                    ? Colors.lightBlue.shade300
                                    : const Color(0xFF0066CC),
                                decoration: TextDecoration.underline,
                                decorationColor: Theme.of(context).brightness == Brightness.dark
                                    ? Colors.lightBlue.shade400
                                    : Colors.blue.shade300,
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.edit_outlined,
                            size: 13,
                            color: Theme.of(context).brightness == Brightness.dark
                                ? Colors.lightBlue.shade300
                                : const Color(0xFF0066CC),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$completed of $total checks inspected',
                    style: TextStyle(
                      fontSize: 11,
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            if (hasDefect) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.red.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.report_problem, size: 12, color: Colors.red.shade800),
                    const SizedBox(width: 4),
                    Text(
                      '$no Defect${no > 1 ? 's' : ''}',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.red.shade900,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
            ],
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: isAllPassed
                    ? Colors.green.withValues(alpha: 0.15)
                    : colors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                isAllPassed ? 'Passed ✓' : '$completed/$total',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: isAllPassed ? Colors.green.shade800 : colors.primary,
                ),
              ),
            ),
            if (onAddItem != null) ...[
              const SizedBox(width: 8),
              InkWell(
                onTap: onAddItem,
                borderRadius: BorderRadius.circular(6),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00D25B).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: const Color(0xFF00D25B).withValues(alpha: 0.5)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.add, size: 13, color: Color(0xFF00D25B)),
                      SizedBox(width: 2),
                      Text(
                        'Item',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF00D25B),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
