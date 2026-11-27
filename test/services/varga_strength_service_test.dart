import 'package:flutter_test/flutter_test.dart';

import '../../lib/models/kundali/kundali_graha.dart';
import '../../lib/services/varga_strength_service.dart';

KundaliChart _chart() {
  const positions = <(String, String, double, int)>[
    ('Sun', 'Su', 20.5, 1),
    ('Moon', 'Mo', 91, 4),
    ('Mars', 'Ma', 42, 2),
    ('Mercury', 'Me', 165, 6),
    ('Jupiter', 'Ju', 250, 9),
    ('Venus', 'Ve', 195, 7),
    ('Saturn', 'Sa', 285, 10),
  ];
  final grahas = positions.map((p) {
    final sign = (p.$3 / 30).floor();
    return KundaliGraha(
      name: p.$1,
      symbol: p.$2,
      longitude: p.$3,
      signIndex: sign,
      houseNumber: ((sign - 0 + 12) % 12) + 1,
      bhavaNumber: ((sign - 0 + 12) % 12) + 1,
    );
  }).toList();
  return KundaliChart(
    ascendantLongitude: 0,
    ascendantSignIndex: 0,
    midheavenLongitude: 270,
    bhavas: [
      for (var i = 0; i < 12; i++)
        BhavaHouse(
          number: i + 1,
          startLongitude: i * 30.0,
          middleLongitude: i * 30.0 + 15,
          endLongitude: (i + 1) * 30.0,
        ),
    ],
    grahas: grahas,
  );
}

void main() {
  group('VargaStrengthService', () {
    test('all four BPHS Vimsopaka schemes have weights totalling 20', () {
      for (final scheme in VimsopakaScheme.values) {
        expect(VargaStrengthService.totalWeight(scheme), 20);
      }
    });

    test('returns seven classical planets and bounded 20-point scores', () {
      final result = VargaStrengthService.calculate(_chart());
      expect(result.map((e) => e.planet).toList(),
          VargaStrengthService.classicalPlanets);
      for (final planet in result) {
        expect(planet.score, inInclusiveRange(0, 20));
        expect(planet.breakdown.length, 16);
        expect(planet.breakdown.fold<double>(0, (s, e) => s + e.weight), 20);
      }
    });

    test('supports each Vimsopaka scheme with its own component set', () {
      final chart = _chart();
      final expectedCounts = {
        VimsopakaScheme.shadvarga: 6,
        VimsopakaScheme.saptavarga: 7,
        VimsopakaScheme.dashavarga: 10,
        VimsopakaScheme.shodashavarga: 16,
      };
      for (final entry in expectedCounts.entries) {
        final result = VargaStrengthService.calculate(chart, scheme: entry.key);
        expect(result.first.breakdown.length, entry.value);
        expect(result.first.scheme, entry.key);
      }
    });

    test('flags Pushkara Navamsa and Pushkara Bhaga using documented bands', () {
      final sun = VargaStrengthService.calculate(_chart())
          .firstWhere((e) => e.planet == 'Sun');
      expect(sun.pushkaraNavamsa, isTrue);
      expect(sun.pushkaraBhaga, isTrue);
    });

    test('identifies D1 and D9 sign repetition as Vargottama', () {
      final moon = VargaStrengthService.calculate(_chart())
          .firstWhere((e) => e.planet == 'Moon');
      expect(moon.vargottama, isTrue);
      expect(moon.d1D9SameSign, isTrue);
    });
  });
}
