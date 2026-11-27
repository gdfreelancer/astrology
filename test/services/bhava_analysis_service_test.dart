import 'package:flutter_test/flutter_test.dart';
import 'package:astrology/models/kundali/kundali_graha.dart';
import 'package:astrology/services/bhava_analysis_service.dart';

void main() {
  KundaliChart chart() => KundaliChart(
    ascendantLongitude: 0,
    ascendantSignIndex: 0,
    midheavenLongitude: 270,
    bhavas: List.generate(12, (index) => BhavaHouse(
      number: index + 1,
      startLongitude: index * 30.0,
      middleLongitude: index * 30.0 + 15,
      endLongitude: (index + 1) * 30.0,
    )),
    grahas: [
      KundaliGraha(name: 'Mars', symbol: 'Ma', longitude: 10,
        signIndex: 0, houseNumber: 1, bhavaNumber: 2),
      KundaliGraha(name: 'Sun', symbol: 'Su', longitude: 40,
        signIndex: 1, houseNumber: 2, bhavaNumber: 2),
      KundaliGraha(name: 'Jupiter', symbol: 'Ju', longitude: 100,
        signIndex: 3, houseNumber: 4, bhavaNumber: 5),
    ],
  );

  test('D1 analysis uses whole-sign house occupancy and aspects', () {
    final houses = BhavaAnalysisService.analyse(chart(), useChalit: false);
    expect(houses, hasLength(12));
    expect(houses[0].occupants.map((g) => g.name), ['Mars']);
    // Mars in house 1 aspects 4th, 7th and 8th; Jupiter in 4 aspects 8th.
    expect(houses[3].aspectingGrahas.map((g) => g.name), contains('Mars'));
    expect(houses[7].aspectingGrahas.map((g) => g.name), containsAll(['Mars', 'Jupiter']));
  });

  test('Bhava Chalit uses Bhava occupancy and Bhava source positions', () {
    final houses = BhavaAnalysisService.analyse(chart(), useChalit: true);
    expect(houses[0].occupants, isEmpty);
    expect(houses[1].occupants.map((g) => g.name), containsAll(['Mars', 'Sun']));
    // Mars is in Bhava 2, so its special aspects fall on 5, 8 and 9.
    expect(houses[4].aspectingGrahas.map((g) => g.name), contains('Mars'));
    expect(houses[0].aspectingGrahas.map((g) => g.name), isNot(contains('Mars')));
  });

  test('returns immutable analysis collections', () {
    final houses = BhavaAnalysisService.analyse(chart(), useChalit: false);
    expect(() => houses.add(houses.first), throwsUnsupportedError);
    expect(() => houses.first.aspectingGrahas.add(chart().grahas.first),
      throwsUnsupportedError);
  });
}
