import 'package:flutter/material.dart';

import '../../widgets/common/custom_header.dart';
import '../../widgets/common/coming_soon_screen.dart';

class ChecklistScreen extends StatelessWidget {
  const ChecklistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return ColoredBox(
      color: colors.surface,
      child: Column(
        children: const [
          CustomHeader(title: "CHECKLIST", subtitle: "Maintenance Checklist"),
          Expanded(
            child: ComingSoonScreen(
              moduleName: "CHECKLIST MODULE",
              title: "Checklist",
              description:
                  "Technicians will be able to complete assigned maintenance checklists from this screen.",
              icon: Icons.fact_check_outlined,
            ),
          ),
        ],
      ),
    );
  }
}
