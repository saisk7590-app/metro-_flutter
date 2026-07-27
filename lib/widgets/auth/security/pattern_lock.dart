import 'package:flutter/material.dart';

import 'pattern_dot.dart';
import 'pattern_painter.dart';

class PatternLock extends StatefulWidget {
  final ValueChanged<List<int>> onPatternChanged;

  const PatternLock({super.key, required this.onPatternChanged});

  @override
  State<PatternLock> createState() => _PatternLockState();
}

class _PatternLockState extends State<PatternLock> {
  static const int gridSize = 3;
  static const double boardSize = 260;
  static const double dotSize = 24;

  final List<int> _selected = [];

  Offset? _currentPoint;

  double get _cellSize => boardSize / gridSize;

  Offset _dotCenter(int index) {
    final row = index ~/ gridSize;
    final col = index % gridSize;

    return Offset(
      col * _cellSize + _cellSize / 2,
      row * _cellSize + _cellSize / 2,
    );
  }

  int? _hitTest(Offset position) {
    for (int i = 0; i < 9; i++) {
      final center = _dotCenter(i);

      if ((center - position).distance < 28) {
        return i;
      }
    }

    return null;
  }

  void _start(DragStartDetails details) {
    final box = context.findRenderObject() as RenderBox;
    final local = box.globalToLocal(details.globalPosition);

    final hit = _hitTest(local);

    if (hit != null) {
      setState(() {
        _selected.clear();
        _selected.add(hit);
        _currentPoint = local;
      });

      widget.onPatternChanged(_selected);
    }
  }

  void _update(DragUpdateDetails details) {
    final box = context.findRenderObject() as RenderBox;
    final local = box.globalToLocal(details.globalPosition);

    _currentPoint = local;

    final hit = _hitTest(local);

    if (hit != null && !_selected.contains(hit)) {
      setState(() {
        _selected.add(hit);
      });

      widget.onPatternChanged(_selected);
    } else {
      setState(() {});
    }
  }

  void _end(DragEndDetails details) {
    setState(() {
      _currentPoint = null;
    });

    widget.onPatternChanged(_selected);
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).primaryColor;

    return Center(
      child: GestureDetector(
        onPanStart: _start,
        onPanUpdate: _update,
        onPanEnd: _end,
        child: SizedBox(
          width: boardSize,
          height: boardSize,
          child: Stack(
            children: [
              CustomPaint(
                size: const Size(boardSize, boardSize),
                painter: PatternPainter(
                  color: primary,
                  points: _selected.map(_dotCenter).toList(),
                  currentPoint: _currentPoint,
                ),
              ),

              ...List.generate(9, (index) {
                final center = _dotCenter(index);

                return Positioned(
                  left: center.dx - dotSize / 2,
                  top: center.dy - dotSize / 2,
                  child: PatternDot(
                    selected: _selected.contains(index),
                    size: dotSize,
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
