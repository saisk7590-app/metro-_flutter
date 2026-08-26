import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/trainset_meter_reading_provider.dart';
import '../../providers/login_provider.dart';

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

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<TrainsetMeterReadingProvider>();
      final loginProvider = context.read<LoginProvider>();
      final loginData = loginProvider.loginData;

      if (loginData == null) {
        return;
      }
      debugPrint('Token: ${loginData.token}');
      debugPrint('UserSession: ${loginData.userSession}');
      debugPrint('================ AUTH DEBUG ================');
      debugPrint('TOKEN FROM LOGIN:');
      debugPrint(loginData.token);

      debugPrint('BEARER TOKEN:');
      debugPrint(loginData.bearerToken);

      debugPrint('RAW USER SESSION:');
      debugPrint(loginData.userSession);

      debugPrint('ENCODED USER SESSION:');
      debugPrint(loginData.encodedUserSession);

      debugPrint('ROLE ID:');
      debugPrint(loginData.roleIds);

      debugPrint('============================================');
      provider.getTrainsetMeterReadings(
        date: '2026-06-04T00:00:00',
        pageNo: 1,
        pageSize: 10,
        pagination: 1,
        token: loginData.bearerToken,
        userSession: loginData.encodedUserSession,
      );
    });
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
        child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TrainsetMeterReadingProvider>();

    final trainsets = provider.trainsetMeterReadings;
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
                        serialNo: startIndex + index + 1,
                        trainset: row.assetNo,
                        location: row.locationCode,
                        previousDay: row.previousDate,
                        previousStatus: row.previousDateReading,
                        currentStatus: row.todayReading,
                        onEdit: () async {
                          await showModalBottomSheet<String>(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (_) {
                              return MeterBottomSheet(
                                trainset: row.assetNo,
                                location: row.locationCode,
                                date: selectedDate.toString().split(" ").first,
                              );
                            },
                          );
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
