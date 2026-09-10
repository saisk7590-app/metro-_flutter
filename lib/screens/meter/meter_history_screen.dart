import 'package:flutter/material.dart';

import '../../widgets/common/custom_header.dart';
import '../../widgets/meter/trainset_table.dart';

class MeterHistoryScreen extends StatelessWidget {
  const MeterHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Theme.of(context).colorScheme.surface,
      child: const Column(
        children: [
          CustomHeader(
            title: 'METER HISTORY',
            subtitle: 'Live readings from the asset register API',
          ),
          Expanded(child: TrainsetTable()),
        ],
      ),
    );
  }
}
