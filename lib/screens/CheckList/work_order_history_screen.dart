import 'package:flutter/material.dart';

import '../../widgets/common/custom_header.dart';
import '../../widgets/common/coming_soon_screen.dart';

class WorkOrderHistoryScreen extends StatelessWidget {
  const WorkOrderHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return ColoredBox(
      color: colors.surface,
      child: Column(
        children: const [
          CustomHeader(
            title: "WORK ORDER HISTORY",
            subtitle: "Completed Work Orders",
          ),
          Expanded(
            child: ComingSoonScreen(
              moduleName: "CHECKLIST MODULE",
              title: "Work Order History",
              description:
                  "Completed work orders and maintenance history will be available here.",
              icon: Icons.history_outlined,
            ),
          ),
        ],
      ),
    );
  }
}
