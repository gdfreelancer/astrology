import 'dart:math' as math;

import '../models/kundali/kundali_graha.dart';
import 'advanced_chart_analysis_service.dart';
import 'varga_chart_service.dart';

/// A component-by-component strength report.
///
/// This intentionally does not publish a total Shadbala score: several
/// classical components require ephemeris quantities not yet available from
/// the current chart model.
class GrahaStrengthReport {
  const GrahaStrengthReport({
    required this.planet,
    required this.uchchaBala,
    required this.digBala,
    required this.naisargikaBala,
    required this.pakshaBala,
    required this.vargottama,
    required this.exaltationDistance,
    required this.directionalPeakHouse,
    required this.notes,
  });

  final KundaliGraha planet;
  /// Uchcha Bala in virupas, 0–60.
  final double uchchaBala;
  /// Dig Bala in virupas, 0–60, measured against Bhava Madhya.
  final double digBala;
  /// Classical natural strength in virupas.
  final double naisargikaBala;
  /// Approximate Paksha Bala in virupas, 0–60.
  final double pakshaBala;
  final bool vargottama;
  final double exaltationDistance;
  final int directionalPeakHouse;
  final List<String> notes;
}

class BhavaStrengthReport {
  const BhavaStrengthReport({
    required this.house,
    required this.signIndex,
    required this.houseLord,
    required this.lordHouse,
    required this.lordDignity,
    required this.occupants,
    required this.aspectingGrahas,
  });

  final BhavaHouse house;
  final int signIndex;
  final String houseLord;
  final int? lordHouse;
  final String lordDignity;
  final List<KundaliGraha> occupants;
  final List<String> aspectingGrahas;
}

class ShadbalaAnalysisService {
  ShadbalaAnalysisService._();

  static const _signLords = <String>[
    'Mars', 'Venus', 'Mercury', 'Moon', 'Sun', 'Mercury',
    'Venus', 'Mars', 'Jupiter', 'Saturn', 'Saturn', 'Jupiter',
  ];

  static const _exaltation = <String, ({int sign, double degree})>{
    'Sun': (sign: 0, degree: 10),
    'Moon': (sign: 1, degree: 3),
    'Mars': (sign: 9, degree: 28),
    'Mercury': (sign: 5, degree: 15),
    'Jupiter': (sign: 3, degree: 5),
    'Venus': (sign: 11, degree: 27),
    'Saturn': (sign: 6, degree: 20),
  };

  static const _natural = <String, double>{
    'Sun': 60,
    'Moon': 51.43,
    'Venus': 42.86,
    'Jupiter': 34.29,
    'Mercury': 25.71,
    'Mars': 17.14,
    'Saturn': 8.57,
  };

  static const _digPeak = <String, int>{
    'Sun': 10,
    'Mars': 10,
    'Moon': 4,
    'Venus': 4,
    'Mercury': 1,
    'Jupiter': 1,
    'Saturn': 7,
  };

