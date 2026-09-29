import 'dart:convert';
import 'dart:io';

void main() async {
  print('Starting asset extraction...');

  // 1. Copy bogie image
  final bogieSrc = File('../NxAMS UI Src/webapplication/src/assets/svg/3 Boghi small High quality.png');
  final bogieDst = File('assets/maps/train_bogie.png');
  if (await bogieSrc.exists()) {
    await bogieSrc.copy(bogieDst.path);
    print('Copied train_bogie.png (${await bogieDst.length()} bytes)');
  } else {
    // Try absolute path if run from project root
    final bogieSrcAbs = File('e:/Sai Kiran/Metro/NxAMS UI Src/webapplication/src/assets/svg/3 Boghi small High quality.png');
    if (await bogieSrcAbs.exists()) {
      await bogieSrcAbs.copy('e:/Sai Kiran/Metro/metro_flutter/assets/maps/train_bogie.png');
      print('Copied train_bogie.png via absolute path');
    } else {
      print('Warning: bogie source not found');
    }
  }

  // 2. Extract UPL background
  await extractBase64Image(
    'assets/maps/UPL DEPO 0.svg',
    'assets/maps/upl_depot_bg.png',
  );

  // 3. Extract MYP background
  await extractBase64Image(
    'assets/maps/MYP DEPO 0.svg',
    'assets/maps/myp_depot_bg.png',
  );

  print('Done!');
}

Future<void> extractBase64Image(String svgPath, String outPngPath) async {
  final file = File(svgPath);
  if (!await file.exists()) {
    print('File not found: $svgPath');
    return;
  }
  print('Reading $svgPath...');
  final content = await file.readAsString();

  final marker = 'data:image/png;base64,';
  final startIdx = content.indexOf(marker);
  if (startIdx == -1) {
    print('No base64 image found in $svgPath');
    return;
  }

  final base64Start = startIdx + marker.length;
  final endIdx = content.indexOf('"', base64Start);
  if (endIdx == -1) {
    print('Could not find end of base64 data in $svgPath');
    return;
  }

  final base64Str = content.substring(base64Start, endIdx).replaceAll(RegExp(r'\s+'), '');
  final bytes = base64Decode(base64Str);
  final outFile = File(outPngPath);
  await outFile.writeAsBytes(bytes);
  print('Wrote $outPngPath (${bytes.length} bytes)');
}
