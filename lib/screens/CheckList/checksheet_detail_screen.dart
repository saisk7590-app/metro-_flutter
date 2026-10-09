import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/checklist_provider.dart';
import '../../models/checklist_model.dart';
import '../../widgets/checklist/checklist_group_header.dart';
import '../../widgets/checklist/checklist_item_card.dart';
import '../../widgets/checklist/checklist_forms.dart';
import '../../widgets/checklist/checksheet_header_widgets.dart';

class ChecksheetDetailScreen extends StatefulWidget {
  final JobPlanChecklistModel checklist;
  final VoidCallback onBackToList;

  const ChecksheetDetailScreen({
    super.key,
    required this.checklist,
    required this.onBackToList,
  });

  @override
  State<ChecksheetDetailScreen> createState() => _ChecksheetDetailScreenState();
}

class _ChecksheetDetailScreenState extends State<ChecksheetDetailScreen> {
  final TextEditingController _itemSearchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChecklistProvider>().selectConfigChecklist(widget.checklist);
    });
  }

  @override
  void dispose() {
    _itemSearchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final provider = context.watch<ChecklistProvider>();
    final cl = widget.checklist;

    return ColoredBox(
      color: colors.surface,
      child: Column(
        children: [
          // ----------------------------------------------------
          // Top Navigation Header (Back to List + Title + Actions)
          // ----------------------------------------------------
          ChecksheetNavHeader(
            checklist: cl,
            onBack: widget.onBackToList,
          ),

          // ----------------------------------------------------
          // Real-time Sync & Progress Status Banner
          // ----------------------------------------------------
          ChecksheetSyncBanner(
            syncStatus: provider.syncStatus,
            completedChecks: provider.fullChecks + provider.partialChecks + provider.noChecks,
            totalChecks: provider.totalChecks,
          ),

          // ----------------------------------------------------
          // Search Checks Bar
          // ----------------------------------------------------
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: TextField(
              controller: _itemSearchController,
              style: const TextStyle(fontSize: 13),
              decoration: InputDecoration(
                hintText: 'Filter checks or subsystems...',
                hintStyle: TextStyle(fontSize: 12, color: colors.outline),
                isDense: true,
                prefixIcon: const Icon(Icons.search, size: 18),
                suffixIcon: _itemSearchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 16),
                        onPressed: () {
                          _itemSearchController.clear();
                          provider.setItemSearchQuery('');
                        },
                      )
                    : null,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: colors.outlineVariant),
                ),
              ),
              onChanged: (val) => provider.setItemSearchQuery(val),
            ),
          ),

          // ----------------------------------------------------
          // Accordion Groups & Check Items
          // ----------------------------------------------------
          Expanded(
            child: provider.isLoadingChecklist
                ? const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 12),
                        Text('Loading Checksheet details from NxAMS...'),
                      ],
                    ),
                  )
                : provider.checklistGroups.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.assignment_outlined,
                                size: 48, color: colors.outline),
                            const SizedBox(height: 8),
                            Text(
                              'No check groups configured for this schedule.',
                              style: TextStyle(color: colors.outline),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.only(bottom: 24, top: 4),
                        itemCount: provider.checklistGroups.length,
                        itemBuilder: (context, gIndex) {
                          final group = provider.checklistGroups[gIndex];

                          final filteredChecks = provider.itemSearchQuery.isEmpty
                              ? group.checks
                              : group.checks.where((c) {
                                  final q = provider.itemSearchQuery.toLowerCase();
                                  return c.checkDescription.toLowerCase().contains(q) ||
                                      c.subGroup.toLowerCase().contains(q) ||
                                      group.group.toLowerCase().contains(q);
                                }).toList();

                          if (filteredChecks.isEmpty &&
                              provider.itemSearchQuery.isNotEmpty) {
                            return const SizedBox.shrink();
                          }

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ChecklistGroupHeader(
                                group: group,
                                onToggle: () => provider.toggleGroupExpand(group),
                                onAddItem: () {
                                  AddChecklistGroupItemDialog.show(
                                    context,
                                    checklistName: cl.jpcChecklistName,
                                    groupName: group.group,
                                    groupId: group.groupId,
                                  );
                                },
                                onEditGroup: () {
                                  EditChecklistGroupDialog.show(
                                    context,
                                    group: group,
                                  );
                                },
                              ),
                              if (group.expand)
                                ...filteredChecks.map((checkItem) {
                                  return ChecklistItemCard(
                                    item: checkItem,
                                    groupName: group.group,
                                    onEdit: () {
                                      EditChecklistGroupItemDialog.show(
                                        context,
                                        groupId: group.groupId,
                                        groupName: group.group,
                                        item: checkItem,
                                      );
                                    },
                                    onDelete: () async {
                                      final confirm = await showDialog<bool>(
                                        context: context,
                                        builder: (ctx) => AlertDialog(
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                          title: const Text('Delete Check Item', style: TextStyle(fontWeight: FontWeight.bold)),
                                          content: Text('Delete check item "${checkItem.checkDescription}" from ${group.group}?'),
                                          actions: [
                                            TextButton(
                                              onPressed: () => Navigator.pop(ctx, false),
                                              child: const Text('Cancel'),
                                            ),
                                            ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.red,
                                                foregroundColor: Colors.white,
                                              ),
                                              onPressed: () => Navigator.pop(ctx, true),
                                              child: const Text('Delete'),
                                            ),
                                          ],
                                        ),
                                      );
                                      if (confirm == true) {
                                        await provider.deleteChecklistGroupItem(
                                          groupId: group.groupId,
                                          checkItemId: checkItem.id,
                                        );
                                      }
                                    },
                                  );
                                }),
                            ],
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
