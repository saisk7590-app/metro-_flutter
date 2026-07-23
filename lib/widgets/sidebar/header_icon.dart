import 'package:flutter/material.dart';

class HeaderIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const HeaderIcon({super.key, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.20),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: Colors.white),
      ),
    );
  }
}
