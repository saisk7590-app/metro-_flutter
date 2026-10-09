import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Verify MYP DEPO 0.svg slice processing preserves structure and handles embedded pattern cleanly', () async {
    final file = File('assets/maps/MYP DEPO 0.svg');
    expect(file.existsSync(), isTrue);

    final raw = await file.readAsString();
    expect(raw.contains('pattern0_2_2'), isTrue);
    expect(raw.contains('image0_2_2'), isTrue);

    final defsIdx = raw.indexOf('<defs>');
    expect(defsIdx != -1, isTrue);

    final withoutDefs = '${raw.substring(0, defsIdx)}</svg>';
    final processed = withoutDefs
        .replaceFirst(
          '<rect width="4076" height="2380" fill="white"/>',
          '<rect width="4076" height="2380" fill="none"/>',
        )
        .replaceFirst('fill="url(#pattern0_2_2)"', 'fill="none"');

    expect(processed.contains('fill="none"'), isTrue);
    expect(processed.contains('<rect width="4076" height="2380" fill="white"/>'), isFalse);
    expect(processed.contains('fill="url(#pattern0_2_2)"'), isFalse);
    expect(processed.contains('xlink:href="data:image/png;base64,'), isFalse);

    // Track bay rects are verified by their exact CAD coordinates
    expect(processed.contains('1658.58'), isTrue); // MPSBL1BE
    expect(processed.contains('1651.79'), isTrue); // MPSBL2BE
    expect(processed.contains('1726.06'), isTrue); // MPWP1
    expect(processed.contains('1605.34'), isTrue); // MPTT1

    print('SUCCESS: Processed SVG length: ${processed.length} chars (reduced from ${raw.length} chars)');
  });
}
