import 'package:flutter/material.dart';

import '../../constants/map_data.dart';
import '../../widgets/common/custom_dropdown.dart';
import '../../widgets/map/section_buttons.dart';
import '../../widgets/map/depot_map.dart';
import '../../widgets/common/custom_header.dart';
import '../../widgets/map/bay_allocation_table.dart';

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
    final colors = Theme.of(context).colorScheme;

    return ColoredBox(
      color: colors.surface,
      child: Column(
        children: [
          const CustomHeader(title: "Dashboard", subtitle: "Depot Overview"),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
              ],
            ),
          ),

          const SizedBox(height: 8),

          /// MAP
          Expanded(
            flex: 5,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: DepotMap(
                depot: selectedDepot == 'Select Depot' ? '' : selectedDepot,
                selectedSection: selectedSection,
              ),
            ),
          ),

          const SizedBox(height: 12),

          if (selectedDepot != 'Select Depot')
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                child: BayAllocationTable(
                  title: "$selectedSection Allocation",
                  depotName: selectedDepot,
                  sectionName: selectedSection,
                  tracks: MapData.getTracks(selectedDepot, selectedSection),
                ),
              ),
            )
          else
            const SizedBox.shrink(),
        ],
      ),
    );
  }
}
