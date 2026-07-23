import 'package:flutter/material.dart';

class DeveloperMarker extends StatelessWidget {
  final Offset position;

  const DeveloperMarker({super.key, required this.position});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: position.dx - 6,
      top: position.dy - 6,
      child: Container(
        width: 12,
        height: 12,
        decoration: const BoxDecoration(
          color: Colors.red,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
