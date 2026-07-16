import 'package:flutter/material.dart';

import '../../constants/map_data.dart';
import '../../widgets/custom_dropdown.dart';
import '../../widgets/section_buttons.dart';
import '../../widgets/depot_map.dart';
import '../../widgets/custom_header.dart';
import '../../widgets/bay_allocation_table.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String selectedDepot = 'Select Depot';
  String selectedSection = '';

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CustomHeader(title: "Dashboard", subtitle: "Depot Overview"),

          const SizedBox(height: 20),

          /// DEPOT DROPDOWN
          CustomDropdown(
            key: ValueKey(selectedDepot),
            label: 'Depot',
            selectedValue: selectedDepot,
            options: const ['Select Depot', 'Miyapur', 'Uppal'],
            onChanged: (value) {
              setState(() {
                selectedDepot = value;

                if (value == 'Select Depot') {
                  selectedSection = '';
                } else {
                  selectedSection = MapData.depotSections[value]!.first;
                }
              });
            },
          ),

          const SizedBox(height: 16),

          /// SECTION BUTTONS
          if (selectedDepot != 'Select Depot')
            SectionButtons(
              depot: selectedDepot,
              sections: MapData.depotSections[selectedDepot]!,
              selectedSection: selectedSection,
              colors: MapData.sectionColors[selectedDepot]!,
              onSectionSelected: (section) {
                setState(() {
                  selectedSection = section;
                });
              },
            ),

          const SizedBox(height: 16),

          /// RESET BUTTON
          if (selectedDepot != 'Select Depot')
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                onPressed: () {
                  // connect later
                },
                icon: const Icon(Icons.refresh, size: 16),
                label: const Text('Reset'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                ),
              ),
            ),

          if (selectedDepot != 'Select Depot') const SizedBox(height: 12),

          /// MAP
          DepotMap(
            depot: selectedDepot == 'Select Depot' ? '' : selectedDepot,
            selectedSection: selectedSection,
          ),

          const SizedBox(height: 20),

          if (selectedDepot != 'Select Depot')
            BayAllocationTable(
              title: "$selectedSection Allocation",
              depotName: selectedDepot,
              sectionName: selectedSection,
              tracks: MapData.getTracks(selectedDepot, selectedSection),
            ),
        ],
      ),
    );
  }
}
