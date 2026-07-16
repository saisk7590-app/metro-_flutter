import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/maintenance_purpose_provider.dart';
import '../providers/status_provider.dart';
import '../providers/train_provider.dart';

import '../widgets/custom_dropdown.dart';
import '../widgets/custom_input.dart';
import '../widgets/custom_button.dart';

class AllocationPopup extends StatefulWidget {
  final String depotName;
  final String sectionName;
  final String trackId;

  const AllocationPopup({
    super.key,
    required this.depotName,
    required this.sectionName,
    required this.trackId,
  });

  @override
  State<AllocationPopup> createState() => _AllocationPopupState();
}

class _AllocationPopupState extends State<AllocationPopup> {
  String trainNo = "";
  String status = "";
  String purpose = "";
  String inwardTime = "";
  String outwardTime = "";
  int? selectedTrainId;
  int? selectedStatusId;
  int? selectedPurposeId;

  bool outwardScheduled = false;

  final remarksController = TextEditingController();
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

  Future<String> pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final statusProvider = context.watch<StatusProvider>();
    final purposeProvider = context.watch<MaintenancePurposeProvider>();
    final trainProvider = context.watch<TrainProvider>();

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(20),

      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 700, maxHeight: 650),

        child: Container(
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: colors.outline),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(.15),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),

          child: Column(
            children: [
              //--------------------------------------------------
              // HEADER
              //--------------------------------------------------
              Container(
                padding: const EdgeInsets.fromLTRB(24, 20, 16, 20),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),

                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Allocate Slot",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: theme.primaryColor,
                            ),
                          ),

                          const SizedBox(height: 8),

                          Text(
                            widget.trackId,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),

                          const SizedBox(height: 4),

                          Text(
                            "${widget.depotName} • ${widget.sectionName}",
                            style: TextStyle(color: Colors.grey.shade700),
                          ),
                        ],
                      ),
                    ),

                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),

              //--------------------------------------------------
              // BODY
              //--------------------------------------------------
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      //------------------------------------------------
                      // TRAINSET
                      //------------------------------------------------
                      CustomDropdown(
                        label: "Train Set",
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

                      const SizedBox(height: 16),

                      //------------------------------------------------
                      // STATUS + PURPOSE
                      //------------------------------------------------
                      Row(
                        children: [
                          Expanded(
                            child: CustomDropdown(
                              label: "Status",
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
                              label: "Purpose",
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

                      //------------------------------------------------
                      // FROM DATE + TO DATE
                      //------------------------------------------------
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
                                  label: "From Date",
                                  controller: TextEditingController(
                                    text: inwardTime,
                                  ),
                                  placeholder: "dd-mm-yyyy",
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
                                  label: "To Date",
                                  controller: TextEditingController(
                                    text: outwardTime,
                                  ),
                                  placeholder: "dd-mm-yyyy",
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      //------------------------------------------------
                      // OUTWARD SCHEDULED
                      //------------------------------------------------
                      CheckboxListTile(
                        value: outwardScheduled,
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                        controlAffinity: ListTileControlAffinity.leading,
                        title: const Text(
                          "Outward Scheduled",
                          style: TextStyle(fontSize: 14),
                        ),
                        onChanged: (value) {
                          setState(() {
                            outwardScheduled = value ?? false;
                          });
                        },
                      ),

                      const SizedBox(height: 12),

                      //------------------------------------------------
                      // REMARKS
                      //------------------------------------------------
                      CustomInput(
                        label: "Remarks",
                        controller: remarksController,
                        placeholder: "Add notes...",
                        multiline: true,
                      ),

                      const SizedBox(height: 28),

                      Divider(color: Colors.grey.shade300),

                      const SizedBox(height: 20),

                      //------------------------------------------------
                      // BUTTONS
                      //------------------------------------------------
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop(context),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                              ),
                              child: const Text("Cancel"),
                            ),
                          ),

                          const SizedBox(width: 16),

                          Expanded(
                            child: CustomButton(
                              title: "Allocate",
                              onPressed: () {
                                if (trainNo.isEmpty ||
                                    status.isEmpty ||
                                    purpose.isEmpty ||
                                    inwardTime.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        "Please fill all required fields",
                                      ),
                                    ),
                                  );
                                  return;
                                }

                                // TODO:
                                // Call Allocation Save API

                                Navigator.pop(context);
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
