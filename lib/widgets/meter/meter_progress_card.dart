import 'package:flutter/material.dart';

class MeterProgressCard extends StatelessWidget {
  /// true = Meter Completed
  final List<bool> meterStatus;

  const MeterProgressCard({
    super.key,
    required this.meterStatus,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final int total = meterStatus.length;
    final int completed = meterStatus.where((status) => status).length;

    final double progress = total == 0 ? 0 : completed / total;

    late final Color color;
    late final IconData icon;
    late final String status;

    if (completed == 0) {
      color = Colors.grey;
      icon = Icons.radio_button_unchecked;
      status = "Not Started";
    } else if (completed == total) {
      color = Colors.green;
      icon = Icons.check_circle;
      status = "Completed";
    } else {
      color = Colors.orange;
      icon = Icons.timelapse;
      status = "Partial";
    }

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: color.withValues(alpha: .25),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //--------------------------------------------------
            // Header
            //--------------------------------------------------

            Row(
              children: [
                Icon(
                  Icons.analytics_outlined,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                const Text(
                  "Meter Reading Progress",
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),

            //--------------------------------------------------
            // Summary Cards
            //--------------------------------------------------

            Row(
              children: [
                Expanded(
                  child: _infoTile(
                    "Completed",
                    "$completed / $total",
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: _statusTile(
                    status,
                    color,
                    icon,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),

            //--------------------------------------------------
            // Progress Bar
            //--------------------------------------------------

            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 10,
                color: color,
                backgroundColor: Colors.grey.shade300,
              ),
            ),

            const SizedBox(height: 10),

            Align(
              alignment: Alignment.centerRight,
              child: Text(
                "${(progress * 100).toInt()}%",
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  //--------------------------------------------------
  // Completed Tile
  //--------------------------------------------------

  Widget _infoTile(String title, String value) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.blueGrey.withValues(alpha: .06),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  //--------------------------------------------------
  // Status Tile
  //--------------------------------------------------

  Widget _statusTile(
    String status,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .10),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 28,
          ),
          const SizedBox(height: 8),
          Text(
            status,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}