import 'package:flutter_test/flutter_test.dart';
import 'package:astrology/services/vimshottari_dasha_service.dart';

void main() {
  group('Vimshottari Dasha calculation', () {
    final birth = DateTime.utc(2000, 1, 1);
    final timeline = VimshottariDashaService.calculate(
      siderealMoonLongitude: (360 / 27) * .5,
      birthDate: birth,
    );

    test('uses the correct Nakshatra lord and proportional birth balance', () {
      expect(timeline.birthNakshatra, 'Ashwini');
      expect(timeline.birthNakshatraLord, 'Ketu');
      expect(timeline.balanceAtBirthYears, closeTo(3.5, 1e-9));
      expect(timeline.mahadashas.first.planet, 'Ketu');
      expect(timeline.mahadashas.first.end.difference(birth).inDays,
          closeTo(3.5 * 365.2425, 1));
    });

    test('follows the nine-lord Vimshottari order', () {
      expect(timeline.mahadashas.map((p) => p.planet).toList(), [
        'Ketu', 'Venus', 'Sun', 'Moon', 'Mars',
        'Rahu', 'Jupiter', 'Saturn', 'Mercury',
      ]);
    });

    test('each full Mahadasha is followed by nine Antardashas', () {
      final venus = timeline.mahadashas[1];
      final periods = timeline.antardashas
          .where((p) => !p.start.isBefore(venus.start) && !p.end.isAfter(venus.end))
          .toList();
      expect(periods, hasLength(9));
      expect(periods.first.planet, 'Venus');
      expect(periods.last.planet, 'Ketu');
      expect(periods.first.start, venus.start);
      expect(periods.last.end, venus.end);
    });

    test('birth date resolves to a running Mahadasha and Antardasha', () {
      expect(timeline.mahadashaAt(birth)?.planet, 'Ketu');
      expect(timeline.antardashaAt(birth), isNotNull);
    });

    test('Moon longitude is normalized into the 27 Nakshatra cycle', () {
      final wrapped = VimshottariDashaService.calculate(
        siderealMoonLongitude: 360 + 1,
        birthDate: birth,
      );
      expect(wrapped.birthNakshatra, 'Ashwini');
      expect(wrapped.birthNakshatraLord, 'Ketu');
    });
  });
}
