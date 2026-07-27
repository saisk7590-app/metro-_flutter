import 'package:flutter/material.dart';

class PatternPainter extends CustomPainter {
  final List<Offset> points;
  final Offset? currentPoint;
  final Color color;

  PatternPainter({
    required this.points,
    required this.color,
    this.currentPoint,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;

    final paint = Paint()
      ..color = color
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final path = Path();

    path.moveTo(points.first.dx, points.first.dy);

    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }

    if (currentPoint != null) {
      path.lineTo(currentPoint!.dx, currentPoint!.dy);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant PatternPainter oldDelegate) {
    return oldDelegate.points != points ||
        oldDelegate.currentPoint != currentPoint;
  }
}
