import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../widgets/common/custom_header.dart';
import '../../providers/checklist/checklist_provider.dart';
import '../../widgets/checklist/work_order_card.dart';
import '../../widgets/meter/pagination_bar.dart';

class WorkOrdersScreen extends StatefulWidget {
  final VoidCallback? onSwitchToChecklist;

  const WorkOrdersScreen({
    super.key,
    this.onSwitchToChecklist,
  });

  @override
  State<WorkOrdersScreen> createState() => _WorkOrdersScreenState();
}

class _WorkOrdersScreenState extends State<WorkOrdersScreen> {
  final TextEditingController _searchController = TextEditingController();

  int _currentPage = 1;
  int _itemsPerPage = 10;
  String _lastFilterKey = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<ChecklistProvider>();
      if (provider.workOrders.isEmpty) {
        provider.loadWorkOrders();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final provider = context.watch<ChecklistProvider>();

    // Reset pagination to page 1 if filter criteria changes
    final currentFilterKey = '${provider.workOrderFilter}_${provider.searchQuery}';
    if (_lastFilterKey != currentFilterKey) {
      _lastFilterKey = currentFilterKey;
      _currentPage = 1;
    }

    final allOrders = provider.filteredWorkOrders;
    final totalItems = allOrders.length;
    final totalPages = (totalItems / _itemsPerPage).ceil().clamp(1, 999999);
    if (_currentPage > totalPages) {
      _currentPage = totalPages;
    }
    if (_currentPage < 1) {
      _currentPage = 1;
    }

    final startIndex = (_currentPage - 1) * _itemsPerPage;
    final visibleWorkOrders = allOrders.skip(startIndex).take(_itemsPerPage).toList();

    return ColoredBox(
      color: colors.surface,
      child: Column(
        children: [
          CustomHeader(
            title: "DEPOT WORK ORDERS",
            subtitle: "Assigned Inspection Orders",
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh_rounded),
                tooltip: 'Refresh Work Orders',
                onPressed: () => provider.loadWorkOrders(refresh: true),
              ),
            ],
          ),

          // Search Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(fontSize: 13),
              decoration: InputDecoration(
                hintText: 'Search by Trainset (e.g., TS-01), WO#, or type...',
                hintStyle: TextStyle(fontSize: 12, color: colors.outline),
                prefixIcon: const Icon(Icons.search, size: 18),
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 16),
                        onPressed: () {
                          _searchController.clear();
                          provider.setSearchQuery('');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: colors.outlineVariant),
                ),
              ),
              onChanged: (val) {
                provider.setSearchQuery(val);
              },
            ),
          ),

          // Filter Chips
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

          // Work Orders List
          Expanded(
            child: provider.isLoadingWorkOrders
                ? const Center(child: CircularProgressIndicator())
                : allOrders.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.assignment_late_outlined,
                                size: 48, color: colors.outline),
                            const SizedBox(height: 8),
                            Text(
                              'No work orders match the filter.',
                              style: TextStyle(color: colors.outline),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: () => provider.loadWorkOrders(refresh: true),
                        child: ListView.builder(
                          padding: const EdgeInsets.only(bottom: 24, top: 4),
                          itemCount: visibleWorkOrders.length,
                          itemBuilder: (context, index) {
                            final wo = visibleWorkOrders[index];
                            final isSelected =
                                provider.selectedWorkOrder?.id == wo.id;
                            return WorkOrderCard(
                              workOrder: wo,
                              isSelected: isSelected,
                              onTap: () async {
                                await provider.selectWorkOrder(wo);
                                if (widget.onSwitchToChecklist != null) {
                                  widget.onSwitchToChecklist!();
                                }
                              },
                            );
                          },
                        ),
                      ),
          ),

          // Web-Style Pagination Bar
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
