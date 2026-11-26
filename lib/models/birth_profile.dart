class BirthProfile {
  const BirthProfile({
    required this.id,
    required this.name,
    required this.gender,
    required this.birthDate,
    required this.hour,
    required this.minute,
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
  final String placeName;
  final double latitude;
  final double longitude;
  final String timeZoneId;

  String get formattedTime =>
      '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'gender': gender,
        'birthDate': DateTime(birthDate.year, birthDate.month, birthDate.day)
            .toIso8601String(),
        'hour': hour,
        'minute': minute,
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
        placeName: json['placeName'] as String,
        latitude: (json['latitude'] as num).toDouble(),
        longitude: (json['longitude'] as num).toDouble(),
        timeZoneId: json['timeZoneId'] as String,
      );
}
