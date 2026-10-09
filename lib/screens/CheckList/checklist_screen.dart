import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../widgets/common/custom_header.dart';
import '../../providers/checklist_provider.dart';
import '../../models/checklist_model.dart';
import '../../widgets/checklist/config_checklist_filters.dart';
import '../../widgets/checklist/config_checklist_card.dart';
import '../../widgets/checklist/checklist_forms.dart';
import 'checksheet_detail_screen.dart';

class ChecklistScreen extends StatefulWidget {
  const ChecklistScreen({super.key});

  @override
  State<ChecklistScreen> createState() => _ChecklistScreenState();
}

class _ChecklistScreenState extends State<ChecklistScreen> {
  JobPlanChecklistModel? _activeDetailChecklist;

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

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final provider = context.watch<ChecklistProvider>();

    // If viewing the detail of a checksheet, show the ChecksheetDetailScreen
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

          // Checklists List
          Expanded(
            child: provider.isLoadingConfigChecklists
                ? const Center(child: CircularProgressIndicator())
                : provider.filteredConfigChecklists.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Website banner matching: <span class="bg-warning text-center fw-bold">CheckList Details not found</span>
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFC107).withValues(alpha: 0.2), // Warning amber
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: const Color(0xFFFFC107), width: 1.5),
                                ),
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.warning_amber_rounded, color: Color(0xFFD39E00), size: 20),
                                    SizedBox(width: 8),
                                    Text(
                                      'CheckList Details not found',
                                      style: TextStyle(
                                        color: Color(0xFF856404),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No checklists match your selected filters (Category, JobPlan, Checklist, Status).',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: colors.onSurfaceVariant,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton.icon(
                                icon: const Icon(Icons.refresh, size: 16),
                                label: const Text('Reset Filters'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF00D25B), // NxAMS theme green
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                ),
                                onPressed: () => provider.resetConfigFilters(),
                              ),
                            ],
                          ),
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: () =>
                            provider.loadConfigChecklists(refresh: true),
                        child: ListView.builder(
                          padding: const EdgeInsets.only(bottom: 24, top: 4),
                          itemCount: provider.filteredConfigChecklists.length,
                          itemBuilder: (context, index) {
                            final cl = provider.filteredConfigChecklists[index];
                            return ConfigChecklistCard(
                              index: index + 1,
                              checklist: cl,
                              onOpenChecksheet: () {
                                setState(() {
                                  _activeDetailChecklist = cl;
                                });
                              },
                              onEdit: () {
                                AddEditChecklistDialog.show(context, checklist: cl);
                              },
                              onDelete: () {
                                _showDeleteChecklistDialog(context, cl, provider);
                              },
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  void _showDeleteChecklistDialog(BuildContext context,
      JobPlanChecklistModel cl, ChecklistProvider provider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Text('Delete Checklist', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text(
          'Are you sure you want to delete "${cl.jpcChecklistName}"?',
          style: const TextStyle(fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              final success = await provider.deleteChecklist(jpcId: cl.jpcId);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: success ? Colors.green.shade700 : Colors.red,
                    content: Text(success ? 'Checklist deleted successfully ✓' : 'Error deleting checklist'),
                  ),
                );
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
