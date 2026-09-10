import 'package:flutter/material.dart';

import '../../widgets/common/custom_header.dart';
import '../../widgets/meter/trainset_table.dart';

class MeterReadingScreen extends StatefulWidget {
  const MeterReadingScreen({super.key});

  @override
  State<MeterReadingScreen> createState() => _MeterReadingScreenState();
}

class _MeterReadingScreenState extends State<MeterReadingScreen> {
  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Theme.of(context).colorScheme.surface,
      child: Column(
        children: [
          const CustomHeader(
            title: "METER READING",
            subtitle: "Live readings from the asset register API",
          ),
          const Expanded(child: TrainsetTable()),
        ],
      ),
    );
  }
}
