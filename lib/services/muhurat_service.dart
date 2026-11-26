import 'package:geoengine/geoengine.dart' as astro;
import 'package:timezone/timezone.dart' as tz;

import '../data/nakshatra_data.dart';
import '../models/panchang_data.dart';
import 'astrology/ayanamsha_service.dart';
import '../utils/astrology_math.dart';

class MuhuratTimeWindow {
  const MuhuratTimeWindow({
    required this.name,
    required this.start,
    required this.end,
  });

  final String name;
  final DateTime start;
  final DateTime end;
}

class MuhuratCandidate {
  const MuhuratCandidate({
    required this.date,
    required this.weekdayIndex,
    required this.tithi,
    required this.nakshatra,
    required this.windows,
  });

  final DateTime date;
  /// Sunday = 0, Monday = 1, ... Saturday = 6.
  final int weekdayIndex;
  final String tithi;
  final String nakshatra;
  final List<MuhuratTimeWindow> windows;
}

/// Produces a preliminary, location-specific date shortlist. This is not a
/// substitute for a complete ceremony Muhurat with Lagna, Tara Bala,
/// Chandra Bala, family horoscope and regional rules.
class MuhuratService {
  static const _tithis = <String>[
    'Pratipada', 'Dwitiya', 'Tritiya', 'Chaturthi', 'Panchami',
    'Shashthi', 'Saptami', 'Ashtami', 'Navami', 'Dashami',
    'Ekadashi', 'Dwadashi', 'Trayodashi', 'Chaturdashi', 'Purnima',
    'Pratipada', 'Dwitiya', 'Tritiya', 'Chaturthi', 'Panchami',
    'Shashthi', 'Saptami', 'Ashtami', 'Navami', 'Dashami',
    'Ekadashi', 'Dwadashi', 'Trayodashi', 'Chaturdashi', 'Amavasya',
  ];

  static const _dayChoghadiya = <List<String>>[
    ['Udveg', 'Char', 'Labh', 'Amrit', 'Kaal', 'Shubh', 'Rog', 'Udveg'],
    ['Amrit', 'Kaal', 'Shubh', 'Rog', 'Udveg', 'Char', 'Labh', 'Amrit'],
    ['Rog', 'Udveg', 'Char', 'Labh', 'Amrit', 'Kaal', 'Shubh', 'Rog'],
    ['Labh', 'Amrit', 'Kaal', 'Shubh', 'Rog', 'Udveg', 'Char', 'Labh'],
    ['Shubh', 'Rog', 'Udveg', 'Char', 'Labh', 'Amrit', 'Kaal', 'Shubh'],
    ['Char', 'Labh', 'Amrit', 'Kaal', 'Shubh', 'Rog', 'Udveg', 'Char'],
    ['Kaal', 'Shubh', 'Rog', 'Udveg', 'Char', 'Labh', 'Amrit', 'Kaal'],
  ];

  static const _allowedTithis = <int>{1, 2, 4, 6, 9, 10, 12};

  static const _activityRules = <String, _ActivityRule>{
    'activity_marriage': _ActivityRule(
      weekdays: {1, 3, 4, 5},
      nakshatras: {'Rohini', 'Mrigashira', 'Uttara Phalguni', 'Hasta', 'Swati', 'Anuradha', 'Uttara Ashadha', 'Uttara Bhadrapada', 'Revati'},
    ),
    'activity_griha_pravesh': _ActivityRule(
      weekdays: {1, 3, 4, 5},
      nakshatras: {'Rohini', 'Mrigashira', 'Uttara Phalguni', 'Chitra', 'Anuradha', 'Revati'},
    ),
    'activity_vehicle': _ActivityRule(
      weekdays: {1, 3, 4, 5},
      nakshatras: {'Ashwini', 'Rohini', 'Mrigashira', 'Pushya', 'Hasta', 'Chitra', 'Swati', 'Anuradha', 'Revati'},
    ),
    'activity_business': _ActivityRule(
      weekdays: {1, 3, 4},
      nakshatras: {'Ashwini', 'Rohini', 'Mrigashira', 'Pushya', 'Hasta', 'Chitra', 'Swati', 'Anuradha', 'Revati'},
    ),
    'activity_naming': _ActivityRule(
      weekdays: {1, 3, 4, 5},
      nakshatras: {'Ashwini', 'Rohini', 'Mrigashira', 'Punarvasu', 'Pushya', 'Hasta', 'Swati', 'Anuradha', 'Uttara Phalguni', 'Revati'},
    ),
    'activity_property': _ActivityRule(
      weekdays: {1, 3, 4, 5},
      nakshatras: {'Rohini', 'Mrigashira', 'Uttara Phalguni', 'Anuradha', 'Revati'},
    ),
    'activity_journey': _ActivityRule(
      weekdays: {1, 3, 4, 5},
      nakshatras: {'Ashwini', 'Mrigashira', 'Punarvasu', 'Pushya', 'Hasta', 'Anuradha', 'Revati'},
    ),
    'activity_learning': _ActivityRule(
      weekdays: {3, 4, 5},
      nakshatras: {'Ashwini', 'Rohini', 'Mrigashira', 'Punarvasu', 'Pushya', 'Hasta', 'Chitra', 'Swati', 'Revati'},
    ),
  };

