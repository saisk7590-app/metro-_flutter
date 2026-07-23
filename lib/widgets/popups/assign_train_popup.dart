import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/active_trains_provider.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_dropdown.dart';
import '../../widgets/common/custom_input.dart';

class AssignTrainPopup extends StatefulWidget {
  final String depotName;
  final String sectionName;
  final String trackNumber;
  final String trackId;

  // Used when editing

  final TrainAssignment? assignment;

  const AssignTrainPopup({
    super.key,
    required this.depotName,
    required this.sectionName,
    required this.trackNumber,
    required this.trackId,

    this.assignment,
  });

  @override
  State<AssignTrainPopup> createState() => _AssignTrainPopupState();
}

class _AssignTrainPopupState extends State<AssignTrainPopup> {
  String trainNo = '';
  String maintenancePurpose = '';
  String status = '';

  final remarksController = TextEditingController();

  @override
  void initState() {
    super.initState();

    if (widget.assignment != null) {
      trainNo = widget.assignment!.trainNo;
      maintenancePurpose = widget.assignment!.maintenancePurpose;
      status = widget.assignment!.status;
      remarksController.text = widget.assignment!.remarks;
    }
  }

  @override
  void dispose() {
    remarksController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 420,
          maxHeight: MediaQuery.of(context).size.height * .85,
        ),
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
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                //--------------------------------------------------
                // Header
                //--------------------------------------------------
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.assignment == null
                                ? "Assign Train"
                                : "Edit Train",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.trackId,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade700,
                            ),
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

                const SizedBox(height: 20),

                //--------------------------------------------------
                // Train Number
                //--------------------------------------------------
                CustomDropdown(
                  label: "Train Number",
                  selectedValue: trainNo,
                  keyboardEnabled: true,
                  options: const ["", "TS01", "TS02", "TS03", "TS04"],
                  onChanged: (value) {
                    setState(() {
                      trainNo = value;
                    });
                  },
                ),

                const SizedBox(height: 16),

                //--------------------------------------------------
                // Maintenance Purpose
                //--------------------------------------------------
                CustomDropdown(
                  label: "Maintenance Purpose",
                  selectedValue: maintenancePurpose,
                  options: const ["", "Inspection", "Preventive", "Corrective"],
                  onChanged: (value) {
                    setState(() {
                      maintenancePurpose = value;
                    });
                  },
                ),

                const SizedBox(height: 16),

                //--------------------------------------------------
                // Status
                //--------------------------------------------------
                CustomDropdown(
                  label: "Status",
                  selectedValue: status,
                  options: const [
                    "",
                    "Running",
                    "Idle",
                    "Maintenance",
                    "Failure",
                  ],
                  onChanged: (value) {
                    setState(() {
                      status = value;
                    });
                  },
                ),

                const SizedBox(height: 16),

                //--------------------------------------------------
                // Remarks
                //--------------------------------------------------
                CustomInput(
                  label: "Remarks",
                  controller: remarksController,
                  placeholder: "Optional remarks...",
                  multiline: true,
                ),

                const SizedBox(height: 24),

                //--------------------------------------------------
                // Save / Update Button
                //--------------------------------------------------
                SizedBox(
                  width: double.infinity,
                  child: CustomButton(
                    title: widget.assignment == null ? "SAVE" : "UPDATE",
                    backgroundColor: Theme.of(context).primaryColor,
                    onPressed: () {
                      if (trainNo.isEmpty ||
                          maintenancePurpose.isEmpty ||
                          status.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Please fill all required fields"),
                          ),
                        );
                        return;
                      }

                      context.read<ActiveTrainsProvider>().assignTrain(
                        TrainAssignment(
                          depotName: widget.depotName,
                          sectionName: widget.sectionName,
                          trackNumber: widget.trackNumber,
                          trackId: widget.trackId,
                          trainNo: trainNo,
                          maintenancePurpose: maintenancePurpose,
                          status: status,
                          remarks: remarksController.text.trim(),
                        ),
                      );

                      Navigator.pop(context);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
