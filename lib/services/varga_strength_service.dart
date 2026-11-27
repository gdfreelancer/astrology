import '../models/kundali/kundali_graha.dart';
import 'varga_chart_service.dart';

enum VimsopakaScheme { shadvarga, saptavarga, dashavarga, shodashavarga }

class VargaStrengthEntry {
  const VargaStrengthEntry({
    required this.division,
    required this.weight,
    required this.signIndex,
    required this.signLord,
    required this.relationship,
    required this.points,
    required this.dignity,
  });
  final int division;
  final double weight;
  final int signIndex;
  final String signLord;
  final String relationship;
  final double points;
  final String dignity;
}

class GrahaVargaStrength {
  const GrahaVargaStrength({
    required this.planet,
    required this.scheme,
    required this.score,
    required this.breakdown,
    required this.vargottama,
    required this.pushkaraNavamsa,
    required this.pushkaraBhaga,
    required this.d1D9SameSign,
    required this.d1D10SameSign,
  });
  final String planet;
  final VimsopakaScheme scheme;
  /// Traditional Vimsopaka score on a 0–20 scale.
  final double score;
  final List<VargaStrengthEntry> breakdown;
  final bool vargottama;
  final bool pushkaraNavamsa;
  final bool pushkaraBhaga;
  final bool d1D9SameSign;
  final bool d1D10SameSign;
}

class VargaStrengthService {
  VargaStrengthService._();

  static const classicalPlanets = [
    'Sun', 'Moon', 'Mars', 'Mercury', 'Jupiter', 'Venus', 'Saturn'
  ];

  static const _lords = [
    'Mars', 'Venus', 'Mercury', 'Moon', 'Sun', 'Mercury',
    'Venus', 'Mars', 'Jupiter', 'Saturn', 'Saturn', 'Jupiter'
  ];
  static const _ownSigns = <String, List<int>>{
    'Sun': [4], 'Moon': [3], 'Mars': [0, 7], 'Mercury': [2, 5],
    'Jupiter': [8, 11], 'Venus': [1, 6], 'Saturn': [9, 10],
  };
  static const _exaltation = <String, int>{
    'Sun': 0, 'Moon': 1, 'Mars': 9, 'Mercury': 5,
    'Jupiter': 3, 'Venus': 11, 'Saturn': 6,
  };
  static const _debilitation = <String, int>{
    'Sun': 6, 'Moon': 7, 'Mars': 3, 'Mercury': 11,
    'Jupiter': 9, 'Venus': 5, 'Saturn': 0,
  };
  static const _moolatrikona = <String, (int, double, double)>{
    'Sun': (4, 0, 20), 'Moon': (1, 4, 30), 'Mars': (0, 0, 12),
    'Mercury': (5, 16, 20), 'Jupiter': (8, 0, 10),
    'Venus': (6, 0, 15), 'Saturn': (10, 0, 20),
  };
  static const _friends = <String, Set<String>>{
    'Sun': {'Moon', 'Mars', 'Jupiter'},
    'Moon': {'Sun', 'Mercury'},
    'Mars': {'Sun', 'Moon', 'Jupiter'},
    'Mercury': {'Sun', 'Venus'},
    'Jupiter': {'Sun', 'Moon', 'Mars'},
    'Venus': {'Mercury', 'Saturn'},
    'Saturn': {'Mercury', 'Venus'},
  };
  static const _enemies = <String, Set<String>>{
    'Sun': {'Venus', 'Saturn'}, 'Moon': {},
    'Mars': {'Mercury'}, 'Mercury': {'Moon'},
    'Jupiter': {'Mercury', 'Venus'}, 'Venus': {'Sun', 'Moon'},
    'Saturn': {'Sun', 'Moon', 'Mars'},
  };

  /// BPHS chapter 7 weight sets. The Saptavarga order follows the verse
  /// sequence: D1,D2,D3,D7,D9,D12,D30 (D12=4.5, D9=2.5).
  static const Map<VimsopakaScheme, Map<int, double>> weights = {
    VimsopakaScheme.shadvarga: {1: 6, 2: 2, 3: 4, 9: 5, 12: 2, 30: 1},
    VimsopakaScheme.saptavarga: {1: 5, 2: 2, 3: 3, 7: 1, 9: 2.5, 12: 4.5, 30: 2},
    VimsopakaScheme.dashavarga: {
      1: 3, 2: 1.5, 3: 1.5, 7: 1.5, 9: 1.5,
      10: 1.5, 12: 1.5, 16: 1.5, 30: 1.5, 60: 5,
    },
    VimsopakaScheme.shodashavarga: {
      1: 3.5, 2: 1, 3: 1, 4: .5, 7: .5, 9: 3,
      10: .5, 12: .5, 16: 2, 20: .5, 24: .5, 27: .5,
      30: 1, 40: .5, 45: .5, 60: 4,
    },
  };

  static double totalWeight(VimsopakaScheme scheme) =>
      weights[scheme]!.values.fold(0, (a, b) => a + b);

