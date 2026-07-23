import 'package:flutter/material.dart';

class CustomHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  // final VoidCallback? onMenuPressed;
  final List<Widget>? actions;

  const CustomHeader({
    super.key,
    required this.title,
    required this.subtitle,
    // this.onMenuPressed,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: theme.colorScheme.surfaceContainerHighest,
      shadowColor: Colors.black12,
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            //------------------------------------------
            // Hamburger Menu
            //------------------------------------------
            Builder(
              builder: (context) {
                return InkWell(
                  onTap: () {
                    Scaffold.of(context).openDrawer();
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: theme.colorScheme.outline.withValues(alpha: 0.4),
                      ),
                    ),
                    child: const Icon(Icons.menu),
                  ),
                );
              },
            ),

            const SizedBox(width: 16),

            //------------------------------------------
            // Title + Subtitle
            //------------------------------------------
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: theme.primaryColor,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),

            //------------------------------------------
            // Optional Right-side actions
            //------------------------------------------
            if (actions != null) ...[const SizedBox(width: 12), ...actions!],
          ],
        ),
      ),
    );
  }
}
