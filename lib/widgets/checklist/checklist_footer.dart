import 'package:flutter/material.dart';

class ChecklistFooter extends StatelessWidget {
  final int showing;
  final int total;
  final VoidCallback? onLoadMore;
  final bool hasMore;

  const ChecklistFooter({
    super.key,
    required this.showing,
    required this.total,
    this.onLoadMore,
    this.hasMore = true,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      child: Column(
        children: [
          Text(
            "Showing $showing of $total Checklists",
            style: TextStyle(
              color: colors.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 12),

          if (hasMore)
            OutlinedButton.icon(
              onPressed: onLoadMore,
              icon: const Icon(Icons.expand_more),
              label: const Text("Load More"),
            )
          else
            Text(
              "No more records",
              style: TextStyle(
                color: colors.onSurfaceVariant,
              ),
            ),
        ],
      ),
    );
  }
}