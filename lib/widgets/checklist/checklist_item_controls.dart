import 'package:flutter/material.dart';
import '../../models/checklist_model.dart';
import '../../providers/checklist_provider.dart';

/// Touch-Friendly Segmented Compliance Selector (No/Defect, Partial, Full/Pass)
class CheckItemComplianceSelector extends StatelessWidget {
  final CheckItemModel item;
  final ChecklistProvider provider;

  const CheckItemComplianceSelector({
    super.key,
    required this.item,
    required this.provider,
  });

  @override
  Widget build(BuildContext context) {
    final isDefect = item.compliance == 0;
    final isPartial = item.compliance == 1;
    final isFull = item.compliance == 2;

    return Row(
      children: [
        Expanded(
          child: _buildOption(
            title: 'No (Defect)',
            icon: Icons.cancel_outlined,
            selectedIcon: Icons.cancel,
            selectedColor: Colors.red.shade700,
            isSelected: isDefect,
            onTap: () => provider.updateCompliance(item, 0),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildOption(
            title: 'Partial',
            icon: Icons.warning_amber_rounded,
            selectedIcon: Icons.warning_rounded,
            selectedColor: Colors.amber.shade900,
            isSelected: isPartial,
            onTap: () => provider.updateCompliance(item, 1),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildOption(
            title: 'Full (Pass)',
            icon: Icons.check_circle_outline,
            selectedIcon: Icons.check_circle,
            selectedColor: Colors.green.shade700,
            isSelected: isFull,
            onTap: () => provider.updateCompliance(item, 2),
          ),
        ),
      ],
    );
  }

  Widget _buildOption({
    required String title,
    required IconData icon,
    required IconData selectedIcon,
    required Color selectedColor,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 6),
        decoration: BoxDecoration(
          color: isSelected ? selectedColor : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? selectedColor : Colors.grey.shade300,
            width: isSelected ? 1.5 : 1.0,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: selectedColor.withValues(alpha: 0.3),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSelected ? selectedIcon : icon,
              size: 16,
              color: isSelected ? Colors.white : Colors.grey.shade600,
            ),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                  color: isSelected ? Colors.white : Colors.grey.shade700,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Defect Warning Banner shown when compliance is No (0)
class CheckItemDefectBanner extends StatelessWidget {
  final CheckItemModel item;

  const CheckItemDefectBanner({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.report_problem_rounded, size: 16, color: Colors.red),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'Defect flagged for live supervisor review.',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
          ),
          TextButton(
            onPressed: () => _showLogCorrectiveDialog(context),
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text(
              'Raise Corrective WO',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  void _showLogCorrectiveDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.assignment_late_outlined, color: Colors.red),
            SizedBox(width: 8),
            Text('Raise Corrective WO'),
          ],
        ),
        content: Text(
          'Flag #${item.id} (${item.subGroup}) as a Corrective Work Order in NxAMS database?\n\n'
          'Item: "${item.checkDescription}"',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Corrective Work Order flagged & synced to NxAMS! ✓'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            child: const Text('Flag Defect WO', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

/// Remarks Input Field with Clear button & Quick Presets chips
class CheckItemRemarksField extends StatelessWidget {
  final CheckItemModel item;
  final TextEditingController controller;
  final ChecklistProvider provider;
  final ValueChanged<bool> onEditingChanged;

  const CheckItemRemarksField({
    super.key,
    required this.item,
    required this.controller,
    required this.provider,
    required this.onEditingChanged,
  });

  static const List<String> presets = [
    'Clean & Intact',
    'Torqued to Spec',
    'Lubricated',
    'Replaced / Fitted',
    'Defect Reported',
  ];

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: controller,
          maxLength: 128,
          style: const TextStyle(fontSize: 13),
          decoration: InputDecoration(
            hintText: 'Technician remarks (e.g., Clean & intact, torqued)...',
            hintStyle: TextStyle(fontSize: 12, color: colors.outline),
            isDense: true,
            counterText: '',
            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            prefixIcon: const Icon(Icons.comment_outlined, size: 16),
            suffixIcon: controller.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear, size: 16),
                    onPressed: () {
                      controller.clear();
                      provider.updateRemarks(item, '');
                    },
                  )
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: colors.outlineVariant),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: colors.outlineVariant.withValues(alpha: 0.7)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: colors.primary, width: 1.5),
            ),
          ),
          onChanged: (val) {
            onEditingChanged(true);
            provider.updateRemarks(item, val);
          },
          onSubmitted: (_) {
            onEditingChanged(false);
          },
        ),
        const SizedBox(height: 6),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: presets.map((text) {
              return Padding(
                padding: const EdgeInsets.only(right: 6),
                child: InkWell(
                  onTap: () {
                    controller.text = text;
                    provider.updateRemarks(item, text);
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: colors.surfaceContainerHighest.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.4)),
                    ),
                    child: Text(
                      '+ $text',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
