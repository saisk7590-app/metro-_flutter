import 'package:flutter/material.dart';

import 'allocation_popup.dart';
import 'package:provider/provider.dart';
import '../providers/allocation_provider.dart';

class BayAllocationTable extends StatelessWidget {
  final String title;
  final String? badge;
  final bool showFilter;
  final List<String> tracks;
  final VoidCallback? onFilterPressed;
  final String depotName;
  final String sectionName;

  const BayAllocationTable({
    super.key,
    required this.title,
    this.badge,
    this.showFilter = false,
    required this.tracks,
    required this.depotName,
    required this.sectionName,
    this.onFilterPressed,
  });
  @override
  Widget build(BuildContext context) {
    final allocationProvider = context.watch<AllocationProvider>();
    return Card(
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          /// HEADER
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            color: Colors.blue.shade50,
            child: Row(
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                if (badge != null) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      badge!,
                      style: const TextStyle(color: Colors.white, fontSize: 11),
                    ),
                  ),
                ],

                const Spacer(),

                if (showFilter)
                  IconButton(
                    onPressed: onFilterPressed,
                    icon: const Icon(Icons.filter_list),
                  ),
              ],
            ),
          ),

          /// TABLE
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(Colors.grey.shade100),
              columnSpacing: 28,
              horizontalMargin: 16,

              columns: const [
                DataColumn(
                  label: Text(
                    "Bay",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                DataColumn(
                  label: Text(
                    "Inward Time",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                DataColumn(
                  label: Text(
                    "Outward Time",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                DataColumn(
                  label: Text(
                    "Actions",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],

              rows: tracks.map((track) {
                final allocation = allocationProvider.getAllocation(track);
                return DataRow(
                  cells: [
                    // Purpose (Track Name)
                    DataCell(Text(track)),

                    DataCell(Text(allocation?.inwardTime ?? "--")),

                    DataCell(Text(allocation?.outwardTime ?? "--")),

                    // Actions
                    DataCell(
                      ElevatedButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (_) => AllocationPopup(
                              depotName: depotName,
                              sectionName: sectionName,
                              trackId: track,
                            ),
                          );
                        },
                        child: const Text("Allocate"),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),

          if (tracks.isEmpty)
            const Padding(
              padding: EdgeInsets.all(20),
              child: Text(
                "No tracks available",
                style: TextStyle(color: Colors.grey),
              ),
            ),
        ],
      ),
    );
  }
}
