import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../constants/map_data.dart';
import '../../providers/active_trains_provider.dart';
import '../popups/assign_train_popup.dart';
import 'train_details_popup.dart';

class TrackMarkers extends StatelessWidget {
  final String depot;

  const TrackMarkers({super.key, required this.depot});

  @override
  Widget build(BuildContext context) {
    if (depot.isEmpty) {
      return const SizedBox.shrink();
    }

    final depotCode = depot == 'Miyapur' ? 'MP' : 'UP';
    final activeTrainsProvider = context.watch<ActiveTrainsProvider>();

    return Stack(
      children: MapData.trackBounds.entries
          .where((entry) {
            return entry.key.startsWith(depotCode);
          })
          .map((entry) {
            final trackId = entry.key;
            final bounds = entry.value;

            final parts = trackId.substring(2).split('-');

            if (parts.length < 2) {
              return const SizedBox.shrink();
            }

            final section = parts[0];
            final trackNumber = parts[1];

            final assignment = activeTrainsProvider.getTrainAtSlot(trackId);

            return Positioned(
              left: bounds.x,
              top: bounds.y,
              width: bounds.w,
              height: bounds.h,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  if (assignment == null) {
                    showDialog(
                      context: context,
                      builder: (_) => AssignTrainPopup(
                        depotName: depot,
                        sectionName: section,
                        trackNumber: trackNumber,
                        trackId: trackId,
                      ),
                    );
                  } else {
                    showDialog(
                      context: context,
                      builder: (_) => TrainDetailsPopup(assignment: assignment),
                    );
                  }
                },
                child: Tooltip(
                  message: trackId,
                  child: Container(
                    decoration: BoxDecoration(
                      color: assignment != null
                          ? assignment.statusColor.withValues(alpha: 0.6)
                          : Colors.transparent,
                      border: Border.all(
                        color: assignment != null
                            ? assignment.statusColor
                            : Colors.transparent,
                        width: 1,
                      ),
                    ),
                    child: assignment != null
                        ? const FittedBox(
                            child: Icon(Icons.train, color: Colors.white),
                          )
                        : null,
                  ),
                ),
              ),
            );
          })
          .toList(),
    );
  }
}
