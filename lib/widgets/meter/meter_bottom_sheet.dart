import 'package:flutter/material.dart';

import '../../models/meter_reading.dart';
import 'meter_expansion_tile.dart';
import 'meter_progress_card.dart';
import 'save_cancel_bar.dart';

class MeterBottomSheet extends StatefulWidget {
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

  String? expandedMeterCode;

  late final List<MeterReading> meterReadings;

  @override
  void initState() {
    super.initState();

    meterReadings = [
      MeterReading(
        meterCode: "HVEC",
        meterName: "HV Consumed Energy",
        assetNumber: "RS1TRS000001",
        previousDate: "29-07-2026",
        previousReading: 2259800,
      ),
      MeterReading(
        meterCode: "HVREG",
        meterName: "HV Regenerated Energy",
        assetNumber: "RS1TRS000001",
        previousDate: "29-07-2026",
        previousReading: 890879,
      ),
      MeterReading(
        meterCode: "MIL",
        meterName: "Accumulative Running Distance",
        assetNumber: "RS1TRS000001",
        previousDate: "29-07-2026",
        previousReading: 1081289,
      ),
      MeterReading(
        meterCode: "TSCOMPDA",
        meterName: "Compressor DA",
        assetNumber: "RS1COMA000001",
        previousDate: "29-07-2026",
        previousReading: 9435,
      ),
      MeterReading(
        meterCode: "TSCOMPDB",
        meterName: "Compressor DB",
        assetNumber: "RS1COMB000001",
        previousDate: "29-07-2026",
        previousReading: 10220,
      ),
    ];
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
                          onExpansionChanged:(isExpanded) {
                            setState(() {
                              expandedMeterCode =
                                  isExpanded ? meter.meterCode : null;
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
                  ),
                ),

                //------------------------------------------------
                // Bottom Buttons
                //------------------------------------------------
                SaveCancelBar(
                  isSaving: isSaving,
                  canSave: meterReadings.any((meter) => meter.isCompleted),
                  onCancel: () {
                    Navigator.pop(context);
                  },
                  onSave: () async {
                    setState(() {
                      isSaving = true;
                    });

                    //------------------------------------------------
                    // Create JSON Payload
                    //------------------------------------------------

                    final payload = {
                      "trainset": widget.trainset,
                      "location": widget.location,
                      "date": widget.date,
                      "meters": meterReadings.map((meter) {
                        return {
                          "meterCode": meter.meterCode,
                          "meterName": meter.meterName,
                          "assetNumber": meter.assetNumber,
                          "previousDate": meter.previousDate,
                          "previousReading": meter.previousReading,
                          "currentReading": meter.currentReading,
                          "netReading": meter.netReading,
                          "remarks": meter.remarks,
                          "reset": meter.reset,
                          "resetRemarks": meter.resetRemarks,
                        };
                      }).toList(),
                    };

                    debugPrint("========== METER PAYLOAD ==========");
                    debugPrint(payload.toString());
                    debugPrint("===================================");

                    await Future.delayed(const Duration(seconds: 2));

                    if (!mounted) return;

                    setState(() {
                      isSaving = false;
                    });

                    //------------------------------------------------
                    // Return Status to Dashboard
                    //------------------------------------------------

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

                    Navigator.pop(this.context, status);
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
