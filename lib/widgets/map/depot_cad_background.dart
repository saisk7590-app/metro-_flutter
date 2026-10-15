import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

class DepotCadBackground extends StatelessWidget {
  final String depot;

  const DepotCadBackground({
    super.key,
    required this.depot,
  });

  static final Map<String, String> _svgCache = {};

  static Future<String> getDepotSvg(String path) async {
    if (_svgCache.containsKey(path)) return _svgCache[path]!;
    final raw = await rootBundle.loadString(path);
    final defsIdx = raw.indexOf('<defs>');
    final withoutDefs =
        defsIdx != -1 ? '${raw.substring(0, defsIdx)}</svg>' : raw;
    final processed = withoutDefs
        .replaceFirst(
          '<rect width="4076" height="2380" fill="white"/>',
          '<rect width="4076" height="2380" fill="none"/>',
        )
        .replaceFirst(
          '<rect width="2644" height="2111.22" fill="white"/>',
          '<rect width="2644" height="2111.22" fill="none"/>',
        )
        .replaceFirst('fill="url(#pattern0_2_2)"', 'fill="none"')
        .replaceFirst('fill="url(#pattern0_1_2)"', 'fill="none"');
    _svgCache[path] = processed;
    return processed;
  }

  @override
  Widget build(BuildContext context) {
    final isMiyapur = depot == "Miyapur";

    return Stack(
      children: [
        // 1. Depot CAD Background Layout (extracted standalone PNG)
        Positioned.fill(
          child: Image.asset(
            isMiyapur
                ? "assets/maps/myp_depot_bg.png"
                : "assets/maps/upl_depot_bg.png",
            fit: BoxFit.fill,
            errorBuilder: (context, error, stackTrace) =>
                const SizedBox.shrink(),
          ),
        ),

        // 2. Depot Tracks and Labels (SVG)
        Positioned.fill(
          child: FutureBuilder<String>(
            future: getDepotSvg(
              isMiyapur
                  ? "assets/maps/MYP DEPO 0.svg"
                  : "assets/maps/UPL DEPO 0.svg",
            ),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const SizedBox.shrink();
              }
              return SvgPicture.string(
                snapshot.data!,
                fit: BoxFit.fill,
              );
            },
          ),
        ),
      ],
    );
  }
}
