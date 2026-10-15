import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/maintenance_bay/maintenance_bay_model.dart';
import '../../providers/auth/login_provider.dart';
import '../../providers/maintenance_bay/maintenance_bay_provider.dart';
import '../../providers/maintenance_bay/maintenance_purpose_provider.dart';
import '../../providers/maintenance_bay/status_provider.dart';
import '../../providers/maintenance_bay/train_provider.dart';
import '../maintenance_bay/ams_update_controller.dart';
import 'ams_update_popup_footer.dart';
import 'ams_update_popup_header.dart';
import 'ams_update_popup_history.dart';
import 'ams_popup_form_fields.dart';

class AMSUpdatePopup extends StatefulWidget {
  final String initialDepot;
  final String initialTrack;
  final MaintenanceBayModel? existingBay;

  const AMSUpdatePopup({
    super.key,
    required this.initialDepot,
    required this.initialTrack,
    this.existingBay,
  });

  @override
  State<AMSUpdatePopup> createState() => _AMSUpdatePopupState();
}

class _AMSUpdatePopupState extends State<AMSUpdatePopup> {
  late String depot;
  late String track;
  late String line;

  bool hasExistingData = false;
  int existingId = 0;
  int selectedSlot = 1;
  bool isOutward = false;

  int selectedTrainSet = 0;
  int selectedStatus = 0;
  int selectedPurpose = 0;

  DateTime? fromDate;
  DateTime? toDate;

  final TextEditingController remarksController = TextEditingController();

  List<DropdownOption> trainSetOptions = [];
  List<DropdownOption> statusOptions = [];
  List<DropdownOption> purposeOptions = [];

  List<Map<String, dynamic>> allocationHistory = [];
  int selectedHistoryIndex = -1;
  bool isSaving = false;
  bool isLoadingDetails = false;

