import 'dart:io';
import 'dart:math';

import 'package:flutter/widgets.dart';

void main() async {
  final miyapurColors = {
    '#86D105': 'TT',
    '#FFA633': 'SBL',
    '#01E6FF': 'IBL',
    '#8351F8': 'PW',
    '#777177': 'WP',
  };

  final uppalColors = {
    '#86D105': 'TT',
    '#FFA633': 'SBL',
    '#01E6FF': 'IBL',
    '#F15BEF': 'WL',
    '#777177': 'WP',
    '#6C5BF1': 'MAIN',
  };

  await extractTracks(
    'Miyapur',
    'assets/maps/miyapur_layout.svg',
    miyapurColors,
  );
  await extractTracks('Uppal', 'assets/maps/upl_layout_new.svg', uppalColors);
}

Future<void> extractTracks(
  String depot,
  String path,
  Map<String, String> colors,
) async {
  final file = File(path);
  final content = await file.readAsString();

  // Note: Some attributes might have single or double quotes, and order might vary.
  // We'll search for <path or <rect and try to find the fill color.
  final pathRegex = RegExp(r'<(path|rect)[^>]*fill="([^"]+)"[^>]*>');
  // Sometimes fill is before d, sometimes after. Let's find any tag with fill="color"
  final allTags = RegExp(r'<[^>]+fill="([^"]+)"[^>]*>').allMatches(content);

  final Map<String, int> counts = {};

  debugPrint('// $depot');

  for (final match in allTags) {
    final tagContent = match.group(0)!;
    String fill = match.group(1)!.toUpperCase();

    final section = colors[fill];
    if (section != null) {
      counts[section] = (counts[section] ?? 0) + 1;
      final num = counts[section];
      final trackName = '${depot == "Miyapur" ? "MP" : "UP"}$section-$num';

      final bounds = getBounds(tagContent);

      if (bounds != null) {
        debugPrint(
          "'$trackName': TrackBounds(x: ${bounds[0].toStringAsFixed(2)}, y: ${bounds[1].toStringAsFixed(2)}, w: ${bounds[2].toStringAsFixed(2)}, h: ${bounds[3].toStringAsFixed(2)}),",
        );
      } else {
        debugPrint("// Failed to parse bounds for $trackName");
      }
    }
  }
}

List<double>? getBounds(String tag) {
  // Extract d="" for path or x="", y="", width="", height="" for rect
  final isRect = tag.contains('<rect');

  if (isRect) {
    final x =
        double.tryParse(
          RegExp(r'x="([^"]+)"').firstMatch(tag)?.group(1) ?? '0',
        ) ??
        0;
    final y =
        double.tryParse(
          RegExp(r'y="([^"]+)"').firstMatch(tag)?.group(1) ?? '0',
        ) ??
        0;
    final w =
        double.tryParse(
          RegExp(r'width="([^"]+)"').firstMatch(tag)?.group(1) ?? '0',
        ) ??
        0;
    final h =
        double.tryParse(
          RegExp(r'height="([^"]+)"').firstMatch(tag)?.group(1) ?? '0',
        ) ??
        0;
    return [x, y, w, h];
  }

  final dMatch = RegExp(r'd="([^"]+)"').firstMatch(tag);
  if (dMatch == null) return null;
  final d = dMatch.group(1)!;

  final regex = RegExp(r'[-+]?\d*\.?\d+(?:[eE][-+]?\d+)?');
  final matches = regex.allMatches(d).toList();

  if (matches.isEmpty) return null;

  double minX = double.infinity;
  double maxX = double.negativeInfinity;
  double minY = double.infinity;
  double maxY = double.negativeInfinity;

  bool isX = true;
  for (int i = 0; i < matches.length; i++) {
    // If we hit M, L, etc. it's usually followed by x y. A simple regex parsing numbers works roughly
    // for absolute paths. Let's assume paths are mostly absolute.
    final val = double.tryParse(matches[i].group(0)!);
    if (val != null) {
      if (isX) {
        minX = min(minX, val);
        maxX = max(maxX, val);
      } else {
        minY = min(minY, val);
        maxY = max(maxY, val);
      }
      isX = !isX;
    }
  }

  return [minX, minY, maxX - minX, maxY - minY];
}
