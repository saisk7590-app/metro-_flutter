import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_dropdown.dart';
import '../../widgets/common/custom_input.dart';

import '../../models/train_model.dart';
import '../../models/status_model.dart';
import '../../models/maintenance_purpose_model.dart';

import '../../providers/status_provider.dart';
import '../../providers/maintenance_purpose_provider.dart';
import '../../providers/train_provider.dart';
import '../../providers/maintenance_bay_provider.dart';
import '../../providers/active_trains_provider.dart';
import '../../providers/login_provider.dart';

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
  bool isOutward = false;

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

    // Deduce slot number from track name (e.g. UPLSBL5BE -> 5, MPIBL2OE -> 2)
    final digits = track.replaceAll(RegExp(r'\D'), '');
    selectedSlotId = int.tryParse(digits) ?? 1;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!context.mounted) return;
      final loginData = context.read<LoginProvider>().loginData;
      final roleId = context.read<LoginProvider>().selectedRoleId ??
          loginData?.roleIds.split(',').first.trim() ??
          '1';

      context.read<StatusProvider>().fetchStatuses();
      context.read<MaintenancePurposeProvider>().fetchMaintenancePurposes();
      context.read<TrainProvider>().fetchTrainSets(
            token: loginData?.token,
            userSession: loginData?.encodedUserSession,
            roleId: roleId,
          );

      final depotId = depotIds[depot];
      if (depotId != null) {
        // Pre-fill from existing bays in provider first if already loaded
        _prefillFromBays();

        // Also fetch to ensure latest data
        context
            .read<MaintenanceBayProvider>()
            .fetchMaintenanceBay(depotId)
            .then((_) {
          if (!mounted) return;
          _prefillFromBays();
        });
      }
    });
  }

  void _prefillFromBays() {
    final bayProvider = context.read<MaintenanceBayProvider>();
    final bay = bayProvider.findBayForMarker(track);
    if (bay != null) {
      setState(() {
        if (bay.id > 0) selectedMbId = bay.id;
        if (bay.slot > 0) {
          selectedSlotId = bay.slot;
        } else if (bay.id > 0) {
          selectedSlotId = bay.id;
        }

        if (bay.isAllocated || bay.trainSetId > 0 || bay.trainSetName.isNotEmpty) {
          trainNo = bay.trainSetName.isNotEmpty
              ? bay.trainSetName
              : (bay.trainSetId > 0 ? 'TS-${bay.trainSetId}' : '');
          selectedTrainId = bay.trainSetId;

          status = bay.statusName;
          selectedStatusId = bay.statusId;

          purpose = bay.purposeName;
          selectedPurposeId = bay.purposeId;

          inwardTime = formatDisplayDate(bay.inward);
          outwardTime = formatDisplayDate(bay.outward);
          isOutward = bay.isOutward;
          remarksController.text = bay.remark;
        } else if (inwardTime.isEmpty) {
          final now = DateTime.now();
          inwardTime =
              "${now.day.toString().padLeft(2, '0')}-${now.month.toString().padLeft(2, '0')}-${now.year} ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";
        }
      });

      // Also call get-maintenance-by-id to retrieve ground-truth DB details
      if (bay.id > 0) {
        _fetchDetailedBay(bay.id);
      }
    } else if (inwardTime.isEmpty) {
      final now = DateTime.now();
      setState(() {
        inwardTime =
            "${now.day.toString().padLeft(2, '0')}-${now.month.toString().padLeft(2, '0')}-${now.year} ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";
      });
    }
  }

  Future<void> _fetchDetailedBay(int mbId) async {
    final bayProvider = context.read<MaintenanceBayProvider>();
    final detailed = await bayProvider.getMaintenanceBayById(mbId);
    if (!mounted || detailed == null) return;

    setState(() {
      if (detailed.id > 0) selectedMbId = detailed.id;
      if (detailed.slot > 0) selectedSlotId = detailed.slot;

      if (detailed.trainSetId > 0 || detailed.trainSetName.isNotEmpty || detailed.isAllocated) {
        trainNo = detailed.trainSetName.isNotEmpty
            ? detailed.trainSetName
            : (detailed.trainSetId > 0 ? 'TS-${detailed.trainSetId}' : '');
        selectedTrainId = detailed.trainSetId;

        if (detailed.statusName.isNotEmpty) status = detailed.statusName;
        if (detailed.statusId > 0) selectedStatusId = detailed.statusId;

        if (detailed.purposeName.isNotEmpty) purpose = detailed.purposeName;
        if (detailed.purposeId > 0) selectedPurposeId = detailed.purposeId;

        if (detailed.inward.isNotEmpty) inwardTime = formatDisplayDate(detailed.inward);
        if (detailed.outward.isNotEmpty) outwardTime = formatDisplayDate(detailed.outward);
        isOutward = detailed.isOutward;
        if (detailed.remark.isNotEmpty) remarksController.text = detailed.remark;
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
        "${dateTime.hour.toString().padLeft(2, '0')}:"
        "${dateTime.minute.toString().padLeft(2, '0')}";
  }

  String formatDisplayDate(String value) {
    if (value.trim().isEmpty) return '';
    try {
      final dt = DateTime.parse(value);
      return "${dt.day.toString().padLeft(2, '0')}-"
          "${dt.month.toString().padLeft(2, '0')}-"
          "${dt.year} "
          "${dt.hour.toString().padLeft(2, '0')}:"
          "${dt.minute.toString().padLeft(2, '0')}";
    } catch (_) {
      return value;
    }
  }

  String formatApiDate(String value) {
    if (value.trim().isEmpty) {
      final now = DateTime.now();
      return "${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}T${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:00";
    }
    if (value.contains('T')) {
      if (value.length == 16) return '$value:00';
      return value;
    }
    final parts = value.trim().split(' ');
    if (parts.length >= 2) {
      final dateParts = parts[0].split('-');
      if (dateParts.length >= 3) {
        final timePart = parts[1].length == 5 ? '${parts[1]}:00' : parts[1];
        if (dateParts[0].length <= 2 && dateParts[2].length == 4) {
          return '${dateParts[2]}-${dateParts[1].padLeft(2, '0')}-${dateParts[0].padLeft(2, '0')}T$timePart';
        }
        if (dateParts[0].length == 4) {
          return '${dateParts[0]}-${dateParts[1].padLeft(2, '0')}-${dateParts[2].padLeft(2, '0')}T$timePart';
        }
      }
    }
    try {
      final dt = DateTime.parse(value);
      return "${dt.year.toString().padLeft(4, '0')}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}T${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}:00";
    } catch (_) {
      final now = DateTime.now();
      return "${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}T${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:00";
    }
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

    // Build Train Set options list, ensuring current trainNo is included
    final trainOptions = trainProvider.trainSets.map((e) => e.no).toList();
    if (trainNo.isNotEmpty && !trainOptions.contains(trainNo)) {
      trainOptions.insert(0, trainNo);
    }

    // Build Status options list, ensuring current status is included
    final statusOptions = statusProvider.statuses.map((e) => e.name).toList();
    if (status.isNotEmpty && !statusOptions.contains(status)) {
      statusOptions.insert(0, status);
    }

    // Build Purpose options list, ensuring current purpose is included
    final purposeOptions = purposeProvider.purposes.map((e) => e.name).toList();
    if (purpose.isNotEmpty && !purposeOptions.contains(purpose)) {
      purposeOptions.insert(0, purpose);
    }

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
                    'Update Bay: $track',
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

                      /// 3. BAY (Disabled, inherited)
                      CustomInput(
                        label: 'Bay',
                        controller: TextEditingController(text: track),
                        placeholder: track,
                      ),

                      /// 4. TRAIN
                      CustomDropdown(
                        label: 'Train Set',
                        selectedValue: trainNo,
                        keyboardEnabled: true,
                        options: trainOptions,
                        onChanged: (value) {
                          final train = trainProvider.trainSets.firstWhere(
                            (e) => e.no == value,
                            orElse: () => TrainModel(
                              id: selectedTrainId ?? 0,
                              no: value,
                            ),
                          );

                          setState(() {
                            trainNo = value;
                            selectedTrainId = train.id > 0 ? train.id : selectedTrainId;
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
                              options: statusOptions,
                              onChanged: (value) {
                                final item = statusProvider.statuses.firstWhere(
                                  (e) => e.name == value,
                                  orElse: () => StatusModel(
                                    id: selectedStatusId ?? 0,
                                    name: value,
                                  ),
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
                              options: purposeOptions,
                              onChanged: (value) {
                                final item = purposeProvider.purposes.firstWhere(
                                  (e) => e.name == value,
                                  orElse: () => MaintenancePurposeModel(
                                    id: selectedPurposeId ?? 0,
                                    name: value,
                                  ),
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
                                final value = await pickDateTime();
                                if (!mounted || value.isEmpty) return;

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
                                if (!mounted || value.isEmpty) return;

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

                      Row(
                        children: [
                          Checkbox(
                            value: isOutward,
                            onChanged: (value) {
                              setState(() => isOutward = value ?? false);
                            },
                          ),
                          const Text(
                            'Outward',
                            style: TextStyle(fontWeight: FontWeight.w600),
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

                  int effectiveMbId = selectedMbId;
                  int effectiveSlotId = selectedSlotId;

                  if (effectiveSlotId == 0 && effectiveMbId > 0) {
                    effectiveSlotId = effectiveMbId;
                  }
                  if (effectiveMbId == 0 && effectiveSlotId > 0) {
                    effectiveMbId = effectiveSlotId;
                  }

                  if (depotId == null ||
                      selectedTrainId == null ||
                      selectedStatusId == null ||
                      selectedPurposeId == null ||
                      effectiveSlotId == 0) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Missing required fields. Please select Train Set, Status, and Purpose.',
                        ),
                      ),
                    );
                    return;
                  }

                  // Capture providers & context BEFORE await
                  final bayProvider = context.read<MaintenanceBayProvider>();
                  final activeProvider = context.read<ActiveTrainsProvider>();
                  final loginProvider = context.read<LoginProvider>();
                  final messenger = ScaffoldMessenger.of(context);
                  final navigator = Navigator.of(context);

                  final userId = loginProvider.loginData?.id ?? 1;

                  final success = await bayProvider.saveMaintenanceBay(
                    mbId: effectiveMbId,
                    mbDepot: depotId,
                    mbSlot: effectiveSlotId,
                    mbTrainSet: selectedTrainId!,
                    mbStatus: selectedStatusId!,
                    mbPurpose: selectedPurposeId!,
                    mbInward: formatApiDate(inwardTime),
                    mbOutward: outwardTime.trim().isEmpty
                        ? ''
                        : formatApiDate(outwardTime),
                    mbRemark: remarksController.text,
                    isOutward: isOutward,
                    userId: userId,
                  );

                  if (!mounted) return;

                  if (success) {
                    // Refresh live ground-truth bays immediately from backend
                    bayProvider.fetchMaintenanceBay(depotId);

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
