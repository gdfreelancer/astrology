import 'package:flutter_test/flutter_test.dart';
import 'package:astrology/models/birth_profile.dart';

void main() {
  group('BirthProfile', () {
    test('round-trips second-level time and accuracy metadata', () {
      const profile = BirthProfile(
        id: 'profile-1',
        name: 'Test',
        gender: 'Not specified',
        birthDate: DateTime(1999, 9, 21),
        hour: 2,
        minute: 30,
        second: 45,
        timeAccuracy: 'exact',
        placeName: 'Junagadh',
        latitude: 21.52,
        longitude: 70.46,
        timeZoneId: 'Asia/Kolkata',
      );
      final restored = BirthProfile.fromJson(profile.toJson());
      expect(restored.second, 45);
      expect(restored.timeAccuracy, 'exact');
      expect(restored.formattedTime, '02:30:45');
    });

    test('reads existing stored profiles without new optional fields', () {
      final restored = BirthProfile.fromJson({
        'id': 'old',
        'name': 'Legacy',
        'gender': 'Not specified',
        'birthDate': '1999-09-21T00:00:00.000',
        'hour': 2,
        'minute': 30,
        'placeName': 'Junagadh',
        'latitude': 21.52,
        'longitude': 70.46,
        'timeZoneId': 'Asia/Kolkata',
      });
      expect(restored.second, 0);
      expect(restored.timeAccuracy, 'unknown');
    });
  });
}
