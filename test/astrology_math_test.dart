import 'package:flutter_test/flutter_test.dart';
import 'package:astrology/utils/astrology_math.dart';
import 'package:astrology/services/astrology/ayanamsha_service.dart';

void main() {
  group('AstrologyMath', () {
    test('normalizes negative and overflowing longitudes', () {
      expect(AstrologyMath.normalizeDegrees(-10), 350);
      expect(AstrologyMath.normalizeDegrees(370), 10);
      expect(AstrologyMath.normalizeDegrees(720), 0);
    });

    test('calculates sidereal longitude across zero degrees', () {
      expect(
        AstrologyMath.toSiderealLongitude(
          tropicalLongitude: 5,
          ayanamsha: 24,
        ),
        341,
      );
    });

    test('maps Nakshatra and Pada boundaries', () {
      expect(AstrologyMath.nakshatraIndex(0), 0);
      expect(AstrologyMath.nakshatraIndex(360), 0);
      expect(AstrologyMath.nakshatraIndex(13 + 1 / 3), 1);
      expect(AstrologyMath.padaNumber(0), 1);
      expect(AstrologyMath.padaNumber(3.3333333334), 2);
    });

    test('maps all 30 tithis and 27 yogas within valid ranges', () {
      expect(AstrologyMath.tithiIndex(0, 0), 0);
      expect(AstrologyMath.tithiIndex(0, 180), 15);
      expect(AstrologyMath.tithiIndex(0, 359.999), 29);
      expect(AstrologyMath.yogaIndex(0, 0), 0);
      expect(AstrologyMath.yogaIndex(180, 180), 0);
    });

    test('maps the 60 karanas with correct fixed ending sequence', () {
      expect(AstrologyMath.karanaName(0), 'Kimstughna');
      expect(AstrologyMath.karanaName(1), 'Bava');
      expect(AstrologyMath.karanaName(56), 'Vishti (Bhadra)');
      expect(AstrologyMath.karanaName(57), 'Shakuni');
      expect(AstrologyMath.karanaName(58), 'Chatushpada');
      expect(AstrologyMath.karanaName(59), 'Naga');
    });

    test('rejects an invalid half-tithi index', () {
      expect(() => AstrologyMath.karanaName(60), throwsA(isA<RangeError>()));
    });
  });

  test('Lahiri ayanamsha is shared and returns degrees', () {
    final value = AyanamshaService.lahiri(DateTime.utc(2000, 1, 1, 12));
    expect(value, closeTo(23.8570922, 0.000001));
    expect(AyanamshaService.systemName, contains('Lahiri'));
  });
}
