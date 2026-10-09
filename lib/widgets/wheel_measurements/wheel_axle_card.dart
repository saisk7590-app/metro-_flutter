import 'package:flutter/material.dart';
import '../../models/wheel_measurement_model.dart';

export 'wheel_entry_column.dart';
import 'wheel_entry_column.dart';

/// Single Axle container with LHS and RHS wheel input columns
class AxleCard extends StatelessWidget {
  final WheelSetItem ws;
  final bool isDark;
  final VoidCallback onWheelChanged;

  const AxleCard({
    super.key,
    required this.ws,
    required this.isDark,
    required this.onWheelChanged,
  });

  @override
  Widget build(BuildContext context) {
    final axleDiff = ws.axleDiaDifference ?? 0.0;
    final isAxleDiffViolated = axleDiff > WheelTolerances.maxSameAxleDiff;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Axle: ${ws.assetPosition} (${ws.assetNo})",
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isAxleDiffViolated ? Colors.red.shade100 : Colors.green.shade100,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  "Axle Diff: ${axleDiff.toStringAsFixed(2)} mm (Max 1mm)",
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: isAxleDiffViolated ? Colors.red.shade900 : Colors.green.shade900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: WheelEntryColumn(
                  sideTitle: "LHS Wheel",
                  wheel: ws.wheels[0],
                  isDark: isDark,
                  onWheelChanged: onWheelChanged,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: WheelEntryColumn(
                  sideTitle: "RHS Wheel",
                  wheel: ws.wheels[1],
                  isDark: isDark,
                  onWheelChanged: onWheelChanged,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Bogie section grouping 2 Axles with bogie difference status
class BogieSection extends StatelessWidget {
  final String bogieTitle;
  final List<WheelSetItem> wheelSets;
  final CarItem car;
  final bool isDark;
  final VoidCallback onWheelChanged;

  const BogieSection({
    super.key,
    required this.bogieTitle,
    required this.wheelSets,
    required this.car,
    required this.isDark,
    required this.onWheelChanged,
  });

  @override
  Widget build(BuildContext context) {
    final bogieWheels = wheelSets.expand((ws) => ws.wheels).toList();
    final dias = bogieWheels.map((w) => w.dia).whereType<double>().toList();
    double bogieDiff = 0.0;
    if (dias.isNotEmpty) {
      final minDia = dias.reduce((a, b) => a < b ? a : b);
      final maxDia = dias.reduce((a, b) => a > b ? a : b);
      bogieDiff = maxDia - minDia;
    }

    final isMotor = car.carType != "TC CAR";
    final maxAllowedBogieDiff = isMotor
        ? WheelTolerances.maxSameBogieMotorDiff
        : WheelTolerances.maxSameBogieTrailerDiff;
    final isBogieViolated = bogieDiff > maxAllowedBogieDiff;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.hub_outlined, size: 18, color: Colors.blue),
                    const SizedBox(width: 8),
                    Text(
                      bogieTitle,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                  ],
                ),
                Text(
                  "Bogie Diff: ${bogieDiff.toStringAsFixed(2)} mm (Max $maxAllowedBogieDiff mm) ${isBogieViolated ? '⚠️' : '✓'}",
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: isBogieViolated ? Colors.red : Colors.green.shade800,
                  ),
                ),
              ],
            ),
          ),
          ...wheelSets.map(
            (ws) => AxleCard(
              ws: ws,
              isDark: isDark,
              onWheelChanged: onWheelChanged,
            ),
          ),
        ],
      ),
    );
  }
}
