import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../constants/data.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_dropdown.dart';
import '../../widgets/custom_input.dart';
import '../../widgets/custom_header.dart';

import '../../providers/status_provider.dart';
import '../../providers/maintenance_purpose_provider.dart';
import '../../providers/train_provider.dart';
import '../../providers/maintenance_bay_provider.dart';

class AMSUpdateScreen extends StatefulWidget {
  const AMSUpdateScreen({super.key});

  @override
  State<AMSUpdateScreen> createState() => _AMSUpdateScreenState();
}

class _AMSUpdateScreenState extends State<AMSUpdateScreen> {
  String depot = '';
  String trainNo = '';
  //String section = '';
  String track = '';
  String status = '';
  String purpose = '';
  String inwardTime = '';
  String outwardTime = '';

  int selectedMbId = 0;
  int selectedSlotId = 0;
  int? selectedTrainId;
  int? selectedStatusId;
  int? selectedPurposeId;
  int? selectedTrackId;

  final remarksController = TextEditingController();
  final Map<String, int> depotIds = {'Uppal': 633, 'Miyapur': 9373};

  Color getStatusColor() {
    switch (status) {
      case 'Running':
        return Colors.green;
      case 'Idle':
        return Colors.orange;
      case 'Maintenance':
      case 'Failure':
        return Colors.red;
      default:
        return Theme.of(context).primaryColor;
    }
  }

  Future<String> pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (!mounted || date == null) return '';

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (!mounted || time == null) return '';

