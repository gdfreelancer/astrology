import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as timezone_data;
import 'package:timezone/timezone.dart' as tz;

import 'package:astrology/services/birth_chart_service.dart';

void main() {
  setUpAll(timezone_data.initializeTimeZones);

  group('BirthChartService', () {
    test('converts local historical birth time to the correct UTC instant', () {
      final result = BirthChartService.calculate(
        birthDate: DateTime(2000, 1, 1),
        hour: 2,
        minute: 30,
        second: 45,
        timeAccuracy: 'exact',
        timeZoneId: 'Asia/Kolkata',
        placeName: 'Test location',
        latitude: 23.0225,
        longitude: 72.5714,
        gender: 'Not specified',
      );

      expect(result.birthLocal, isA<tz.TZDateTime>());
      expect(result.birthUtc, DateTime.utc(1999, 12, 31, 21, 0, 45));
      expect(result.timeZoneId, 'Asia/Kolkata');
      expect(result.timeAccuracy, 'exact');
    });

    test('resolves historical daylight-saving offsets from the IANA zone', () {
      final winter = BirthChartService.calculate(
        birthDate: DateTime(2000, 1, 1),
        hour: 12,
        minute: 0,
        timeZoneId: 'America/New_York',
        placeName: 'Test location',
        latitude: 40.7128,
        longitude: -74.0060,
        gender: 'Not specified',
      );
      final summer = BirthChartService.calculate(
        birthDate: DateTime(2000, 7, 1),
        hour: 12,
        minute: 0,
        timeZoneId: 'America/New_York',
        placeName: 'Test location',
        latitude: 40.7128,
        longitude: -74.0060,
        gender: 'Not specified',
      );

      expect(winter.birthUtc, DateTime.utc(2000, 1, 1, 17));
      expect(summer.birthUtc, DateTime.utc(2000, 7, 1, 16));
    });

    test('returns complete normalized chart structures', () {
      final result = BirthChartService.calculate(
        birthDate: DateTime(2000, 1, 1),
        hour: 12,
        minute: 0,
        timeZoneId: 'UTC',
        placeName: 'Test location',
        latitude: 0,
        longitude: 0,
        gender: 'Not specified',
      );
      final chart = result.kundaliChart;

      expect(chart.grahas, hasLength(9));
      expect(chart.bhavas, hasLength(12));
      expect(chart.ascendantLongitude, inInclusiveRange(0, 360));
      expect(chart.midheavenLongitude, inInclusiveRange(0, 360));
      expect(chart.ascendantSignIndex, inInclusiveRange(0, 11));

      for (var index = 0; index < chart.bhavas.length; index++) {
        final house = chart.bhavas[index];
        expect(house.number, index + 1);
        expect(house.width, greaterThan(0));
        expect(
          BirthChartService.houseForLongitude(
            house.middleLongitude,
            chart.bhavas,
          ),
          house.number,
        );
      }

      for (final graha in chart.grahas) {
        expect(graha.longitude, inInclusiveRange(0, 360));
        expect(graha.signIndex, inInclusiveRange(0, 11));
        expect(graha.houseNumber, inInclusiveRange(1, 12));
        expect(graha.bhavaNumber, inInclusiveRange(1, 12));
        expect(graha.dailyMotion.isFinite, isTrue);
      }
    });

    test('rejects invalid coordinates and clock values before calculation', () {
      expect(
        () => BirthChartService.calculate(
          birthDate: DateTime(2000, 1, 1),
          hour: 12,
          minute: 0,
          timeZoneId: 'UTC',
          placeName: 'Invalid',
          latitude: 91,
          longitude: 0,
          gender: 'Not specified',
        ),
        throwsArgumentError,
      );
      expect(
        () => BirthChartService.calculate(
          birthDate: DateTime(2000, 1, 1),
          hour: 24,
          minute: 0,
          timeZoneId: 'UTC',
          placeName: 'Invalid',
          latitude: 0,
          longitude: 0,
          gender: 'Not specified',
        ),
        throwsRangeError,
      );
    });
  });
}
