import 'package:flutter/material.dart';
import '../../models/checklist/checklist_model.dart';

/// Web-style Data Table matching NxAMS `app-table` for Configuration Maintenance Checklists
class ConfigChecklistTable extends StatelessWidget {
  final List<JobPlanChecklistModel> checklists;
  final int startIndex;
  final void Function(JobPlanChecklistModel) onOpenChecksheet;
  final void Function(JobPlanChecklistModel) onEdit;
  final void Function(JobPlanChecklistModel) onDelete;

  const ConfigChecklistTable({
    super.key,
    required this.checklists,
    required this.startIndex,
    required this.onOpenChecksheet,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return LayoutBuilder(
      builder: (context, constraints) {
        const double minTableWidth = 920;
        final tableWidth = constraints.maxWidth > minTableWidth ? constraints.maxWidth : minTableWidth;

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: tableWidth,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ----------------------------------------------------
                // Table Header (Matching NxAMS Web table headers)
                // ----------------------------------------------------
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 14),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: isDark ? colors.surfaceContainerHighest : const Color(0xFFF1F5F9),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(10),
                      topRight: Radius.circular(10),
                    ),
                    border: Border.all(
                      color: colors.outlineVariant.withValues(alpha: 0.7),
                    ),
                  ),
                  child: Row(
                    children: [
                      _buildHeaderCell('#', width: 45, align: TextAlign.center),
                      _buildHeaderCell('Checklist Name', flex: 3),
                      _buildHeaderCell('Category', flex: 1),
                      _buildHeaderCell('JobPlan Name', flex: 2),
                      _buildHeaderCell('Schedule Name', flex: 2),
                      _buildHeaderCell('Status', width: 90, align: TextAlign.center),
                      _buildHeaderCell('Actions', width: 130, align: TextAlign.center),
                    ],
                  ),
                ),

                // ----------------------------------------------------
                // Table Body Rows
                // ----------------------------------------------------
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    itemCount: checklists.length,
                    itemBuilder: (context, index) {
                      final cl = checklists[index];
                      final rowNumber = startIndex + index + 1;
                      final isEven = index % 2 == 0;
                      final rowColor = isEven
                          ? (isDark ? colors.surface : Colors.white)
                          : (isDark ? colors.surfaceContainer : const Color(0xFFF8FAFC));

                      return Container(
                        decoration: BoxDecoration(
                          color: rowColor,
                          border: Border(
                            left: BorderSide(color: colors.outlineVariant.withValues(alpha: 0.7)),
                            right: BorderSide(color: colors.outlineVariant.withValues(alpha: 0.7)),
                            bottom: BorderSide(color: colors.outlineVariant.withValues(alpha: 0.5)),
                          ),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => onOpenChecksheet(cl),
                            hoverColor: colors.primary.withValues(alpha: 0.05),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              child: Row(
                                children: [
                                  // 1. Row Index (#)
                                  SizedBox(
                                    width: 45,
                                    child: Center(
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: colors.primary.withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          '$rowNumber',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color: colors.primary,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),

                                  // 2. Checklist Name (Link style matching web)
                                  Expanded(
                                    flex: 3,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 8),
                                      child: InkWell(
                                        onTap: () => onOpenChecksheet(cl),
                                        borderRadius: BorderRadius.circular(4),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Flexible(
                                              child: Text(
                                                cl.jpcChecklistName,
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w600,
                                                  color: isDark ? Colors.lightBlue.shade300 : const Color(0xFF0066CC),
                                                  decoration: TextDecoration.underline,
                                                  decorationColor: isDark ? Colors.lightBlue.shade400 : Colors.blue.shade300,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            const SizedBox(width: 4),
                                            Icon(
                                              Icons.open_in_new,
                                              size: 12,
                                              color: isDark ? Colors.lightBlue.shade300 : const Color(0xFF0066CC),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),

                                  // 3. Asset Category Code
                                  Expanded(
                                    flex: 1,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 8),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                                            decoration: BoxDecoration(
                                              color: colors.surfaceContainerHighest,
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              cl.assetCategoryCode,
                                              style: TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w600,
                                                color: colors.onSurfaceVariant,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),

                                  // 4. JobPlan Name
                                  Expanded(
                                    flex: 2,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 8),
                                      child: Text(
                                        cl.jobplanName.isEmpty ? '—' : cl.jobplanName,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: colors.onSurface,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ),

                                  // 5. Schedule Name
                                  Expanded(
                                    flex: 2,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 8),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.event_repeat_rounded, size: 13, color: Colors.blue.shade700),
                                          const SizedBox(width: 4),
                                          Flexible(
                                            child: Text(
                                              cl.scheduleName.isEmpty ? '—' : cl.scheduleName,
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500,
                                                color: Colors.blue.shade800,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),

                                  // 6. Status Badge
                                  SizedBox(
                                    width: 90,
                                    child: Center(
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: cl.isActive
                                              ? Colors.green.withValues(alpha: 0.12)
                                              : Colors.grey.withValues(alpha: 0.12),
                                          borderRadius: BorderRadius.circular(6),
                                          border: Border.all(
                                            color: cl.isActive
                                                ? Colors.green.withValues(alpha: 0.4)
                                                : Colors.grey.withValues(alpha: 0.4),
                                          ),
                                        ),
                                        child: Text(
                                          cl.isActive ? 'Active' : 'Inactive',
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: cl.isActive ? Colors.green.shade800 : Colors.grey.shade700,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),

                                  // 7. Actions (Inspect, Edit, Delete)
                                  SizedBox(
                                    width: 130,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        // Inspect Checksheet
                                        IconButton(
                                          icon: const Icon(Icons.fact_check_outlined, size: 18),
                                          tooltip: 'Inspect / View Checksheet',
                                          color: colors.primary,
                                          visualDensity: VisualDensity.compact,
                                          onPressed: () => onOpenChecksheet(cl),
                                        ),
                                        // Edit Checklist
                                        IconButton(
                                          icon: const Icon(Icons.edit_outlined, size: 18),
                                          tooltip: 'Edit Checklist',
                                          color: Colors.blue.shade700,
                                          visualDensity: VisualDensity.compact,
                                          onPressed: () => onEdit(cl),
                                        ),
                                        // Delete Checklist
                                        IconButton(
                                          icon: const Icon(Icons.delete_outline, size: 18),
                                          tooltip: 'Delete Checklist',
                                          color: Colors.red.shade700,
                                          visualDensity: VisualDensity.compact,
                                          onPressed: () => onDelete(cl),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeaderCell(String title, {int flex = 1, double? width, TextAlign align = TextAlign.left}) {
    final cell = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Text(
        title,
        textAlign: align,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Color(0xFF334155),
        ),
      ),
    );

    if (width != null) {
      return SizedBox(width: width, child: cell);
    }
    return Expanded(flex: flex, child: cell);
  }
}
