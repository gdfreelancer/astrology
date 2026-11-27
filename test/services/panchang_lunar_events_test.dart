import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as timezone_data;
import 'package:timezone/timezone.dart' as tz;

import 'package:astrology/models/panchang_data.dart';
import 'package:astrology/services/panchang_service.dart';

void main() {
  setUpAll(timezone_data.initializeTimeZones);

  const location = PanchangLocation(
    name: 'Ahmedabad, Gujarat, India',
    latitude: 23.0225,
    longitude: 72.5714,
    timeZoneId: 'Asia/Kolkata',
  );

  group('PanchangService lunar calculations', () {
    test('moon illumination remains within physical percentage bounds', () {
      final samples = [
        DateTime.utc(2026, 1, 1),
        DateTime.utc(2026, 1, 8),
        DateTime.utc(2026, 1, 15),
        DateTime.utc(2026, 1, 22),
      ];

      for (final sample in samples) {
        final illumination = PanchangService.lunarIllumination(sample);
        expect(illumination, inInclusiveRange(0, 100));
      }
    });

    test('phase classifier returns one of the eight supported phases', () {
      const supported = {
        'lunar_phase_new',
        'lunar_phase_waxing_crescent',
        'lunar_phase_first_quarter',
        'lunar_phase_waxing_gibbous',
        'lunar_phase_full',
        'lunar_phase_waning_gibbous',
        'lunar_phase_last_quarter',
        'lunar_phase_waning_crescent',
      };

      final phase = PanchangService.lunarPhaseKey(DateTime.utc(2026, 1, 1));
      expect(supported, contains(phase));
    });

    test('90-day event scan returns sorted UTC lunar and solar events', () {
      final from = DateTime(2026, 1, 1);
      final start = tz.TZDateTime(
        tz.getLocation(location.timeZoneId),
        from.year,
        from.month,
        from.day,
      ).toUtc();
      final end = start.add(const Duration(days: 90));

      final events = PanchangService.upcomingLunarEvents(
        from: from,
        location: location,
        days: 90,
      );

      expect(events, isNotEmpty);
      expect(
        events.every((event) => event.time.isUtc),
        isTrue,
      );
      expect(
        events.every(
          (event) =>
              !event.time.isBefore(start) && event.time.isBefore(end),
        ),
        isTrue,
      );

      for (var index = 1; index < events.length; index++) {
        expect(
          events[index].time.isBefore(events[index - 1].time),
          isFalse,
          reason: 'Events must be ordered chronologically.',
        );
      }

      expect(
        events.any((event) => event.categoryKey == 'lunar_phase'),
        isTrue,
      );
      expect(
        events.any((event) => event.categoryKey == 'lunar_tithi'),
        isTrue,
      );
      expect(
        events.any((event) => event.categoryKey == 'solar_ingress'),
        isTrue,
      );
    });

    test('phase events cover all four quarter boundaries', () {
      final events = PanchangService.upcomingLunarEvents(
        from: DateTime(2026, 1, 1),
        location: location,
        days: 90,
      );
      final phaseTitles = events
          .where((event) => event.categoryKey == 'lunar_phase')
          .map((event) => event.titleKey)
          .toSet();

      expect(
        phaseTitles,
        containsAll({
          'lunar_new_moon',
          'lunar_first_quarter',
          'lunar_full_moon',
          'lunar_last_quarter',
        }),
      );
    });

    test('Ekadashi and Sankranti event metadata stays in valid ranges', () {
      final events = PanchangService.upcomingLunarEvents(
        from: DateTime(2026, 1, 1),
        location: location,
        days: 90,
      );

      final ekadashiEvents = events
          .where((event) => event.categoryKey == 'lunar_tithi')
          .toList(growable: false);
      final ingressEvents = events
          .where((event) => event.categoryKey == 'solar_ingress')
          .toList(growable: false);

      expect(ekadashiEvents, isNotEmpty);
      expect(
        ekadashiEvents.every((event) => event.titleKey == 'lunar_ekadashi'),
        isTrue,
      );
      expect(ingressEvents, isNotEmpty);
      expect(
        ingressEvents.every(
          (event) =>
              event.titleKey == 'lunar_sankranti' &&
              event.rashiIndex != null &&
              event.rashiIndex! >= 0 &&
              event.rashiIndex! < 12,
        ),
        isTrue,
      );
    });

    test('invalid coordinates are rejected before event calculation', () {
      const invalidLocation = PanchangLocation(
        name: 'Invalid',
        latitude: 91,
        longitude: 0,
        timeZoneId: 'Asia/Kolkata',
      );

      expect(
        () => PanchangService.upcomingLunarEvents(
          from: DateTime(2026, 1, 1),
          location: invalidLocation,
        ),
        throwsA(isA<ArgumentError>()),
      );
    });
  });
}
