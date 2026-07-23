import 'package:flutter/material.dart';

class DeveloperPanel extends StatelessWidget {
  final double x;
  final double y;

  const DeveloperPanel({super.key, required this.x, required this.y});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.black87,
      padding: const EdgeInsets.all(8),
      child: Text(
        "X : ${x.toStringAsFixed(3)}   |   "
        "Y : ${y.toStringAsFixed(3)}",
        style: const TextStyle(color: Colors.white, fontFamily: 'monospace'),
      ),
    );
  }
}
