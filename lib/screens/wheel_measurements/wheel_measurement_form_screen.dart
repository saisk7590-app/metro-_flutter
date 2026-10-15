import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/wheel_measurement_default_data.dart';
import '../../models/maintenance_bay/train_model.dart';
import '../../models/wheel/wheel_measurement_model.dart';
import '../../providers/auth/login_provider.dart';
import '../../providers/maintenance_bay/train_provider.dart';
import '../../services/api_service.dart';
import '../../widgets/common/custom_header.dart';
import '../../widgets/wheel_measurements/wheel_axle_card.dart';
import '../../widgets/wheel_measurements/wheel_form_widgets.dart';

class WheelMeasurementFormScreen extends StatefulWidget {
  const WheelMeasurementFormScreen({super.key});

  @override
  State<WheelMeasurementFormScreen> createState() =>
      _WheelMeasurementFormScreenState();
}

class _WheelMeasurementFormScreenState
    extends State<WheelMeasurementFormScreen> with SingleTickerProviderStateMixin {
  final ApiService _apiService = ApiService();

  String _selectedTrainSet = 'TS001';
  final TextEditingController _kmReadingController = TextEditingController(text: '125430');
  final TextEditingController _remarksController = TextEditingController();

  late TabController _carTabController;
  int _activeCarIndex = 0;
  bool _isSaving = false;

  late List<CarItem> _carsData;

  @override
  void initState() {
    super.initState();
    _carTabController = TabController(length: 3, vsync: this);
    _carTabController.addListener(() {
      if (!_carTabController.indexIsChanging) {
        setState(() {
          _activeCarIndex = _carTabController.index;
        });
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final login = context.read<LoginProvider>();
      final ld = login.loginData;
      final roleId = login.selectedRoleId ?? ld?.roleIds.split(',').first.trim() ?? '1';
      context.read<TrainProvider>().fetchTrainSets(
        token: ld?.token,
        userSession: ld?.encodedUserSession,
        roleId: roleId,
      );
    });

    _carsData = WheelMeasurementDefaultData.generateDefaultCarHierarchy();
  }

  @override
  void dispose() {
    _carTabController.dispose();
    _kmReadingController.dispose();
    _remarksController.dispose();
    super.dispose();
  }

  Future<void> _submitMeasurement({required int submitMode}) async {
    setState(() => _isSaving = true);

    final kmVal = double.tryParse(_kmReadingController.text.trim()) ?? 0.0;
    final trainProvider = Provider.of<TrainProvider>(context, listen: false);
    final matchingTrain = trainProvider.trainSets.firstWhere(
      (t) => t.no == _selectedTrainSet,
      orElse: () => TrainModel(
        id: int.tryParse(_selectedTrainSet.replaceAll(RegExp(r'[^0-9]'), '')) ?? 1,
        no: _selectedTrainSet,
      ),
    );
    final tsId = matchingTrain.id;

    final data = WheelMeasurementData(
      woId: 0,
      trainsetId: tsId,
      trainsetNo: _selectedTrainSet,
      kmReading: kmVal,
      remarks: _remarksController.text.trim(),
      cars: _carsData,
      submit: submitMode,
    );

    try {
      final success = await _apiService.saveWheelMeasurementDetails(data);
      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 8),
                Text(submitMode == 1
                    ? "Wheel Measurements for $_selectedTrainSet submitted successfully!"
                    : "Draft saved for $_selectedTrainSet successfully!"),
              ],
            ),
            backgroundColor: Colors.green.shade700,
            duration: const Duration(seconds: 3),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("Recorded locally. Server sync pending."),
            backgroundColor: Colors.orange.shade800,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error saving measurements: $e"),
          backgroundColor: Colors.red.shade700,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Widget _buildCarTabBar(bool isDark) {
    return Container(
      color: isDark ? const Color(0xFF0F172A) : Colors.white,
      child: TabBar(
        controller: _carTabController,
        labelColor: Colors.blue.shade700,
        unselectedLabelColor: Colors.grey,
        indicatorColor: Colors.blue.shade700,
        indicatorWeight: 3,
        tabs: const [
          Tab(text: "Car 1 • DMC1 (Motor)"),
          Tab(text: "Car 2 • TC (Trailer)"),
          Tab(text: "Car 3 • DMC2 (Motor)"),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final activeCar = _carsData[_activeCarIndex];

    final trainProvider = context.watch<TrainProvider>();
    final List<String> trainsets = trainProvider.trainSets.isNotEmpty
        ? trainProvider.trainSets
            .map((t) => t.no.isNotEmpty ? t.no : 'TS-${t.id}')
            .toSet()
            .toList()
        : [for (int i = 1; i <= 57; i++) 'TS${i.toString().padLeft(3, '0')}'];

    final effectiveTrainSet = trainsets.contains(_selectedTrainSet)
        ? _selectedTrainSet
        : (trainsets.isNotEmpty ? trainsets.first : 'TS001');

    return Scaffold(
      body: Column(
        children: [
          CustomHeader(
            title: "WHEEL MEASUREMENT",
            subtitle: "Digital Field Entry • No More Notebooks",
            actions: [
              IconButton(
                icon: const Icon(Icons.help_outline),
                tooltip: "Acceptability Rules",
                onPressed: () => QuickToleranceModal.show(context),
              ),
            ],
          ),
          WheelFormHeaderBar(
            selectedTrainSet: effectiveTrainSet,
            trainsets: trainsets,
            kmReadingController: _kmReadingController,
            isDark: isDark,
            onTrainSetChanged: (val) {
              if (val != null) setState(() => _selectedTrainSet = val);
            },
          ),
          _buildCarTabBar(isDark),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 90),
              children: [
                CarSummaryStatsCard(car: activeCar, isDark: isDark),
                const SizedBox(height: 12),
                BogieSection(
                  bogieTitle: "BOGIE 1 (Front)",
                  wheelSets: activeCar.wheelSets.sublist(0, 2),
                  car: activeCar,
                  isDark: isDark,
                  onWheelChanged: () => setState(() {}),
                ),
                const SizedBox(height: 14),
                BogieSection(
                  bogieTitle: "BOGIE 2 (Rear)",
                  wheelSets: activeCar.wheelSets.sublist(2, 4),
                  car: activeCar,
                  isDark: isDark,
                  onWheelChanged: () => setState(() {}),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomSheet: WheelFormBottomBar(
        isSaving: _isSaving,
        isDark: isDark,
        onSaveDraft: () => _submitMeasurement(submitMode: 0),
        onSubmit: () => _submitMeasurement(submitMode: 1),
      ),
    );
  }
}
