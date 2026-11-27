import '../../models/kundali/kundali_graha.dart';
import '../varga_chart_service.dart';

class ManglikAssessment {
  const ManglikAssessment({
    required this.fromLagna, required this.fromMoon, required this.fromVenus,
    required this.marsSignIndex, required this.marsHouseFromLagna,
    required this.mitigationIndicators,
  });
  final bool? fromLagna, fromMoon, fromVenus;
  final int? marsSignIndex, marsHouseFromLagna;
  /// Traditional screening indicators, not automatic cancellation.
  final List<String> mitigationIndicators;
  bool get hasAnyIndicator => fromLagna == true || fromMoon == true || fromVenus == true;
  bool get isComplete => fromLagna != null && fromMoon != null && fromVenus != null;
}

class HouseCompatibilityProfile {
  const HouseCompatibilityProfile({
    required this.seventhHouseSign, required this.seventhHouseOccupants,
    required this.seventhLord, required this.seventhLordHouse,
    required this.seventhLordDignity, required this.seventhHouseAspectedBy,
    required this.seventhLordAspectedBy,
  });
  final int? seventhHouseSign;
  final List<String> seventhHouseOccupants;
  final String? seventhLord;
  final int? seventhLordHouse;
  final String? seventhLordDignity;
  final List<String> seventhHouseAspectedBy;
  final List<String> seventhLordAspectedBy;
}

class NavamsaCompatibilityProfile {
  const NavamsaCompatibilityProfile({
    required this.ascendantSign, required this.seventhHouseSign,
    required this.seventhHouseOccupants, required this.seventhLord,
    required this.seventhLordHouse, required this.seventhLordDignity,
    required this.seventhHouseAspectedBy,
  });
  final int ascendantSign, seventhHouseSign;
  final List<String> seventhHouseOccupants;
  final String seventhLord;
  final int? seventhLordHouse;
  final String? seventhLordDignity;
  final List<String> seventhHouseAspectedBy;
}

class AdvancedMatchingAnalysis {
  const AdvancedMatchingAnalysis({
    required this.brideManglik, required this.groomManglik,
    required this.brideSeventhHouse, required this.groomSeventhHouse,
    required this.brideNavamsa, required this.groomNavamsa,
  });
  final ManglikAssessment brideManglik, groomManglik;
  final HouseCompatibilityProfile brideSeventhHouse, groomSeventhHouse;
  final NavamsaCompatibilityProfile? brideNavamsa, groomNavamsa;
}

class AdvancedMatchingService {
  static const _marsHouses = {1, 2, 4, 7, 8, 12};
  static const _lords = [
    'Mars', 'Venus', 'Mercury', 'Moon', 'Sun', 'Mercury',
    'Venus', 'Mars', 'Jupiter', 'Saturn', 'Saturn', 'Jupiter',
  ];
  static const _ownSigns = <String, Set<int>>{
    'Sun': {4}, 'Moon': {3}, 'Mars': {0, 7},
    'Mercury': {2, 5}, 'Jupiter': {8, 11},
    'Venus': {1, 6}, 'Saturn': {9, 10},
  };
  static const _exaltationSigns = <String, int>{
    'Sun': 0, 'Moon': 1, 'Mars': 9, 'Mercury': 5,
    'Jupiter': 3, 'Venus': 11, 'Saturn': 6,
  };
  static const _debilitationSigns = <String, int>{
    'Sun': 6, 'Moon': 7, 'Mars': 3, 'Mercury': 11,
    'Jupiter': 9, 'Venus': 5, 'Saturn': 0,
  };

  static AdvancedMatchingAnalysis calculate({
    required KundaliChart? bride, required KundaliChart? groom,
  }) => AdvancedMatchingAnalysis(
    brideManglik: _manglik(bride), groomManglik: _manglik(groom),
    brideSeventhHouse: _seventh(bride), groomSeventhHouse: _seventh(groom),
    brideNavamsa: _navamsa(bride), groomNavamsa: _navamsa(groom),
  );

