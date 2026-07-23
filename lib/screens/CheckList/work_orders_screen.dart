import 'package:flutter/material.dart';
import '../../widgets/common/custom_header.dart';
import '../../widgets/common/coming_soon_screen.dart';

class WorkOrdersScreen extends StatelessWidget {
  const WorkOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return ColoredBox(
      color: colors.surface,
      child: Column(
        children: const [
          CustomHeader(
            title: "CHECKLIST WORK ORDERS",
            subtitle: "Assigned Work Orders",
          ),
          Expanded(
            child: ComingSoonScreen(
              moduleName: "CHECKLIST MODULE",
              title: "Work Orders",
              description:
                  "Assigned work orders will appear here for technicians.",
              icon: Icons.assignment_outlined,
            ),
          ),
        ],
      ),
    );
  }
}
