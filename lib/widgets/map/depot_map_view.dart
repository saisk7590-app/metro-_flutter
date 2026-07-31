import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'developer_marker.dart';
import 'track_markers.dart';

class DepotMapView extends StatelessWidget {
  final String depot;

  final TransformationController controller;

  final GlobalKey mapKey;
  final GlobalKey viewerKey;

  final bool developerMode;
  final Offset? tapPosition;

  final ValueChanged<PointerUpEvent> onPointerUp;

  const DepotMapView({
    super.key,
    required this.depot,
    required this.controller,
    required this.mapKey,
    required this.viewerKey,
    required this.developerMode,
    required this.tapPosition,
    required this.onPointerUp,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(12),
          bottomRight: Radius.circular(12),
        ),
        child: InteractiveViewer(
          key: viewerKey,
          transformationController: controller,
          minScale: .2,
          maxScale: 8,
          scaleEnabled: true, // enable pinch-to-zoom for touch devices
          panEnabled: true,
          constrained: false,
          boundaryMargin: const EdgeInsets.all(1500),
          clipBehavior: Clip.none,
          child: Listener(
            behavior: HitTestBehavior.opaque,
            onPointerUp: onPointerUp,
            child: Stack(
              children: [
                LayoutBuilder(
                  builder: (context, constraints) {
                    final availableWidth = constraints.maxWidth.isFinite
                        ? constraints.maxWidth
                        : MediaQuery.of(context).size.width;
                    // original asset natural size was 1224 x 792 -> preserve aspect ratio
                    const assetAspect = 1224.0 / 792.0;
                    final calculatedHeight = availableWidth / assetAspect;

                    return SizedBox(
                      key: mapKey,
                      width: availableWidth,
                      height: calculatedHeight,
                      child: depot == "Miyapur"
                          ? SvgPicture.asset(
                              "assets/maps/miyapur_layout.svg",
                              fit: BoxFit.contain,
                            )
                          : SvgPicture.asset(
                              "assets/maps/upl_layout_new.svg",
                              fit: BoxFit.contain,
                            ),
                    );
                  },
                ),

                //--------------------------------------
                // Track Markers
                //--------------------------------------
                LayoutBuilder(
                  builder: (context, constraints) {
                    final availableWidth = constraints.maxWidth.isFinite
                        ? constraints.maxWidth
                        : MediaQuery.of(context).size.width;
                    const assetAspect = 1224.0 / 792.0;
                    final calculatedHeight = availableWidth / assetAspect;
                    final scaleX = availableWidth / 1224.0;
                    final scaleY = calculatedHeight / 792.0;

                    return SizedBox(
                      width: availableWidth,
                      height: calculatedHeight,
                      child: TrackMarkers(
                        depot: depot,
                        scaleX: scaleX,
                        scaleY: scaleY,
                      ),
                    );
                  },
                ),

                //--------------------------------------
                // Developer Marker
                //--------------------------------------
                if (developerMode && tapPosition != null)
                  DeveloperMarker(position: tapPosition!),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
