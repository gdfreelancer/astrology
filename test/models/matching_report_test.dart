import 'package:flutter_test/flutter_test.dart';

import 'package:astrology/models/kundali/kundali_graha.dart';
import 'package:astrology/models/matching/koota_result.dart';
import 'package:astrology/models/matching/matching_person.dart';
import 'package:astrology/models/matching/matching_report.dart';

MatchingPerson person({bool includeChart = true}) => MatchingPerson(
  name: 'Test',
  role: 'Bride',
  birthDate: DateTime(1999, 9, 21),
  birthTime: '2:30 AM',
  placeName: 'Junagadh',
  latitude: 21.52,
  longitude: 70.46,
  timeZoneId: 'Asia/Kolkata',
  rashi: 'Leo',
  rashiSymbol: '♌',
  nakshatra: 'Magha',
  pada: 2,
  siderealMoonLongitude: 130.5,
  ayanamsa: 23.8,
  nearBoundary: false,
  kundaliChart: includeChart
      ? const KundaliChart(
          ascendantLongitude: 120.5,
          ascendantSignIndex: 4,
          midheavenLongitude: 210,
          bhavas: [
            BhavaHouse(number: 1, startLongitude: 100, middleLongitude: 115, endLongitude: 130),
          ],
          grahas: [
            KundaliGraha(
              name: 'Moon',
              symbol: '☾',
              longitude: 130.5,
              signIndex: 4,
              houseNumber: 1,
              bhavaNumber: 1,
              dailyMotion: 13.2,
            ),
          ],
        )
      : null,
);

KootaResult koota() => const KootaResult(
  key: 'varna',
  name: 'Varna',
  maxPoints: 1,
  points: 1,
  brideValue: 'Brahmin',
  groomValue: 'Kshatriya',
  summary: 'Compatible',
  explanation: 'Fixture explanation',
);

void main() {
  group('Matching report persistence', () {
    test('round-trips full D1 chart data and report scoring', () {
      final report = MatchingReport(
        createdAt: DateTime(2026, 11, 27, 12),
        bride: person(),
        groom: person().copyWithRoleForTest('Groom'),
        kootas: [koota()],
        calculationVersion: 'test-v1',
      );

      final restored = MatchingReport.fromJson(report.toJson(), id: 42);
      expect(restored.id, 42);
      expect(restored.totalPoints, 1);
      expect(restored.maximumPoints, 1);
      expect(restored.bride.kundaliChart, isNotNull);
      expect(restored.bride.kundaliChart!.grahas.single.longitude, 130.5);
      expect(restored.bride.kundaliChart!.bhavas.single.middleLongitude, 115);
      expect(restored.groom.kundaliChart!.ascendantSignIndex, 4);
    });

    test('loads legacy matching reports without optional chart and boundary data', () {
      final legacy = {
        'createdAt': '2025-01-01T00:00:00.000',
        'calculationVersion': 'legacy-v1',
        'bride': {
          'name': 'Bride', 'role': 'Bride', 'birthDate': '1999-09-21T00:00:00.000',
          'birthTime': '2:30 AM', 'placeName': 'Junagadh', 'latitude': 21.52,
          'longitude': 70.46, 'timeZoneId': 'Asia/Kolkata', 'rashi': 'Leo',
          'rashiSymbol': '♌', 'nakshatra': 'Magha', 'pada': 2,
          'siderealMoonLongitude': 130.5, 'ayanamsa': 23.8,
        },
        'groom': {
          'name': 'Groom', 'role': 'Groom', 'birthDate': '2000-01-01T00:00:00.000',
          'birthTime': '10:00 AM', 'placeName': 'Surat', 'latitude': 21.17,
          'longitude': 72.83, 'timeZoneId': 'Asia/Kolkata', 'rashi': 'Taurus',
          'rashiSymbol': '♉', 'nakshatra': 'Rohini', 'pada': 1,
          'siderealMoonLongitude': 40.5, 'ayanamsa': 23.8,
        },
        'kootas': [koota().toJson()],
      };

      final restored = MatchingReport.fromJson(legacy);
      expect(restored.bride.nearBoundary, isFalse);
      expect(restored.bride.kundaliChart, isNull);
      expect(restored.groom.kundaliChart, isNull);
      expect(restored.totalPoints, 1);
    });
  });
}

extension on MatchingPerson {
  MatchingPerson copyWithRoleForTest(String role) => MatchingPerson(
    name: name, role: role, birthDate: birthDate, birthTime: birthTime,
    placeName: placeName, latitude: latitude, longitude: longitude,
    timeZoneId: timeZoneId, rashi: rashi, rashiSymbol: rashiSymbol,
    nakshatra: nakshatra, pada: pada,
    siderealMoonLongitude: siderealMoonLongitude, ayanamsa: ayanamsa,
    nearBoundary: nearBoundary, kundaliChart: kundaliChart,
  );
}
