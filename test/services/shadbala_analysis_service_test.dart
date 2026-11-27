import 'package:flutter_test/flutter_test.dart';
import 'package:astrology/models/kundali/kundali_graha.dart';
import 'package:astrology/services/shadbala_analysis_service.dart';

KundaliChart _chart({
  double sun = 0,
  double moon = 180,
  double mars = 30,
}) {
  final midpoints = List<double>.generate(12, (i) => (15 + i * 30) % 360);
  final houses = List<BhavaHouse>.generate(12, (i) {
    final middle = midpoints[i];
    return BhavaHouse(
      number: i + 1,
      startLongitude: (middle - 15 + 360) % 360,
      middleLongitude: middle,
      endLongitude: (middle + 15) % 360,
    );
  });
  final positions = <({String name, String symbol, double longitude})>[
    (name: 'Sun', symbol: 'Su', longitude: sun),
    (name: 'Moon', symbol: 'Mo', longitude: moon),
    (name: 'Mars', symbol: 'Ma', longitude: mars),
    (name: 'Mercury', symbol: 'Me', longitude: 90),
    (name: 'Jupiter', symbol: 'Ju', longitude: 120),
    (name: 'Venus', symbol: 'Ve', longitude: 150),
    (name: 'Saturn', symbol: 'Sa', longitude: 210),
    (name: 'Rahu', symbol: 'Ra', longitude: 240),
    (name: 'Ketu', symbol: 'Ke', longitude: 60),
  ];
  final grahas = positions.map((p) {
    final sign = (p.longitude / 30).floor();
    return KundaliGraha(
      name: p.name,
      symbol: p.symbol,
      longitude: p.longitude,
      signIndex: sign,
      houseNumber: (sign % 12) + 1,
      bhavaNumber: (sign % 12) + 1,
    );
  }).toList(growable: false);
  return KundaliChart(
    ascendantLongitude: 0,
    ascendantSignIndex: 0,
    midheavenLongitude: 270,
    bhavas: houses,
    grahas: grahas,
  );
}

void main() {
  group('ShadbalaAnalysisService', () {
    test('returns component values within the 0–60 virupa range', () {
      final reports = ShadbalaAnalysisService.grahaStrength(_chart());
      expect(reports, hasLength(7));
      for (final report in reports) {
        expect(report.uchchaBala, inInclusiveRange(0, 60));
        expect(report.digBala, inInclusiveRange(0, 60));
        expect(report.pakshaBala, inInclusiveRange(0, 60));
        expect(report.naisargikaBala, inInclusiveRange(0, 60));
      }
    });

    test('calculates maximum Uchcha Bala at the exact exaltation point', () {
      final sun = ShadbalaAnalysisService.grahaStrength(
        _chart(sun: 10),
      ).firstWhere((r) => r.planet.name == 'Sun');
      expect(sun.uchchaBala, closeTo(60, 1e-8));
    });

    test('calculates zero Uchcha Bala at the exact debilitation point', () {
      final sun = ShadbalaAnalysisService.grahaStrength(
        _chart(sun: 190),
      ).firstWhere((r) => r.planet.name == 'Sun');
      expect(sun.uchchaBala, closeTo(0, 1e-8));
    });

    test('calculates Dig Bala from the configured Bhava Madhya peak', () {
      // House 10 midpoint is 285 degrees in this fixture.
      final sun = ShadbalaAnalysisService.grahaStrength(
        _chart(sun: 285),
      ).firstWhere((r) => r.planet.name == 'Sun');
      expect(sun.digBala, closeTo(60, 1e-8));
    });

    test('Paksha Bala reflects waxing and waning separation', () {
      final waxing = ShadbalaAnalysisService.grahaStrength(
        _chart(sun: 0, moon: 180),
      );
      final waning = ShadbalaAnalysisService.grahaStrength(
        _chart(sun: 0, moon: 0),
      );
      final waxingJupiter = waxing.firstWhere((r) => r.planet.name == 'Jupiter');
      final waningJupiter = waning.firstWhere((r) => r.planet.name == 'Jupiter');
      final waxingMars = waxing.firstWhere((r) => r.planet.name == 'Mars');
      final waningMars = waning.firstWhere((r) => r.planet.name == 'Mars');
      expect(waxingJupiter.pakshaBala, greaterThan(waningJupiter.pakshaBala));
      expect(waningMars.pakshaBala, greaterThan(waxingMars.pakshaBala));
    });

    test('returns twelve descriptive Bhava reports with valid lords', () {
      final reports = ShadbalaAnalysisService.bhavaStrength(_chart());
      expect(reports, hasLength(12));
      for (var i = 0; i < reports.length; i++) {
        expect(reports[i].house.number, i + 1);
        expect(reports[i].houseLord, isNotEmpty);
        expect(reports[i].signIndex, inInclusiveRange(0, 11));
      }
    });
  });
}