  static Future<List<MuhuratCandidate>> findDates({
    required DateTime from,
    required DateTime through,
    required PanchangLocation location,
    required String activityKey,
  }) async {
    final rule = _activityRules[activityKey] ?? _activityRules['activity_business']!;
    final zone = tz.getLocation(location.timeZoneId);
    final observer = astro.Observer(location.latitude, location.longitude, 0);
    final results = <MuhuratCandidate>[];
    final start = DateTime(from.year, from.month, from.day);
    final end = DateTime(through.year, through.month, through.day);

    for (var date = start; !date.isAfter(end); date = date.add(const Duration(days: 1))) {
      final localMidnight = tz.TZDateTime(zone, date.year, date.month, date.day);
      final rise = astro.searchRiseSet(
        astro.Body.Sun, observer, 1, localMidnight.toUtc(), 1.0,
      );
      if (rise == null) continue;
      final sunrise = rise.date;
      final set = astro.searchRiseSet(
        astro.Body.Sun, observer, -1,
        sunrise.add(const Duration(seconds: 1)), 1.0,
      );
      if (set == null) continue;
      final sunset = set.date;
      final weekday = tz.TZDateTime.from(sunrise, zone).weekday % 7;
      if (!rule.weekdays.contains(weekday)) continue;

      final phase = _phase(sunrise);
      final tithiIndex = (phase / 12).floor().clamp(0, 29);
      final tithiInPaksha = tithiIndex % 15;
      if (!_allowedTithis.contains(tithiInPaksha)) continue;

      final nakshatraIndex = (_moon(sunrise) / (360 / 27)).floor().clamp(0, 26);
      final nakshatra = nakshatras[nakshatraIndex].name;
      if (!rule.nakshatras.contains(nakshatra)) continue;

      final daylight = sunset.difference(sunrise);
      final rahu = _dayPeriod(sunrise, daylight, const [8, 2, 7, 5, 6, 4, 3][weekday]);
      final yama = _dayPeriod(sunrise, daylight, const [5, 4, 3, 2, 1, 7, 6][weekday]);
      final gulika = _dayPeriod(sunrise, daylight, const [7, 6, 5, 4, 3, 2, 1][weekday]);
      final excluded = [rahu, yama, gulika];
      final segmentLength = daylight.inMicroseconds / 8;
      final windows = <MuhuratTimeWindow>[];

      for (var i = 0; i < 8; i++) {
        final name = _dayChoghadiya[weekday][i];
        if (!const {'Amrit', 'Shubh', 'Labh', 'Char'}.contains(name)) continue;
        final windowStart = sunrise.add(Duration(
          microseconds: (segmentLength * i).round(),
        ));
        final windowEnd = sunrise.add(Duration(
          microseconds: (segmentLength * (i + 1)).round(),
        ));
        final blocked = excluded.any((period) =>
            windowStart.isBefore(period.end) && windowEnd.isAfter(period.start));
        if (!blocked) {
          windows.add(MuhuratTimeWindow(
            name: name, start: windowStart, end: windowEnd,
          ));
        }
      }

      if (windows.isNotEmpty) {
        results.add(MuhuratCandidate(
          date: date,
          weekdayIndex: weekday,
          tithi: _tithis[tithiIndex],
          nakshatra: nakshatra,
          windows: windows,
        ));
      }

      // Yield periodically so the annual scan does not freeze the screen.
      if (date.day % 5 == 0) {
        await Future<void>.delayed(Duration.zero);
      }
    }
    return results;
  }

  static PanchangPeriod _dayPeriod(DateTime start, Duration duration, int segment) {
    final segmentLength = duration.inMicroseconds / 8;
    final from = start.add(Duration(
      microseconds: (segmentLength * (segment - 1)).round(),
    ));
    return PanchangPeriod(
      name: '',
      start: from,
      end: from.add(Duration(microseconds: segmentLength.round())),
    );
  }

  static double _phase(DateTime date) =>
      AstrologyMath.angularSeparation(_sun(date), _moon(date));

  static double _moon(DateTime date) => AstrologyMath.toSiderealLongitude(
    tropicalLongitude: astro.eclipticGeoMoon(date).lon,
    ayanamsha: AyanamshaService.lahiri(date),
  );

  static double _sun(DateTime date) => AstrologyMath.toSiderealLongitude(
    tropicalLongitude: astro.sunPosition(date).eLon,
    ayanamsha: AyanamshaService.lahiri(date),
  );
}

class _ActivityRule {
  const _ActivityRule({required this.weekdays, required this.nakshatras});
  final Set<int> weekdays;
  final Set<String> nakshatras;
}
