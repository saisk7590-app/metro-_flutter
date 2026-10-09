import 'package:flutter/material.dart';

import '../../models/meter_reading.dart';
import 'meter_validation.dart';

class MeterDetails extends StatefulWidget {
  final MeterReading meter;
  final VoidCallback onChanged;

  const MeterDetails({
    super.key,
    required this.meter,
    required this.onChanged,
  });

  @override
  State<MeterDetails> createState() => _MeterDetailsState();
}

class _MeterDetailsState extends State<MeterDetails> {
  late final TextEditingController currentReadingController;
  late final TextEditingController remarksController;
  late final TextEditingController resetRemarksController;

  @override
  void initState() {
    super.initState();

    currentReadingController = TextEditingController(
      text: widget.meter.currentReading?.toString() ?? '',
    );

    remarksController = TextEditingController(
      text: widget.meter.remarks,
    );

    resetRemarksController = TextEditingController(
      text: widget.meter.resetRemarks,
    );
  }

  @override
  void dispose() {
    currentReadingController.dispose();
    remarksController.dispose();
    resetRemarksController.dispose();
    super.dispose();
  }

  void _updateMeter() {
    widget.meter.isCompleted = MeterValidation.isMeterCompleted(widget.meter);

    widget.onChanged();

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final errorText = MeterValidation.readingError(
      previousReading: widget.meter.previousReading,
      currentReading: widget.meter.currentReading,
      isReset: widget.meter.reset,
    );

    return Column(
      children: [
        _infoCard(context),

        const SizedBox(height: 20),

        //--------------------------------------------------
        // Current Reading
        //--------------------------------------------------

        TextField(
          controller: currentReadingController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            labelText: "Current Reading",
            border: const OutlineInputBorder(),
            prefixIcon: const Icon(Icons.speed),
            errorText: errorText,
          ),
          onChanged: (value) {
            widget.meter.currentReading = double.tryParse(value);
            _updateMeter();
          },
        ),

        const SizedBox(height: 18),

        //--------------------------------------------------
        // Net Reading
        //--------------------------------------------------

        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.green.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Net Reading",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                "${widget.meter.netReading == widget.meter.netReading.roundToDouble() ? widget.meter.netReading.toInt() : widget.meter.netReading.toStringAsFixed(2)} kWh",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: theme.primaryColor,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        //--------------------------------------------------
        // Remarks
        //--------------------------------------------------

        TextField(
          controller: remarksController,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: "Remarks",
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.notes),
          ),
          onChanged: (value) {
            widget.meter.remarks = value;
            _updateMeter();
          },
        ),

        const SizedBox(height: 18),

        //--------------------------------------------------
        // Reset Meter
        //--------------------------------------------------

        CheckboxListTile(
          value: widget.meter.reset,
          contentPadding: EdgeInsets.zero,
          title: const Text("Reset Meter"),
          subtitle: const Text(
            "Enable if this meter has been reset.",
          ),
          onChanged: (value) {
            widget.meter.reset = value ?? false;
            _updateMeter();
          },
        ),

        //--------------------------------------------------
        // Reset Remarks
        //--------------------------------------------------

        if (widget.meter.reset) ...[
          const SizedBox(height: 12),

          TextField(
            controller: resetRemarksController,
            maxLines: 2,
            decoration: InputDecoration(
              labelText: "Reset Remarks",
              border: const OutlineInputBorder(),
              prefixIcon: const Icon(Icons.warning_amber_rounded),
              errorText: widget.meter.reset &&
                      resetRemarksController.text.trim().isEmpty
                  ? "Reset Remarks is required"
                  : null,
            ),
            onChanged: (value) {
              widget.meter.resetRemarks = value;
              _updateMeter();
            },
          ),
        ],
      ],
    );
  }

  //--------------------------------------------------
  // Information Card
  //--------------------------------------------------

  Widget _infoCard(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          _infoRow(
            Icons.confirmation_number_outlined,
            "Asset Number",
            widget.meter.assetNumber,
          ),

          const Divider(height: 22),

          _infoRow(
            Icons.calendar_today_outlined,
            "Previous Date",
            widget.meter.previousDate,
          ),

          const Divider(height: 22),

          _infoRow(
            Icons.speed_outlined,
            "Previous Reading",
            "${widget.meter.previousReading == widget.meter.previousReading.roundToDouble() ? widget.meter.previousReading.toInt() : widget.meter.previousReading.toStringAsFixed(2)} kWh",
          ),
        ],
      ),
    );
  }

  //--------------------------------------------------
  // Information Row
  //--------------------------------------------------

  Widget _infoRow(
    IconData icon,
    String title,
    String value,
  ) {
    return Row(
      children: [
        Icon(icon, size: 20),

        const SizedBox(width: 12),

        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}