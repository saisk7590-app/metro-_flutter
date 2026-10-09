import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/checklist_provider.dart';
import '../../models/checklist_model.dart';

class WorkOrderSelectionSheet extends StatelessWidget {
  const WorkOrderSelectionSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ChecklistProvider>();
    final colors = Theme.of(context).colorScheme;

    return Material(
      color: colors.surface,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.75,
        child: Padding(
          padding: const EdgeInsets.only(top: 16),
          child: Column(
            children: [
              // Drag handle
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: colors.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    const Icon(Icons.assignment_outlined, size: 22),
                    const SizedBox(width: 8),
                    const Text(
                      'Select Work Order / Trainset',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              const Divider(),
              // Filter chips
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: ['All', 'In Progress', 'Assigned', 'Completed'].map((filter) {
                      final isSelected = provider.workOrderFilter == filter;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(filter),
                          selected: isSelected,
                          onSelected: (_) => provider.setWorkOrderFilter(filter),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              Expanded(
                child: provider.filteredWorkOrders.isEmpty
                    ? Center(
                        child: Text(
                          'No work orders found.',
                          style: TextStyle(color: colors.outline),
                        ),
                      )
                    : ListView.builder(
                        itemCount: provider.filteredWorkOrders.length,
                        itemBuilder: (context, index) {
                          final wo = provider.filteredWorkOrders[index];
                          final isSelected = provider.selectedWorkOrder?.id == wo.id;
                          return Material(
                            color: Colors.transparent,
                            child: ListTile(
                              leading: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: isSelected ? colors.primary : colors.surfaceContainerHighest,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  wo.assetDetails,
                                  style: TextStyle(
                                    color: isSelected ? Colors.white : colors.onSurface,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              title: Text(
                                wo.no,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: isSelected ? colors.primary : null,
                                ),
                              ),
                              subtitle: Text(
                                '${wo.schedule} • ${wo.location}',
                                style: const TextStyle(fontSize: 12),
                              ),
                              trailing: isSelected
                                  ? const Icon(Icons.check_circle, color: Colors.green)
                                  : const Icon(Icons.chevron_right),
                              onTap: () {
                                provider.selectWorkOrder(wo);
                                Navigator.pop(context);
                              },
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
