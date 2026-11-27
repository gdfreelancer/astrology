import 'package:flutter_test/flutter_test.dart';
import 'package:astrology/utils/astrology_math.dart';

void main() {
  group('AstrologyMath', () {
    test('normalizes positive, negative and full-circle angles', () {
      expect(AstrologyMath.normalizeDegrees(361), closeTo(1, 1e-10));
      expect(AstrologyMath.normalizeDegrees(-1), closeTo(359, 1e-10));
      expect(AstrologyMath.normalizeDegrees(720), closeTo(0, 1e-10));
    });

    test('converts tropical longitude to normalized sidereal longitude', () {
      expect(
        AstrologyMath.toSiderealLongitude(
          tropicalLongitude: 10,
          ayanamsha: 24,
        ),
        closeTo(346, 1e-10),
      );
    });

    test('calculates Nakshatra and Pada including boundaries', () {
      expect(AstrologyMath.nakshatraIndex(0), 0);
      expect(AstrologyMath.nakshatraIndex(360), 0);
      expect(AstrologyMath.nakshatraIndex(360 / 27), 1);
      expect(AstrologyMath.padaNumber(0), 1);
      expect(AstrologyMath.padaNumber(AstrologyMath.degreesPerPada), 2);
      expect(AstrologyMath.padaNumber(360), 1);
    });

    test('calculates Tithi index from forward Sun-Moon separation', () {
      expect(AstrologyMath.tithiIndex(0, 0), 0);
      expect(AstrologyMath.tithiIndex(0, 12), 1);
      expect(AstrologyMath.tithiIndex(350, 2), 1);
      expect(AstrologyMath.tithiIndex(0, 180), 15);
      expect(AstrologyMath.tithiIndex(0, 359.999), 29);
    });

    test('calculates Yoga index from normalized sum of longitudes', () {
      expect(AstrologyMath.yogaIndex(0, 0), 0);
      expect(AstrologyMath.yogaIndex(350, 20), 0);
      expect(AstrologyMath.yogaIndex(0, 360 / 27), 1);
    });

    test('maps all 60 half-tithis to the traditional Karana sequence', () {
      expect(AstrologyMath.karanaName(0), 'Kimstughna');
      expect(AstrologyMath.karanaName(1), 'Bava');
      expect(AstrologyMath.karanaName(7), 'Vishti (Bhadra)');
      expect(AstrologyMath.karanaName(8), 'Bava');
      expect(AstrologyMath.karanaName(56), 'Vishti (Bhadra)');
      expect(AstrologyMath.karanaName(57), 'Shakuni');
      expect(AstrologyMath.karanaName(58), 'Chatushpada');
      expect(AstrologyMath.karanaName(59), 'Naga');
      expect(
        () => AstrologyMath.karanaName(60),
        throwsRangeError,
      );
    });
  });
}
