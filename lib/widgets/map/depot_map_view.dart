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
          scaleEnabled: false,
          panEnabled: true,
          constrained: false,
          boundaryMargin: const EdgeInsets.all(1500),
          clipBehavior: Clip.none,
          child: Listener(
            behavior: HitTestBehavior.opaque,
            onPointerUp: onPointerUp,
            child: Stack(
              children: [
                SizedBox(
                  key: mapKey,
                  width: 1224,
                  height: 792,
                  child: depot == "Miyapur"
                      ? SvgPicture.asset(
                          "assets/maps/miyapur_layout.svg",
                          fit: BoxFit.contain,
                        )
                      : SvgPicture.asset(
                          "assets/maps/upl_layout_new.svg",
                          fit: BoxFit.contain,
                        ),
                ),

                //--------------------------------------
                // Track Markers
                //--------------------------------------
                TrackMarkers(depot: depot),

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
