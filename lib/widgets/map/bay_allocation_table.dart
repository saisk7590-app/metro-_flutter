import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/maintenance_bay_model.dart';
import '../../providers/allocation_provider.dart';
import '../../widgets/popups/allocation_popup.dart';
import '../../widgets/popups/ams_update_popup.dart';

class BayAllocationTable extends StatelessWidget {
  final String title;
  final String? badge;
  final bool showFilter;
  final List<String> tracks;
  final List<MaintenanceBayModel>? allocations;
  final bool isLoading;
  final String error;
  final VoidCallback? onFilterPressed;
  final String depotName;
  final String sectionName;

  const BayAllocationTable({
    super.key,
    required this.title,
    this.badge,
    this.showFilter = false,
    required this.tracks,
    this.allocations,
    this.isLoading = false,
    this.error = '',
    required this.depotName,
    required this.sectionName,
    this.onFilterPressed,
  });

  @override
  Widget build(BuildContext context) {
    final localAllocations = context.watch<AllocationProvider>();
    final apiRows = allocations ?? const <MaintenanceBayModel>[];

    return Card(
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (badge != null) Text(badge!),
                if (showFilter)
                  IconButton(
                    onPressed: onFilterPressed,
                    icon: const Icon(Icons.filter_list),
                  ),
              ],
            ),
          ),
          if (isLoading)
            const Padding(
              padding: EdgeInsets.all(24),
              child: CircularProgressIndicator(),
            )
          else if (error.isNotEmpty)
            Padding(padding: const EdgeInsets.all(24), child: Text(error))
          else if (allocations != null)
            _buildApiTable(context, apiRows)
          else
            _buildLocalTable(context, localAllocations),
        ],
      ),
    );
  }

  Widget _buildApiTable(BuildContext context, List<MaintenanceBayModel> rows) {
    if (rows.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(24),
        child: Text('No allocation data available.'),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: const [
          DataColumn(label: Text('Bay')),
          DataColumn(label: Text('Trainset')),
          DataColumn(label: Text('Status')),
          DataColumn(label: Text('Purpose')),
          DataColumn(label: Text('Inward')),
          DataColumn(label: Text('Outward')),
          DataColumn(label: Text('Remarks')),
          DataColumn(label: Text('Action')),
        ],
        rows: rows.map((row) {
          final isAllocated = row.isAllocated;
          return DataRow(
            cells: [
              DataCell(
                Text(
                  row.slotName.isEmpty ? '—' : row.slotName,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              DataCell(
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isAllocated) ...[
                      const Icon(Icons.train, size: 16, color: Colors.green),
                      const SizedBox(width: 4),
                    ],
                    Text(
                      row.trainSetName.isNotEmpty
                          ? row.trainSetName
                          : (row.trainSetId > 0 ? 'TS-${row.trainSetId}' : '—'),
                      style: TextStyle(
                        fontWeight: isAllocated ? FontWeight.bold : FontWeight.normal,
                        color: isAllocated ? Colors.green.shade800 : Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              DataCell(Text(row.statusName.isEmpty ? '—' : row.statusName)),
              DataCell(Text(row.purposeName.isEmpty ? '—' : row.purposeName)),
              DataCell(Text(row.inward.isEmpty ? '—' : row.inward)),
              DataCell(Text(row.outward.isEmpty ? '—' : row.outward)),
              DataCell(Text(row.remark.isEmpty ? '—' : row.remark)),
              DataCell(
                FilledButton.tonal(
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    visualDensity: VisualDensity.compact,
                  ),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (_) => AMSUpdatePopup(
                        initialDepot: depotName,
                        initialTrack: row.slotName,
                      ),
                    );
                  },
                  child: const Text('Edit', style: TextStyle(fontSize: 12)),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildLocalTable(BuildContext context, AllocationProvider provider) {
    if (tracks.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(20),
        child: Text('No tracks available'),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: const [
          DataColumn(label: Text('Bay')),
          DataColumn(label: Text('Inward')),
          DataColumn(label: Text('Outward')),
          DataColumn(label: Text('Actions')),
        ],
        rows: tracks.map((track) {
          final allocation = provider.getAllocation(track);
          return DataRow(
            cells: [
              DataCell(Text(track)),
              DataCell(Text(allocation?.inwardTime ?? '—')),
              DataCell(Text(allocation?.outwardTime ?? '—')),
              DataCell(
                FilledButton(
                  onPressed: () => showDialog(
                    context: context,
                    builder: (_) => AllocationPopup(
                      depotName: depotName,
                      sectionName: sectionName,
                      trackId: track,
                    ),
                  ),
                  child: const Text('Allocate'),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}
