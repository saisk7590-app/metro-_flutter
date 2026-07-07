import 'package:flutter/material.dart';

class DrawerMenuButton extends StatelessWidget {
  const DrawerMenuButton({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: InkWell(
        onTap: () {
          // Traverse up the tree to find the nearest ancestor Scaffold that has a drawer
          ScaffoldState? targetScaffold;
          context.visitAncestorElements((element) {
            if (element is StatefulElement && element.state is ScaffoldState) {
              final state = element.state as ScaffoldState;
              if (state.hasDrawer) {
                targetScaffold = state;
                return false; // Stop traversing
              }
            }
            return true; // Continue traversing
          });

          if (targetScaffold != null) {
            targetScaffold!.openDrawer();
          } else {
            Scaffold.of(context).openDrawer();
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: theme.colorScheme.outline.withOpacity(.4),
            ),
          ),
          child: const Icon(Icons.menu),
        ),
      ),
    );
  }
}
