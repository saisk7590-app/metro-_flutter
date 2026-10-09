import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/checklist_model.dart';
import '../../providers/checklist_provider.dart';
import 'checklist_item_controls.dart';

class ChecklistItemCard extends StatefulWidget {
  final CheckItemModel item;
  final String groupName;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const ChecklistItemCard({
    super.key,
    required this.item,
    required this.groupName,
    this.onEdit,
    this.onDelete,
  });

  @override
  State<ChecklistItemCard> createState() => _ChecklistItemCardState();
}

class _ChecklistItemCardState extends State<ChecklistItemCard> {
  late TextEditingController _remarksController;
  bool _isEditingRemarks = false;

  @override
  void initState() {
    super.initState();
    _remarksController = TextEditingController(text: widget.item.remarks);
  }

  @override
  void didUpdateWidget(covariant ChecklistItemCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.item.remarks != widget.item.remarks && !_isEditingRemarks) {
      _remarksController.text = widget.item.remarks;
    }
  }

  @override
  void dispose() {
    _remarksController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final provider = context.read<ChecklistProvider>();
    final item = widget.item;

    final isDefect = item.compliance == 0;
    final isPartial = item.compliance == 1;

    Color cardBorderColor = colors.outlineVariant.withValues(alpha: 0.5);
    if (isDefect) {
      cardBorderColor = Colors.red.shade400;
    } else if (isPartial) {
      cardBorderColor = Colors.amber.shade600;
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: cardBorderColor,
          width: isDefect ? 1.5 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: SubGroup Tag (editable) + Item ID + Sync Status + Edit + Delete
            Row(
              children: [
                InkWell(
                  onTap: widget.onEdit,
                  borderRadius: BorderRadius.circular(6),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: colors.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: colors.primary.withValues(alpha: 0.35),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          item.subGroup.isNotEmpty ? item.subGroup : 'General',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: colors.primary,
                          ),
                        ),
                        if (widget.onEdit != null) ...[
                          const SizedBox(width: 4),
                          Icon(Icons.edit_outlined, size: 11, color: colors.primary),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '#${item.id}',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: colors.primary,
                  ),
                ),
                const Spacer(),
                // Real-time sync indicator
                if (item.isSyncing) ...[
                  const SizedBox(
                    width: 12,
                    height: 12,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    'Syncing...',
                    style: TextStyle(fontSize: 11, color: colors.outline),
                  ),
                ] else if (item.isSynced) ...[
                  const Icon(Icons.check_circle_rounded, size: 14, color: Colors.green),
                  const SizedBox(width: 4),
                  const Text(
                    'Synced ✓',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
                if (widget.onEdit != null) ...[
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: widget.onEdit,
                    borderRadius: BorderRadius.circular(4),
                    child: Padding(
                      padding: const EdgeInsets.all(2),
                      child: Icon(Icons.edit_outlined, size: 16, color: colors.primary),
                    ),
                  ),
                ],
                if (widget.onDelete != null) ...[
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: widget.onDelete,
                    borderRadius: BorderRadius.circular(4),
                    child: Padding(
                      padding: const EdgeInsets.all(2),
                      child: Icon(Icons.delete_outline, size: 16, color: Colors.red.shade400),
                    ),
                  ),
                ],
              ],
            ),

            const SizedBox(height: 10),

            // Check Description (editable via tap or icon)
            InkWell(
              onTap: widget.onEdit,
              borderRadius: BorderRadius.circular(4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      item.checkDescription,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: colors.onSurface,
                        height: 1.3,
                      ),
                    ),
                  ),
                  if (widget.onEdit != null) ...[
                    const SizedBox(width: 6),
                    Icon(Icons.edit_outlined, size: 14, color: colors.outline),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Touch-Friendly Segmented Compliance Selector
            CheckItemComplianceSelector(
              item: item,
              provider: provider,
            ),

            // Defect Warning Banner (If Non-Compliant)
            if (isDefect) ...[
              const SizedBox(height: 10),
              CheckItemDefectBanner(item: item),
            ],

            const SizedBox(height: 10),

            // Remarks Input (Max 128 characters) + Quick Presets
            CheckItemRemarksField(
              item: item,
              controller: _remarksController,
              provider: provider,
              onEditingChanged: (isEditing) {
                _isEditingRemarks = isEditing;
              },
            ),
          ],
        ),
      ),
    );
  }
}
