class BirthProfile {
  const BirthProfile({
    required this.id,
    required this.name,
    required this.gender,
    required this.birthDate,
    required this.hour,
    required this.minute,
    this.second = 0,
    this.timeAccuracy = 'unknown',
    required this.placeName,
    required this.latitude,
    required this.longitude,
    required this.timeZoneId,
  });

  final String id;
  final String name;
  final String gender;
  final DateTime birthDate;
  final int hour;
  final int minute;
  final int second;
  /// exact, approximate, or unknown.
  final String timeAccuracy;
  final String placeName;
  final double latitude;
  final double longitude;
  final String timeZoneId;

  String get formattedTime =>
      '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}:${second.toString().padLeft(2, '0')}';

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'gender': gender,
        'birthDate': DateTime(birthDate.year, birthDate.month, birthDate.day)
            .toIso8601String(),
        'hour': hour,
        'minute': minute,
        'second': second,
        'timeAccuracy': timeAccuracy,
        'placeName': placeName,
        'latitude': latitude,
        'longitude': longitude,
        'timeZoneId': timeZoneId,
      };

  factory BirthProfile.fromJson(Map<String, dynamic> json) => BirthProfile(
        id: json['id'] as String,
        name: json['name'] as String,
        gender: json['gender'] as String? ?? 'Not specified',
        birthDate: DateTime.parse(json['birthDate'] as String),
        hour: (json['hour'] as num).toInt(),
        minute: (json['minute'] as num).toInt(),
        second: (json['second'] as num?)?.toInt() ?? 0,
        timeAccuracy: const ['exact', 'approximate', 'unknown'].contains(json['timeAccuracy'])
            ? json['timeAccuracy'] as String
            : 'unknown',
        placeName: json['placeName'] as String,
        latitude: (json['latitude'] as num).toDouble(),
        longitude: (json['longitude'] as num).toDouble(),
        timeZoneId: json['timeZoneId'] as String,
      );
}