  @override
  void initState() {
    super.initState();
    depot = widget.initialDepot;
    track = widget.initialTrack;
    line = AmsUpdateService.getLineForSlot(track);

    final digits = track.replaceAll(RegExp(r'\D'), '');
    selectedSlot = int.tryParse(digits) ?? 1;
    fromDate = DateTime.now();

    _initFromExistingBay(widget.existingBay);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _loadInitialData();
    });
  }

  @override
  void dispose() {
    remarksController.dispose();
    super.dispose();
  }

  void _initFromExistingBay(MaintenanceBayModel? bay) {
    if (bay == null) {
      final bayProvider = context.read<MaintenanceBayProvider>();
      bay = bayProvider.findBayForMarker(track);
    }

    if (bay != null) {
      existingId = bay.id;
      if (bay.slot > 0) selectedSlot = bay.slot;

      final hasData =
          bay.trainSetId > 0 || bay.trainSetName.isNotEmpty || bay.isAllocated;
      hasExistingData = hasData;

      if (hasData) {
        selectedTrainSet = bay.trainSetId;
        selectedStatus = bay.statusId;
        selectedPurpose = bay.purposeId;

        if (bay.inward.isNotEmpty) {
          fromDate = DateTime.tryParse(bay.inward) ?? DateTime.now();
        }
        if (bay.outward.isNotEmpty) {
          toDate = DateTime.tryParse(bay.outward);
        }
        isOutward = bay.isOutward;
        remarksController.text = bay.remark;
      }
    }
  }

  void _loadInitialData() {
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

    if (existingId > 0) {
      _fetchBayDetails(existingId);
    } else {
      final found =
          context.read<MaintenanceBayProvider>().findBayForMarker(track);
      if (found != null && found.id > 0) {
        existingId = found.id;
        _initFromExistingBay(found);
        _fetchBayDetails(found.id);
      }
    }
  }

  Future<void> _fetchBayDetails(int mbId) async {
    setState(() => isLoadingDetails = true);
    try {
      final parsed = await AmsUpdateService.fetchParsedBayDetails(
        mbId,
        context.read<MaintenanceBayProvider>(),
      );
      if (!mounted || parsed == null) return;

      setState(() {
        allocationHistory = parsed.allocations;
        if (parsed.trainSet != null && parsed.trainSet! > 0) {
          hasExistingData = true;
          selectedTrainSet = parsed.trainSet!;
          selectedStatus = parsed.status ?? selectedStatus;
          selectedPurpose = parsed.purpose ?? selectedPurpose;
          if (parsed.inward != null) fromDate = parsed.inward;
          if (parsed.outward != null) toDate = parsed.outward;
          if (parsed.isOutward != null) isOutward = parsed.isOutward!;
          if (parsed.remarks != null && remarksController.text.isEmpty) {
            remarksController.text = parsed.remarks!;
          }
        }
      });
    } catch (e) {
      debugPrint('Error fetching bay details: $e');
    } finally {
      if (mounted) setState(() => isLoadingDetails = false);
    }
  }

  List<Map<String, dynamic>> get futureAllocations {
    final todayStart =
        DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    final future = allocationHistory.where((a) {
      final allocOn = a['mbaAllocatedOn'] ??
          a['mba_allocated_on'] ??
          a['createdOn'] ??
          '';
      if (allocOn.toString().isEmpty) return false;
      final dt = DateTime.tryParse(allocOn.toString());
      return dt != null && !dt.isBefore(todayStart);
    }).toList();

    return future.isNotEmpty ? future : allocationHistory;
  }

  String get currentTrainSetName {
    if (selectedTrainSet == 0) return '';
    final opt = trainSetOptions.where((o) => o.value == selectedTrainSet);
    return opt.isNotEmpty ? opt.first.label : 'TS-$selectedTrainSet';
  }

  void _onAssignFromHistory(Map<String, dynamic> allocation, int index) {
    if (selectedTrainSet > 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please remove "$currentTrainSetName" first then Assign'),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final tsVal = int.tryParse(
            '${allocation['mbaTrainSet'] ?? allocation['mba_train_set'] ?? 0}') ??
        0;
    final statusVal = int.tryParse(
            '${allocation['mbaStatus'] ?? allocation['mba_status'] ?? 0}') ??
        0;
    final purposeVal = int.tryParse(
            '${allocation['mbaPurpose'] ?? allocation['mba_purpose'] ?? 0}') ??
        0;
    final allocOnStr =
        '${allocation['mbaAllocatedOn'] ?? allocation['mba_allocated_on'] ?? ''}';
    final remarks =
        '${allocation['mbaRemarks'] ?? allocation['mba_remarks'] ?? ''}';

    setState(() {
      selectedHistoryIndex = index;
      selectedTrainSet = tsVal;
      selectedStatus = statusVal;
      selectedPurpose = purposeVal;
      if (allocOnStr.isNotEmpty) {
        fromDate = DateTime.tryParse(allocOnStr) ?? DateTime.now();
      }
      remarksController.text = remarks;
    });
  }

  Future<void> _handleSave() async {
    if (selectedTrainSet == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a Train Set.'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    if (selectedStatus == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a Status.'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    if (selectedPurpose == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a Purpose.'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final depotUpper = depot.toUpperCase();
    final depotId = AmsUpdateService.depotIds[depotUpper] ??
        (depotUpper == 'UPPAL' ? 633 : 9373);
    final mbId = existingId;
    final userId = context.read<LoginProvider>().loginData?.id ?? 1;

    final inwardDate =
        AmsUpdateService.formatToLocalIso(fromDate ?? DateTime.now());
    final outwardDate = (hasExistingData && toDate != null)
        ? AmsUpdateService.formatToLocalIso(toDate!)
        : '';

    setState(() => isSaving = true);

    final bayProvider = context.read<MaintenanceBayProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    try {
      final success = await bayProvider.saveMaintenanceBay(
        mbId: mbId,
        mbDepot: depotId,
        mbSlot: selectedSlot,
        mbTrainSet: selectedTrainSet,
        mbStatus: selectedStatus,
        mbPurpose: selectedPurpose,
        mbInward: inwardDate,
        mbOutward: outwardDate,
        mbRemark: remarksController.text.trim(),
        isOutward: hasExistingData ? isOutward : false,
        userId: userId,
      );

      if (!mounted) return;

      if (success) {
        final trainOpt =
            trainSetOptions.where((o) => o.value == selectedTrainSet);
        final tsName =
            trainOpt.isNotEmpty ? trainOpt.first.label : 'TS-$selectedTrainSet';
        final statusOpt = statusOptions.where((o) => o.value == selectedStatus);
        final stName = statusOpt.isNotEmpty ? statusOpt.first.label : '';
        final purposeOpt =
            purposeOptions.where((o) => o.value == selectedPurpose);
        final prName = purposeOpt.isNotEmpty ? purposeOpt.first.label : '';

        bayProvider.setOrUpdateBayAllocation(
          markerOrSlotName: track,
          depotId: depotId,
          slot: selectedSlot,
          trainSetId: selectedTrainSet,
          trainSetName: tsName,
          statusId: selectedStatus,
          statusName: stName,
          purposeId: selectedPurpose,
          purposeName: prName,
          inward: inwardDate,
          outward: outwardDate,
          remark: remarksController.text.trim(),
          isOutward: hasExistingData ? isOutward : false,
          id: mbId,
        );

        bayProvider.fetchMaintenanceBay(depotId);

        messenger.showSnackBar(
          const SnackBar(
            content: Text('Maintenance bay allocation saved successfully.'),
            backgroundColor: Color(0xFF10B981),
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 3),
          ),
        );
        navigator.pop('saved');
      } else {
        messenger.showSnackBar(
          SnackBar(
            content: const Text('Failed to save maintenance bay allocation.'),
            backgroundColor: Colors.red.shade700,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(
          content: Text('An error occurred while saving allocation: $e'),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 4),
        ),
      );
    } finally {
      if (mounted) setState(() => isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final trainProvider = context.watch<TrainProvider>();
    final statusProvider = context.watch<StatusProvider>();
    final purposeProvider = context.watch<MaintenancePurposeProvider>();

    trainSetOptions = AmsUpdateService.buildTrainSetOptions(
        trainProvider.trainSets, selectedTrainSet);
    statusOptions = AmsUpdateService.buildStatusOptions(
        statusProvider.statuses, selectedStatus);
    purposeOptions = AmsUpdateService.buildPurposeOptions(
        purposeProvider.purposes, selectedPurpose);

    final isSaveDisabled = isSaving ||
        selectedTrainSet == 0 ||
        selectedStatus == 0 ||
        selectedPurpose == 0;

    return Dialog(
      backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 860, maxHeight: 820),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AmsPopupHeader(
                track: track,
                line: line,
                hasExistingData: hasExistingData,
                onClose: () => Navigator.of(context).pop(),
              ),
              const SizedBox(height: 16),
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Row 1: Train Set, Status, Purpose
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final isNarrow = constraints.maxWidth < 650;
                          final trainSetField = AmsPopupDropdown(
                            label: 'Train Set',
                            value: selectedTrainSet,
                            options: trainSetOptions,
                            onChanged: (val) =>
                                setState(() => selectedTrainSet = val ?? 0),
                          );

                          final statusField = AmsPopupDropdown(
                            label: 'Status',
                            value: selectedStatus,
                            options: statusOptions,
                            onChanged: (val) =>
                                setState(() => selectedStatus = val ?? 0),
                          );

                          final purposeField = AmsPopupDropdown(
                            label: 'Purpose',
                            value: selectedPurpose,
                            options: purposeOptions,
                            onChanged: (val) =>
                                setState(() => selectedPurpose = val ?? 0),
                          );

                          if (isNarrow) {
                            return Column(
                              children: [
                                trainSetField,
                                const SizedBox(height: 12),
                                statusField,
                                const SizedBox(height: 12),
                                purposeField,
                              ],
                            );
                          }

                          return Row(
                            children: [
                              Expanded(child: trainSetField),
                              const SizedBox(width: 14),
                              Expanded(child: statusField),
                              const SizedBox(width: 14),
                              Expanded(child: purposeField),
                            ],
                          );
                        },
                      ),

                      const SizedBox(height: 14),

                      // Row 2: From Date, To Date, Outward Checkbox
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final isNarrow = constraints.maxWidth < 650;

                          final fromDateField = AmsPopupDatePicker(
                            label: 'From Date *',
                            value: fromDate,
                            enabled: true,
                            onTap: () async {
                              final dt = await AmsUpdateService.pickDateTime(
                                context,
                                fromDate ?? DateTime.now(),
                              );
                              if (dt != null) setState(() => fromDate = dt);
                            },
                          );

                          final toDateField = AmsPopupDatePicker(
                            label: 'To Date',
                            value: toDate,
                            enabled: hasExistingData,
                            onTap: hasExistingData
                                ? () async {
                                    final dt =
                                        await AmsUpdateService.pickDateTime(
                                      context,
                                      toDate ?? fromDate ?? DateTime.now(),
                                      minDate: fromDate,
                                    );
                                    if (dt != null) setState(() => toDate = dt);
                                  }
                                : null,
                          );

                          final outwardCheckbox = Padding(
                            padding: const EdgeInsets.only(top: 22),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Checkbox(
                                  value: isOutward,
                                  onChanged: hasExistingData
                                      ? (val) =>
                                          setState(() => isOutward = val ?? false)
                                      : null,
                                ),
                                Text(
                                  'Outward',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: hasExistingData
                                        ? (isDark
                                            ? Colors.white
                                            : const Color(0xFF475569))
                                        : Colors.grey.shade400,
                                  ),
                                ),
                              ],
                            ),
                          );

                          if (isNarrow) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                fromDateField,
                                const SizedBox(height: 12),
                                toDateField,
                                const SizedBox(height: 4),
                                outwardCheckbox,
                              ],
                            );
                          }

                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(child: fromDateField),
                              const SizedBox(width: 14),
                              Expanded(child: toDateField),
                              const SizedBox(width: 14),
                              outwardCheckbox,
                            ],
                          );
                        },
                      ),

                      const SizedBox(height: 14),

                      // Row 3: Remarks
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Remarks',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? Colors.grey.shade300
                                  : const Color(0xFF475569),
                            ),
                          ),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: remarksController,
                            maxLines: 3,
                            decoration: InputDecoration(
                              hintText: 'Remarks',
                              hintStyle: TextStyle(
                                color: Colors.grey.shade400,
                                fontSize: 13,
                              ),
                              contentPadding: const EdgeInsets.all(12),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(6),
                                borderSide:
                                    BorderSide(color: Colors.grey.shade300),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(6),
                                borderSide: BorderSide(
                                  color: isDark
                                      ? Colors.grey.shade700
                                      : Colors.grey.shade300,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      // Allocation History Section
                      if (futureAllocations.isNotEmpty) ...[
                        const SizedBox(height: 20),
                        AmsPopupAllocationHistory(
                          allocations: futureAllocations,
                          selectedHistoryIndex: selectedHistoryIndex,
                          selectedTrainSet: selectedTrainSet,
                          onAssign: _onAssignFromHistory,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              AmsPopupFooter(
                isSaving: isSaving,
                isSaveDisabled: isSaveDisabled,
                onCancel: () => Navigator.of(context).pop(),
                onSave: _handleSave,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
