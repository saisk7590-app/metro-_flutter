import 'package:flutter/material.dart';

class SidebarLogout extends StatelessWidget {
  final VoidCallback onTap;

  const SidebarLogout({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.red.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.red.withValues(alpha: 0.25)),
          ),
          child: const Row(
            children: [
              Icon(Icons.logout, color: Colors.red),

              SizedBox(width: 12),

              Expanded(
                child: Text(
                  "Logout",
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              Icon(Icons.chevron_right, color: Colors.red),
            ],
          ),
        ),
      ),
    );
  }
}
