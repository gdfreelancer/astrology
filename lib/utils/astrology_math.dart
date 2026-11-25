/// Pure helpers for common Jyotish angular calculations.
class AstrologyMath {
  AstrologyMath._();

  static const double degreesPerNakshatra = 360.0 / 27.0;
  static const double degreesPerPada = degreesPerNakshatra / 4.0;

  static const List<String> karanas = [
    'Kimstughna',
    'Bava',
    'Balava',
    'Kaulava',
    'Taitila',
    'Garaja',
    'Vanija',
    'Vishti (Bhadra)',
    'Shakuni',
    'Chatushpada',
    'Naga',
  ];

  static double normalizeDegrees(double value) =>
      (value % 360.0 + 360.0) % 360.0;

  static double toSiderealLongitude({
    required double tropicalLongitude,
    required double ayanamsha,
  }) =>
      normalizeDegrees(tropicalLongitude - ayanamsha);

  /// Forward angular separation from [from] to [to], in the range [0, 360).
  static double angularSeparation(double from, double to) =>
      normalizeDegrees(to - from);

  static int nakshatraIndex(double siderealLongitude) =>
      (normalizeDegrees(siderealLongitude) / degreesPerNakshatra)
          .floor()
          .clamp(0, 26)
          .toInt();

  static int padaNumber(double siderealLongitude) {
    final withinNakshatra =
        normalizeDegrees(siderealLongitude) % degreesPerNakshatra;
    return (withinNakshatra / degreesPerPada).floor().clamp(0, 3).toInt() + 1;
  }

  /// Tithi index: 0..14 Shukla, 15..29 Krishna.
  static int tithiIndex(double sunLongitude, double moonLongitude) =>
      (angularSeparation(sunLongitude, moonLongitude) / 12.0)
          .floor()
          .clamp(0, 29)
          .toInt();

  static int yogaIndex(double sunLongitude, double moonLongitude) {
    final sum = normalizeDegrees(
      normalizeDegrees(sunLongitude) + normalizeDegrees(moonLongitude),
    );
    return (sum / degreesPerNakshatra).floor().clamp(0, 26).toInt();
  }

  /// Maps the 60 half-tithis to the seven repeating and four fixed karanas.
  ///
  /// Sequence: Kimstughna; seven movable karanas repeated eight times;
  /// then Shakuni, Chatushpada and Naga.
  static String karanaName(int halfTithiIndex) {
    if (halfTithiIndex < 0 || halfTithiIndex > 59) {
      throw RangeError.range(halfTithiIndex, 0, 59, 'halfTithiIndex');
    }
    if (halfTithiIndex == 0) return karanas[0];
    if (halfTithiIndex >= 57) return karanas[8 + halfTithiIndex - 57];
    return karanas[1 + ((halfTithiIndex - 1) % 7)];
  }
}
