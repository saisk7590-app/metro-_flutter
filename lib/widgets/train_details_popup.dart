import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'assign_train_popup.dart';
import '../providers/active_trains_provider.dart';
import '../widgets/custom_button.dart';

class TrainDetailsPopup extends StatelessWidget {
  final TrainAssignment assignment;

  const TrainDetailsPopup({super.key, required this.assignment});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 420,
          maxHeight: MediaQuery.of(context).size.height * .85,
        ),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: colors.outline),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(20),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                //--------------------------------------------------
                // Header
                //--------------------------------------------------
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Train Details",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),

                          const SizedBox(height: 4),

                          Text(
                            assignment.trackId,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),

                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                //--------------------------------------------------
                // Details
                //--------------------------------------------------
                _buildDetailRow("Depot", assignment.depotName),

                _buildDetailRow("Section", assignment.sectionName),

                _buildDetailRow("Track", assignment.trackNumber),

                const Divider(height: 28),

                _buildDetailRow("Train Number", assignment.trainNo),

                _buildDetailRow(
                  "Maintenance Purpose",
                  assignment.maintenancePurpose,
                ),

                _buildDetailRow(
                  "Status",
                  assignment.status,
                  color: assignment.statusColor,
                ),

                _buildDetailRow(
                  "Remarks",
                  assignment.remarks.isEmpty ? "-" : assignment.remarks,
                ),

                const SizedBox(height: 28),

                //--------------------------------------------------
                // Buttons
                //--------------------------------------------------
                Row(
                  children: [
                    Expanded(
                      child: CustomButton(
                        title: "EDIT",
                        backgroundColor: Colors.orange,
                        onPressed: () async {
                          Navigator.pop(context);

                          await showDialog(
                            context: context,
                            builder: (_) => AssignTrainPopup(
                              depotName: assignment.depotName,
                              sectionName: assignment.sectionName,
                              trackNumber: assignment.trackNumber,
                              trackId: assignment.trackId,
                              assignment: assignment,
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(width: 10),

                    Expanded(
                      child: CustomButton(
                        title: "REMOVE",
                        backgroundColor: Colors.red,
                        onPressed: () {
                          context.read<ActiveTrainsProvider>().removeTrain(
                            assignment.trackId,
                          );

                          Navigator.pop(context);
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),

          Expanded(
            child: Text(
              value,
              style: TextStyle(fontWeight: FontWeight.w600, color: color),
            ),
          ),
        ],
      ),
    );
  }
}
