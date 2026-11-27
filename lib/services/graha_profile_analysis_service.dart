import '../models/kundali/kundali_graha.dart';
import 'varga_chart_service.dart';

/// Rule-based D1 profile helpers. These are traditional screening rules,
/// not a substitute for a lineage-specific full horoscope judgement.
class GrahaProfile {
  const GrahaProfile({
    required this.planet,
    required this.naturalNature,
    required this.functionalNature,
    required this.ownedHouses,
    required this.isYogakaraka,
    required this.isVargottama,
    required this.d1Sign,
    required this.d9Sign,
    required this.houseTheme,
  });

  final KundaliGraha planet;
  final String naturalNature;
  final String functionalNature;
  final List<int> ownedHouses;
  final bool isYogakaraka;
  final bool isVargottama;
  final int d1Sign;
  final int d9Sign;
  final String houseTheme;
}

class GrahaProfileAnalysisService {
  GrahaProfileAnalysisService._();

  static const _lords = <String, List<int>>{
    'Mars': [0, 7], 'Venus': [1, 6], 'Mercury': [2, 5],
    'Moon': [3], 'Sun': [4], 'Jupiter': [8, 11],
    'Saturn': [9, 10],
  };

  static const _naturalBenefics = {'Jupiter', 'Venus', 'Mercury', 'Moon'};
  static const _themes = <String>[
    'Self, vitality, body and approach to life',
    'Wealth, speech, family and stored resources',
    'Courage, initiative, skills and siblings',
    'Home, mother, comfort, property and foundations',
    'Learning, creativity, children and discernment',
    'Work, service, health routines, debts and competition',
    'Marriage, agreements, partnerships and public dealings',
    'Transformation, longevity, shared resources and research',
    'Dharma, teachers, higher learning and long journeys',
    'Career, responsibilities, status and public contribution',
    'Gains, communities, aspirations and networks',
    'Expenses, retreat, foreign connections and liberation',
  ];

  static List<GrahaProfile> analyse(KundaliChart chart) {
    if (chart.grahas.isEmpty) return const [];
    final asc = chart.ascendantSignIndex;
    final owned = <String, List<int>>{};
    for (final entry in _lords.entries) {
      owned[entry.key] = [
        for (var house = 1; house <= 12; house++)
          if (entry.value.contains((asc + house - 1) % 12)) house,
      ];
    }

    final d9 = VargaChartService.calculate(chart, 9);
    final d9ByName = {for (final planet in d9.planets) planet.name: planet};
    final result = <GrahaProfile>[];
    for (final graha in chart.grahas) {
      final houses = owned[graha.name] ?? const <int>[];
      final hasKendra = houses.any(const {1, 4, 7, 10}.contains);
      final hasTrikona = houses.any(const {1, 5, 9}.contains);
      final yogakaraka = hasKendra && hasTrikona &&
          houses.any(const {4, 7, 10}.contains) &&
          houses.any(const {5, 9}.contains);
      final functional = _functionalNature(houses, graha.name);
      final navamsa = d9ByName[graha.name]?.signIndex ?? graha.signIndex;
      result.add(GrahaProfile(
        planet: graha,
        naturalNature: _naturalNature(graha.name),
        functionalNature: functional,
        ownedHouses: houses,
        isYogakaraka: yogakaraka,
        isVargottama: graha.signIndex == navamsa,
        d1Sign: graha.signIndex,
        d9Sign: navamsa,
        houseTheme: _themes[graha.houseNumber - 1],
      ));
    }
    return result;
  }

  static String _naturalNature(String name) {
    if (_naturalBenefics.contains(name)) return 'Natural benefic (Moon depends on paksha)';
    if (name == 'Sun' || name == 'Mars' || name == 'Saturn' ||
        name == 'Rahu' || name == 'Ketu') return 'Natural malefic';
    return 'School-dependent';
  }

  static String _functionalNature(List<int> houses, String name) {
    if (houses.isEmpty) return 'Not classified by this rule set';
    if (houses.contains(1)) return 'Lagna lord: generally supportive';
    if (houses.any(const {4, 5, 7, 9, 10}.contains)) {
      if (houses.any(const {5, 9}.contains) &&
          houses.any(const {4, 7, 10}.contains)) return 'Yogakaraka / highly supportive';
      if (houses.any(const {5, 9}.contains)) return 'Trikona lord: generally supportive';
      if (houses.any(const {4, 7, 10}.contains)) return 'Kendra lord: mixed; depends on natural nature';
    }
    if (houses.any(const {6, 8, 12}.contains)) return 'Dusthana ownership: challenging or mixed';
    if (houses.any(const {2, 7}.contains)) return 'Maraka-house ownership: requires context';
    if (houses.contains(11) || houses.contains(3)) return 'Upachaya ownership: context-dependent';
    return 'Mixed; judge with placement, aspects and association';
  }

  static List<int> ownedHouses(KundaliChart chart, String planet) {
    final signs = _lords[planet] ?? const <int>[];
    return [
      for (var house = 1; house <= 12; house++)
        if (signs.contains((chart.ascendantSignIndex + house - 1) % 12)) house,
    ];
  }
}
