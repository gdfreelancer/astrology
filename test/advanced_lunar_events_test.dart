import 'package:flutter_test/flutter_test.dart';
import 'package:astrology/models/panchang_data.dart';
import 'package:astrology/services/panchang_service.dart';
import 'package:timezone/data/latest.dart' as timezone_data;

void main() {
  timezone_data.initializeTimeZones();
  const location = PanchangLocation(
    name: 'Ahmedabad, Gujarat, India',
    latitude: 23.0225,
    longitude: 72.5714,
    timeZoneId: 'Asia/Kolkata',
  );

  group('Advanced lunar events', () {
    test('lunar illumination stays within physical percentage bounds', () {
      final value = PanchangService.lunarIllumination(DateTime.utc(2026, 1, 1));
      expect(value, inInclusiveRange(0, 100));
    });

    test('phase classifier returns a supported translation key', () {
      final key = PanchangService.lunarPhaseKey(DateTime.utc(2026, 1, 1));
      expect(key, startsWith('lunar_phase_'));
    });

    test('events are chronologically sorted and cover lunar and solar events', () {
      final start = DateTime.utc(2026, 1, 1);
      final events = PanchangService.upcomingLunarEvents(
        from: start,
        location: location,
        days: 90,
      );
      expect(events, isNotEmpty);
      expect(events.every((event) =>
        !event.time.isBefore(start) &&
        event.time.isBefore(start.add(const Duration(days: 90)))), isTrue);
      for (var i = 1; i < events.length; i++) {
        expect(events[i].time.isBefore(events[i - 1].time), isFalse);
      }
      expect(events.any((event) => event.categoryKey == 'lunar_phase'), isTrue);
      expect(events.any((event) => event.categoryKey == 'lunar_tithi'), isTrue);
      expect(events.any((event) => event.categoryKey == 'solar_ingress'), isTrue);
    });

    test('Sankranti events carry a valid entered Rashi index', () {
      final events = PanchangService.upcomingLunarEvents(
        from: DateTime.utc(2026, 1, 1),
        location: location,
        days: 90,
      ).where((event) => event.categoryKey == 'solar_ingress');
      expect(events, isNotEmpty);
      for (final event in events) {
        expect(event.rashiIndex, inInclusiveRange(0, 11));
      }
    });
  });
}
