import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../widgets/common/custom_header.dart';
import '../../providers/checklist/checklist_provider.dart';
import '../../models/checklist/checklist_model.dart';
import '../../widgets/checklist/config_checklist_filters.dart';
import '../../widgets/checklist/config_checklist_card.dart';
import '../../widgets/checklist/config_checklist_table.dart';
import '../../widgets/checklist/checklist_empty_state.dart';
import '../../widgets/checklist/delete_checklist_dialog.dart';
import '../../widgets/checklist/checklist_forms.dart';
import '../../widgets/meter/pagination_bar.dart';
import 'checksheet_detail_screen.dart';

class ChecklistScreen extends StatefulWidget {
  const ChecklistScreen({super.key});

  @override
  State<ChecklistScreen> createState() => _ChecklistScreenState();
}

class _ChecklistScreenState extends State<ChecklistScreen> {
  JobPlanChecklistModel? _activeDetailChecklist;

  int _currentPage = 1;
  int _itemsPerPage = 10;
  bool? _isTableView;
  String _lastFilterKey = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<ChecklistProvider>();
      provider.loadFilterOptions();
      if (provider.configChecklists.isEmpty) {
        provider.loadConfigChecklists();
      }
    });
  }

  Future<void> _handleDelete(
    BuildContext context,
    JobPlanChecklistModel cl,
    ChecklistProvider provider,
  ) async {
    final confirmed = await showDeleteChecklistDialog(
      context,
      checklistName: cl.jpcChecklistName,
    );
    if (confirmed == true && context.mounted) {
      final success = await provider.deleteChecklist(jpcId: cl.jpcId);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: success ? Colors.green.shade700 : Colors.red,
            content: Text(
              success
                  ? 'Checklist deleted successfully ✓'
                  : 'Error deleting checklist',
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final provider = context.watch<ChecklistProvider>();

    if (_activeDetailChecklist != null) {
      return ChecksheetDetailScreen(
        checklist: _activeDetailChecklist!,
        onBackToList: () {
          setState(() {
            _activeDetailChecklist = null;
          });
        },
      );
    }

    // Reset pagination to page 1 if filter criteria changes
    final currentFilterKey =
        '${provider.selectedCategory}_${provider.selectedJobPlan}_${provider.selectedChecklistName}_${provider.selectedStatus}_${provider.configSearchQuery}';
    if (_lastFilterKey != currentFilterKey) {
      _lastFilterKey = currentFilterKey;
      _currentPage = 1;
    }

    // Pagination calculations matching web MatPaginator
    final allChecklists = provider.filteredConfigChecklists;
    final totalItems = allChecklists.length;
    final totalPages = (totalItems / _itemsPerPage).ceil().clamp(1, 999999);
    if (_currentPage > totalPages) _currentPage = totalPages;
    if (_currentPage < 1) _currentPage = 1;

    final startIndex = (_currentPage - 1) * _itemsPerPage;
    final visibleChecklists =
        allChecklists.skip(startIndex).take(_itemsPerPage).toList();

    final screenWidth = MediaQuery.of(context).size.width;
    final bool showTableView = _isTableView ?? (screenWidth >= 768);

    return ColoredBox(
      color: colors.surface,
      child: Column(
        children: [
          // Header matching website: CONFIG MAINTENANCE > Checklists
          CustomHeader(
            title: "CONFIG MAINTENANCE",
            subtitle: "Checklists & Checksheets Master",
            actions: [
              IconButton(
                icon: Icon(
                  showTableView
                      ? Icons.view_agenda_outlined
                      : Icons.table_chart_outlined,
                ),
                tooltip: showTableView
                    ? 'Switch to Cards View'
                    : 'Switch to Table View (Web style)',
                onPressed: () {
                  setState(() {
                    _isTableView = !showTableView;
                  });
                },
              ),
              IconButton(
                icon: const Icon(Icons.refresh_rounded),
                tooltip: 'Refresh Checklists',
                onPressed: () => provider.loadConfigChecklists(refresh: true),
              ),
              IconButton(
                icon: const Icon(Icons.add_rounded),
                tooltip: 'New Checklist',
                onPressed: () => AddEditChecklistDialog.show(context),
              ),
            ],
          ),

          // Filters matching website: Category, JobPlan, Status, Search, Reset
          const ConfigChecklistFilters(),

          // Checklists List / Table
          Expanded(
            child: provider.isLoadingConfigChecklists
                ? const Center(child: CircularProgressIndicator())
                : allChecklists.isEmpty
                    ? ChecklistEmptyState(
                        onResetFilters: () => provider.resetConfigFilters(),
                      )
                    : showTableView
                        ? ConfigChecklistTable(
                            checklists: visibleChecklists,
                            startIndex: startIndex,
                            onOpenChecksheet: (cl) {
                              setState(() {
                                _activeDetailChecklist = cl;
                              });
                            },
                            onEdit: (cl) {
                              AddEditChecklistDialog.show(
                                context,
                                checklist: cl,
                              );
                            },
                            onDelete: (cl) =>
                                _handleDelete(context, cl, provider),
                          )
                        : RefreshIndicator(
                            onRefresh: () =>
                                provider.loadConfigChecklists(refresh: true),
                            child: ListView.builder(
                              padding: const EdgeInsets.only(bottom: 24, top: 4),
                              itemCount: visibleChecklists.length,
                              itemBuilder: (context, index) {
                                final cl = visibleChecklists[index];
                                return ConfigChecklistCard(
                                  index: startIndex + index + 1,
                                  checklist: cl,
                                  onOpenChecksheet: () {
                                    setState(() {
                                      _activeDetailChecklist = cl;
                                    });
                                  },
                                  onEdit: () {
                                    AddEditChecklistDialog.show(
                                      context,
                                      checklist: cl,
                                    );
                                  },
                                  onDelete: () =>
                                      _handleDelete(context, cl, provider),
                                );
                              },
                            ),
                          ),
          ),

          // Web-Style Pagination Bar (MatPaginator equivalent)
          if (totalItems > 0)
            PaginationBar(
              currentPage: _currentPage,
              totalItems: totalItems,
              itemsPerPage: _itemsPerPage,
              onItemsChanged: (value) {
                setState(() {
                  _itemsPerPage = value;
                  _currentPage = 1;
                });
              },
              onFirst: _currentPage <= 1
                  ? null
                  : () {
                      setState(() {
                        _currentPage = 1;
                      });
                    },
              onPrevious: _currentPage <= 1
                  ? null
                  : () {
                      setState(() {
                        _currentPage--;
                      });
                    },
              onNext: _currentPage >= totalPages
                  ? null
                  : () {
                      setState(() {
                        _currentPage++;
                      });
                    },
              onLast: _currentPage >= totalPages
                  ? null
                  : () {
                      setState(() {
                        _currentPage = totalPages;
                      });
                    },
            ),
        ],
      ),
    );
  }
}
