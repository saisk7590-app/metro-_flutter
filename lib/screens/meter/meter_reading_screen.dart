import 'package:flutter/material.dart';

import '../../constants/data.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_dropdown.dart';
import '../../widgets/custom_input.dart';
import '../../widgets/drawer_menu_button.dart';

class MeterReadingScreen extends StatefulWidget {
  const MeterReadingScreen({super.key});

  @override
  State<MeterReadingScreen> createState() => _MeterReadingScreenState();
}

class _MeterReadingScreenState extends State<MeterReadingScreen> {

  String depot = '';
  String meter = '';
  String status = 'Healthy';

  DateTime selectedDate = DateTime.now();

  final previousReadingController =
      TextEditingController(text: '0.00');

  final currentReadingController =
      TextEditingController();

  final consumptionController =
      TextEditingController(text: '0.00');

  final remarksController =
      TextEditingController();

  @override
  void initState() {
    super.initState();

    currentReadingController.addListener(_calculateConsumption);
  }

  @override
  void dispose() {
    previousReadingController.dispose();
    currentReadingController.dispose();
    consumptionController.dispose();
    remarksController.dispose();
    super.dispose();
  }

  void _calculateConsumption() {

    final previous =
        double.tryParse(previousReadingController.text) ?? 0;

    final current =
        double.tryParse(currentReadingController.text) ?? 0;

    final consumption = current - previous;

    if (consumption >= 0) {
      consumptionController.text =
          consumption.toStringAsFixed(2);
    } else {
      consumptionController.text = '0.00';
    }
  }

  Future<void> _pickDate() async {

    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  void _saveReading() {

    if (depot.isEmpty ||
        meter.isEmpty ||
        currentReadingController.text.isEmpty) {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              "Please fill all mandatory fields."),
        ),
      );

      return;
    }

    final previous =
        double.tryParse(previousReadingController.text) ?? 0;

    final current =
        double.tryParse(currentReadingController.text) ?? 0;

    if (current < previous) {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              "Current reading cannot be less than previous reading."),
        ),
      );

      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Reading Saved Successfully"),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark =
        theme.brightness == Brightness.dark;

    return Scaffold(

      backgroundColor: colors.surface,

      appBar: AppBar(

        elevation: 0,

        backgroundColor:
            isDark
                ? const Color(0xFF1E293B)
                : Colors.white,

        centerTitle: false,

        leading: DrawerMenuButton(),

        title: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [

            Text(
              "METER READING",
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 18,
                color: theme.primaryColor,
                letterSpacing: 0.5,
              ),
            ),

            Text(
              "Record Energy Meter Reading",
              style: TextStyle(
                fontSize: 12,
                color: colors.secondary,
              ),
            ),
          ],
        ),
      ),

      body: Center(

        child: SingleChildScrollView(

          padding: const EdgeInsets.all(16),

          child: ConstrainedBox(

            constraints:
                const BoxConstraints(maxWidth: 600),

            child: Container(

              padding: const EdgeInsets.all(20),

              decoration: BoxDecoration(

                color: colors.surface,

                borderRadius:
                    BorderRadius.circular(16),

                border: Border.all(
                  color: colors.outline,
                ),

                boxShadow: [

                  BoxShadow(
                    color:
                        Colors.black.withAlpha(20),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),

              child: Column(

                crossAxisAlignment:
                    CrossAxisAlignment.stretch,

                children: [

                  CustomDropdown(
                    label: "Depot",
                    selectedValue: depot,
                    options: AppData.depots,
                    onChanged: (value) {
                      setState(() {
                        depot = value;
                      });
                    },
                  ),

                  CustomDropdown(
                    label: "Meter",
                    selectedValue: meter,
                    options: const [
                      "EM-001",
                      "EM-002",
                      "EM-003",
                      "EM-004",
                    ],
                    keyboardEnabled: true,
                    onChanged: (value) {

                      setState(() {

                        meter = value;

                        previousReadingController.text =
                            "12540.25";

                        _calculateConsumption();

                      });

                    },
                  ),
                                    const SizedBox(height: 16),

                  // Reading Date
                  InkWell(
                    onTap: _pickDate,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: colors.outline),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today_outlined),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              "${selectedDate.day.toString().padLeft(2, '0')}/"
                              "${selectedDate.month.toString().padLeft(2, '0')}/"
                              "${selectedDate.year}",
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Previous Reading
                  CustomInput(
                    label: "Previous Reading (kWh)",
                    controller: previousReadingController,
                    placeholder: "Previous Reading",
                    enabled: false,
                  ),

                  // Current Reading
                  CustomInput(
                    label: "Current Reading (kWh)",
                    controller: currentReadingController,
                    placeholder: "Enter current reading",
                    keyboardType: TextInputType.number,
                  ),

                  // Consumption
                  CustomInput(
                    label: "Consumption (kWh)",
                    controller: consumptionController,
                    placeholder:"Calculated automatically",
                    enabled: false,
                  ),

                  CustomDropdown(
                    label: "Status",
                    selectedValue: status,
                    options: const [
                      "Healthy",
                      "Faulty",
                      "Maintenance",
                      "Offline",
                    ],
                    onChanged: (value) {
                      setState(() {
                        status = value;
                      });
                    },
                  ),

                  CustomInput(
                    label: "Remarks",
                    controller: remarksController,
                    placeholder: "Optional remarks...",
                    multiline: true,
                  ),

                  const SizedBox(height: 24),

                  CustomButton(
                    title: "SAVE READING",
                    onPressed: _saveReading,
                    backgroundColor: theme.primaryColor,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}