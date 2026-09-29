import 'dart:async';

import 'package:flutter/material.dart';
import '../../models/trainset_meter_reading_model.dart';
import 'package:provider/provider.dart';
import '../../providers/trainset_meter_reading_provider.dart';
import '../../providers/login_provider.dart';

import 'date_search_bar.dart';
import 'meter_bottom_sheet.dart';
import 'pagination_bar.dart';
import 'trainset_row.dart';
import 'website_date_picker.dart';
import '../../services/api_service.dart';
import '../../utils/token_diagnostics.dart';

class TrainsetTable extends StatefulWidget {
  const TrainsetTable({super.key});

  @override
  State<TrainsetTable> createState() => _TrainsetTableState();
}

class _TrainsetTableState extends State<TrainsetTable> {
  DateTime selectedDate = DateTime.now();

  int itemsPerPage = 10;
  int currentPage = 1;
  String searchText = '';
  List<TrainsetMeterReadingModel> searchMatches = [];
  Timer? searchDebounce;
  bool searchLoading = false;

  final TextEditingController searchController = TextEditingController();

  @override
  void dispose() {
    searchDebounce?.cancel();
    searchController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadReadings();
    });
  }

  String _normalize(String value) =>
      value.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');

  void _filterTrainsets(String value) {
    final query = _normalize(value);
    searchDebounce?.cancel();
    setState(() {
      searchText = query;
      currentPage = 1;
      searchMatches = [];
      searchLoading = query.isNotEmpty;
    });
    if (query.isNotEmpty) {
      searchDebounce = Timer(
        const Duration(milliseconds: 350),
        _loadSearchResults,
      );
    }
  }

  Future<void> _loadSearchResults() async {
    final requestedQuery = searchText;
    final loginData = context.read<LoginProvider>().loginData;
    final token = loginData?.token ?? ApiService.currentToken ?? '';
    final userSession = loginData?.encodedUserSession ?? ApiService.currentUserSession ?? '';
    final roleId = context.read<LoginProvider>().selectedRoleId ??
        (loginData != null && loginData.roleIds.isNotEmpty
            ? loginData.roleIds.split(',').first.trim()
            : ApiService.currentRoleId ?? '1');
    if (token.isEmpty) return;
    final date = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
    ).toIso8601String().split('.').first;
    try {
      final results = await context
          .read<TrainsetMeterReadingProvider>()
          .getAllForSearch(
            date: date,
            token: token,
            userSession: userSession,
            roleId: roleId,
          );
      if (!mounted || requestedQuery != searchText) return;
      setState(() {
        searchMatches = results;
        searchLoading = false;
      });
    } catch (_) {
      if (mounted && requestedQuery == searchText) {
        setState(() {
          searchMatches = [];
          searchLoading = false;
        });
      }
    }
  }

  void _changePage(int page) {
    setState(() => currentPage = page);
    if (searchText.isEmpty) {
      _loadReadings();
    }
  }

  void _clearSearchAndLoad() {
    searchDebounce?.cancel();
    searchController.clear();
    setState(() {
      searchText = '';
      searchMatches = [];
      searchLoading = false;
      currentPage = 1;
    });
    _loadReadings();
  }

  Future<void> _loadReadings() async {
    final loginData = context.read<LoginProvider>().loginData;
    final token = loginData?.token ?? ApiService.currentToken ?? '';
    final userSession = loginData?.encodedUserSession ?? ApiService.currentUserSession ?? '';
    final roleId = context.read<LoginProvider>().selectedRoleId ??
        (loginData != null && loginData.roleIds.isNotEmpty
            ? loginData.roleIds.split(',').first.trim()
            : ApiService.currentRoleId ?? '1');

    if (token.isEmpty) {
      return;
    }

    logTokenDiagnostics('after LoginProvider retrieval', token);

    final date = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
    ).toIso8601String().split('.').first;

    await context.read<TrainsetMeterReadingProvider>().getTrainsetMeterReadings(
      date: date,
      pageNo: currentPage,
      pageSize: itemsPerPage,
      pagination: 1,
      token: token,
      userSession: userSession,
      roleId: roleId,
    );
  }

  Future<void> pickDate() async {
    final picked = await showDialog<DateTime>(
      context: context,
      builder: (context) => WebsiteDatePicker(
        initialDate: selectedDate,
        firstDate: DateTime(2025),
        lastDate: DateTime(2100),
      ),
    );

    if (picked != null) {
      searchDebounce?.cancel();
      searchController.clear();
      setState(() {
        selectedDate = picked;
        searchText = '';
        searchMatches = [];
        searchLoading = false;
        currentPage = 1;
      });
      await _loadReadings();
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

    final matches = searchText.isEmpty
        ? trainsets
        : searchMatches.where((row) {
            final searchable = _normalize(
              '${row.assetNo} ${row.locationCode} ${row.locationName}',
            );
            return searchable.contains(searchText);
          }).toList();
    final totalItems = searchText.isNotEmpty
        ? matches.length
        : provider.totalRows > 0
        ? provider.totalRows
        : trainsets.length;
    final totalPages = (totalItems / itemsPerPage).ceil().clamp(1, 999999);
    final visibleRows = searchText.isEmpty
        ? trainsets
        : matches
              .skip((currentPage - 1) * itemsPerPage)
              .take(itemsPerPage)
              .toList();

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
                  onSearch: _clearSearchAndLoad,
                  onSearchChanged: _filterTrainsets,
                  onRefresh: () {
                    searchController.clear();
                    searchDebounce?.cancel();

                    setState(() {
                      selectedDate = DateTime.now();
                      searchText = '';
                      searchMatches = [];
                      searchLoading = false;
                      currentPage = 1;
                    });
                    _loadReadings();
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
                  child: provider.isLoading || searchLoading
                      ? const Center(child: CircularProgressIndicator())
                      : provider.errorMessage != null
                      ? Center(child: Text(provider.errorMessage!))
                      : visibleRows.isEmpty
                      ? Center(
                          child: Text(
                            searchText.isEmpty
                                ? 'No meter readings found.'
                                : 'No matching trainset found.',
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(12),
                          itemCount: visibleRows.length,
                          itemBuilder: (context, index) {
                            final row = visibleRows[index];

                            return TrainsetRow(
                              isMobile: isMobile,
                              serialNo:
                                  (currentPage - 1) * itemsPerPage + index + 1,
                              trainset: row.assetNo,
                              location: row.locationCode,
                              previousDay: row.formattedPreviousDate,
                              previousStatus: row.previousDateReading,
                              currentStatus: row.todayReading,
                              onEdit: () async {
                                MeterBottomSheet.selectedTrainsetId =
                                    row.assetId;
                                final result =
                                    await showModalBottomSheet<String>(
                                  context: context,
                                  isScrollControlled: true,
                                  backgroundColor: Colors.transparent,
                                  builder: (_) {
                                    return MeterBottomSheet(
                                      trainset: row.assetNo,
                                      location: row.locationCode,
                                      date: DateTime(
                                        selectedDate.year,
                                        selectedDate.month,
                                        selectedDate.day,
                                      ).toIso8601String().split('.').first,
                                    );
                                  },
                                );
                                if (result != null) {
                                  _loadReadings();
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
                  totalItems: totalItems,
                  itemsPerPage: itemsPerPage,
                  onItemsChanged: (value) {
                    setState(() {
                      itemsPerPage = value;
                      currentPage = 1;
                    });
                    _changePage(currentPage);
                  },
                  onFirst: currentPage <= 1
                      ? null
                      : () {
                          setState(() {
                            currentPage = 1;
                          });
                          _changePage(currentPage);
                        },
                  onPrevious: currentPage <= 1
                      ? null
                      : () {
                          setState(() {
                            currentPage--;
                          });
                          _changePage(currentPage);
                        },
                  onNext: currentPage >= totalPages
                      ? null
                      : () {
                          setState(() {
                            currentPage++;
                          });
                          _changePage(currentPage);
                        },
                  onLast: currentPage >= totalPages
                      ? null
                      : () {
                          setState(() {
                            currentPage = totalPages;
                          });
                          _changePage(currentPage);
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
