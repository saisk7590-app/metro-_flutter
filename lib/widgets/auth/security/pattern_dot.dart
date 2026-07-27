import 'package:flutter/material.dart';

class PatternDot extends StatelessWidget {
  final bool selected;
  final double size;
  final VoidCallback? onTap;

  const PatternDot({
    super.key,
    required this.selected,
    this.size = 24,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: selected ? theme.primaryColor : colors.outlineVariant,
          border: Border.all(
            color: selected ? theme.primaryColor : colors.outline,
            width: 2,
          ),
        ),
      ),
    );
  }
}
