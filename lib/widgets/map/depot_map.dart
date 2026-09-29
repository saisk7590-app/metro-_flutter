import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;

import '../../constants/map_data.dart';
import '../../constants/website_bay_markers.dart';
import '../../providers/maintenance_bay_provider.dart';
import '../../widgets/popups/ams_update_popup.dart';

class DepotMap extends StatefulWidget {
  final String depot;
  final String selectedSection;
  final VoidCallback? onResetZoom;

  const DepotMap({
    super.key,
    required this.depot,
    required this.selectedSection,
    this.onResetZoom,
  });

  @override
  State<DepotMap> createState() => _DepotMapState();
}

class _DepotMapState extends State<DepotMap> {
  final TransformationController _controller = TransformationController();

  final GlobalKey _mapKey = GlobalKey();
  final GlobalKey _viewerKey = GlobalKey();

  Offset? _tapPosition;
  double _tapX = 0;
  double _tapY = 0;

  /// Turn OFF after collecting coordinates.
  bool developerMode = false;

  static final Map<String, String> _svgCache = {};

  static Future<String> _getDepotSvg(String path) async {
    if (_svgCache.containsKey(path)) return _svgCache[path]!;
    final raw = await rootBundle.loadString(path);
    final processed = raw
        .replaceFirst(
          '<rect width="4076" height="2380" fill="white"/>',
          '<rect width="4076" height="2380" fill="none"/>',
        )
        .replaceFirst(
          '<rect width="2644" height="2111.22" fill="white"/>',
          '<rect width="2644" height="2111.22" fill="none"/>',
        )
        .replaceFirst('fill="url(#pattern0_2_2)"', 'fill="none"')
        .replaceFirst('fill="url(#pattern0_1_2)"', 'fill="none"');
    _svgCache[path] = processed;
    return processed;
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _resetZoom();

      if (widget.selectedSection.isNotEmpty) {
        Future.delayed(const Duration(milliseconds: 200), () {
          if (mounted && widget.selectedSection.isNotEmpty) {
            _zoomToSection();
          }
        });
      }
    });
  }

  @override
  void didUpdateWidget(covariant DepotMap oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.depot != widget.depot) {
      _resetZoom();
    } else if (oldWidget.selectedSection != widget.selectedSection) {
      if (widget.selectedSection.isEmpty) {
        _resetZoom();
      } else {
        _zoomToSection();
      }
    }
  }

  double _depotAspect() {
    switch (widget.depot) {
      case 'Miyapur':
        return 4076.0 / 2380.0;
      case 'Uppal':
        return 2644.0 / 2112.0;
      default:
        return 4076.0 / 2380.0;
    }
  }

  double _depotWidth() {
    switch (widget.depot) {
      case 'Miyapur':
        return 4076.0;
      case 'Uppal':
        return 2644.0;
      default:
        return 4076.0;
    }
  }

  double _depotHeight() {
    switch (widget.depot) {
      case 'Miyapur':
        return 2380.0;
      case 'Uppal':
        return 2112.0;
      default:
        return 2380.0;
    }
  }

  void _resetZoom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final viewerBox =
          _viewerKey.currentContext?.findRenderObject() as RenderBox?;
      final mapBox = _mapKey.currentContext?.findRenderObject() as RenderBox?;

      if (viewerBox == null || mapBox == null) return;

      final viewport = viewerBox.size;
      final mapSize = mapBox.size;

      final scale = math.min(
        viewport.width / mapSize.width,
        viewport.height / mapSize.height,
      );

      final dx = (viewport.width - mapSize.width * scale) / 2;
      final dy = (viewport.height - mapSize.height * scale) / 2;

      _controller.value = Matrix4.identity()
        ..translateByDouble(dx, dy, 0, 1)
        ..scaleByDouble(scale, scale, scale, 1);
    });
  }

  void _zoomToSection() {
    final center =
        MapData.sectionCenters[widget.depot]?[widget.selectedSection];
    final zoom = MapData.zoomLevels[widget.depot]?[widget.selectedSection];

    if (center == null || zoom == null) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final viewerBox =
          _viewerKey.currentContext?.findRenderObject() as RenderBox?;
      final mapBox = _mapKey.currentContext?.findRenderObject() as RenderBox?;

      if (viewerBox == null || mapBox == null) return;

      final viewport = viewerBox.size;
      final mapSize = mapBox.size;

      final targetX = center.x * mapSize.width;
      final targetY = center.y * mapSize.height;

      final tx = viewport.width / 2 - targetX * zoom;
      final ty = viewport.height / 2 - targetY * zoom;

      _controller.value = Matrix4.identity()
        ..translateByDouble(tx, ty, 0, 1)
        ..scaleByDouble(zoom, zoom, zoom, 1);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;
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
          //---------------------------------------------------
          // Header (NxAMS Style)
          //---------------------------------------------------
          Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : const Color(0xFFEAF4FF),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
              border: Border(bottom: BorderSide(color: colors.outline)),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.map,
                  color: isDark ? Colors.blue.shade300 : const Color(0xFF1E3A8A),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "${widget.depot.toUpperCase()} – Depot Layout",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: isMobile ? 13 : 15,
                      color: isDark ? Colors.white : const Color(0xFF1E3A8A),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                TextButton.icon(
                  onPressed: () {
                    _resetZoom();
                    widget.onResetZoom?.call();
                  },
                  icon: Icon(Icons.refresh, color: theme.primaryColor, size: 16),
                  label: Text(
                    "Reset",
                    style: TextStyle(
                      color: theme.primaryColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),

          //---------------------------------------------------
          // Map Canvas
          //---------------------------------------------------
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
              child: LayoutBuilder(
                builder: (context, viewportConstraints) {
                  return InteractiveViewer(
                    key: _viewerKey,
                    transformationController: _controller,
                    minScale: 0.01,
                    maxScale: 6.0,
                    scaleEnabled: true,
                    panEnabled: true,
                    constrained: false,
                    boundaryMargin: const EdgeInsets.all(2500),
                    clipBehavior: Clip.none,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTapUp: (details) {
                        if (!developerMode) return;

                        final box =
                            _mapKey.currentContext!.findRenderObject() as RenderBox;
                        final local = box.globalToLocal(details.globalPosition);
                        final x = local.dx / box.size.width;
                        final y = local.dy / box.size.height;

                        setState(() {
                          _tapPosition = local;
                          _tapX = x;
                          _tapY = y;
                        });

                        debugPrint("");
                        debugPrint("========== ${widget.depot} ==========");
                        debugPrint(
                          "'${widget.selectedSection}': OffsetData("
                          "${x.toStringAsFixed(3)}, "
                          "${y.toStringAsFixed(3)}),",
                        );
                        debugPrint("====================================");
                      },
                      child: SizedBox(
                        key: _mapKey,
                        width: nativeWidth,
                        height: nativeHeight,
                        child: Stack(
                          children: [
                            // 1. Depot CAD Background Layout (extracted standalone PNG)
                            Positioned.fill(
                              child: Image.asset(
                                widget.depot == "Miyapur"
                                    ? "assets/maps/myp_depot_bg.png"
                                    : "assets/maps/upl_depot_bg.png",
                                fit: BoxFit.fill,
                                errorBuilder: (context, error, stackTrace) =>
                                    const SizedBox.shrink(),
                              ),
                            ),

                            // 2. Depot Tracks and Labels (SVG)
                            Positioned.fill(
                              child: FutureBuilder<String>(
                                future: _getDepotSvg(
                                  widget.depot == "Miyapur"
                                      ? "assets/maps/MYP DEPO 0.svg"
                                      : "assets/maps/UPL DEPO 0.svg",
                                ),
                                builder: (context, snapshot) {
                                  if (!snapshot.hasData) {
                                    return const SizedBox.shrink();
                                  }
                                  return SvgPicture.string(
                                    snapshot.data!,
                                    fit: BoxFit.fill,
                                  );
                                },
                              ),
                            ),

                            // 3. Interactive Tracks with Allocation Overlays (NxAMS style)
                            ..._buildTrackMarkers(context, 1.0, 1.0),

                            // 4. Developer Marker
                            if (developerMode && _tapPosition != null)
                              Positioned(
                                left: _tapPosition!.dx - 6,
                                top: _tapPosition!.dy - 6,
                                child: Container(
                                  width: 12,
                                  height: 12,
                                  decoration: const BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // Developer Panel
          if (developerMode)
            Container(
              width: double.infinity,
              color: Colors.black87,
              padding: const EdgeInsets.all(8),
              child: Text(
                "X : ${_tapX.toStringAsFixed(3)}   |   "
                "Y : ${_tapY.toStringAsFixed(3)}",
                style: const TextStyle(
                  color: Colors.white,
                  fontFamily: 'monospace',
                ),
              ),
            ),
        ],
      ),
    );
  }

  List<Widget> _buildTrackMarkers(
    BuildContext context,
    double scaleX,
    double scaleY,
  ) {
    final bayProvider = context.watch<MaintenanceBayProvider>();
    final markers = widget.depot == 'Miyapur'
        ? WebsiteBayMarkers.miyapur
        : WebsiteBayMarkers.uppal;

    final widgets = <Widget>[];

    for (final marker in markers) {
      final bay = bayProvider.findBayForMarker(marker.id);
      final isAllocated = bay != null && bay.isAllocated;

      final trackLeft = marker.x * scaleX;
      final trackTop = marker.y * scaleY;
      final trackWidth = marker.width * scaleX;
      final trackHeight = marker.height * scaleY;
      final angle = marker.angle;

      final trainName = (bay != null && isAllocated)
          ? (bay.trainSetName.isNotEmpty
              ? bay.trainSetName
              : (bay.trainSetId > 0 ? 'TS-${bay.trainSetId}' : ''))
          : '';

      widgets.add(
        Positioned(
          left: trackLeft,
          top: trackTop,
          width: trackWidth,
          height: trackHeight,
          child: Transform.rotate(
            angle: angle,
            alignment: Alignment.topLeft,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // 1. If allocated, show green highlight fill (#28A745) matching SVG track
                if (isAllocated)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF28A745).withOpacity(0.85),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),

                // 2. Train bogie overlay (scaled 2.2x height, vertically centered on track, exactly matching NxAMS)
                if (isAllocated)
                  Positioned(
                    left: 0,
                    top: -(trackHeight * 1.2) / 2,
                    width: trackWidth,
                    height: trackHeight * 2.2,
                    child: IgnorePointer(
                      child: Image.asset(
                        'assets/maps/3 Boghi small High quality.png',
                        fit: BoxFit.fill,
                        errorBuilder: (context, error, stackTrace) => Image.asset(
                          'assets/maps/train_bogie.png',
                          fit: BoxFit.fill,
                          errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
                        ),
                      ),
                    ),
                  ),

                // 3. Centered white badge with bold Trainset Name (NxAMS style)
                if (isAllocated && trainName.isNotEmpty)
                  Positioned.fill(
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 5,
                          vertical: 1,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(2),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 2,
                              offset: Offset(0, 1),
                            ),
                          ],
                        ),
                        child: Text(
                          trainName,
                          style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 9,
                            decoration: TextDecoration.none,
                          ),
                        ),
                      ),
                    ),
                  ),

                // 4. Interactive touch target & informative tooltip
                Positioned.fill(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (_) => AMSUpdatePopup(
                          initialDepot: widget.depot,
                          initialTrack: marker.id,
                          existingBay: bay,
                        ),
                      );
                    },
                    child: Tooltip(
                      message: isAllocated
                          ? '${marker.id}\nTrain: ${bay.trainSetName}\nStatus: ${bay.statusName}\nPurpose: ${bay.purposeName}'
                          : '${marker.id} (Empty)',
                      child: const SizedBox.expand(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return widgets;
  }
}
