import 'package:flutter_test/flutter_test.dart';
import 'package:astrology/models/kundali/kundali_graha.dart';
import 'package:astrology/services/graha_profile_analysis_service.dart';

void main() {
  KundaliChart chart(int asc) => KundaliChart(
    ascendantLongitude: asc * 30.0, ascendantSignIndex: asc,
    midheavenLongitude: 0,
    bhavas: List.generate(12, (i) => BhavaHouse(number: i + 1,
      startLongitude: i * 30.0, middleLongitude: i * 30.0 + 15,
      endLongitude: (i + 1) * 30.0)),
    grahas: [
      for (final entry in [
        ('Sun', 'Su', 0), ('Moon', 'Mo', 30), ('Mars', 'Ma', 60),
        ('Mercury', 'Me', 90), ('Jupiter', 'Ju', 120), ('Venus', 'Ve', 150),
        ('Saturn', 'Sa', 180), ('Rahu', 'Ra', 210), ('Ketu', 'Ke', 240),
      ])
        KundaliGraha(name: entry.$1, symbol: entry.$2, longitude: entry.$3.toDouble(),
          signIndex: entry.$3 ~/ 30, houseNumber: ((entry.$3 ~/ 30 - asc + 12) % 12) + 1,
          bhavaNumber: ((entry.$3 ~/ 30 - asc + 12) % 12) + 1),
    ],
  );

  test('returns nine graha profiles and D1/D9 vargottama flags', () {
    final result = GrahaProfileAnalysisService.analyse(chart(0));
    expect(result, hasLength(9));
    expect(result.every((p) => p.d1Sign >= 0 && p.d1Sign < 12), isTrue);
    expect(result.every((p) => p.d9Sign >= 0 && p.d9Sign < 12), isTrue);
    expect(result.where((p) => p.isVargottama).length, greaterThanOrEqualTo(0));
  });

  test('computes house lord ownership relative to the ascendant', () {
    expect(GrahaProfileAnalysisService.ownedHouses(chart(0), 'Mars'), [1, 8]);
    expect(GrahaProfileAnalysisService.ownedHouses(chart(3), 'Mars'), [5, 12]);
  });

  test('marks a planet owning a trikona and kendra as yogakaraka', () {
    final profiles = GrahaProfileAnalysisService.analyse(chart(6));
    final venus = profiles.firstWhere((p) => p.planet.name == 'Venus');
    expect(venus.isYogakaraka, isTrue);
  });
}
