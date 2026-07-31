import 'package:flutter/material.dart';
import 'package:pattern_lock/pattern_lock.dart';

class PatternLockWidget extends StatelessWidget {
  final ValueChanged<List<int>> onPatternComplete;

  const PatternLockWidget({super.key, required this.onPatternComplete});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Center(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final maxSide = constraints.maxWidth.isFinite
              ? constraints.maxWidth
              : MediaQuery.of(context).size.width;
          final size = (maxSide * 0.8).clamp(160.0, 280.0);

          return SizedBox(
            width: size,
            height: size,
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
          );
        },
      ),
    );
  }
}
