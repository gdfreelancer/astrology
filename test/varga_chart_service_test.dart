import 'package:flutter_test/flutter_test.dart';
import 'package:astrology/models/kundali/kundali_graha.dart';
import 'package:astrology/services/varga_chart_service.dart';

void main() {
  group('Varga sign mapping', () {
    test('exposes all fifteen requested divisional charts', () {
      expect(VargaChartService.definitions.map((v) => v.division), [
        2, 3, 4, 7, 9, 10, 12, 16, 20, 24, 27, 30, 40, 45, 60,
      ]);
    });

    test('Hora assigns odd and even sign halves to the correct Hora', () {
      expect(VargaChartService.mapLongitude(1, 2), 4); // Aries first: Leo
      expect(VargaChartService.mapLongitude(16, 2), 3); // Aries second: Cancer
      expect(VargaChartService.mapLongitude(31, 2), 3); // Taurus first: Cancer
      expect(VargaChartService.mapLongitude(46, 2), 4); // Taurus second: Leo
    });

    test('Drekkana and Navamsa use their sign-counting rules', () {
      expect(VargaChartService.mapLongitude(0.1, 3), 0);
      expect(VargaChartService.mapLongitude(10.1, 3), 4);
      expect(VargaChartService.mapLongitude(20.1, 3), 8);
      expect(VargaChartService.mapLongitude(30.1, 9), 9); // fixed sign -> ninth
      expect(VargaChartService.mapLongitude(60.1, 9), 6); // dual sign -> fifth
    });

    test('other special Varga starts are applied', () {
      expect(VargaChartService.mapLongitude(30.1, 16), 4); // fixed -> Leo
      expect(VargaChartService.mapLongitude(30.1, 20), 8); // fixed -> Sagittarius
      expect(VargaChartService.mapLongitude(30.1, 24), 3); // even -> Cancer
      expect(VargaChartService.mapLongitude(0.1, 27), 0); // fire -> Aries
      expect(VargaChartService.mapLongitude(30.1, 40), 6); // even -> Libra
      expect(VargaChartService.mapLongitude(60.1, 45), 8); // dual -> Sagittarius
      expect(VargaChartService.mapLongitude(30.1, 60), 6); // even -> Libra
    });

    test('Trimshamsa uses unequal odd/even segments and own signs', () {
      expect(VargaChartService.mapLongitude(2, 30), 0); // Aries: Mars
      expect(VargaChartService.mapLongitude(6, 30), 10); // Aries: Saturn
      expect(VargaChartService.mapLongitude(32, 30), 1); // Taurus: Venus
      expect(VargaChartService.mapLongitude(38, 30), 5); // Taurus: Mercury
    });

    test('all supported divisions return a valid sign for boundary values', () {
      for (final division in VargaChartService.definitions.map((v) => v.division)) {
        for (final longitude in [0.0, 29.999999, 30.0, 179.999999, 359.999999, 360.0]) {
          final sign = VargaChartService.mapLongitude(longitude, division);
          expect(sign, inInclusiveRange(0, 11), reason: 'D$division at $longitude');
        }
      }
    });

    test('builds divisional houses from the divisional Ascendant', () {
      const natal = KundaliChart(
        ascendantLongitude: 0,
        ascendantSignIndex: 0,
        midheavenLongitude: 270,
        bhavas: [],
        grahas: [
          KundaliGraha(
            name: 'Sun', symbol: 'Su', longitude: 45, signIndex: 1,
            houseNumber: 2, bhavaNumber: 2,
          ),
        ],
      );
      final d9 = VargaChartService.calculate(natal, 9);
      expect(d9.ascendantSignIndex, 0);
      expect(d9.planets.single.signIndex, 1);
      expect(d9.planets.single.houseNumber, 2);
      expect(d9.inHouse(2).single.name, 'Sun');
    });
  });
}
