import 'package:flutter/material.dart';

import '../../widgets/common/custom_header.dart';
import '../../widgets/meter/trainset_table.dart';

class MeterDashboardScreen extends StatelessWidget {
  const MeterDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return ColoredBox(
      color: colors.surface,
      child: Column(
        children: const [
          CustomHeader(
            title: "Trainset Meter Measurements",
            subtitle: "Daily Meter Reading Monitoring",
          ),

          Expanded(child: TrainsetTable()),
        ],
      ),
    );
  }
}
