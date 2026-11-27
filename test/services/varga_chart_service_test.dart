import 'package:flutter_test/flutter_test.dart';

import '../../lib/models/kundali/kundali_graha.dart';
import '../../lib/services/varga_chart_service.dart';

void main() {
  test('maps degree within each regular Varga segment', () {
    const divisions = [2, 3, 4, 7, 9, 10, 12, 16, 20, 24, 27, 40, 45, 60];
    for (final division in divisions) {
      final segment = 30 / division;
      final longitude = 12 * 30 + segment / 2;
      final chart = KundaliChart(
        ascendantLongitude: 0,
        ascendantSignIndex: 0,
        midheavenLongitude: 180,
        bhavas: const [],
        grahas: [
          KundaliGraha(
            name: 'Sun',
            symbol: 'Su',
            longitude: longitude,
            signIndex: 0,
            houseNumber: 1,
            bhavaNumber: 1,
          ),
        ],
      );
      final result = VargaChartService.calculate(chart, division);
      expect(result.planets.single.degreeInSign, closeTo(15, 0.000001),
          reason: 'D$division midpoint must map to 15 degrees');
    }
  });

  test('maps unequal Trimshamsa segment midpoint to 15 degrees', () {
    final chart = KundaliChart(
      ascendantLongitude: 0,
      ascendantSignIndex: 0,
      midheavenLongitude: 180,
      bhavas: const [],
      grahas: [
        KundaliGraha(
          name: 'Sun',
          symbol: 'Su',
          longitude: 2.5,
          signIndex: 0,
          houseNumber: 1,
          bhavaNumber: 1,
        ),
      ],
    );
    final result = VargaChartService.calculate(chart, 30);
    expect(result.planets.single.degreeInSign, closeTo(15, 0.000001));
  });
}
