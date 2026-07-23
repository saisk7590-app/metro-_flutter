import 'package:flutter/material.dart';

//import '../../widgets/drawer_menu_button.dart';
import '../../widgets/common/custom_header.dart';

class MeterDashboardScreen extends StatefulWidget {
  const MeterDashboardScreen({super.key});

  @override
  State<MeterDashboardScreen> createState() => _MeterDashboardScreenState();
}

class _MeterDashboardScreenState extends State<MeterDashboardScreen> {
  final TextEditingController _searchController = TextEditingController();

  String selectedDepot = 'All';
  String selectedStatus = 'All';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return ColoredBox(
      color: colors.surface,
      child: Column(
        children: [
          const CustomHeader(
            title: "Meter Dashboard",
            subtitle: "Energy Meter Monitoring",
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  //-----------------------------
                  // Summary Cards
                  //-----------------------------
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      _buildStatCard(context, "Total", "0", Colors.blue),
                      _buildStatCard(context, "Healthy", "0", Colors.green),
                      _buildStatCard(context, "Pending", "0", Colors.orange),
                      _buildStatCard(context, "Faulty", "0", Colors.red),
                    ],
                  ),
                  const SizedBox(height: 20),
                  //-----------------------------
                  // Search + Filter Card
                  //-----------------------------
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E293B) : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: colors.outline.withAlpha(100)),
                    ),
                    child: Column(
                      children: [
                        TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: "Search Meter...",
                            prefixIcon: const Icon(Icons.search),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                initialValue: selectedDepot,
                                decoration: const InputDecoration(
                                  labelText: "Depot",
                                ),
                                items: const [
                                  DropdownMenuItem(
                                    value: "All",
                                    child: Text("All"),
                                  ),
                                  DropdownMenuItem(
                                    value: "Miyapur",
                                    child: Text("Miyapur"),
                                  ),
                                  DropdownMenuItem(
                                    value: "Uppal",
                                    child: Text("Uppal"),
                                  ),
                                ],
                                onChanged: (v) {
                                  setState(() {
                                    selectedDepot = v!;
                                  });
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                initialValue: selectedStatus,
                                decoration: const InputDecoration(
                                  labelText: "Status",
                                ),
                                items: const [
                                  DropdownMenuItem(
                                    value: "All",
                                    child: Text("All"),
                                  ),
                                  DropdownMenuItem(
                                    value: "Healthy",
                                    child: Text("Healthy"),
                                  ),
                                  DropdownMenuItem(
                                    value: "Pending",
                                    child: Text("Pending"),
                                  ),
                                  DropdownMenuItem(
                                    value: "Faulty",
                                    child: Text("Faulty"),
                                  ),
                                ],
                                onChanged: (v) {
                                  setState(() {
                                    selectedStatus = v!;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  //-----------------------------
                  // Meter List Title
                  //-----------------------------
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text(
                        "Meters (0)",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  //-----------------------------
                  // Empty State
                  //-----------------------------
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 60),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E293B) : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: colors.outline),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.electric_meter,
                          size: 70,
                          color: colors.secondary,
                        ),
                        const SizedBox(height: 15),
                        const Text(
                          "No Meter Readings",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Meter readings will appear here once available.",
                          style: TextStyle(color: colors.secondary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    Color color,
  ) {
    final colors = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final width = (MediaQuery.of(context).size.width - 64) / 4 < 140
        ? (MediaQuery.of(context).size.width - 50) / 2
        : (MediaQuery.of(context).size.width - 68) / 4;

    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.outline.withAlpha(100)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: colors.secondary,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w900,
              fontSize: 24,
            ),
          ),
        ],
      ),
    );
  }
}
