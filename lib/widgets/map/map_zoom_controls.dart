import 'package:flutter/material.dart';

class MapZoomControls extends StatelessWidget {
  final VoidCallback onZoomIn;
  final VoidCallback onZoomOut;
  final VoidCallback onResetZoom;

  const MapZoomControls({
    super.key,
    required this.onZoomIn,
    required this.onZoomOut,
    required this.onResetZoom,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF1E293B).withValues(alpha: 0.92)
            : Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: 0.7),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.add_rounded, size: 20),
            tooltip: "Zoom In",
            visualDensity: VisualDensity.compact,
            color: colors.primary,
            onPressed: onZoomIn,
          ),
          Divider(
            height: 1,
            thickness: 1,
            color: colors.outlineVariant.withValues(alpha: 0.5),
          ),
          IconButton(
            icon: const Icon(Icons.remove_rounded, size: 20),
            tooltip: "Zoom Out",
            visualDensity: VisualDensity.compact,
            color: colors.primary,
            onPressed: onZoomOut,
          ),
          Divider(
            height: 1,
            thickness: 1,
            color: colors.outlineVariant.withValues(alpha: 0.5),
          ),
          IconButton(
            icon: const Icon(Icons.fit_screen_rounded, size: 18),
            tooltip: "Fit Full Depot",
            visualDensity: VisualDensity.compact,
            color: colors.onSurfaceVariant,
            onPressed: onResetZoom,
          ),
        ],
      ),
    );
  }
}
