import 'package:flutter/material.dart';

/// Informational banner for Wheel Measurement digital standard
class WheelStandardsBanner extends StatelessWidget {
  const WheelStandardsBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E3A8A), Color(0xFF3B82F6)],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Row(
        children: [
          Icon(Icons.info_outline, color: Colors.white, size: 28),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Digital Field Recording Standard",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  "Readings recorded via mobile validate in real-time against NxAMS Metro specifications to cut off paper notebook delays.",
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Criteria Card displaying allowable tolerances for a wheel measurement parameter
class WheelCriteriaCard extends StatelessWidget {
  final String title;
  final String range;
  final String description;
  final Color color;
  final IconData icon;
  final bool isDark;

  const WheelCriteriaCard({
    super.key,
    required this.title,
    required this.range,
    required this.description,
    required this.color,
    required this.icon,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          range,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: color,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Table displaying differential wear limits across axle, bogie, and car
class WheelDiffTable extends StatelessWidget {
  final bool isDark;

  const WheelDiffTable({super.key, required this.isDark});

  Widget _buildDiffRow(String title, String limit, String note, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                ),
                Text(
                  note,
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              limit,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            _buildDiffRow(
              "Within Same Axle",
              "≤ 1.0 mm",
              "Diameter variance between LHS and RHS on same axle",
              Colors.red,
            ),
            const Divider(),
            _buildDiffRow(
              "Within Same Bogie (Motor)",
              "≤ 3.0 mm",
              "Variance between 4 wheels on a Motor Bogie (DMA / DMB)",
              Colors.orange,
            ),
            const Divider(),
            _buildDiffRow(
              "Within Same Bogie (Trailer)",
              "≤ 6.0 mm",
              "Variance between 4 wheels on a Trailer Bogie (TC)",
              Colors.amber.shade800,
            ),
            const Divider(),
            _buildDiffRow(
              "Within Same Car (Motor)",
              "≤ 6.0 mm",
              "Variance across all 8 wheels of a DMA / DMB Car",
              Colors.indigo,
            ),
            const Divider(),
            _buildDiffRow(
              "Within Same Car (Trailer)",
              "≤ 13.0 mm",
              "Variance across all 8 wheels of a Trailer (TC) Car",
              Colors.blue,
            ),
          ],
        ),
      ),
    );
  }
}
