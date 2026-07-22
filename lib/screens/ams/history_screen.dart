import 'package:flutter/material.dart';
import '../../widgets/custom_header.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CustomHeader(
            title: "History",
            subtitle: "Train Maintenance Records",
          ),

          const SizedBox(height: 20),

          Expanded(
            child: ListView(
              children: const [
                Material(
                  color: Colors.transparent,
                  child: ListTile(
                    title: Text('TS-01'),
                    subtitle: Text('Brake Testing'),
                    trailing: Text('Completed'),
                  ),
                ),
                Material(
                  color: Colors.transparent,
                  child: ListTile(
                    title: Text('TS-05'),
                    subtitle: Text('Inspection'),
                    trailing: Text('In Progress'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
