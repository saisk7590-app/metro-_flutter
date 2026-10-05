import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/active_trains_provider.dart';
import '../../providers/maintenance_bay_provider.dart';
import '../../constants/map_data.dart';

class SectionButtons extends StatelessWidget {
  final String depot;
  final List<String> sections;
  final String selectedSection;
  final Map<String, String> colors;
  final ValueChanged<String> onSectionSelected;

  const SectionButtons({
    super.key,
    required this.depot,
    required this.sections,
    required this.selectedSection,
    required this.colors,
    required this.onSectionSelected,
  });

  Color _hexToColor(String hex) {
    hex = hex.replaceAll('#', '');
    if (hex.length == 6) {
      hex = 'FF$hex';
    }
    return Color(int.parse(hex, radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    final bayProvider = context.watch<MaintenanceBayProvider>();
    final activeTrainsProvider = context.watch<ActiveTrainsProvider>();

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: sections.map((section) {
        final isSelected = section == selectedSection;
        final lineColor = _hexToColor(colors[section] ?? '#9E9E9E');

        // Dynamic occupancy count from ground-truth MaintenanceBayProvider
        final bayOccupied = bayProvider.getOccupiedCount(depot, section);
        final activeOccupied = activeTrainsProvider.getOccupiedCount(depot, section);
        final occupied = bayOccupied > 0 ? bayOccupied : activeOccupied;
        final total = MapData.sectionCapacity[depot]?[section] ?? 0;
        final capacityString = '$occupied/$total';

        return GestureDetector(
          onTap: () {
            // Clicking currently selected section toggles back to full view
            if (isSelected) {
              onSectionSelected('');
            } else {
              onSectionSelected(section);
            }
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 88,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(
                color: isSelected ? lineColor : Colors.grey.shade300,
                width: isSelected ? 2.5 : 1.0,
              ),
              borderRadius: BorderRadius.circular(8),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: lineColor.withValues(alpha: 0.35),
                        blurRadius: 6,
                        spreadRadius: 1,
                      ),
                    ]
                  : [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 3,
                        offset: const Offset(0, 1),
                      ),
                    ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                /// Line Code Header (NxAMS Style)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  decoration: BoxDecoration(
                    color: lineColor.withValues(alpha: 0.18),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(6),
                      topRight: Radius.circular(6),
                    ),
                  ),
                  child: Text(
                    section,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: lineColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),

                /// Occupancy Count Body
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 7),
                  child: Text(
                    capacityString,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: isSelected ? lineColor : Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
