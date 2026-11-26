import '../kundali/kundali_graha.dart';

class MatchingPerson {
  const MatchingPerson({
    required this.name,
    required this.role,
    required this.birthDate,
    required this.birthTime,
    required this.placeName,
    required this.latitude,
    required this.longitude,
    required this.timeZoneId,
    required this.rashi,
    required this.rashiSymbol,
    required this.nakshatra,
    required this.pada,
    required this.siderealMoonLongitude,
    required this.ayanamsa,
    required this.nearBoundary,
    this.kundaliChart,
  });

  final String name;
  final String role;
  final DateTime birthDate;
  final String birthTime;
  final String placeName;
  final double latitude;
  final double longitude;
  final String timeZoneId;
  final String rashi;
  final String rashiSymbol;
  final String nakshatra;
  final int pada;
  final double siderealMoonLongitude;
  final double ayanamsa;
  final bool nearBoundary;
  final KundaliChart? kundaliChart;

  Map<String, dynamic> toJson() => {
    'name': name,
    'role': role,
    'birthDate': birthDate.toIso8601String(),
    'birthTime': birthTime,
    'placeName': placeName,
    'latitude': latitude,
    'longitude': longitude,
    'timeZoneId': timeZoneId,
    'rashi': rashi,
    'rashiSymbol': rashiSymbol,
    'nakshatra': nakshatra,
    'pada': pada,
    'siderealMoonLongitude': siderealMoonLongitude,
    'ayanamsa': ayanamsa,
    'nearBoundary': nearBoundary,
    if (kundaliChart != null) 'kundaliChart': {
      'ascendantLongitude': kundaliChart!.ascendantLongitude,
      'ascendantSignIndex': kundaliChart!.ascendantSignIndex,
      'midheavenLongitude': kundaliChart!.midheavenLongitude,
      'bhavas': kundaliChart!.bhavas.map((b) => {'number':b.number,'startLongitude':b.startLongitude,'middleLongitude':b.middleLongitude,'endLongitude':b.endLongitude}).toList(),
      'grahas': kundaliChart!.grahas.map((g) => {
        'name': g.name, 'symbol': g.symbol, 'longitude': g.longitude,
        'signIndex': g.signIndex, 'houseNumber': g.houseNumber, 'bhavaNumber':g.bhavaNumber, 'dailyMotion':g.dailyMotion,
        'isRetrograde': g.isRetrograde,
      }).toList(),
    },
  };

  factory MatchingPerson.fromJson(Map<String, dynamic> json) => MatchingPerson(
    name: json['name'] as String,
    role: json['role'] as String,
    birthDate: DateTime.parse(json['birthDate'] as String),
    birthTime: json['birthTime'] as String,
    placeName: json['placeName'] as String,
    latitude: (json['latitude'] as num).toDouble(),
    longitude: (json['longitude'] as num).toDouble(),
    timeZoneId: json['timeZoneId'] as String,
    rashi: json['rashi'] as String,
    rashiSymbol: json['rashiSymbol'] as String,
    nakshatra: json['nakshatra'] as String,
    pada: json['pada'] as int,
    siderealMoonLongitude: (json['siderealMoonLongitude'] as num).toDouble(),
    ayanamsa: (json['ayanamsa'] as num).toDouble(),
    nearBoundary: json['nearBoundary'] as bool? ?? false,
    kundaliChart: json['kundaliChart'] == null ? null : KundaliChart(
      ascendantLongitude: (json['kundaliChart']['ascendantLongitude'] as num).toDouble(),
      ascendantSignIndex: json['kundaliChart']['ascendantSignIndex'] as int,
      midheavenLongitude: (json['kundaliChart']['midheavenLongitude'] as num?)?.toDouble() ?? 0,
      bhavas: ((json['kundaliChart']['bhavas'] as List<dynamic>?) ?? const []).map((item) => BhavaHouse(number:item['number'] as int,startLongitude:(item['startLongitude'] as num).toDouble(),middleLongitude:(item['middleLongitude'] as num).toDouble(),endLongitude:(item['endLongitude'] as num).toDouble())).toList(),
      grahas: (json['kundaliChart']['grahas'] as List<dynamic>).map((item) => KundaliGraha(
        name: item['name'] as String,
        symbol: item['symbol'] as String,
        longitude: (item['longitude'] as num).toDouble(),
        signIndex: item['signIndex'] as int,
        houseNumber: item['houseNumber'] as int,
        bhavaNumber: item['bhavaNumber'] as int? ?? item['houseNumber'] as int,
        dailyMotion: (item['dailyMotion'] as num?)?.toDouble() ?? 0,
        isRetrograde: item['isRetrograde'] as bool? ?? false,
      )).toList(),
    ),
  );
}
