import 'package:flutter/material.dart';

class DateSearchBar extends StatelessWidget {
  final DateTime selectedDate;
  final TextEditingController searchController;

  final VoidCallback onPickDate;
  final VoidCallback onSearch;
  final VoidCallback onRefresh;

  const DateSearchBar({
    super.key,
    required this.selectedDate,
    required this.searchController,
    required this.onPickDate,
    required this.onSearch,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          //------------------------------------
          // Row 1
          //------------------------------------
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: onPickDate,
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: "Date",
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                    child: Text(
                      "${selectedDate.day.toString().padLeft(2, '0')}-"
                      "${selectedDate.month.toString().padLeft(2, '0')}-"
                      "${selectedDate.year}",
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 10),

              IconButton.filled(
                tooltip: "Load Data",
                onPressed: onSearch,
                icon: const Icon(Icons.search),
              ),

              const SizedBox(width: 8),

              IconButton.outlined(
                tooltip: "Reset",
                onPressed: onRefresh,
                icon: const Icon(Icons.refresh),
              ),
            ],
          ),

          const SizedBox(height: 14),

          //------------------------------------
          // Row 2
          //------------------------------------
          TextField(
            controller: searchController,
            decoration: const InputDecoration(
              hintText: "Search Trainset...",
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
    );
  }
}