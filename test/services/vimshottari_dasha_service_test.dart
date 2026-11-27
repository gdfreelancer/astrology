import 'package:flutter_test/flutter_test.dart';
import 'package:astrology/services/vimshottari_dasha_service.dart';

void main() {
  final birth = DateTime.utc(2000, 1, 1);

  test('starts with the lord of Ashwini at zero longitude', () {
    final timeline = VimshottariDashaService.calculate(
      siderealMoonLongitude: 0,
      birthDate: birth,
    );
    expect(timeline.birthNakshatraLord, 'Ketu');
    expect(timeline.balanceAtBirthYears, closeTo(7, 1e-9));
    expect(timeline.mahadashas.first.planet, 'Ketu');
  });

  test('normalizes longitudes and wraps the 27 Nakshatra sequence', () {
    final zero = VimshottariDashaService.calculate(
      siderealMoonLongitude: 0,
      birthDate: birth,
    );
    final wrapped = VimshottariDashaService.calculate(
      siderealMoonLongitude: 360,
      birthDate: birth,
    );
    expect(wrapped.birthNakshatra, zero.birthNakshatra);
    expect(wrapped.birthNakshatraLord, zero.birthNakshatraLord);
    expect(wrapped.balanceAtBirthYears, closeTo(zero.balanceAtBirthYears, 1e-9));
  });

  test('uses the traditional nine-lord order and 120-year allocations', () {
    final timeline = VimshottariDashaService.calculate(
      siderealMoonLongitude: 0,
      birthDate: birth,
    );
    expect(timeline.mahadashas.map((p) => p.planet).toList(), [
      'Ketu', 'Venus', 'Sun', 'Moon', 'Mars',
      'Rahu', 'Jupiter', 'Saturn', 'Mercury',
    ]);
    expect(timeline.mahadashas.map((p) => p.years).toList(),
      [7, 20, 6, 10, 7, 18, 16, 19, 17]);
  });

  test('reconstructs the first Mahadasha Antardasha from before birth', () {
    final timeline = VimshottariDashaService.calculate(
      siderealMoonLongitude: 8,
      birthDate: birth,
    );
    final currentMaha = timeline.mahadashaAt(birth)!;
    final currentAntar = timeline.antardashaAt(birth)!;
    expect(currentAntar.start.isBefore(birth), isTrue);
    expect(currentAntar.end.isAfter(birth), isTrue);
    expect(currentMaha.contains(birth), isTrue);
  });

  test('returns null outside the calculated nine-Mahadasha horizon', () {
    final timeline = VimshottariDashaService.calculate(
      siderealMoonLongitude: 0,
      birthDate: birth,
    );
    expect(timeline.mahadashaAt(birth.subtract(const Duration(days: 1))), isNull);
    expect(timeline.mahadashaAt(timeline.mahadashas.last.end), isNull);
  });
}
