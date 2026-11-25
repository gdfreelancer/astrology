import '../data/nakshatra_data.dart';
import '../models/vimshottari_timeline.dart';

/// Traditional 120-year Vimshottari sequence calculated from the sidereal
/// Moon's birth Nakshatra. A Dasha year is represented by 365.2425 days.
class VimshottariDashaService {
  VimshottariDashaService._();

  static const int cycleYears = 120;
  static const double daysPerYear = 365.2425;
  static const List<String> sequence = [
    'Ketu', 'Venus', 'Sun', 'Moon', 'Mars',
    'Rahu', 'Jupiter', 'Saturn', 'Mercury',
  ];
  static const Map<String, int> years = {
    'Ketu': 7, 'Venus': 20, 'Sun': 6, 'Moon': 10, 'Mars': 7,
    'Rahu': 18, 'Jupiter': 16, 'Saturn': 19, 'Mercury': 17,
  };

  static VimshottariTimeline calculate({
    required double siderealMoonLongitude,
    required DateTime birthDate,
  }) {
    final longitude = _normalize(siderealMoonLongitude);
    const nakshatraSpan = 360 / 27;
    final nakshatraIndex = (longitude / nakshatraSpan).floor().clamp(0, 26);
    final progress = (longitude - nakshatraIndex * nakshatraSpan) /
        nakshatraSpan;
    final lord = sequence[nakshatraIndex % sequence.length];
    final lordYears = years[lord]!;
    final balanceYears = lordYears * (1 - progress);

    final mahadashas = <VimshottariPeriod>[];
    var cursor = birthDate;
    final startIndex = sequence.indexOf(lord);
    for (var i = 0; i < sequence.length; i++) {
      final planet = sequence[(startIndex + i) % sequence.length];
      final durationYears = i == 0 ? balanceYears : years[planet]!.toDouble();
      final end = _addYears(cursor, durationYears);
      mahadashas.add(VimshottariPeriod(
        planet: planet,
        years: years[planet]!,
        start: cursor,
        end: end,
      ));
      cursor = end;
    }

    final antardashas = <VimshottariPeriod>[];
    for (final maha in mahadashas) {
      final mahaStartIndex = sequence.indexOf(maha.planet);
      var antarCursor = maha.start;
      for (var i = 0; i < sequence.length; i++) {
        final antarLord = sequence[(mahaStartIndex + i) % sequence.length];
        final fraction = years[antarLord]! / cycleYears;
        final duration = maha.end.difference(maha.start).inMicroseconds *
            fraction;
        final antarEnd = antarCursor.add(
          Duration(microseconds: duration.round()),
        );
        antardashas.add(VimshottariPeriod(
          planet: '$antarLord',
          years: years[antarLord]!,
          start: antarCursor,
          end: antarEnd,
        ));
        antarCursor = antarEnd;
      }
      // Keep adjacent sub-periods contiguous despite microsecond rounding.
    }

    return VimshottariTimeline(
      birthNakshatra: nakshatras[nakshatraIndex].name,
      birthNakshatraLord: lord,
      balanceAtBirthYears: balanceYears,
      mahadashas: mahadashas,
      antardashas: antardashas,
    );
  }

  static DateTime _addYears(DateTime date, double years) {
    final micros = (years * daysPerYear *
        Duration.microsecondsPerDay).round();
    return date.add(Duration(microseconds: micros));
  }

  static double _normalize(double value) => (value % 360 + 360) % 360;
}
