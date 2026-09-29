import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import '../../models/meter_reading.dart';
import '../../providers/login_provider.dart';
import '../../services/api_service.dart';
import 'meter_expansion_tile.dart';
import 'meter_progress_card.dart';
import 'save_cancel_bar.dart';

class MeterBottomSheet extends StatefulWidget {
  static int selectedTrainsetId = 0;
  final String trainset;
  final String location;
  final String date;

  const MeterBottomSheet({
    super.key,
    required this.trainset,
    required this.location,
    required this.date,
  });

  @override
  State<MeterBottomSheet> createState() => _MeterBottomSheetState();
}

class _MeterBottomSheetState extends State<MeterBottomSheet> {
  bool isSaving = false;
  bool isLoading = true;
  String? loadError;

  String? expandedMeterCode;
  List<MeterReading> meterReadings = [];

  @override
  void initState() {
    super.initState();
    _loadMeterReadings();
  }

  Future<void> _loadMeterReadings() async {
    final loginData = context.read<LoginProvider>().loginData;
    final token = loginData?.token ?? ApiService.currentToken ?? '';
    final userSession =
        loginData?.encodedUserSession ?? ApiService.currentUserSession ?? '';
    final roleId = context.read<LoginProvider>().selectedRoleId ??
        (loginData != null && loginData.roleIds.isNotEmpty
            ? loginData.roleIds.split(',').first.trim()
            : ApiService.currentRoleId ?? '1');

    if (token.isEmpty) {
      if (mounted) {
        setState(() {
          isLoading = false;
          loadError = 'Login session is unavailable. Please log in.';
        });
      }
      return;
    }

    try {
      final rows = await ApiService().getTrainsetMeterDetails(
        trainsetId: MeterBottomSheet.selectedTrainsetId,
        location: widget.location,
        date: widget.date,
        token: token,
        userSession: userSession,
        roleId: roleId,
      );

      final loadedMeters = rows.map((row) {
        final previousReading = _toInt(row['mr_previousreading']);
        final currentReading = _toNullableInt(row['mr_currentreading']);
        final reset = row['mr_reset'] == 1 || row['mr_reset'] == true;
        final resetRemarks = row['mr_reset_remarks']?.toString() ?? '';
        final meterId = _toInt(row['mmr_meter_type']);
        final trainsetId = _toInt(
          row['mmr_meter_assetid'] ?? MeterBottomSheet.selectedTrainsetId,
        );
        final cumulativeReading = _toInt(row['mr_cumilativereading']);

        final meter = MeterReading(
          meterId: meterId,
          trainsetId: trainsetId,
          meterCode:
              row['mmr_meter_name']?.toString() ??
              row['mt_name']?.toString() ??
              '',
          meterName:
              row['mt_name']?.toString() ??
              row['mmr_meter_name']?.toString() ??
              '',
          assetNumber: row['mmr_assoc_assetnumber']?.toString() ?? '',
          previousDate: row['mr_previousreadingdate']?.toString() ?? '',
          previousReading: previousReading,
          currentReading: currentReading,
          cumulativeReading: cumulativeReading,
          remarks: row['Remarks']?.toString() ?? '',
          reset: reset,
          resetRemarks: resetRemarks,
        );
        meter.updateCompletionStatus();
        return meter;
      }).toList();

      if (mounted) {
        setState(() {
          meterReadings = loadedMeters;
          isLoading = false;
        });
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          isLoading = false;
          loadError = error.toString();
        });
      }
    }
  }

  int _toInt(dynamic value) {
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  int? _toNullableInt(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString());
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return SafeArea(
      child: DraggableScrollableSheet(
        initialChildSize: 0.92,
        minChildSize: 0.70,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return Container(
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
            ),
            child: Column(
              children: [
                //------------------------------------------------
                // Drag Handle
                //------------------------------------------------
                const SizedBox(height: 10),

                Container(
                  width: 50,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),

                const SizedBox(height: 18),

                //------------------------------------------------
                // Header
                //------------------------------------------------
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Meter Readings",
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text("Trainset : ${widget.trainset}"),
                            const SizedBox(height: 4),
                            Text("Location : ${widget.location}"),
                            const SizedBox(height: 4),
                            Text("Date : ${widget.date}"),
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

                const Divider(),

                //------------------------------------------------
                // Body
                //------------------------------------------------
                Expanded(
                  child: ListView(
                    controller: scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      if (isLoading)
                        const Padding(
                          padding: EdgeInsets.only(top: 48),
                          child: Center(child: CircularProgressIndicator()),
                        )
                      else if (loadError != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 48),
                          child: Center(child: Text(loadError!)),
                        )
                      else ...[
                        MeterProgressCard(
                          meterStatus: meterReadings
                              .map((meter) => meter.isCompleted)
                              .toList(),
                        ),

                        const SizedBox(height: 16),

                        ...meterReadings.map(
                          (meter) => MeterExpansionTile(
                            meter: meter,

                            isExpanded: expandedMeterCode == meter.meterCode,
                            onExpansionChanged: (isExpanded) {
                              setState(() {
                                expandedMeterCode = isExpanded
                                    ? meter.meterCode
                                    : null;
                              });
                            },

                            /// THIS IS THE IMPORTANT PART
                            onChanged: () {
                              setState(() {});
                            },
                          ),
                        ),

                        const SizedBox(height: 24),
                      ],
                    ],
                  ),
                ),

                //------------------------------------------------
                // Bottom Buttons
                //------------------------------------------------
                SaveCancelBar(
                  isSaving: isSaving,
                  canSave:
                      !isLoading &&
                      loadError == null &&
                      meterReadings.any((meter) => meter.isCompleted),
                  onCancel: () {
                    Navigator.pop(context);
                  },
                  onSave: () async {
                    setState(() {
                      isSaving = true;
                    });

                    try {
                      final loginData = context.read<LoginProvider>().loginData;
                      final token =
                          loginData?.token ?? ApiService.currentToken ?? '';
                      final userSession = loginData?.encodedUserSession ??
                          ApiService.currentUserSession ??
                          '';
                      final roleId = context.read<LoginProvider>().selectedRoleId ??
                          (loginData != null && loginData.roleIds.isNotEmpty
                              ? loginData.roleIds.split(',').first.trim()
                              : ApiService.currentRoleId ?? '1');
                      final userId = loginData?.id ?? 0;

                      final payload = meterReadings.map((meter) {
                        return meter.toApiJson(
                          userId: userId,
                          date: widget.date,
                        );
                      }).toList();

                      debugPrint("========== METER SAVE PAYLOAD ==========");
                      debugPrint(payload.toString());
                      debugPrint("========================================");

                      final result = await ApiService().addTrainsetMeterReadings(
                        readings: payload,
                        token: token,
                        userSession: userSession,
                        roleId: roleId,
                      );

                      if (!mounted) return;

                      final statusVal = result['Status'] ?? result['status'];
                      final isSuccess = statusVal != null && statusVal != 0;

                      if (isSuccess) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Meter readings saved successfully"),
                            backgroundColor: Colors.green,
                          ),
                        );

                        final completed = meterReadings
                            .where((e) => e.isCompleted)
                            .length;
                        String status;
                        if (completed == 0) {
                          status = "Not Started";
                        } else if (completed == meterReadings.length) {
                          status = "Completed";
                        } else {
                          status = "Partial";
                        }

                        Navigator.pop(context, status);
                      } else {
                        final msg = result['Message'] ??
                            result['message'] ??
                            "Failed to save meter readings";
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(msg.toString()),
                            backgroundColor: Colors.red,
                          ),
                        );
                        setState(() {
                          isSaving = false;
                        });
                      }
                    } catch (e) {
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Failed to save: $e"),
                          backgroundColor: Colors.red,
                        ),
                      );
                      setState(() {
                        isSaving = false;
                      });
                    }
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
