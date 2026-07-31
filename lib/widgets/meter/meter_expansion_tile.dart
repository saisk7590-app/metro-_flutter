import 'package:flutter/material.dart';

import '../../models/meter_reading.dart';
import 'meter_details.dart';

class MeterExpansionTile extends StatelessWidget {
  final MeterReading meter;

  final bool isExpanded;

  final ValueChanged<bool> onExpansionChanged;

  final VoidCallback onChanged;

  const MeterExpansionTile({
    super.key,
    required this.meter,
    required this.isExpanded,
    required this.onExpansionChanged,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: colors.outline.withValues(alpha: 0.20)),
      ),

      // <-- THIS IS THE IMPORTANT CHANGE
      child: ExpansionTile(
        key: ValueKey('${meter.meterCode}_$isExpanded'),

        initiallyExpanded: isExpanded,

        onExpansionChanged: onExpansionChanged,

        tilePadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),

        childrenPadding: const EdgeInsets.fromLTRB(18, 0, 18, 18),

        title: Text(
          meter.meterCode,
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
        ),

        subtitle: Text(meter.meterName),

        children: [MeterDetails(meter: meter, onChanged: onChanged)],
      ),
    );
  }
}
