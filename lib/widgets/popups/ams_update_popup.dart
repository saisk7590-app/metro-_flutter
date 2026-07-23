import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_dropdown.dart';
import '../../widgets/common/custom_input.dart';

import '../../providers/status_provider.dart';
import '../../providers/maintenance_purpose_provider.dart';
import '../../providers/train_provider.dart';
import '../../providers/maintenance_bay_provider.dart';
import '../../providers/active_trains_provider.dart';

class AMSUpdatePopup extends StatefulWidget {
  final String initialDepot;
  final String initialTrack;

  const AMSUpdatePopup({
    super.key,
    required this.initialDepot,
    required this.initialTrack,
  });

  @override
  State<AMSUpdatePopup> createState() => _AMSUpdatePopupState();
}

class _AMSUpdatePopupState extends State<AMSUpdatePopup> {
  late String depot;
  String trainNo = '';
  late String track;
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
    depot = widget.initialDepot;
    track = widget.initialTrack;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!context.mounted) return;
      context.read<StatusProvider>().fetchStatuses();
      context.read<MaintenancePurposeProvider>().fetchMaintenancePurposes();
      context.read<TrainProvider>().fetchTrainSets();

      final depotId = depotIds[depot];
      if (depotId != null) {
        context
            .read<MaintenanceBayProvider>()
            .fetchMaintenanceBay(depotId)
            .then((_) {
              if (!mounted) return;
              // Find mbId and slotId for initialTrack
              final bayProvider = context.read<MaintenanceBayProvider>();
              try {
                final bay = bayProvider.maintenanceBays.firstWhere(
                  (e) => e.slotName == track,
                );
                setState(() {
                  selectedMbId = bay.id;
                  selectedSlotId = bay.slot;
                });
              } catch (_) {
                // Bay not found
              }
            });
      }
    });
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
    if (value.isEmpty) return '';
    final parts = value.split(' ');
    if (parts.length < 2) return '';
    final dateParts = parts[0].split('-');
    if (dateParts.length < 3) return '';

    return '${dateParts[2]}-${dateParts[1]}-${dateParts[0]}T${parts[1]}:00';
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

    final colors = Theme.of(context).colorScheme;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 800),
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
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Update Track: $track',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Theme.of(context).primaryColor,
                      letterSpacing: 1,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      /// 1. DEPOT (Disabled, inherited)
                      CustomInput(
                        label: 'Depot',
                        controller: TextEditingController(text: depot),
                        placeholder: depot,
                      ),

                      /// 3. TRACK (Disabled, inherited)
                      CustomInput(
                        label: 'Track',
                        controller: TextEditingController(text: track),
                        placeholder: track,
                      ),

                      /// 4. TRAIN
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
                                final item = purposeProvider.purposes
                                    .firstWhere((e) => e.name == value);

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

                      /// 9. REMARKS
                      CustomInput(
                        label: 'Remarks (Optional)',
                        controller: remarksController,
                        placeholder: 'Optional notes...',
                        multiline: true,
                      ),
                    ],
                  ),
                ),
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
                      selectedPurposeId == null ||
                      selectedSlotId == 0) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Missing required IDs, please fill all fields',
                        ),
                      ),
                    );
                    return;
                  }

                  // Capture everything BEFORE await
                  final bayProvider = context.read<MaintenanceBayProvider>();
                  final activeProvider = context.read<ActiveTrainsProvider>();
                  final messenger = ScaffoldMessenger.of(context);
                  final navigator = Navigator.of(context);

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
                    activeProvider.assignTrain(
                      TrainAssignment(
                        depotName: depot,
                        sectionName: track,
                        trackNumber: track,
                        trackId: track,
                        trainNo: trainNo,
                        maintenancePurpose: purpose,
                        status: status,
                        remarks: remarksController.text.trim(),
                      ),
                    );

                    messenger.showSnackBar(
                      const SnackBar(content: Text('Saved Successfully')),
                    );

                    navigator.pop();
                  } else {
                    messenger.showSnackBar(
                      const SnackBar(content: Text('Save Failed')),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
