import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/active_trains_provider.dart';
import '../constants/map_data.dart';

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
    final activeTrainsProvider = context.watch<ActiveTrainsProvider>();

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: sections.map((section) {
        final isSelected = section == selectedSection;
        
        final occupied = activeTrainsProvider.getOccupiedCount(depot, section);
        final total = MapData.sectionCapacity[depot]?[section] ?? 0;
        final capacityString = '$occupied/$total';

        return GestureDetector(
          onTap: () => onSectionSelected(section),
          child: Container(
            width: 85,
            decoration: BoxDecoration(
              border: Border.all(
                color: isSelected ? Colors.black : Colors.grey.shade300,
                width: isSelected ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                /// TRACK NAME
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: _hexToColor(colors[section] ?? '#9E9E9E'),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(9),
                      topRight: Radius.circular(9),
                    ),
                  ),
                  child: Text(
                    section,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                /// OCCUPANCY
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  color: Colors.white,
                  child: Text(
                    capacityString,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
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
