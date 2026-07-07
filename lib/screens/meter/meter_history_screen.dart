import 'package:flutter/material.dart';
import '../../widgets/drawer_menu_button.dart';

class MeterHistoryScreen extends StatefulWidget {
  const MeterHistoryScreen({super.key});

  @override
  State<MeterHistoryScreen> createState() =>
      _MeterHistoryScreenState();
}

class _MeterHistoryScreenState
    extends State<MeterHistoryScreen> {

  String searchQuery = "";

  final List<Map<String, dynamic>> readings = [

    {
      "meter": "EM-001",
      "depot": "Miyapur",
      "reading": "12850.50",
      "consumption": "310.25",
      "status": "Healthy",
      "date": "03 Jul 2026",
      "time": "10:45 AM",
    },

    {
      "meter": "EM-002",
      "depot": "Uppal",
      "reading": "9620.75",
      "consumption": "215.50",
      "status": "Faulty",
      "date": "02 Jul 2026",
      "time": "03:20 PM",
    },

    {
      "meter": "EM-003",
      "depot": "Miyapur",
      "reading": "8450.10",
      "consumption": "180.30",
      "status": "Healthy",
      "date": "01 Jul 2026",
      "time": "09:15 AM",
    },
  ];

  Future<void> _refresh() async {
    await Future.delayed(
      const Duration(seconds: 1),
    );
  }

  Color getStatusColor(String status) {

    switch (status) {

      case "Healthy":
        return Colors.green;

      case "Faulty":
        return Colors.red;

      case "Maintenance":
        return Colors.orange;

      case "Offline":
        return Colors.grey;

      default:
        return Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {

    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark =
        theme.brightness == Brightness.dark;

    final filtered = readings.where((reading) {

      return reading["meter"]
          .toLowerCase()
          .contains(searchQuery.toLowerCase());

    }).toList();

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
              "METER HISTORY",
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 18,
                color: theme.primaryColor,
                letterSpacing: 0.5,
              ),
            ),

            Text(
              "View Recorded Meter Readings",
              style: TextStyle(
                fontSize: 12,
                color: colors.secondary,
              ),
            ),
          ],
        ),
      ),

      body: RefreshIndicator(

        onRefresh: _refresh,

        child: SingleChildScrollView(

          physics:
              const AlwaysScrollableScrollPhysics(),

          padding:
              const EdgeInsets.all(16),

          child: Column(

            crossAxisAlignment:
                CrossAxisAlignment.start,

            children: [

              TextField(

                onChanged: (value) {

                  setState(() {

                    searchQuery = value;

                  });

                },

                decoration: InputDecoration(

                  hintText: "Search Meter",

                  prefixIcon:
                      const Icon(Icons.search),

                  border: OutlineInputBorder(

                    borderRadius:
                        BorderRadius.circular(12),

                  ),
                ),
              ),

              const SizedBox(height: 20),

              Text(

                "History (${filtered.length})",

                style: const TextStyle(

                  fontSize: 18,

                  fontWeight: FontWeight.bold,

                ),
              ),

              const SizedBox(height: 12),

              if (filtered.isEmpty)

                Center(

                  child: Padding(

                    padding: const EdgeInsets.only(
                      top: 80,
                    ),

                    child: Column(

                      children: [

                        Icon(

                          Icons.history,

                          size: 70,

                          color: colors.secondary,

                        ),

                        const SizedBox(height: 16),

                        const Text(

                          "No History Found",

                          style: TextStyle(

                            fontSize: 18,

                            fontWeight: FontWeight.bold,

                          ),
                        ),
                      ],
                    ),
                  ),
                )

              else

                ListView.builder(

                  shrinkWrap: true,

                  physics:
                      const NeverScrollableScrollPhysics(),

                  itemCount: filtered.length,

                  itemBuilder: (context, index) {

                    final item = filtered[index];

                    // PART 2 CONTINUES HERE...
                    return Card(

                        elevation: 2,
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [

                                /// Meter Number + Status
                                Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                    Text(
                                    item['meter'],
                                    style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                    ),
                                    ),
                                    Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                        color: item['status'] == 'Healthy'
                                            ? Colors.green.withAlpha(25)
                                            : Colors.red.withAlpha(25),
                                        borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                        item['status'],
                                        style: TextStyle(
                                        color: item['status'] == 'Healthy'
                                            ? Colors.green
                                            : Colors.red,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                        ),
                                    ),
                                    ),
                                ],
                                ),

                                const SizedBox(height: 12),

                                /// Reading Details
                                Row(
                                    children: [
                                        const Icon(Icons.speed, size: 18),
                                        const SizedBox(width: 8),
                                        Text(
                                            'Reading : ${item['reading']} kWh',
                                            style: const TextStyle(fontSize: 15),
                                        ),
                                    ],
                                ),

                                const SizedBox(height: 8),

                                Row(
                                    children: [
                                        const Icon(Icons.bolt, size: 18),
                                        const SizedBox(width: 8),
                                        Text(
                                            'Consumption : ${item['consumption']} kWh',
                                            style: const TextStyle(fontSize: 15),
                                        ),
                                    ],
                                ),

                                const Divider(height: 24),

                                /// Date & Time
                                Row(
                                    children: [
                                        const Icon(
                                        Icons.schedule,
                                        size: 18,
                                        color: Colors.grey,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                            "${item['date']} • ${item['time']}",
                                            style: TextStyle(
                                                color: Colors.grey.shade700,
                                            ),
                                        ),
                                    ],
                                ),
                            ],
                            ),  
                        ),
                    );
                    },                  
                ),
            ],
          ),
        ),
      ),
    );
  }
}