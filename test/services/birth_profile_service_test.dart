import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:astrology/models/birth_profile.dart';
import 'package:astrology/services/birth_profile_service.dart';

BirthProfile _profile(String id) => BirthProfile(
      id: id,
      name: id,
      gender: 'Not specified',
      birthDate: DateTime(2000, 1, 1),
      hour: 12,
      minute: 0,
      placeName: 'Test',
      latitude: 0,
      longitude: 0,
      timeZoneId: 'UTC',
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('BirthProfileService selection', () {
    test('selects the first saved profile by default', () async {
      await BirthProfileService.save(_profile('first'));
      await BirthProfileService.save(_profile('second'));
      expect(await BirthProfileService.getSelectedId(), 'first');
    });

    test('persists explicit selection and falls back after deletion', () async {
      await BirthProfileService.save(_profile('first'));
      await BirthProfileService.save(_profile('second'));
      await BirthProfileService.select('second');
      expect((await BirthProfileService.getSelected())?.id, 'second');

      await BirthProfileService.delete('second');
      expect((await BirthProfileService.getSelected())?.id, 'first');
    });

    test('clears selection when the final profile is deleted', () async {
      await BirthProfileService.save(_profile('only'));
      await BirthProfileService.delete('only');
      expect(await BirthProfileService.getSelectedId(), isNull);
    });
  });
}
