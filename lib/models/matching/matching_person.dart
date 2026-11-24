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
  );
}
