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
    final start = ((currentPage - 1) * itemsPerPage) + 1;

    final end = (start + itemsPerPage - 1) > totalItems
        ? totalItems
        : (start + itemsPerPage - 1);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Row(
        children: [
          //----------------------------------
          // Items Dropdown
          //----------------------------------
          ItemsPerPageDropdown(value: itemsPerPage, onChanged: onItemsChanged),

          const Spacer(),

          //----------------------------------
          // First Page
          //----------------------------------
          IconButton(
            tooltip: "First Page",
            visualDensity: VisualDensity.compact,
            onPressed: onFirst,
            icon: const Icon(Icons.first_page),
          ),

          //----------------------------------
          // Previous
          //----------------------------------
          IconButton(
            tooltip: "Previous",
            visualDensity: VisualDensity.compact,
            onPressed: onPrevious,
            icon: const Icon(Icons.chevron_left),
          ),

          //----------------------------------
          // Count
          //----------------------------------
          Flexible(
            fit: FlexFit.loose,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                "$start–$end / $totalItems",
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                softWrap: false,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          ),

          //----------------------------------
          // Next
          //----------------------------------
          IconButton(
            tooltip: "Next",
            visualDensity: VisualDensity.compact,
            onPressed: onNext,
            icon: const Icon(Icons.chevron_right),
          ),

          //----------------------------------
          // Last Page
          //----------------------------------
          IconButton(
            tooltip: "Last Page",
            visualDensity: VisualDensity.compact,
            onPressed: onLast,
            icon: const Icon(Icons.last_page),
          ),
        ],
      ),
    );
  }
}
