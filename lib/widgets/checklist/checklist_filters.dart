import 'package:flutter/material.dart';

import '../common/custom_button.dart';
import '../common/custom_dropdown.dart';

class ChecklistFilters extends StatefulWidget {
  const ChecklistFilters({super.key});

  @override
  State<ChecklistFilters> createState() => _ChecklistFiltersState();
}

class _ChecklistFiltersState extends State<ChecklistFilters> {
  bool expanded = false;

  String selectedCategory = "All";
  String selectedJobPlan = "All";
  String selectedChecklist = "All";
  String selectedStatus = "All";

  final List<String> categoryOptions = const [
    "All",
    "Rolling Stock",
    "Track",
    "Electrical",
    "Civil",
  ];

  final List<String> jobPlanOptions = const [
    "All",
    "Daily Inspection",
    "Weekly Inspection",
    "Monthly Inspection",
  ];

  final List<String> checklistOptions = const [
    "All",
    "ABCDE",
    "MAINTENANCE CHECK LIST – AFC STATION ASSETS BI-WEEKLY",
    "MAINTENANCE CHECK LIST – AFC STATION ASSETS MONTHLY",
    "New Check",
    "MAINTENANCE BEG STN CHECK LIST",
    "MAINTENANCE INTERCHANGE STN CHECK LIST",
    "MAINTENANCE JCP STN CHECK LIST",
  ];

  final List<String> statusOptions = const ["All", "Active", "Inactive"];

  void resetFilters() {
    setState(() {
      selectedCategory = "All";
      selectedJobPlan = "All";
      selectedChecklist = "All";
      selectedStatus = "All";
    });
  }

  void applyFilters() {
    // TODO: Apply API/Provider filtering here.

    setState(() {
      expanded = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Filters applied"),
        duration: Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {
              setState(() {
                expanded = !expanded;
              });
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Row(
                children: [
                  Icon(Icons.filter_alt_outlined, color: colors.primary),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      "Filters",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Icon(
                    expanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                  ),
                ],
              ),
            ),
          ),

          if (expanded) ...[
            const Divider(height: 1),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  CustomDropdown(
                    label: "Category",
                    selectedValue: selectedCategory,
                    options: categoryOptions,
                    onChanged: (value) {
                      setState(() {
                        selectedCategory = value;
                      });
                    },
                  ),

                  CustomDropdown(
                    label: "Job Plan",
                    selectedValue: selectedJobPlan,
                    options: jobPlanOptions,
                    onChanged: (value) {
                      setState(() {
                        selectedJobPlan = value;
                      });
                    },
                  ),

                  CustomDropdown(
                    label: "Checklist",
                    selectedValue: selectedChecklist,
                    options: checklistOptions,
                    onChanged: (value) {
                      setState(() {
                        selectedChecklist = value;
                      });
                    },
                  ),

                  CustomDropdown(
                    label: "Status",
                    selectedValue: selectedStatus,
                    options: statusOptions,
                    onChanged: (value) {
                      setState(() {
                        selectedStatus = value;
                      });
                    },
                  ),

                  const SizedBox(height: 8),

                  Row(
                    children: [
                      Expanded(
                        child: CustomButton(
                          title: "Reset",
                          isSecondary: true,
                          onPressed: resetFilters,
                        ),
                      ),

                      const SizedBox(width: 12),

                      Expanded(
                        child: CustomButton(
                          title: "Apply",
                          icon: Icons.search,
                          onPressed: applyFilters,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
