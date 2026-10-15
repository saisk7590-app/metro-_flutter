import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../constants/map_data.dart';
import '../../constants/website_bay_markers.dart';
import '../../providers/maintenance_bay/maintenance_bay_provider.dart';
import '../popups/ams_update_popup.dart';

class DepotBayMarkersLayer extends StatelessWidget {
  final String depot;
  final String selectedSection;
  final double scaleX;
  final double scaleY;

  const DepotBayMarkersLayer({
    super.key,
    required this.depot,
    required this.selectedSection,
    this.scaleX = 1.0,
    this.scaleY = 1.0,
  });

  static Color _hexToColor(String hex) {
    final cleanHex = hex.replaceAll('#', '');
    if (cleanHex.length == 6) {
      return Color(int.parse('FF$cleanHex', radix: 16));
    }
    return Color(int.parse(cleanHex, radix: 16));
  }

  static bool _isMarkerInSection(String markerId, String section) {
    if (section.isEmpty) return true;
    final id = markerId.toUpperCase();
    final sec = section.toUpperCase();
    if (sec == 'WP') {
      return id.contains('WP') && !id.contains('MPPW') && !id.contains('UPLPW');
    }
    if (sec == 'PW') {
      return id.contains('MPPW') ||
          id.contains('UPLPW') ||
          (id.contains('PW') && !id.contains('WP'));
    }
    return id.contains(sec);
  }

  @override
  Widget build(BuildContext context) {
    final bayProvider = context.watch<MaintenanceBayProvider>();
    final markers = depot == 'Miyapur'
        ? WebsiteBayMarkers.miyapur
        : WebsiteBayMarkers.uppal;

    final hasSection = selectedSection.isNotEmpty;
    final sectionHex = MapData.sectionColors[depot]?[selectedSection];
    final sectionColor = sectionHex != null ? _hexToColor(sectionHex) : null;

    final widgets = <Widget>[];

    for (final marker in markers) {
      final bay = bayProvider.findBayForMarker(marker.id);
      final isAllocated = bay != null && bay.isAllocated;

      final isInSelected = _isMarkerInSection(marker.id, selectedSection);
      final showHighlight = hasSection && isInSelected;
      final showDimmed = hasSection && !isInSelected;

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
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 250),
              opacity: showDimmed ? 0.30 : 1.0,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // 1. If allocated, show green highlight fill (#28A745) matching SVG track
                  if (isAllocated)
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF28A745).withValues(alpha: 0.85),
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
                            errorBuilder: (context, error, stackTrace) =>
                                const SizedBox.shrink(),
                          ),
                        ),
                      ),
                    ),

                  // 3. Highlight outline for tracks in selected section
                  if (showHighlight && sectionColor != null)
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(2),
                          border: Border.all(
                            color: sectionColor,
                            width: isAllocated ? 2.5 : 1.8,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: sectionColor.withValues(alpha: 0.45),
                              blurRadius: 4,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                      ),
                    ),

                  // 4. Centered white badge with bold Trainset Name (NxAMS style)
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

                  // 5. Interactive touch target & informative tooltip
                  Positioned.fill(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (_) => AMSUpdatePopup(
                            initialDepot: depot,
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
        ),
      );
    }

    return Stack(
      clipBehavior: Clip.none,
      children: widgets,
    );
  }
}
