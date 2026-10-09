import 'package:flutter/material.dart';
import '../../models/wheel_measurement_model.dart';

/// Modal bottom sheet showing detailed wheel record breakdown
class WheelRecordDetailSheet extends StatelessWidget {
  final WheelMeasurementListItem record;

  const WheelRecordDetailSheet({super.key, required this.record});

  static void show(BuildContext context, WheelMeasurementListItem record) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => WheelRecordDetailSheet(record: record),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.55,
      minChildSize: 0.4,
      maxChildSize: 0.85,
      expand: false,
      builder: (context, scrollController) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: ListView(
            controller: scrollController,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  const Icon(Icons.album, color: Colors.blue),
                  const SizedBox(width: 8),
                  Text(
                    "${record.tsNumber} Wheel Profiling Summary",
                    style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildDetailRow("Work Order", record.woNumber),
              _buildDetailRow("Measured On", record.measuredDate),
              _buildDetailRow("Purpose", record.schedule),
              _buildDetailRow("KM Reading", "${record.kmReading} km"),
              _buildDetailRow("Avg Wheel Diameter", "${record.averageDia.toStringAsFixed(2)} mm"),
              _buildDetailRow("Last Measured Schedule", record.lastMeasuredSchedule.isNotEmpty ? record.lastMeasuredSchedule : "--"),
              _buildDetailRow("Last KM Reading", "${record.lastKmReading} km"),
              _buildDetailRow("Remarks", record.remarks.isNotEmpty ? record.remarks : "None"),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.check),
                label: const Text("Close Details"),
              ),
            ],
          ),
        );
      },
    );
  }
}
