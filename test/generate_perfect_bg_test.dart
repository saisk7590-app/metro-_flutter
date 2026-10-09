import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Generate perfect 4076x2380 Miyapur CAD background PNG', () async {
    print('Starting background generation...');

    // 1. Read existing myp_depot_bg.png
    final inputFile = File('assets/maps/myp_depot_bg.png');
    if (!inputFile.existsSync()) {
      print('Input file not found: ${inputFile.path}');
      return;
    }

    final rawBytes = await inputFile.readAsBytes();
    print('Read input file: ${rawBytes.length} bytes');

    // 2. Decode into ui.Image
    final codec = await ui.instantiateImageCodec(rawBytes);
    final frame = await codec.getNextFrame();
    final sourceImage = frame.image;
    print('Decoded source image: ${sourceImage.width} x ${sourceImage.height}');

    // 3. Create 4076 x 2380 Canvas
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder, const Rect.fromLTWH(0, 0, 4076, 2380));

    // Fill white
    final paintWhite = Paint()..color = Colors.white;
    canvas.drawRect(const Rect.fromLTWH(0, 0, 4076, 2380), paintWhite);

    // Clip to exact blueprint rectangle (x:2, y:37, w:4076, h:2336)
    canvas.save();
    canvas.clipRect(const Rect.fromLTWH(2, 37, 4076, 2336));

    // Apply exact affine transformation matching SVG pattern0_2_2:
    // x' = 5144.672896 - 1.489765772 * py
    // y' = -529.92384 + 1.707601984 * px
    // In Matrix4 (column-major):
    // col0: (0, 1.707601984, 0, 0)
    // col1: (-1.489765772, 0, 0, 0)
    // col2: (0, 0, 1, 0)
    // col3: (5144.672896, -529.92384, 0, 1)
    final matrix = Matrix4(
      0, 1.707601984, 0, 0,
      -1.489765772, 0, 0, 0,
      0, 0, 1, 0,
      5144.672896, -529.92384, 0, 1,
    );

    canvas.transform(matrix.storage);
    canvas.drawImage(sourceImage, Offset.zero, Paint()..filterQuality = FilterQuality.high);
    canvas.restore();

    // 4. Render to 4076 x 2380 image
    final picture = recorder.endRecording();
    final renderedImage = await picture.toImage(4076, 2380);
    print('Rendered image: ${renderedImage.width} x ${renderedImage.height}');

    // 5. Encode to PNG
    final byteData = await renderedImage.toByteData(format: ui.ImageByteFormat.png);
    if (byteData == null) {
      print('Failed to encode image to PNG');
      return;
    }

    final pngBytes = byteData.buffer.asUint8List();
    print('Encoded PNG: ${pngBytes.length} bytes');

    // 6. Save backup of old bg and write new bg
    final backupFile = File('assets/maps/myp_depot_bg_original_raw.png');
    if (!backupFile.existsSync()) {
      await inputFile.copy(backupFile.path);
      print('Saved backup to: ${backupFile.path}');
    }

    await inputFile.writeAsBytes(pngBytes);
    print('Successfully updated ${inputFile.path} with 4076x2380 landscape CAD layout!');
  });
}
