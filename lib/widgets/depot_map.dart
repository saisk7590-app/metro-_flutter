import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../constants/map_data.dart';
import '../providers/active_trains_provider.dart';
import '../widgets/assign_train_popup.dart';
import '../widgets/train_details_popup.dart';

class DepotMap extends StatefulWidget {
  final String depot;
  final String selectedSection;

  const DepotMap({
    super.key,
    required this.depot,
    required this.selectedSection,
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
  bool developerMode = true;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _resetZoom();

      if (widget.selectedSection.isNotEmpty) {
        Future.delayed(const Duration(milliseconds: 200), () {
          if (mounted) {
            _zoomToSection();
          }
        });
      }
    });
  }

  @override
  void didUpdateWidget(covariant DepotMap oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.selectedSection != widget.selectedSection) {
      _zoomToSection();
    }
  }

  void _resetZoom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final viewerBox =
          _viewerKey.currentContext?.findRenderObject() as RenderBox?;

      if (viewerBox == null) return;

      final viewport = viewerBox.size;

      const mapWidth = 1800.0;
      const mapHeight = 1200.0;

      final scale = (viewport.width / mapWidth) < (viewport.height / mapHeight)
          ? (viewport.width / mapWidth)
          : (viewport.height / mapHeight);

      final dx = (viewport.width - mapWidth * scale) / 2;
      final dy = (viewport.height - mapHeight * scale) / 2;

      _controller.value = Matrix4.identity()
        ..translateByDouble(dx, dy, 0, 1)
        ..scaleByDouble(scale, scale, 1, 1);
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
        ..scaleByDouble(zoom, zoom, 1, 1);
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
    if (widget.depot.isEmpty) {
      return Container(
        height: 450,
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

    return Container(
      height: MediaQuery.of(context).size.height * .65,
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade400),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          //---------------------------------------------------
          // Header
          //---------------------------------------------------
          Container(
            height: 50,
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
                Text(
                  "${widget.depot} Layout",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: isDark ? Colors.white : const Color(0xFF1E3A8A),
                  ),
                ),

                const Spacer(),

                TextButton.icon(
                  onPressed: _resetZoom,
                  icon: Icon(Icons.refresh, color: theme.primaryColor),
                  label: Text(
                    "Reset",
                    style: TextStyle(color: theme.primaryColor),
                  ),
                ),
              ],
            ),
          ),

          //---------------------------------------------------
          // Map
          //---------------------------------------------------
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
              child: InteractiveViewer(
                key: _viewerKey,
                transformationController: _controller,

                // allow your code (_zoomToSection) to control zoom
                minScale: .2,
                maxScale: 8,
                // user cannot accidentally zoom with mouse wheel
                scaleEnabled: false,
                // user can still drag/pan the map
                panEnabled: true,
                constrained: false,
                boundaryMargin: const EdgeInsets.all(1500),
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
                    debugPrint("");
                  },
                  child: Stack(
                    children: [
                      SizedBox(
                        key: _mapKey,
                        width: 1224,
                        height: 792,
                        child: widget.depot == "Miyapur"
                            ? SvgPicture.asset(
                                "assets/maps/miyapur_layout.svg",
                                fit: BoxFit.contain,
                              )
                            : SvgPicture.asset(
                                "assets/maps/upl_layout_new.svg",
                                fit: BoxFit.contain,
                              ),
                      ),

                      //-------------------------------------------------
                      // Tracks
                      //-------------------------------------------------
                      ..._buildTrackMarkers(),

                      //-------------------------------------------------
                      // Developer Marker
                      //-------------------------------------------------
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
            ),
          ),

          //---------------------------------------------------
          // Developer Panel
          //---------------------------------------------------
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

  List<Widget> _buildTrackMarkers() {
    if (widget.depot.isEmpty) return [];

    final depotCode = widget.depot == 'Miyapur' ? 'MP' : 'UP';
    final activeTrainsProvider = Provider.of<ActiveTrainsProvider>(context);
    List<Widget> markers = [];

    MapData.trackBounds.forEach((trackId, bounds) {
      if (!trackId.startsWith(depotCode)) return;

      final parts = trackId.substring(2).split('-');
      if (parts.length < 2) return;
      final section = parts[0];
      final trackNumber = parts[1];

      final assignment = activeTrainsProvider.getTrainAtSlot(trackId);

      markers.add(
        Positioned(
          left: bounds.x,
          top: bounds.y,
          width: bounds.w,
          height: bounds.h,
          child: GestureDetector(
            onTap: () {
              if (assignment == null) {
                showDialog(
                  context: context,
                  builder: (context) => AssignTrainPopup(
                    depotName: widget.depot,
                    sectionName: section,
                    trackNumber: trackNumber,
                    trackId: trackId,
                  ),
                );
              } else {
                showDialog(
                  context: context,
                  builder: (context) =>
                      TrainDetailsPopup(assignment: assignment),
                );
              }
            },
            child: Tooltip(
              message: trackId,
              child: Container(
                decoration: BoxDecoration(
                  color: assignment != null
                      ? assignment.statusColor.withValues(alpha: 0.6)
                      : Colors.transparent,
                  border: Border.all(
                    color: assignment != null
                        ? assignment.statusColor
                        : Colors.transparent,
                    width: 1,
                  ),
                ),
                child: assignment != null
                    ? FittedBox(child: Icon(Icons.train, color: Colors.white))
                    : null,
              ),
            ),
          ),
        ),
      );
    });

    return markers;
  }
}
