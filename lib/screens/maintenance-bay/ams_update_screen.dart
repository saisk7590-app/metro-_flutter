import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../constants/data.dart';
import '../../models/maintenance_bay_model.dart';
import '../../providers/login_provider.dart';
import '../../providers/maintenance_bay_provider.dart';
import '../../providers/maintenance_purpose_provider.dart';
import '../../providers/status_provider.dart';
import '../../providers/train_provider.dart';

import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_dropdown.dart';
import '../../widgets/common/custom_header.dart';
import '../../widgets/common/custom_input.dart';
import '../../widgets/common/responsive_container.dart';

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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

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

      if (depot.isEmpty && AppData.depots.isNotEmpty) {
        depot = AppData.depots.first;
        final depotId = depotIds[depot];
        if (depotId != null) {
          context.read<MaintenanceBayProvider>().fetchMaintenanceBay(depotId);
        }
      }
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

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final statusProvider = context.watch<StatusProvider>();
    final purposeProvider = context.watch<MaintenancePurposeProvider>();
    final trainProvider = context.watch<TrainProvider>();
    final bayProvider = context.watch<MaintenanceBayProvider>();

    return ColoredBox(
      color: colors.surface,
      child: Column(
        children: [
          const CustomHeader(
            title: "Bay Layout Update",
            subtitle: "Update Train Allocation",
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  Center(
                    child: ResponsiveContainer(
                      maxWidth: 600,
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
                                  trainNo = '';
                                  status = '';
                                  purpose = '';
                                  inwardTime = '';
                                  outwardTime = '';
                                  isOutward = false;
                                  selectedMbId = 0;
                                  selectedSlotId = 0;
                                  selectedTrainId = null;
                                  selectedStatusId = null;
                                  selectedPurposeId = null;
                                  remarksController.clear();
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
                            // Bay
                            //----------------------------------
                            CustomDropdown(
                              label: 'Bay',
                              selectedValue: track,
                              keyboardEnabled: true,
                              options: bayProvider.maintenanceBays
                                  .map((e) => e.slotName)
                                  .toList(),
                              onChanged: (value) {
                                final bay = bayProvider.maintenanceBays.firstWhere(
                                  (e) => e.slotName == value,
                                  orElse: () => MaintenanceBayModel(
                                    id: 0,
                                    slot: 0,
                                    slotName: value,
                                    slotType: '',
                                  ),
                                );

                                setState(() {
                                  track = value;
                                  selectedMbId = bay.id;
                                  selectedSlotId = bay.slot > 0 ? bay.slot : bay.id;

                                  if (bay.trainSetId > 0 ||
                                      bay.trainSetName.isNotEmpty ||
                                      bay.isAllocated) {
                                    trainNo = bay.trainSetName.isNotEmpty
                                        ? bay.trainSetName
                                        : (bay.trainSetId > 0
                                            ? 'TS-${bay.trainSetId}'
                                            : '');
                                    selectedTrainId = bay.trainSetId;
                                    status = bay.statusName;
                                    selectedStatusId = bay.statusId;
                                    purpose = bay.purposeName;
                                    selectedPurposeId = bay.purposeId;
                                    inwardTime = formatDisplayDate(bay.inward);
                                    outwardTime = formatDisplayDate(bay.outward);
                                    isOutward = bay.isOutward;
                                    remarksController.text = bay.remark;
                                  } else {
                                    trainNo = '';
                                    selectedTrainId = null;
                                    status = '';
                                    selectedStatusId = null;
                                    purpose = '';
                                    selectedPurposeId = null;
                                    final now = DateTime.now();
                                    inwardTime =
                                        "${now.day.toString().padLeft(2, '0')}-${now.month.toString().padLeft(2, '0')}-${now.year} ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";
                                    outwardTime = '';
                                    isOutward = false;
                                    remarksController.clear();
                                  }
                                });

                                if (bay.id > 0) {
                                  _fetchDetailedBay(bay.id);
                                }
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
                                final train = trainProvider.trainSets
                                    .firstWhere((e) => e.no == value);

                                setState(() {
                                  trainNo = value;
                                  selectedTrainId = train.id;
                                });
                              },
                            ),

                            if (statusProvider.isLoading ||
                                purposeProvider.isLoading)
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
                                      final item = statusProvider.statuses
                                          .firstWhere((e) => e.name == value);

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
                                        "Missing required fields. Please select Depot, Bay, Train Set, Status, and Purpose.",
                                      ),
                                    ),
                                  );
                                  return;
                                }

                                final bayProvider = context
                                    .read<MaintenanceBayProvider>();
                                final loginProvider = context
                                    .read<LoginProvider>();
                                final userId = loginProvider.loginData?.id ?? 1;

                                final success = await bayProvider
                                    .saveMaintenanceBay(
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
                                  bayProvider.fetchMaintenanceBay(depotId);

                                  setState(() {
                                    track = "";
                                    trainNo = "";
                                    status = "";
                                    purpose = "";
                                    inwardTime = "";
                                    outwardTime = "";
                                    isOutward = false;

                                    selectedMbId = 0;
                                    selectedSlotId = 0;
                                    selectedTrainId = null;
                                    selectedStatusId = null;
                                    selectedPurposeId = null;

                                    remarksController.clear();
                                  });

                                  ScaffoldMessenger.of(
                                    context,
                                  ).showSnackBar(
                                    const SnackBar(
                                      content: Text("Saved Successfully"),
                                    ),
                                  );
                                } else {
                                  ScaffoldMessenger.of(
                                    context,
                                  ).showSnackBar(
                                    const SnackBar(
                                      content: Text("Save Failed"),
                                    ),
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
            ),
          ),
        ],
      ),
    );
  }
}