  static List<GrahaVargaStrength> calculate(
    KundaliChart chart, {
    VimsopakaScheme scheme = VimsopakaScheme.shodashavarga,
  }) {
    if ((totalWeight(scheme) - 20).abs() > 0.000001) {
      throw StateError('Vimsopaka weights must total 20.');
    }
    final selectedWeights = weights[scheme]!;
    final byName = {for (final graha in chart.grahas) graha.name: graha};
    return [
      for (final name in classicalPlanets)
        if (byName.containsKey(name))
          _calculatePlanet(chart, byName[name]!, scheme, selectedWeights, byName),
    ];
  }

  static GrahaVargaStrength _calculatePlanet(
    KundaliChart chart,
    KundaliGraha natal,
    VimsopakaScheme scheme,
    Map<int, double> selectedWeights,
    Map<String, KundaliGraha> byName,
  ) {
    final entries = <VargaStrengthEntry>[];
    var score = 0.0;
    for (final item in selectedWeights.entries) {
      final division = item.key;
      final weight = item.value;
      final position = division == 1
          ? null
          : VargaChartService.calculate(chart, division).planets
              .firstWhere((p) => p.name == natal.name);
      final sign = position?.signIndex ?? natal.signIndex;
      final degree = position?.degreeInSign ?? natal.signDegree;
      final lord = _lords[sign];
      final relation = _compoundRelation(natal.name, lord, byName);
      final points = relation == 'Own'
          ? 20.0
          : switch (relation) {
              'Great friend' => 18.0,
              'Friend' => 15.0,
              'Neutral' => 10.0,
              'Enemy' => 7.0,
              'Great enemy' => 5.0,
              _ => 10.0,
            };
      final dignity = _dignity(natal.name, sign, degree);
      score += weight * points / 20;
      entries.add(VargaStrengthEntry(
        division: division,
        weight: weight,
        signIndex: sign,
        signLord: lord,
        relationship: relation,
        points: points,
        dignity: dignity,
      ));
    }
    final d9 = VargaChartService.calculate(chart, 9).planets
        .firstWhere((p) => p.name == natal.name).signIndex;
    final d10 = VargaChartService.calculate(chart, 10).planets
        .firstWhere((p) => p.name == natal.name).signIndex;
    final within = natal.signDegree;
    return GrahaVargaStrength(
      planet: natal.name,
      scheme: scheme,
      score: score,
      breakdown: List.unmodifiable(entries),
      vargottama: natal.signIndex == d9,
      pushkaraNavamsa: _isPushkaraNavamsa(natal.signIndex, within),
      pushkaraBhaga: _isPushkaraBhaga(natal.signIndex, within),
      d1D9SameSign: natal.signIndex == d9,
      d1D10SameSign: natal.signIndex == d10,
    );
  }

  static String _compoundRelation(
    String planet,
    String signLord,
    Map<String, KundaliGraha> byName,
  ) {
    if (planet == signLord) return 'Own';
    final natural = (_friends[planet] ?? {}).contains(signLord)
        ? 1
        : (_enemies[planet] ?? {}).contains(signLord) ? -1 : 0;
    final p = byName[planet];
    final l = byName[signLord];
    var temporary = 0;
    if (p != null && l != null) {
      final distance = ((l.signIndex - p.signIndex + 12) % 12) + 1;
      temporary = const [2, 3, 4, 10, 11, 12].contains(distance) ? 1 : -1;
    }
    if (natural == 1 && temporary == 1) return 'Great friend';
    if (natural == -1 && temporary == -1) return 'Great enemy';
    if (natural == 1 || temporary == 1) {
      if (natural == -1 || temporary == -1) return 'Neutral';
      return 'Friend';
    }
    if (natural == -1 || temporary == -1) return 'Enemy';
    return 'Neutral';
  }

  static String _dignity(String planet, int sign, double? degree) {
    if (_exaltation[planet] == sign) return 'Exalted';
    if (_debilitation[planet] == sign) return 'Debilitated';
    final mt = _moolatrikona[planet];
    if (mt != null && mt.$1 == sign && degree != null &&
        degree >= mt.$2 && degree < mt.$3) return 'Moolatrikona';
    if ((_ownSigns[planet] ?? const []).contains(sign)) return 'Own';
    final lord = _lords[sign];
    final natural = (_friends[planet] ?? {}).contains(lord)
        ? 'Friendly'
        : (_enemies[planet] ?? {}).contains(lord) ? 'Enemy' : 'Neutral';
    return natural;
  }

  /// Fire: 7th/9th; Earth: 3rd/5th; Air: 6th/8th; Water: 1st/3rd.
  /// This is the later, commonly used Pushkara Navamsa convention.
  static bool _isPushkaraNavamsa(int sign, double degree) {
    final part = (degree / (30 / 9)).floor() + 1;
    final element = sign % 4;
    final allowed = switch (element) {
      0 => const [7, 9],
      1 => const [3, 5],
      2 => const [6, 8],
      _ => const [1, 3],
    };
    return allowed.contains(part);
  }

  /// Jataka Parijata 1.58 degree-band reading: the named nth degree is the
  /// one-degree interval immediately below the integer degree. Applied to
  /// grahas as a common modern extension; the source verse directly discusses
  /// the Moon. A point-orb interpretation is a different convention.
  static const _pushkaraDegrees = [21, 14, 18, 8, 19, 9, 24, 11, 23, 14, 19, 9];
  static bool _isPushkaraBhaga(int sign, double degree) {
    final target = _pushkaraDegrees[sign];
    return degree >= target - 1 && degree < target;
  }
}
