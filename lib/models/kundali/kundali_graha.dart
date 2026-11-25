class KundaliGraha {
  const KundaliGraha({
    required this.name,
    required this.symbol,
    required this.longitude,
    required this.signIndex,
    required this.houseNumber,
    this.isRetrograde = false,
  });

  final String name;
  final String symbol;
  final double longitude;
  final int signIndex;
  final int houseNumber;
  final bool isRetrograde;

  double get signDegree => longitude % 30;
}

class KundaliChart {
  const KundaliChart({
    required this.ascendantLongitude,
    required this.ascendantSignIndex,
    required this.grahas,
  });

  final double ascendantLongitude;
  final int ascendantSignIndex;
  final List<KundaliGraha> grahas;

  List<KundaliGraha> inHouse(int houseNumber) =>
      grahas.where((graha) => graha.houseNumber == houseNumber).toList();
}

const kundaliRashiNames = <String>[
  'Aries', 'Taurus', 'Gemini', 'Cancer', 'Leo', 'Virgo',
  'Libra', 'Scorpio', 'Sagittarius', 'Capricorn', 'Aquarius', 'Pisces',
];

const kundaliRashiSymbols = <String>[
  '♈', '♉', '♊', '♋', '♌', '♍',
  '♎', '♏', '♐', '♑', '♒', '♓',
];
