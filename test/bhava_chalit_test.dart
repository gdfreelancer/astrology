import 'package:flutter_test/flutter_test.dart';
import 'package:astrology/services/birth_chart_service.dart';

void main() {
  group('Bhava Chalit house cusps', () {
    final houses = BirthChartService.calculateBhavaHouses(
      ascendantLongitude: 100,
      midheavenLongitude: 10,
    );

    test('creates twelve ordered houses with positive spans', () {
      expect(houses, hasLength(12));
      expect(houses.map((house) => house.number).toList(),
          List<int>.generate(12, (index) => index + 1));
      for (final house in houses) {
        expect(house.width, greaterThan(0));
        expect(house.width, lessThan(90));
      }
    });

    test('all house spans cover one complete zodiac', () {
      final total = houses.fold<double>(0, (sum, house) => sum + house.width);
      expect(total, closeTo(360, 1e-6));
    });

    test('each Bhava Madhya belongs to its own house', () {
      for (final house in houses) {
        expect(
          BirthChartService.houseForLongitude(house.middleLongitude, houses),
          house.number,
        );
      }
    });

    test('every zodiac degree maps to a valid house', () {
      for (var degree = 0; degree < 360; degree++) {
        final house = BirthChartService.houseForLongitude(
          degree.toDouble(), houses,
        );
        expect(house, inInclusiveRange(1, 12));
      }
    });
  });
}
