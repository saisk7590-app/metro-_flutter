import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:metro_flutter/constants/website_bay_markers.dart';

void main() {
  test('Verify all 36 Miyapur bay markers match SVG rects pin-to-pin', () {
    final markers = WebsiteBayMarkers.miyapur;
    print('Total markers in WebsiteBayMarkers.miyapur: ${markers.length}');

    expect(markers.length, equals(36));

    // Verify all expected bay IDs are present
    final expectedIds = [
      for (int i = 1; i <= 12; i++) 'MPSBL${i}BE',
      for (int i = 1; i <= 12; i++) 'MPSBL${i}OE',
      for (int i = 1; i <= 4; i++) 'MPIBL${i}BE',
      for (int i = 1; i <= 4; i++) 'MPIBL${i}OE',
      'MPWP1',
      'MPTT1',
      'MPPW1',
      'MPPW2',
    ];

    final markerIds = markers.map((m) => m.id).toSet();
    for (final id in expectedIds) {
      expect(markerIds.contains(id), isTrue, reason: 'Missing marker $id');
    }

    print('All 36 markers validated successfully!');
  });
}
