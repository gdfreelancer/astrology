import '../models/kundali/kundali_graha.dart';

class VargaDefinition {
  const VargaDefinition({
    required this.division,
    required this.nameKey,
    required this.shortName,
    required this.descriptionKey,
  });
  final int division;
  final String nameKey;
  final String shortName;
  final String descriptionKey;
}

class VargaPlanetPosition {
  const VargaPlanetPosition({
    required this.name,
    required this.symbol,
    required this.signIndex,
    required this.houseNumber,
    required this.isRetrograde,
  });
  final String name;
  final String symbol;
  final int signIndex;
  final int houseNumber;
  final bool isRetrograde;
}

class VargaChart {
  const VargaChart({
    required this.definition,
    required this.ascendantSignIndex,
    required this.planets,
  });
  final VargaDefinition definition;
  final int ascendantSignIndex;
  final List<VargaPlanetPosition> planets;

  List<VargaPlanetPosition> inHouse(int house) =>
      planets.where((p) => p.houseNumber == house).toList();
}

class VargaChartService {
  VargaChartService._();

  static const definitions = <VargaDefinition>[
    VargaDefinition(division: 2, nameKey: 'varga_d2', shortName: 'D2', descriptionKey: 'varga_d2_desc'),
    VargaDefinition(division: 3, nameKey: 'varga_d3', shortName: 'D3', descriptionKey: 'varga_d3_desc'),
    VargaDefinition(division: 4, nameKey: 'varga_d4', shortName: 'D4', descriptionKey: 'varga_d4_desc'),
    VargaDefinition(division: 7, nameKey: 'varga_d7', shortName: 'D7', descriptionKey: 'varga_d7_desc'),
    VargaDefinition(division: 9, nameKey: 'varga_d9', shortName: 'D9', descriptionKey: 'varga_d9_desc'),
    VargaDefinition(division: 10, nameKey: 'varga_d10', shortName: 'D10', descriptionKey: 'varga_d10_desc'),
    VargaDefinition(division: 12, nameKey: 'varga_d12', shortName: 'D12', descriptionKey: 'varga_d12_desc'),
    VargaDefinition(division: 16, nameKey: 'varga_d16', shortName: 'D16', descriptionKey: 'varga_d16_desc'),
    VargaDefinition(division: 20, nameKey: 'varga_d20', shortName: 'D20', descriptionKey: 'varga_d20_desc'),
    VargaDefinition(division: 24, nameKey: 'varga_d24', shortName: 'D24', descriptionKey: 'varga_d24_desc'),
    VargaDefinition(division: 27, nameKey: 'varga_d27', shortName: 'D27', descriptionKey: 'varga_d27_desc'),
    VargaDefinition(division: 30, nameKey: 'varga_d30', shortName: 'D30', descriptionKey: 'varga_d30_desc'),
    VargaDefinition(division: 40, nameKey: 'varga_d40', shortName: 'D40', descriptionKey: 'varga_d40_desc'),
    VargaDefinition(division: 45, nameKey: 'varga_d45', shortName: 'D45', descriptionKey: 'varga_d45_desc'),
    VargaDefinition(division: 60, nameKey: 'varga_d60', shortName: 'D60', descriptionKey: 'varga_d60_desc'),
  ];

  static VargaChart calculate(KundaliChart natal, int division) {
    final definition = definitions.firstWhere((d) => d.division == division);
    final asc = _mapLongitude(natal.ascendantLongitude, division);
    final planets = natal.grahas.map((graha) {
      final sign = _mapLongitude(graha.longitude, division);
      return VargaPlanetPosition(
        name: graha.name,
        symbol: graha.symbol,
        signIndex: sign,
        houseNumber: ((sign - asc + 12) % 12) + 1,
        isRetrograde: graha.isRetrograde,
      );
    }).toList(growable: false);
    return VargaChart(
      definition: definition,
      ascendantSignIndex: asc,
      planets: planets,
    );
  }

  static int mapLongitude(double longitude, int division) =>
      _mapLongitude(longitude, division);

  static int _mapLongitude(double longitude, int division) {
    final normalized = (longitude % 360 + 360) % 360;
    final sign = (normalized / 30).floor();
    final within = normalized - sign * 30;
    final odd = sign.isEven; // Aries is the first (odd) sign.
    final part = switch (division) {
      2 => within < 15 ? (odd ? 4 : 3) : (odd ? 3 : 4),
      3 => (sign + (within / 10).floor() * 4) % 12,
      4 => (sign + (within / 7.5).floor() * 3) % 12,
      7 => _sequential(sign, (within / (30 / 7)).floor(), odd ? sign : (sign + 6) % 12),
      9 => _sequential(sign, (within / (30 / 9)).floor(), _navamsaStart(sign)),
      10 => _sequential(sign, (within / 3).floor(), odd ? sign : (sign + 8) % 12),
      12 => (sign + (within / 2.5).floor()) % 12,
      16 => _sequential(sign, (within / (30 / 16)).floor(), _modalityStart(sign, 0, 4, 8)),
      20 => _sequential(sign, (within / 1.5).floor(), _modalityStart(sign, 0, 8, 4)),
      24 => _sequential(sign, (within / 1.25).floor(), odd ? 4 : 3),
      27 => _sequential(sign, (within / (30 / 27)).floor(), _elementStart(sign)),
      30 => _trimshamsa(sign, within),
      40 => _sequential(sign, (within / .75).floor(), odd ? 0 : 6),
      45 => _sequential(sign, (within / (30 / 45)).floor(), _modalityStart(sign, 0, 4, 8)),
      60 => _sequential(sign, (within / .5).floor(), odd ? 0 : 6),
      _ => throw ArgumentError.value(division, 'division', 'Unsupported Varga division'),
    };
    return part.clamp(0, 11).toInt();
  }

  static int _sequential(int natalSign, int part, int start) =>
      (start + part) % 12;

  static int _navamsaStart(int sign) {
    final modality = sign % 3;
    return switch (modality) {
      0 => sign, // movable
      1 => (sign + 8) % 12, // fixed: ninth sign
      _ => (sign + 4) % 12, // dual: fifth sign
    };
  }

  static int _modalityStart(int sign, int movable, int fixed, int dual) =>
      switch (sign % 3) {
        0 => movable,
        1 => fixed,
        _ => dual,
      };

  static int _elementStart(int sign) => switch (sign % 4) {
    0 => 0, // Fire -> Aries
    1 => 3, // Earth -> Cancer
    2 => 6, // Air -> Libra
    _ => 9, // Water -> Capricorn
  };

  static int _trimshamsa(int sign, double degree) {
    final segments = sign.isEven
        ? const [(5.0, 0), (5.0, 10), (8.0, 8), (7.0, 2), (5.0, 6)]
        : const [(5.0, 1), (7.0, 5), (8.0, 11), (5.0, 9), (5.0, 7)];
    var edge = 0.0;
    for (final segment in segments) {
      edge += segment.$1;
      if (degree < edge) return segment.$2;
    }
    return segments.last.$2;
  }
}
