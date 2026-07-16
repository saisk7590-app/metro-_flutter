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
  // String meter = '';
  String status = 'Healthy';

  DateTime selectedDate = DateTime.now();

  //final previousReadingController =
  //   TextEditingController(text: '0.00');

  //final currentReadingController =
  //  TextEditingController();

  //  final consumptionController =
  // TextEditingController(text: '0.00');
  final List<TextEditingController> previousControllers = List.generate(
    5,
    (_) => TextEditingController(text: "0.00"),
  );

  final List<TextEditingController> currentControllers = List.generate(
    5,
    (_) => TextEditingController(),
  );

  final List<TextEditingController> consumptionControllers = List.generate(
    5,
    (_) => TextEditingController(text: "0.00"),
  );

  final remarksController = TextEditingController();

  @override
  void initState() {
    super.initState();

    for (int i = 0; i < 5; i++) {
      currentControllers[i].addListener(() {
        _calculateConsumption(i);
      });
    }
  }

  @override
  void dispose() {
    for (int i = 0; i < 5; i++) {
      previousControllers[i].dispose();
      currentControllers[i].dispose();
      consumptionControllers[i].dispose();
    }

    remarksController.dispose();

    super.dispose();
  }

  void _calculateConsumption(int index) {
    final previous = double.tryParse(previousControllers[index].text) ?? 0;

    final current = double.tryParse(currentControllers[index].text) ?? 0;

    final consumption = current - previous;

    consumptionControllers[index].text = consumption >= 0
        ? consumption.toStringAsFixed(2)
        : "0.00";
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

  void _saveMeter(int index) {
  if (depot.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Please select depot."),
      ),
    );
    return;
  }

  if (currentControllers[index].text.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "Please enter Meter ${index + 1} reading.",
        ),
      ),
    );
    return;
  }

  final previous =
      double.tryParse(previousControllers[index].text) ?? 0;

  final current =
      double.tryParse(currentControllers[index].text) ?? 0;

  if (current < previous) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          "Current reading cannot be less than previous reading.",
        ),
      ),
    );
    return;
  }

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      backgroundColor: Colors.green,
      content: Text(
        "Meter ${index + 1} saved successfully.",
      ),
    ),
  );

  // TODO:
  // Call your API here.
}

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: colors.surface,

      appBar: AppBar(
        elevation: 0,

        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,

        centerTitle: false,

        leading: DrawerMenuButton(),

        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

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
              style: TextStyle(fontSize: 12, color: colors.secondary),
            ),
          ],
        ),
      ),

      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),

          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),

            child: Container(
              padding: const EdgeInsets.all(20),

              decoration: BoxDecoration(
                color: colors.surface,

                borderRadius: BorderRadius.circular(16),

                border: Border.all(color: colors.outline),

                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(20),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,

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
                  for (int i = 0; i < 5; i++)
                    Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      elevation: 1,
                      child: ExpansionTile(
                        initiallyExpanded: false,

                        leading: Icon(
                          Icons.electric_meter,
                          color: theme.primaryColor,
                        ),

                        title: Text(
                          "EM-00${i + 1}",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),

                        subtitle: const Text("Tap to enter reading"),

                        childrenPadding: const EdgeInsets.fromLTRB(
                          16,
                          8,
                          16,
                          16,
                        ),

                        children: [
                          CustomInput(
                            label: "Previous Reading (kWh)",
                            controller: previousControllers[i],
                            placeholder: "Previous Reading",
                            enabled: false,
                          ),

                          const SizedBox(height: 12),

                          CustomInput(
                            label: "Current Reading (kWh)",
                            controller: currentControllers[i],
                            placeholder: "Enter Current Reading",
                            keyboardType: TextInputType.number,
                          ),

                          const SizedBox(height: 12),

                          CustomInput(
                            label: "Consumption (kWh)",
                            controller: consumptionControllers[i],
                            placeholder: "Calculated Automatically",
                            enabled: false,
                          ),

                          const SizedBox(height: 12),

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

                          const SizedBox(height: 20),

                          SizedBox(
                            width: double.infinity,
                            child: CustomButton(
                              title: "SAVE METER ${i + 1}",
                              backgroundColor: theme.primaryColor,
                              onPressed: () {
                                _saveMeter(i);
                              },
                            ),
                          ),
                        ],
                      ),
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
