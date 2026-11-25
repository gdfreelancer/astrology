import 'kundali/kundali_graha.dart';

class BirthChartResult {
  const BirthChartResult({
    required this.birthLocal,
    required this.birthUtc,
    required this.placeName,
    required this.latitude,
    required this.longitude,
    required this.timeZoneId,
    required this.gender,
    required this.tropicalMoonLongitude,
    required this.ayanamsa,
    required this.siderealMoonLongitude,
    required this.moonLatitude,
    required this.moonDistanceAu,
    required this.rashi,
    required this.rashiSymbol,
    required this.nakshatra,
    required this.pada,
    required this.namingSyllable,
    required this.nakshatraProgress,
    required this.nearBoundary,
    required this.kundaliChart,
  });

  final DateTime birthLocal;
  final DateTime birthUtc;
  final String placeName;
  final double latitude;
  final double longitude;
  final String timeZoneId;
  final String gender;
  final double tropicalMoonLongitude;
  final double ayanamsa;
  final double siderealMoonLongitude;
  final double moonLatitude;
  final double moonDistanceAu;
  final String rashi;
  final String rashiSymbol;
  final String nakshatra;
  final int pada;
  final String namingSyllable;
  final double nakshatraProgress;
  final bool nearBoundary;
  final KundaliChart kundaliChart;
}
