import '../models/kundali/kundali_graha.dart';

/// House-based Parashari Drishti mapping for the selected house system.
/// Rahu/Ketu 5th and 9th aspects follow the convention already used by the
/// app's transit analysis; other lineages may omit or vary node aspects.
class BhavaAspect {
  const BhavaAspect({
    required this.houseNumber,
    required this.aspectingGrahas,
    required this.occupants,
  });

  final int houseNumber;
  final List<KundaliGraha> aspectingGrahas;
  final List<KundaliGraha> occupants;
}

class BhavaAnalysisService {
  BhavaAnalysisService._();

  static const Map<String, List<int>> _aspectOffsets = {
    'Mars': [4, 7, 8],
    'Jupiter': [5, 7, 9],
    'Saturn': [3, 7, 10],
    'Rahu': [5, 7, 9],
    'Ketu': [5, 7, 9],
  };

  /// Returns one entry per house. [useChalit] changes both occupancy and
  /// the origin house used for aspect mapping; it never mixes D1 and Chalit.
  static List<BhavaAspect> analyse(KundaliChart chart, {required bool useChalit}) {
    final result = <BhavaAspect>[];
    for (var house = 1; house <= 12; house++) {
      final aspecting = <KundaliGraha>[];
      for (final graha in chart.grahas) {
        final sourceHouse = useChalit ? graha.bhavaNumber : graha.houseNumber;
        final offsets = _aspectOffsets[graha.name] ?? const [7];
        final targets = offsets
            .map((offset) => ((sourceHouse + offset - 2) % 12) + 1)
            .toSet();
        if (targets.contains(house)) aspecting.add(graha);
      }
      result.add(BhavaAspect(
        houseNumber: house,
        aspectingGrahas: List.unmodifiable(aspecting),
        occupants: List.unmodifiable(
          useChalit ? chart.inBhava(house) : chart.inHouse(house),
        ),
      ));
    }
    return List.unmodifiable(result);
  }
}