  static ManglikAssessment _manglik(KundaliChart? chart) {
    if (chart == null) {
      return const ManglikAssessment(
        fromLagna: null, fromMoon: null, fromVenus: null,
        marsSignIndex: null, marsHouseFromLagna: null, mitigationIndicators: [],
      );
    }
    KundaliGraha? mars, moon, venus, jupiter;
    for (final graha in chart.grahas) {
      if (graha.name == 'Mars') mars = graha;
      if (graha.name == 'Moon') moon = graha;
      if (graha.name == 'Venus') venus = graha;
      if (graha.name == 'Jupiter') jupiter = graha;
    }
    if (mars == null) {
      return const ManglikAssessment(
        fromLagna: null, fromMoon: null, fromVenus: null,
        marsSignIndex: null, marsHouseFromLagna: null, mitigationIndicators: [],
      );
    }
    int houseFrom(int sign) => ((mars!.signIndex - sign + 12) % 12) + 1;
    final indicators = <String>[];
    if ((_ownSigns['Mars']!).contains(mars.signIndex)) {
      indicators.add('mars_own_sign');
    }
    if (_exaltationSigns['Mars'] == mars.signIndex) {
      indicators.add('mars_exalted_sign');
    }
    if (jupiter != null && (jupiter.signIndex == mars.signIndex ||
        _aspectsSign(jupiter.name, jupiter.signIndex, mars.signIndex))) {
      indicators.add('jupiter_influence');
    }
    return ManglikAssessment(
      fromLagna: _marsHouses.contains(houseFrom(chart.ascendantSignIndex)),
      fromMoon: moon == null ? null : _marsHouses.contains(houseFrom(moon.signIndex)),
      fromVenus: venus == null ? null : _marsHouses.contains(houseFrom(venus.signIndex)),
      marsSignIndex: mars.signIndex,
      marsHouseFromLagna: houseFrom(chart.ascendantSignIndex),
      mitigationIndicators: List.unmodifiable(indicators),
    );
  }

  static HouseCompatibilityProfile _seventh(KundaliChart? chart) {
    if (chart == null) {
      return const HouseCompatibilityProfile(
        seventhHouseSign: null, seventhHouseOccupants: [], seventhLord: null,
        seventhLordHouse: null, seventhLordDignity: null,
        seventhHouseAspectedBy: [], seventhLordAspectedBy: [],
      );
    }
    final sign = (chart.ascendantSignIndex + 6) % 12;
    final lord = _lords[sign];
    final lordGraha = _findGraha(chart.grahas, lord);
    final occupants = chart.grahas.where((g) => g.signIndex == sign).map((g) => g.name);
    return HouseCompatibilityProfile(
      seventhHouseSign: sign,
      seventhHouseOccupants: List.unmodifiable(occupants),
      seventhLord: lord,
      seventhLordHouse: lordGraha?.houseNumber,
      seventhLordDignity: lordGraha == null ? null : _dignity(lord, lordGraha.signIndex),
      seventhHouseAspectedBy: List.unmodifiable(_aspecting(chart.grahas, sign)),
      seventhLordAspectedBy: lordGraha == null ? const [] : List.unmodifiable(
        _aspecting(chart.grahas, lordGraha.signIndex, excludeGraha: lord)),
    );
  }

  static NavamsaCompatibilityProfile? _navamsa(KundaliChart? chart) {
    if (chart == null) return null;
    final d9 = VargaChartService.calculate(chart, 9);
    final seventhSign = (d9.ascendantSignIndex + 6) % 12;
    final lord = _lords[seventhSign];
    VargaPlanetPosition? lordGraha;
    for (final planet in d9.planets) {
      if (planet.name == lord) { lordGraha = planet; break; }
    }
    return NavamsaCompatibilityProfile(
      ascendantSign: d9.ascendantSignIndex,
      seventhHouseSign: seventhSign,
      seventhHouseOccupants: List.unmodifiable(d9.inHouse(7).map((p) => p.name)),
      seventhLord: lord,
      seventhLordHouse: lordGraha?.houseNumber,
      seventhLordDignity: lordGraha == null ? null : _dignity(lord, lordGraha.signIndex),
      seventhHouseAspectedBy: List.unmodifiable(_aspectingVarga(d9.planets, seventhSign)),
    );
  }

  static KundaliGraha? _findGraha(List<KundaliGraha> grahas, String name) {
    for (final graha in grahas) {
      if (graha.name == name) return graha;
    }
    return null;
  }

  static String _dignity(String planet, int sign) {
    if (_exaltationSigns[planet] == sign) return 'exalted';
    if (_debilitationSigns[planet] == sign) return 'debilitated';
    if ((_ownSigns[planet] ?? {}).contains(sign)) return 'own';
    return 'other';
  }

  static List<String> _aspecting(List<KundaliGraha> grahas, int targetSign, {String? excludeGraha}) =>
      grahas.where((g) => g.name != excludeGraha &&
          _aspectsSign(g.name, g.signIndex, targetSign)).map((g) => g.name).toList();

  static List<String> _aspectingVarga(List<VargaPlanetPosition> planets, int targetSign) =>
      planets.where((p) => _aspectsSign(p.name, p.signIndex, targetSign))
          .map((p) => p.name).toList();

  /// Whole-sign Parashari drishti: all grahas 7th; Mars 4th/8th,
  /// Jupiter 5th/9th and Saturn 3rd/10th. Nodes are excluded.
  static bool _aspectsSign(String planet, int fromSign, int targetSign) {
    final house = ((targetSign - fromSign + 12) % 12) + 1;
    if (house == 7) return true;
    return switch (planet) {
      'Mars' => house == 4 || house == 8,
      'Jupiter' => house == 5 || house == 9,
      'Saturn' => house == 3 || house == 10,
      _ => false,
    };
  }
}
