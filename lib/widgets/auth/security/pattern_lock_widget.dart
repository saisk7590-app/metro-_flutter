import 'package:flutter/material.dart';
import 'package:pattern_lock/pattern_lock.dart';

class PatternLockWidget extends StatelessWidget {
  final ValueChanged<List<int>> onPatternComplete;

  const PatternLockWidget({
    super.key,
    required this.onPatternComplete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Center(
      child: SizedBox(
        width: 280,
        height: 280,
        child: PatternLock(
          dimension: 3,
          relativePadding: 0.7,
          selectThreshold: 25,
          pointRadius: 12,

          // Theme colors
          selectedColor: colors.primary,
          notSelectedColor: colors.outline,

          fillPoints: true,
          showInput: true,

          onInputComplete: onPatternComplete,
        ),
      ),
    );
  }
}