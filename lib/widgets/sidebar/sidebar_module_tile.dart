import 'package:flutter/material.dart';

class SidebarModuleTile extends StatelessWidget {
  final bool selected;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const SidebarModuleTile({
  super.key,
  required this.title,
  required this.subtitle,
  required this.icon,
  required this.color,
  required this.selected,
  required this.onTap,
});

  @override
  Widget build(BuildContext context) {
    

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: selected
                  ? color.withValues(alpha: 0.10)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: selected ? color : Colors.grey.shade300,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color),
                ),

                const SizedBox(width: 14),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),

                      const SizedBox(height: 2),

                      Text(
                        subtitle,
                        style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),

                Icon(Icons.chevron_right, color: color),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