  static List<GrahaStrengthReport> grahaStrength(KundaliChart chart) {
    final sun = chart.grahas.firstWhere((g) => g.name == 'Sun');
    final moon = chart.grahas.firstWhere((g) => g.name == 'Moon');
    final elongation = _forward(sun.longitude, moon.longitude);
    final pakshaVirupa = elongation / 3.0;
    final d9 = VargaChartService.calculate(chart, 9);

    return chart.grahas
        .where((g) => _exaltation.containsKey(g.name))
        .map((planet) {
      final exalt = _exaltation[planet.name]!;
      final exaltPoint = exalt.sign * 30.0 + exalt.degree;
      final debilitationPoint = (exaltPoint + 180) % 360;
      final exaltDistance = _distance(planet.longitude, debilitationPoint);
      final uchcha = exaltDistance / 3.0;

      final peakHouse = _digPeak[planet.name]!;
      final peakLongitude = chart.bhava(peakHouse).middleLongitude;
      final distanceToPeak = _distance(planet.longitude, peakLongitude);
      final dig = (60.0 - distanceToPeak / 3.0).clamp(0.0, 60.0);

      final isNaturalBenefic = const {'Jupiter', 'Venus', 'Mercury'}
          .contains(planet.name);
      final paksha = planet.name == 'Moon'
          ? pakshaVirupa
          : isNaturalBenefic
              ? pakshaVirupa
              : 60.0 - pakshaVirupa;

      final d9Planet = d9.planets.firstWhere((p) => p.name == planet.name);
      final notes = <String>[
        'Uchcha Bala uses the traditional exaltation and debilitation degrees.',
        'Dig Bala uses the existing Bhava Madhya for the planet’s directional peak.',
        'Paksha Bala is an approximate waxing/waning phase component; Mercury is treated as a natural benefic for this reference.',
      ];
      if (planet.name == 'Rahu' || planet.name == 'Ketu') {
        notes.add('Classical Shadbala does not assign the standard seven-planet component set to the lunar nodes.');
      }
      return GrahaStrengthReport(
        planet: planet,
        uchchaBala: uchcha,
        digBala: dig,
        naisargikaBala: _natural[planet.name] ?? 0,
        pakshaBala: paksha.clamp(0.0, 60.0),
        vargottama: planet.signIndex == d9Planet.signIndex,
        exaltationDistance: _distance(planet.longitude, exaltPoint),
        directionalPeakHouse: peakHouse,
        notes: notes,
      );
    }).toList(growable: false);
  }

  static List<BhavaStrengthReport> bhavaStrength(KundaliChart chart) {
    final aspects = AdvancedChartAnalysisService.aspects(chart);
    return List<BhavaStrengthReport>.generate(12, (index) {
      final house = chart.bhava(index + 1);
      final sign = house.signIndex;
      final lordName = _signLords[sign];
      final lord = chart.grahas.where((g) => g.name == lordName).firstOrNull;
      final lordDignity = lord == null
          ? 'Not available'
          : _dignity(lord);
      final aspecting = aspects
          .where((a) => a.targetHouse == index + 1)
          .map((a) => a.planet.name)
          .toSet()
          .toList(growable: false);
      return BhavaStrengthReport(
        house: house,
        signIndex: sign,
        houseLord: lordName,
        lordHouse: lord?.houseNumber,
        lordDignity: lordDignity,
        occupants: chart.inBhava(index + 1),
        aspectingGrahas: aspecting,
      );
    }, growable: false);
  }

  static String _dignity(KundaliGraha planet) {
    final exalt = _exaltation[planet.name];
    if (exalt != null &&
        planet.signIndex == exalt.sign &&
        (planet.longitude % 30 - exalt.degree).abs() < 1e-6) {
      return 'Exact exaltation degree';
    }
    if (exalt != null && planet.signIndex == exalt.sign) return 'Exaltation sign';
    const debilitation = <String, int>{
      'Sun': 6, 'Moon': 7, 'Mars': 3, 'Mercury': 11,
      'Jupiter': 9, 'Venus': 5, 'Saturn': 0,
    };
    if (debilitation[planet.name] == planet.signIndex) return 'Debilitation sign';
    const own = <String, List<int>>{
      'Sun': [4], 'Moon': [3], 'Mars': [0, 7], 'Mercury': [2, 5],
      'Jupiter': [8, 11], 'Venus': [1, 6], 'Saturn': [9, 10],
    };
    if ((own[planet.name] ?? const <int>[]).contains(planet.signIndex)) {
      return 'Own sign';
    }
    return 'Other / friendship not assessed';
  }

  static double _forward(double from, double to) =>
      (to - from + 360.0) % 360.0;

  static double _distance(double a, double b) {
    final difference = (a - b).abs() % 360.0;
    return math.min(difference, 360.0 - difference);
  }
}
