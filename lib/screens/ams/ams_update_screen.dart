import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../constants/data.dart';
import '../../providers/maintenance_bay_provider.dart';
import '../../providers/maintenance_purpose_provider.dart';
import '../../providers/status_provider.dart';
import '../../providers/train_provider.dart';

import '../../widgets/custom_button.dart';
import '../../widgets/custom_dropdown.dart';
import '../../widgets/custom_header.dart';
import '../../widgets/custom_input.dart';

class AMSUpdateScreen extends StatefulWidget {
  const AMSUpdateScreen({super.key});

  @override
  State<AMSUpdateScreen> createState() => _AMSUpdateScreenState();
}

class _AMSUpdateScreenState extends State<AMSUpdateScreen> {
  String depot = '';
  String trainNo = '';
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

  final remarksController = TextEditingController();

  final Map<String, int> depotIds = {'Uppal': 633, 'Miyapur': 9373};

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

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

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final statusProvider = context.watch<StatusProvider>();
    final purposeProvider = context.watch<MaintenancePurposeProvider>();
    final trainProvider = context.watch<TrainProvider>();
    final bayProvider = context.watch<MaintenanceBayProvider>();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CustomHeader(
            title: "Bay Layout Upadate",
            subtitle: "Update Train Status",
          ),

          const SizedBox(height: 20),

          Center(
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
                    //----------------------------------
                    // Depot
                    //----------------------------------
                    CustomDropdown(
                      label: 'Depot',
                      selectedValue: depot,
                      options: AppData.depots,
                      onChanged: (value) {
                        setState(() {
                          depot = value;
                          track = '';
                        });

                        final depotId = depotIds[value];

                        if (depotId != null) {
                          context
                              .read<MaintenanceBayProvider>()
                              .fetchMaintenanceBay(depotId);
                        }
                      },
                    ),

                    //----------------------------------
                    // Track
                    //----------------------------------
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
                      },
                    ),

                    //----------------------------------
                    // Train
                    //----------------------------------
                    CustomDropdown(
                      label: 'Train Set',
                      selectedValue: trainNo,
                      keyboardEnabled: true,
                      options: trainProvider.trainSets
                          .map((e) => e.no)
                          .toList(),
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

                    if (statusProvider.isLoading || purposeProvider.isLoading)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(12),
                          child: CircularProgressIndicator(),
                        ),
                      ),

                    //----------------------------------
                    // Status + Purpose
                    //----------------------------------
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
                    const SizedBox(height: 16),

                    //----------------------------------
                    // Inward Time + Outward Time
                    //----------------------------------
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () async {
                              final value = await pickDateTime();

                              if (!mounted) return;

                              setState(() {
                                inwardTime = value;
                              });
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
                              final value = await pickDateTime();

                              if (!mounted) return;

                              setState(() {
                                outwardTime = value;
                              });
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

                    const SizedBox(height: 16),

                    //----------------------------------
                    // Remarks
                    //----------------------------------
                    CustomInput(
                      label: 'Remarks (Optional)',
                      controller: remarksController,
                      placeholder: 'Optional notes...',
                      multiline: true,
                    ),

                    const SizedBox(height: 24),

                    //----------------------------------
                    // Save Button
                    //----------------------------------
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
                            const SnackBar(
                              content: Text("Missing required fields"),
                            ),
                          );
                          return;
                        }

                        final bayProvider = context
                            .read<MaintenanceBayProvider>();

                        final success = await bayProvider.saveMaintenanceBay(
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
                          debugPrint("===== SAVED DATA =====");
                          debugPrint("Depot : $depot");
                          debugPrint("Track : $track");
                          debugPrint("Train : $trainNo");
                          debugPrint("Status : $status");
                          debugPrint("Purpose : $purpose");
                          debugPrint("Inward : $inwardTime");
                          debugPrint("Outward : $outwardTime");
                          debugPrint("Remarks : ${remarksController.text}");

                          setState(() {
                            track = "";
                            trainNo = "";
                            status = "";
                            purpose = "";
                            inwardTime = "";
                            outwardTime = "";

                            selectedMbId = 0;
                            selectedSlotId = 0;
                            selectedTrainId = null;
                            selectedStatusId = null;
                            selectedPurposeId = null;

                            remarksController.clear();
                          });
                          if (!mounted) return;

                          ScaffoldMessenger.of(this.context).showSnackBar(
                            const SnackBar(content: Text("Saved Successfully")),
                          );
                        } else {
                          ScaffoldMessenger.of(this.context).showSnackBar(
                            const SnackBar(content: Text("Save Failed")),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
