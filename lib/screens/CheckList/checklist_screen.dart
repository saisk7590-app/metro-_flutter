import 'package:flutter/material.dart';

import '../../widgets/common/custom_header.dart';
import '../../widgets/checklist/checklist_filters.dart';
import '../../widgets/checklist/checklist_list.dart';

class ChecklistScreen extends StatelessWidget {
  const ChecklistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return ColoredBox(
      color: colors.surface,
      child: Column(
        children: [
          const CustomHeader(
            title: "CHECKLIST",
            subtitle: "Maintenance Checklist",
          ),

          const ChecklistFilters(),

          Expanded(child: ChecklistList()),
        ],
      ),
    );
  }
}
