import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Optimize MYP DEPO 0.svg for mobile adaptability while keeping pin-to-pin vector tracks', () async {
    final svgFile = File('assets/maps/MYP DEPO 0.svg');
    expect(svgFile.existsSync(), isTrue);

    final rawContent = await svgFile.readAsString();
    print('Original SVG size: ${rawContent.length} bytes');

    // Save backup if not already present
    final bakFile = File('assets/maps/MYP DEPO 0.svg.original.bak');
    if (!bakFile.existsSync()) {
      await svgFile.copy(bakFile.path);
      print('Backup saved to: ${bakFile.path}');
    }

    // Extract all lines from line 5 to line 76 (the track rects and path labels)
    // Find where line 5 begins (<rect width="220.521" height="14.7298" transform="matrix(0.960447 ...)
    final rectStartMarker = '<rect width="220.521"';
    final rectStartIndex = rawContent.indexOf(rectStartMarker);
    expect(rectStartIndex != -1, isTrue);

    // Find where the elements end (before </g> or <defs>)
    final defsIndex = rawContent.indexOf('<defs>');
    expect(defsIndex != -1, isTrue);

    final gCloseIndex = rawContent.lastIndexOf('</g>', defsIndex);
    final elementsSlice = rawContent.substring(rectStartIndex, gCloseIndex).trim();

    // Construct the clean, ultra-fast, mobile-adaptable SVG
    final optimizedSvg = '''<svg width="4076" height="2380" viewBox="0 0 4076 2380" fill="none" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink">
  <g id="miyapur_depot_layout">
    <!-- Standalone CAD Blueprint Background (Linked to high-res 4076x2380 PNG) -->
    <image id="depot_cad_background" href="myp_depot_bg.png" xlink:href="myp_depot_bg.png" width="4076" height="2380" x="0" y="0" preserveAspectRatio="none"/>

    <!-- Interactive Track Bay Geometry & Text Labels (100% Pin-to-Pin Original) -->
    $elementsSlice
  </g>
</svg>
''';

    await svgFile.writeAsString(optimizedSvg);
    print('Optimized SVG size: ${optimizedSvg.length} bytes');
    print('Size reduced from ${(rawContent.length / 1024 / 1024).toStringAsFixed(2)} MB to ${(optimizedSvg.length / 1024).toStringAsFixed(2)} KB');

    expect(optimizedSvg.contains('MPSBL1BE'), isTrue);
    expect(optimizedSvg.contains('MPTT1'), isTrue);
    expect(optimizedSvg.contains('myp_depot_bg.png'), isTrue);
  });
}
