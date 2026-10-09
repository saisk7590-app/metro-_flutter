import 'package:flutter/material.dart';
import '../../models/wheel_measurement_model.dart';
import '../../services/api_service.dart';
import '../../utils/scaffold_keys.dart';
import '../../widgets/common/custom_header.dart';
import '../../widgets/wheel_measurements/wheel_history_widgets.dart';

class WheelMeasurementHistoryScreen extends StatefulWidget {
  const WheelMeasurementHistoryScreen({super.key});

  @override
  State<WheelMeasurementHistoryScreen> createState() =>
      _WheelMeasurementHistoryScreenState();
}

class _WheelMeasurementHistoryScreenState
    extends State<WheelMeasurementHistoryScreen> {
  final ApiService _apiService = ApiService();

  bool _isLoading = true;
  String _selectedTrainSet = '0';
  List<WheelMeasurementListItem> _records = [];
  String? _errorMessage;

  final List<String> _trainsets = [
    'All Trainsets',
    for (int i = 1; i <= 57; i++) 'TS-${i.toString().padLeft(2, '0')}',
  ];

  @override
  void initState() {
    super.initState();
    _fetchRecords();
  }

  Future<void> _fetchRecords() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final tsParam = _selectedTrainSet == 'All Trainsets' || _selectedTrainSet == '0'
          ? '0'
          : _selectedTrainSet.replaceFirst('TS-', '');
      final list = await _apiService.getWheelMeasurementsList(trainSet: tsParam);
      setState(() {
        _records = list;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load wheel measurement records: $e';
        _isLoading = false;
      });
    }
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 12),
            Text(
              _errorMessage ?? "Unknown error",
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _fetchRecords,
              child: const Text("Try Again"),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ColoredBox(
      color: theme.colorScheme.surface,
      child: Column(
        children: [
          CustomHeader(
            title: "WHEEL HISTORY",
            subtitle: "Historical Records & Profiling Data",
            onMenuPressed: () => AppScaffoldKeys.wheelKey.currentState?.openDrawer(),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                tooltip: "Refresh Records",
                onPressed: _fetchRecords,
              ),
            ],
          ),
          WheelMeasurementFilterBar(
            selectedTrainSet: _selectedTrainSet,
            trainsets: _trainsets,
            isDark: isDark,
            onTrainSetChanged: (val) {
              setState(() => _selectedTrainSet = val);
              _fetchRecords();
            },
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage != null
                    ? _buildErrorView()
                    : _records.isEmpty
                        ? const WheelHistoryEmptyView()
                        : RefreshIndicator(
                            onRefresh: _fetchRecords,
                            child: ListView.builder(
                              padding: const EdgeInsets.all(12),
                              itemCount: _records.length,
                              itemBuilder: (context, index) {
                                return WheelRecordCard(
                                  record: _records[index],
                                  isDark: isDark,
                                  onTap: () => WheelRecordDetailSheet.show(
                                    context,
                                    _records[index],
                                  ),
                                );
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }
}
