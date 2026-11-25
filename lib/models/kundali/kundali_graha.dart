class KundaliGraha {
  const KundaliGraha({
    required this.name,
    required this.symbol,
    required this.longitude,
    required this.signIndex,
    required this.houseNumber,
    required this.bhavaNumber,
    this.isRetrograde = false,
    this.dailyMotion = 0,
  });

  final String name;
  final String symbol;
  /// Sidereal geocentric longitude in degrees, normalized to [0, 360).
  final double longitude;
  final int signIndex;
  /// Whole-sign D1 house, retained for the Rashi chart.
  final int houseNumber;
  /// Sripati-style Bhava Chalit house based on computed house boundaries.
  final int bhavaNumber;
  final bool isRetrograde;
  /// Approximate sidereal longitude change per day.
  final double dailyMotion;

  double get signDegree => longitude % 30;
  int get nakshatraIndex => (longitude / (360 / 27)).floor().clamp(0, 26);
  int get pada => (((longitude % (360 / 27)) / (360 / 108)).floor() + 1).clamp(1, 4).toInt();
}

class BhavaHouse {
  const BhavaHouse({
    required this.number,
    required this.startLongitude,
    required this.middleLongitude,
    required this.endLongitude,
  });

  final int number;
  /// Beginning boundary (inclusive), measured sidereally.
  final double startLongitude;
  /// Bhava madhya (house midpoint).
  final double middleLongitude;
  /// Ending boundary (exclusive), measured sidereally.
  final double endLongitude;

  double get width => (endLongitude - startLongitude + 360) % 360;
  int get signIndex => (middleLongitude / 30).floor().clamp(0, 11);
}

class KundaliChart {
  const KundaliChart({
    required this.ascendantLongitude,
    required this.ascendantSignIndex,
    required this.midheavenLongitude,
    required this.bhavas,
    required this.grahas,
  });

  final double ascendantLongitude;
  final int ascendantSignIndex;
  final double midheavenLongitude;
  final List<BhavaHouse> bhavas;
  final List<KundaliGraha> grahas;

  List<KundaliGraha> inHouse(int houseNumber) =>
      grahas.where((graha) => graha.houseNumber == houseNumber).toList();

  List<KundaliGraha> inBhava(int bhavaNumber) =>
      grahas.where((graha) => graha.bhavaNumber == bhavaNumber).toList();

  BhavaHouse bhava(int number) => bhavas[number - 1];
}

const kundaliRashiNames = <String>[
  'Aries', 'Taurus', 'Gemini', 'Cancer', 'Leo', 'Virgo',
  'Libra', 'Scorpio', 'Sagittarius', 'Capricorn', 'Aquarius', 'Pisces',
];

const kundaliRashiSymbols = <String>[
  '♈', '♉', '♊', '♋', '♌', '♍',
  '♎', '♏', '♐', '♑', '♒', '♓',
];
