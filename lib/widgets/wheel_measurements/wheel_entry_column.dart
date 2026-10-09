import 'package:flutter/material.dart';
import '../../models/wheel_measurement_model.dart';

/// Single parameter text input field with tolerance validation highlight
class WheelParamField extends StatelessWidget {
  final String label;
  final String initialValue;
  final String? error;
  final ValueChanged<String> onChanged;

  const WheelParamField({
    super.key,
    required this.label,
    required this.initialValue,
    this.error,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final hasError = error != null;

    return TextFormField(
      initialValue: initialValue,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      onChanged: onChanged,
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: hasError ? Colors.red : null,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          fontSize: 10,
          color: hasError ? Colors.red : Colors.grey.shade600,
        ),
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: BorderSide(color: hasError ? Colors.red : Colors.grey.shade400),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: BorderSide(color: hasError ? Colors.red : Colors.grey.shade400),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: BorderSide(color: hasError ? Colors.red : Colors.blue, width: 1.5),
        ),
      ),
    );
  }
}

/// LHS or RHS single wheel input column
class WheelEntryColumn extends StatelessWidget {
  final String sideTitle;
  final WheelItem wheel;
  final bool isDark;
  final VoidCallback onWheelChanged;

  const WheelEntryColumn({
    super.key,
    required this.sideTitle,
    required this.wheel,
    required this.isDark,
    required this.onWheelChanged,
  });

  @override
  Widget build(BuildContext context) {
    final diaError = WheelTolerances.validateDia(wheel.dia);
    final ftError = WheelTolerances.validateFT(wheel.ft);
    final fhError = WheelTolerances.validateFH(wheel.fh);
    final qrError = WheelTolerances.validateQR(wheel.qr);

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "$sideTitle • ${wheel.assetPosition}",
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.blue),
              ),
              if (diaError != null)
                const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 14),
            ],
          ),
          const SizedBox(height: 6),
          WheelParamField(
            label: "Dia (780-860.5)",
            initialValue: wheel.dia?.toString() ?? '',
            error: diaError,
            onChanged: (val) {
              wheel.dia = double.tryParse(val);
              onWheelChanged();
            },
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: WheelParamField(
                  label: "FT (25-33)",
                  initialValue: wheel.ft?.toString() ?? '',
                  error: ftError,
                  onChanged: (val) {
                    wheel.ft = double.tryParse(val);
                    onWheelChanged();
                  },
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: WheelParamField(
                  label: "FH (28-36)",
                  initialValue: wheel.fh?.toString() ?? '',
                  error: fhError,
                  onChanged: (val) {
                    wheel.fh = double.tryParse(val);
                    onWheelChanged();
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: WheelParamField(
                  label: "QR (≥6.5)",
                  initialValue: wheel.qr?.toString() ?? '',
                  error: qrError,
                  onChanged: (val) {
                    wheel.qr = double.tryParse(val);
                    onWheelChanged();
                  },
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: WheelParamField(
                  label: "Oval (≤0.5)",
                  initialValue: wheel.ovality?.toString() ?? '',
                  onChanged: (val) {
                    wheel.ovality = double.tryParse(val);
                    onWheelChanged();
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: WheelParamField(
                  label: "Warp (≤1.0)",
                  initialValue: wheel.warp?.toString() ?? '',
                  onChanged: (val) {
                    wheel.warp = double.tryParse(val);
                    onWheelChanged();
                  },
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: WheelParamField(
                  label: "DIF",
                  initialValue: wheel.dif?.toString() ?? '',
                  onChanged: (val) {
                    wheel.dif = double.tryParse(val);
                    onWheelChanged();
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
