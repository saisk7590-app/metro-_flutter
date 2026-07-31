import 'package:flutter/material.dart';

import 'date_search_bar.dart';
import 'meter_bottom_sheet.dart';
import 'pagination_bar.dart';
import 'trainset_row.dart';

class TrainsetTable extends StatefulWidget {
  const TrainsetTable({super.key});

  @override
  State<TrainsetTable> createState() => _TrainsetTableState();
}

class _TrainsetTableState extends State<TrainsetTable> {
  DateTime selectedDate = DateTime.now();

  int itemsPerPage = 10;
  int currentPage = 1;

  final TextEditingController searchController = TextEditingController();

  final List<Map<String, dynamic>> trainsets = List.generate(57, (index) {
    return {
      "no": index + 1,
      "trainset": "TS${(index + 1).toString().padLeft(3, '0')}",
      "location": index < 30 ? "NDP" : "MDP",
      "previousDay": "29-07-2026",
      "previousStatus": "Completed",
      "currentStatus": "Not Started",
    };
  });

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2025),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  Widget headerCell(String text, int flex) {
    return Expanded(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Text(
          text,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final totalPages = (trainsets.length / itemsPerPage).ceil();

    final startIndex = (currentPage - 1) * itemsPerPage;

    final endIndex = (startIndex + itemsPerPage > trainsets.length)
        ? trainsets.length
        : startIndex + itemsPerPage;

    final visibleRows = trainsets.sublist(startIndex, endIndex);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Card(
        elevation: 1,
        clipBehavior: Clip.antiAlias,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isMobile = constraints.maxWidth < 760;

            return Column(
              children: [
                //--------------------------------------------------
                // Date + Search
                //--------------------------------------------------
                DateSearchBar(
                  selectedDate: selectedDate,
                  searchController: searchController,
                  onPickDate: pickDate,
                  onSearch: () {},
                  onRefresh: () {
                    searchController.clear();

                    setState(() {
                      selectedDate = DateTime.now();
                      currentPage = 1;
                    });
                  },
                ),

                //--------------------------------------------------
                // Header
                //--------------------------------------------------
                if (!isMobile)
                  Container(
                    height: 52,
                    color: colors.surfaceContainerHighest,
                    child: Row(
                      children: [
                        headerCell("No", 1),
                        headerCell("Trainset", 2),
                        headerCell("Location", 2),
                        headerCell("Previous Day", 2),
                        headerCell("Previous Day Status", 3),
                        headerCell("Current Day Status", 3),
                        headerCell("Action", 1),
                      ],
                    ),
                  ),

                //--------------------------------------------------
                // Rows
                //--------------------------------------------------
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: visibleRows.length,
                    itemBuilder: (context, index) {
                      final row = visibleRows[index];

                      return TrainsetRow(
                        serialNo: row["no"],
                        trainset: row["trainset"],
                        location: row["location"],
                        previousDay: row["previousDay"],
                        previousStatus: row["previousStatus"],
                        currentStatus: row["currentStatus"],
                        onEdit: () async {
                          final status =
                              await showModalBottomSheet<String>(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (_) {
                              return MeterBottomSheet(
                                trainset: row["trainset"],
                                location: row["location"],
                                date: selectedDate
                                    .toString()
                                    .split(" ")
                                    .first,
                              );
                            },
                          );

                          if (status != null) {
                            setState(() {
                              row["currentStatus"] = status;
                            });
                          }
                        },
                      );
                    },
                  ),
                ),

                //--------------------------------------------------
                // Pagination
                //--------------------------------------------------
                PaginationBar(
                  currentPage: currentPage,
                  totalItems: trainsets.length,
                  itemsPerPage: itemsPerPage,
                  onItemsChanged: (value) {
                    setState(() {
                      itemsPerPage = value;
                      currentPage = 1;
                    });
                  },
                  onFirst: currentPage == 1
                      ? null
                      : () {
                          setState(() {
                            currentPage = 1;
                          });
                        },
                  onPrevious: currentPage == 1
                      ? null
                      : () {
                          setState(() {
                            currentPage--;
                          });
                        },
                  onNext: currentPage == totalPages
                      ? null
                      : () {
                          setState(() {
                            currentPage++;
                          });
                        },
                  onLast: currentPage == totalPages
                      ? null
                      : () {
                          setState(() {
                            currentPage = totalPages;
                          });
                        },
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}