    final dateTime = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );

    //final formattedTime = "${time.format(context)}";

    return "${dateTime.day.toString().padLeft(2, '0')}-"
        "${dateTime.month.toString().padLeft(2, '0')}-"
        "${dateTime.year} "
        "${time.hour.toString().padLeft(2, '0')}:"
        "${time.minute.toString().padLeft(2, '0')}";
  }

  String formatApiDate(String value) {
    final parts = value.split(' ');
    final dateParts = parts[0].split('-');

    return '${dateParts[2]}-${dateParts[1]}-${dateParts[0]}T${parts[1]}:00';
  }

  bool validateForm() {
    return depot.isNotEmpty &&
        //section.isNotEmpty &&
        track.isNotEmpty &&
        trainNo.isNotEmpty &&
        status.isNotEmpty &&
        purpose.isNotEmpty &&
        inwardTime.isNotEmpty &&
        outwardTime.isNotEmpty;
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!context.mounted) return;
      context.read<StatusProvider>().fetchStatuses();
      context.read<MaintenancePurposeProvider>().fetchMaintenancePurposes();
      context.read<TrainProvider>().fetchTrainSets();
    });
  }

  @override
  void dispose() {
    remarksController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final statusProvider = Provider.of<StatusProvider>(context);
    final purposeProvider = Provider.of<MaintenancePurposeProvider>(context);
    final trainProvider = Provider.of<TrainProvider>(context);
    final bayProvider = Provider.of<MaintenanceBayProvider>(context);

    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(80),
        child: CustomHeader(
          title: "AMS UPDATE",
          subtitle: "Update Train Status",
        ),
      ),

      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: colors.outline),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(20),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  /// 1. DEPOT
                  CustomDropdown(
                    label: 'Depot',
                    selectedValue: depot,
                    options: AppData.depots,
                    onChanged: (value) {
                      setState(() {
                        depot = value;
                        //section = '';
                        track = '';
                      });
                      debugPrint('Selected Depot: $value');

                      final depotId = depotIds[value];
                      debugPrint('Depot ID: $depotId');

                      if (depotId != null) {
                        context
                            .read<MaintenanceBayProvider>()
                            .fetchMaintenanceBay(depotId);
                      }
                    },
                  ),

                  /// 3. TRACK
                  CustomDropdown(
                    label: 'Track',
                    selectedValue: track,
                    keyboardEnabled: true,
                    options: bayProvider.maintenanceBays
                        .map((e) => e.slotName)
                        .toList(),
                    onChanged: (value) {
                      final selectedBay = bayProvider.maintenanceBays
                          .firstWhere((e) => e.slotName == value);

                      setState(() {
                        track = value;
                        selectedMbId = selectedBay.id;
                        selectedSlotId = selectedBay.slot;
                      });

                      debugPrint('Selected MbId: $selectedMbId');
                      debugPrint('Selected SlotId: $selectedSlotId');
                    },
                  ),

                  /// 4. TRAIN
                  CustomDropdown(
                    label: 'Train Set',
                    selectedValue: trainNo,
                    keyboardEnabled: true,
                    options: trainProvider.trainSets.map((e) => e.no).toList(),
                    onChanged: (value) {
                      final train = trainProvider.trainSets.firstWhere(
                        (e) => e.no == value,
                      );

                      setState(() {
                        trainNo = value;
                        selectedTrainId = train.id;
                      });
                    },
                  ),

                  /// 5. STATUS & 6. PURPOSE
                  if (statusProvider.isLoading || purposeProvider.isLoading)
                    const Center(child: CircularProgressIndicator()),

                  Row(
                    children: [
                      Expanded(
                        child: CustomDropdown(
                          label: 'Status',
                          selectedValue: status,
                          options: statusProvider.statuses
                              .map((e) => e.name)
                              .toList(),
                          onChanged: (value) {
                            final item = statusProvider.statuses.firstWhere(
                              (e) => e.name == value,
                            );

                            setState(() {
                              status = value;
                              selectedStatusId = item.id;
                            });
                          },
                        ),
                      ),

                      const SizedBox(width: 12),

                      Expanded(
                        child: CustomDropdown(
                          label: 'Purpose',
                          selectedValue: purpose,
                          options: purposeProvider.purposes
                              .map((e) => e.name)
                              .toList(),
                          onChanged: (value) {
                            final item = purposeProvider.purposes.firstWhere(
                              (e) => e.name == value,
                            );

                            setState(() {
                              purpose = value;
                              selectedPurposeId = item.id;
                            });
                          },
                        ),
                      ),
                    ],
                  ),

                  /// 7. INWARD TIME & 8. OUTWARD TIME
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () async {
                            inwardTime = await pickDateTime();
                            setState(() {});
                          },
                          child: AbsorbPointer(
                            child: CustomInput(
                              label: 'From (Inward)',
                              controller: TextEditingController(
                                text: inwardTime,
                              ),
                              placeholder: 'dd-mm-yyyy --:--',
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 12),

                      Expanded(
                        child: GestureDetector(
                          onTap: () async {
                            outwardTime = await pickDateTime();
                            setState(() {});
                          },
                          child: AbsorbPointer(
                            child: CustomInput(
                              label: 'To (Outward)',
                              controller: TextEditingController(
                                text: outwardTime,
                              ),
                              placeholder: 'dd-mm-yyyy --:--',
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  /// 9. REMARKS
                  CustomInput(
                    label: 'Remarks (Optional)',
                    controller: remarksController,
                    placeholder: 'Optional notes...',
                    multiline: true,
                  ),

                  const SizedBox(height: 20),

                  /// SAVE BUTTON
                  CustomButton(
                    title: 'SAVE UPDATE',
                    backgroundColor: getStatusColor(),
                    onPressed: () async {
                      final depotId = depotIds[depot];

                      if (depotId == null ||
                          selectedTrainId == null ||
                          selectedStatusId == null ||
                          selectedPurposeId == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Missing required IDs')),
                        );
                        return;
                      }
                      debugPrint('API Inward: ${formatApiDate(inwardTime)}');
                      debugPrint('API Outward: ${formatApiDate(outwardTime)}');
                      final success = await context
                          .read<MaintenanceBayProvider>()
                          .saveMaintenanceBay(
                            mbId: selectedMbId,
                            mbDepot: depotId,
                            mbSlot: selectedSlotId,
                            mbTrainSet: selectedTrainId!,
                            mbStatus: selectedStatusId!,
                            mbPurpose: selectedPurposeId!,
                            mbInward: formatApiDate(inwardTime),
                            mbOutward: formatApiDate(outwardTime),
                            mbRemark: remarksController.text,
                          );
                      if (!mounted) return;

                      if (success) {
                        if (success) {
                          // Show saved values
                          debugPrint('===== SAVED DATA =====');
                          debugPrint('Depot: $depot');
                          debugPrint('Track: $track');
                          debugPrint('Train: $trainNo');
                          debugPrint('Status: $status');
                          debugPrint('Purpose: $purpose');
                          debugPrint('Inward: $inwardTime');
                          debugPrint('Outward: $outwardTime');
                          debugPrint('Remarks: ${remarksController.text}');
                          debugPrint('MbId: $selectedMbId');
                          debugPrint('Slot ID: $selectedSlotId');
                          debugPrint('Train ID: $selectedTrainId');
                          debugPrint('Status ID: $selectedStatusId');
                          debugPrint('Purpose ID: $selectedPurposeId');

                          // Clear form except depot
                          setState(() {
                            track = '';
                            trainNo = '';
                            status = '';
                            purpose = '';
                            inwardTime = '';
                            outwardTime = '';

                            selectedMbId = 0;
                            selectedSlotId = 0;
                            selectedTrainId = null;
                            selectedStatusId = null;
                            selectedPurposeId = null;

                            remarksController.clear();
                          });

                          // Show clear confirmation
                          debugPrint(
                            'Form cleared successfully. Depot retained = $depot (${depotIds[depot]})',
                          );
                          debugPrint('Track: $track');

                          if (!mounted) return;

                          ScaffoldMessenger.of(this.context).showSnackBar(
                            const SnackBar(content: Text('Saved Successfully')),
                          );
                        }
                      } else {
                        ScaffoldMessenger.of(this.context).showSnackBar(
                          const SnackBar(content: Text('Save Failed')),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
