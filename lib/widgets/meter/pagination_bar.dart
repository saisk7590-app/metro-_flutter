import 'package:flutter/material.dart';
import 'items_per_page_dropdown.dart';

class PaginationBar extends StatelessWidget {
  final int currentPage;
  final int totalItems;
  final int itemsPerPage;

  final VoidCallback? onFirst;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;
  final VoidCallback? onLast;

  final ValueChanged<int> onItemsChanged;

  const PaginationBar({
    super.key,
    required this.currentPage,
    required this.totalItems,
    required this.itemsPerPage,
    required this.onFirst,
    required this.onPrevious,
    required this.onNext,
    required this.onLast,
    required this.onItemsChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final totalPages =
        totalItems == 0 ? 1 : (totalItems / itemsPerPage).ceil().clamp(1, 999999);
    final start = totalItems == 0 ? 0 : ((currentPage - 1) * itemsPerPage) + 1;
    final end =
        totalItems == 0 ? 0 : (start + itemsPerPage - 1).clamp(start, totalItems);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? colors.surface : Colors.white,
        border: Border(
          top: BorderSide(
            color: colors.outlineVariant.withValues(alpha: 0.6),
          ),
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isCompact = constraints.maxWidth < 520;

          if (isCompact) {
            // --------------------------------------------------------
            // Mobile Device View (2 clean rows, total clearly visible)
            // --------------------------------------------------------
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Row 1: Total records range and rows selector
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Total badge (never truncated on mobile)
                    _buildTotalBadge(colors, start, end, totalItems),

                    // Items per page dropdown
                    ItemsPerPageDropdown(
                      value: itemsPerPage,
                      onChanged: onItemsChanged,
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // Row 2: Page controls & page numbers
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // First Page
                    _buildPageButton(
                      icon: Icons.first_page_rounded,
                      tooltip: "First Page",
                      onPressed: onFirst,
                      colors: colors,
                    ),
                    const SizedBox(width: 4),

                    // Previous Page
                    _buildPageButton(
                      icon: Icons.chevron_left_rounded,
                      tooltip: "Previous Page",
                      onPressed: onPrevious,
                      colors: colors,
                    ),
                    const SizedBox(width: 10),

                    // Page Indicator pill: "Page 1 of 5"
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 5),
                      decoration: BoxDecoration(
                        color: isDark
                            ? colors.surfaceContainerHighest
                            : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: colors.outlineVariant.withValues(alpha: 0.6),
                        ),
                      ),
                      child: Text(
                        "Page $currentPage of $totalPages",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: colors.onSurface,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),

                    // Next Page
                    _buildPageButton(
                      icon: Icons.chevron_right_rounded,
                      tooltip: "Next Page",
                      onPressed: onNext,
                      colors: colors,
                    ),
                    const SizedBox(width: 4),

                    // Last Page
                    _buildPageButton(
                      icon: Icons.last_page_rounded,
                      tooltip: "Last Page",
                      onPressed: onLast,
                      colors: colors,
                    ),
                  ],
                ),
              ],
            );
          } else {
            // --------------------------------------------------------
            // Desktop / Tablet / Wide Screen View (Single row)
            // --------------------------------------------------------
            return Row(
              children: [
                // Items per page
                ItemsPerPageDropdown(
                  value: itemsPerPage,
                  onChanged: onItemsChanged,
                ),

                const Spacer(),

                // Total range badge
                _buildTotalBadge(colors, start, end, totalItems),

                const SizedBox(width: 14),

                // First Page
                _buildPageButton(
                  icon: Icons.first_page_rounded,
                  tooltip: "First Page",
                  onPressed: onFirst,
                  colors: colors,
                ),

                // Previous Page
                _buildPageButton(
                  icon: Icons.chevron_left_rounded,
                  tooltip: "Previous Page",
                  onPressed: onPrevious,
                  colors: colors,
                ),

                const SizedBox(width: 6),

                // Page indicator
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Text(
                    "Page $currentPage of $totalPages",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      color: colors.onSurface,
                    ),
                  ),
                ),

                const SizedBox(width: 6),

                // Next Page
                _buildPageButton(
                  icon: Icons.chevron_right_rounded,
                  tooltip: "Next Page",
                  onPressed: onNext,
                  colors: colors,
                ),

                // Last Page
                _buildPageButton(
                  icon: Icons.last_page_rounded,
                  tooltip: "Last Page",
                  onPressed: onLast,
                  colors: colors,
                ),
              ],
            );
          }
        },
      ),
    );
  }

  Widget _buildTotalBadge(
      ColorScheme colors, int start, int end, int totalItems) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: colors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colors.primary.withValues(alpha: 0.25),
        ),
      ),
      child: RichText(
        text: TextSpan(
          style: TextStyle(
            fontSize: 12,
            color: colors.onSurface,
          ),
          children: [
            const TextSpan(text: "Showing "),
            TextSpan(
              text: "$start–$end",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const TextSpan(text: " of "),
            TextSpan(
              text: "$totalItems",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: colors.primary,
              ),
            ),
            const TextSpan(text: " total"),
          ],
        ),
      ),
    );
  }

  Widget _buildPageButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback? onPressed,
    required ColorScheme colors,
  }) {
    final isEnabled = onPressed != null;

    return IconButton(
      tooltip: tooltip,
      visualDensity: VisualDensity.compact,
      iconSize: 22,
      onPressed: onPressed,
      icon: Icon(
        icon,
        color: isEnabled
            ? colors.onSurface
            : colors.outline.withValues(alpha: 0.35),
      ),
    );
  }
}
