import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:astrology/models/birth_profile.dart';
import 'package:astrology/services/kundali_history_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('stores and restores recent reports with full birth details', () async {
    final profile = BirthProfile(
      id: 'report-1',
      name: 'Test chart',
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

    await KundaliHistoryService.record(RecentKundaliReport(
      profile: profile,
      rashi: 'Leo',
      nakshatra: 'Magha',
      createdAt: DateTime(2026, 11, 27, 12),
    ));

    final recent = await KundaliHistoryService.getRecent();
    expect(recent, hasLength(1));
    expect(recent.first.profile.second, 45);
    expect(recent.first.profile.timeAccuracy, 'exact');
    expect(recent.first.rashi, 'Leo');
    expect(recent.first.nakshatra, 'Magha');
  });

  test('keeps the newest eight reports only', () async {
    for (var i = 0; i < 10; i++) {
      await KundaliHistoryService.record(RecentKundaliReport(
        profile: BirthProfile(
          id: 'report-$i',
          name: 'Chart $i',
          gender: 'Not specified',
          birthDate: DateTime(2000, 1, 1),
          hour: 12,
          minute: 0,
          placeName: 'Test',
          latitude: 0,
          longitude: 0,
          timeZoneId: 'UTC',
        ),
        rashi: 'Aries',
        nakshatra: 'Ashwini',
        createdAt: DateTime(2026, 1, 1).add(Duration(days: i)),
      ));
    }
    final recent = await KundaliHistoryService.getRecent();
    expect(recent, hasLength(8));
    expect(recent.first.profile.id, 'report-9');
    expect(recent.last.profile.id, 'report-2');
  });
}
