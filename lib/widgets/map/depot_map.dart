import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../../constants/map_data.dart';
import 'depot_cad_background.dart';
import 'depot_bay_markers_layer.dart';
import 'depot_map_header.dart';
import 'developer_marker.dart';
import 'developer_panel.dart';
import 'map_touch_hint.dart';
import 'map_zoom_controls.dart';

class DepotMap extends StatefulWidget {
  final String depot;
  final String selectedSection;
  final VoidCallback? onResetZoom;
  final ValueChanged<bool>? onInteractionChange;

  const DepotMap({
    super.key,
    required this.depot,
    required this.selectedSection,
    this.onResetZoom,
    this.onInteractionChange,
  });

  @override
  State<DepotMap> createState() => _DepotMapState();
}

class _DepotMapState extends State<DepotMap>
    with SingleTickerProviderStateMixin {
  final TransformationController _controller = TransformationController();
  late AnimationController _animController;
  Animation<Matrix4>? _matrixAnimation;

  final GlobalKey _mapKey = GlobalKey();
  final GlobalKey _viewerKey = GlobalKey();

  int _pointerCount = 0;
  Offset? _tapPosition;
  double _tapX = 0;
  double _tapY = 0;

  /// Turn OFF after collecting coordinates.
  bool developerMode = false;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (widget.selectedSection.isNotEmpty) {
        _zoomToSection(animate: false);
      } else {
        _resetZoom(animate: false);
      }
    });
  }

  @override
  void didUpdateWidget(covariant DepotMap oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.depot != widget.depot) {
      if (widget.selectedSection.isNotEmpty) {
        _zoomToSection(animate: false);
      } else {
        _resetZoom(animate: false);
      }
    } else if (oldWidget.selectedSection != widget.selectedSection) {
      if (widget.selectedSection.isEmpty) {
        _resetZoom(animate: true);
      } else {
        _zoomToSection(animate: true);
      }
    }
  }

  @override
  void dispose() {
    _matrixAnimation?.removeListener(_onMatrixAnimTick);
    _animController.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _onMatrixAnimTick() {
    if (_matrixAnimation != null) {
      _controller.value = _matrixAnimation!.value;
    }
  }

  void _handlePointerDown() {
    _pointerCount++;
    if (_pointerCount == 1) widget.onInteractionChange?.call(true);
  }

  void _handlePointerRelease() {
    _pointerCount = math.max(0, _pointerCount - 1);
    if (_pointerCount == 0) widget.onInteractionChange?.call(false);
  }

  void _handleTapUp(TapUpDetails details) {
    if (!developerMode) return;
    final box = _mapKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return;
    final local = box.globalToLocal(details.globalPosition);
    final x = local.dx / box.size.width;
    final y = local.dy / box.size.height;
    setState(() {
      _tapPosition = local;
      _tapX = x;
      _tapY = y;
    });
    debugPrint("\n========== ${widget.depot} ==========");
    debugPrint("'${widget.selectedSection}': OffsetData(${x.toStringAsFixed(3)}, ${y.toStringAsFixed(3)}),");
    debugPrint("====================================");
  }

  void _zoomIn() {
    _zoomBy(1.35);
  }

  void _zoomOut() {
    _zoomBy(1.0 / 1.35);
  }

  void _zoomBy(double factor) {
    final viewerBox =
        _viewerKey.currentContext?.findRenderObject() as RenderBox?;
    if (viewerBox == null || !viewerBox.hasSize) return;

    final size = viewerBox.size;
    final center = Offset(size.width / 2.0, size.height / 2.0);

    final currentMatrix = _controller.value;
    final currentScale = currentMatrix.getMaxScaleOnAxis();
    final targetScale = (currentScale * factor).clamp(0.05, 6.0);
    if (currentScale == 0) return;
    final effectiveFactor = targetScale / currentScale;

    final targetMatrix = Matrix4.translationValues(center.dx, center.dy, 0.0)
      ..multiply(Matrix4.diagonal3Values(effectiveFactor, effectiveFactor, 1.0))
      ..multiply(Matrix4.translationValues(-center.dx, -center.dy, 0.0))
      ..multiply(currentMatrix);

    _animateToMatrix(targetMatrix);
  }

  void _animateToMatrix(Matrix4 targetMatrix) {
    _matrixAnimation?.removeListener(_onMatrixAnimTick);
    _animController.stop();

    final currentMatrix = _controller.value;
    if (currentMatrix == targetMatrix) return;

    _matrixAnimation = Matrix4Tween(
      begin: currentMatrix,
      end: targetMatrix,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    ));

    _matrixAnimation!.addListener(_onMatrixAnimTick);
    _animController.forward(from: 0.0);
  }

  double _depotWidth() => widget.depot == 'Uppal' ? 2644.0 : 4076.0;
  double _depotHeight() => widget.depot == 'Uppal' ? 2112.0 : 2380.0;

  void _resetZoom({bool animate = true}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final viewerBox =
          _viewerKey.currentContext?.findRenderObject() as RenderBox?;
      final mapBox = _mapKey.currentContext?.findRenderObject() as RenderBox?;

      if (viewerBox == null ||
          mapBox == null ||
          !viewerBox.hasSize ||
          !mapBox.hasSize) {
        Future.delayed(const Duration(milliseconds: 50), () {
          if (mounted) _resetZoom(animate: animate);
        });
        return;
      }

      final viewport = viewerBox.size;
      final mapSize = mapBox.size;
      if (viewport.width <= 0 ||
          viewport.height <= 0 ||
          mapSize.width <= 0 ||
          mapSize.height <= 0) {
        return;
      }

      final scale = math.min(
        viewport.width / mapSize.width,
        viewport.height / mapSize.height,
      );

      final dx = (viewport.width - mapSize.width * scale) / 2.0;
      final dy = (viewport.height - mapSize.height * scale) / 2.0;

      final targetMatrix = Matrix4.translationValues(dx, dy, 0.0)
        ..multiply(Matrix4.diagonal3Values(scale, scale, 1.0));

      if (animate) {
        _animateToMatrix(targetMatrix);
      } else {
        _controller.value = targetMatrix;
      }
    });
  }

  void _zoomToSection({bool animate = true}) {
    final bounds =
        MapData.sectionBounds[widget.depot]?[widget.selectedSection];

    if (bounds == null) {
      _resetZoom(animate: animate);
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final viewerBox =
          _viewerKey.currentContext?.findRenderObject() as RenderBox?;
      final mapBox = _mapKey.currentContext?.findRenderObject() as RenderBox?;

      if (viewerBox == null ||
          mapBox == null ||
          !viewerBox.hasSize ||
          !mapBox.hasSize) {
        Future.delayed(const Duration(milliseconds: 50), () {
          if (mounted) _zoomToSection(animate: animate);
        });
        return;
      }

      final viewport = viewerBox.size;
      final mapSize = mapBox.size;
      if (viewport.width <= 0 ||
          viewport.height <= 0 ||
          mapSize.width <= 0 ||
          mapSize.height <= 0) {
        return;
      }

      final overviewScale = math.min(
        viewport.width / mapSize.width,
        viewport.height / mapSize.height,
      );

      final padX = math.max(80.0, bounds.width * 0.18);
      final padY = math.max(80.0, bounds.height * 0.22);
      final paddedWidth = bounds.width + padX * 2.0;
      final paddedHeight = bounds.height + padY * 2.0;

      final scaleX = viewport.width / paddedWidth;
      final scaleY = viewport.height / paddedHeight;
      final fitScale = math.min(scaleX, scaleY);

      final minZoom = overviewScale * 1.35;
      final maxZoom = math.max(minZoom, math.min(2.2, overviewScale * 6.5));
      final zoom = fitScale.clamp(minZoom, maxZoom);

      final centerX = bounds.center.dx;
      final centerY = bounds.center.dy;

      final tx = viewport.width / 2.0 - centerX * zoom;
      final ty = viewport.height / 2.0 - centerY * zoom;

      final mapW = mapSize.width * zoom;
      final mapH = mapSize.height * zoom;

      final clampedTx = mapW > viewport.width
          ? tx.clamp(viewport.width - mapW, 0.0)
          : (viewport.width - mapW) / 2.0;
      final clampedTy = mapH > viewport.height
          ? ty.clamp(viewport.height - mapH, 0.0)
          : (viewport.height - mapH) / 2.0;

      final targetMatrix = Matrix4.translationValues(clampedTx, clampedTy, 0.0)
        ..multiply(Matrix4.diagonal3Values(zoom, zoom, 1.0));

      if (animate) {
        _animateToMatrix(targetMatrix);
      } else {
        _controller.value = targetMatrix;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;
    final screenHeight = MediaQuery.of(context).size.height;
    final containerHeight = isMobile
        ? math.max(340.0, screenHeight * 0.48)
        : math.max(460.0, screenHeight * 0.62);

    if (widget.depot.isEmpty || widget.depot == 'Select Depot') {
      return Container(
        height: isMobile ? 260 : 400,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade400),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Text(
          'Please Select Depot',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
      );
    }

    final nativeWidth = _depotWidth();
    final nativeHeight = _depotHeight();

    return Container(
      height: containerHeight,
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade400),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // Header (NxAMS Style)
          DepotMapHeader(
            depot: widget.depot,
            selectedSection: widget.selectedSection,
            isMobile: isMobile,
            onReset: () {
              _resetZoom(animate: true);
              widget.onResetZoom?.call();
            },
          ),

          // Map Canvas
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
              child: LayoutBuilder(
                builder: (context, viewportConstraints) {
                  return Stack(
                    children: [
                      // 1. InteractiveViewer with Touch-isolation Listener
                      Listener(
                        behavior: HitTestBehavior.opaque,
                        onPointerDown: (_) => _handlePointerDown(),
                        onPointerUp: (_) => _handlePointerRelease(),
                        onPointerCancel: (_) => _handlePointerRelease(),
                        child: InteractiveViewer(
                          key: _viewerKey,
                          transformationController: _controller,
                          minScale: 0.05,
                          maxScale: 6.0,
                          scaleEnabled: true,
                          panEnabled: true,
                          constrained: false,
                          boundaryMargin: EdgeInsets.symmetric(
                            horizontal: math.max(
                              140.0,
                              viewportConstraints.maxWidth * 0.4,
                            ),
                            vertical: math.max(
                              100.0,
                              viewportConstraints.maxHeight * 0.4,
                            ),
                          ),
                          clipBehavior: Clip.hardEdge,
                          interactionEndFrictionCoefficient: 0.0005,
                          onInteractionStart: (_) => widget.onInteractionChange?.call(true),
                          onInteractionEnd: (_) {
                            if (_pointerCount == 0) {
                              widget.onInteractionChange?.call(false);
                            }
                          },
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTapUp: _handleTapUp,
                            child: RepaintBoundary(
                              child: SizedBox(
                                key: _mapKey,
                                width: nativeWidth,
                                height: nativeHeight,
                                child: Stack(
                                  children: [
                                    // 1. Depot CAD Background (PNG) & SVG Tracks
                                    Positioned.fill(
                                      child: DepotCadBackground(
                                        depot: widget.depot,
                                      ),
                                    ),

                                    // 2. Interactive Tracks with Allocation Overlays
                                    Positioned.fill(
                                      child: DepotBayMarkersLayer(
                                        depot: widget.depot,
                                        selectedSection: widget.selectedSection,
                                      ),
                                    ),

                                    // 3. Developer Marker
                                    if (developerMode && _tapPosition != null)
                                      DeveloperMarker(position: _tapPosition!),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      // 2. Floating On-Screen Map Zoom & Fit Controls
                      Positioned(
                        right: 12,
                        bottom: 12,
                        child: MapZoomControls(
                          onZoomIn: _zoomIn,
                          onZoomOut: _zoomOut,
                          onResetZoom: () {
                            _resetZoom(animate: true);
                            widget.onResetZoom?.call();
                          },
                        ),
                      ),

                      // 3. Mobile Touch Hint Banner
                      if (isMobile)
                        const Positioned(
                          left: 12,
                          top: 10,
                          child: MapTouchHintBanner(),
                        ),
                    ],
                  );
                },
              ),
            ),
          ),

          // Developer Panel
          if (developerMode)
            DeveloperPanel(
              x: _tapX,
              y: _tapY,
            ),
        ],
      ),
    );
  }
}
