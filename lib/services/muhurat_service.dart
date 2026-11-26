import '../models/muhurat_activity.dart';
import '../models/panchang_data.dart';
import 'panchang_service.dart';

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

/// A location-specific preliminary shortlist. It reuses the app's Panchang
/// calculation so sunrise, Tithi, Nakshatra, Choghadiya and inauspicious
/// periods come from one calculation path.
class MuhuratService {
  static const _allowedTithis = <String>{
    'Dwitiya', 'Tritiya', 'Panchami', 'Saptami',
    'Dashami', 'Ekadashi', 'Trayodashi',
  };

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
    final rule = _activityRules[activityKey];
    if (rule == null) {
      throw ArgumentError.value(activityKey, 'activityKey', 'Unknown Muhurat activity');
    }

    final results = <MuhuratCandidate>[];
    final first = DateTime(from.year, from.month, from.day);
    final last = DateTime(through.year, through.month, through.day);

    for (var date = first; !date.isAfter(last); date = date.add(const Duration(days: 1))) {
      PanchangData panchang;
      try {
        panchang = PanchangService.calculate(date: date, location: location);
      } catch (_) {
        // Polar/no-sunrise dates or invalid location data cannot be assigned
        // a reliable local Panchang day, so they are never shown as suitable.
        continue;
      }

      final weekdayIndex = _weekdayIndex(panchang.weekday);
      if (weekdayIndex == null || !rule.weekdays.contains(weekdayIndex)) continue;

      final tithiElement = panchang.element('Tithi');
      final nakshatraElement = panchang.element('Nakshatra');
      if (!_allowedTithis.contains(tithiElement.value)) continue;
      if (!rule.nakshatras.contains(nakshatraElement.value)) continue;

      final blockedPeriods = <PanchangPeriod>[
        panchang.rahuKaal,
        panchang.yamaganda,
        panchang.gulika,
      ];
      final windows = <MuhuratTimeWindow>[];

      for (final choghadiya in panchang.choghadiyaDay) {
        if (choghadiya.category != 'Favourable') continue;

        // A favourable Choghadiya is usable only while both the Tithi and
        // Nakshatra that qualified the date are still in effect.
        final start = _laterOf(
          choghadiya.start,
          _laterOf(tithiElement.start, nakshatraElement.start),
        );
        final end = _earlierOf(
          choghadiya.end,
          _earlierOf(tithiElement.end, nakshatraElement.end),
        );
        if (!end.isAfter(start)) continue;

        var available = <_TimeRange>[_TimeRange(start, end)];
        for (final blocked in blockedPeriods) {
          available = available.expand((range) => _subtract(range, blocked)).toList();
        }

        for (final range in available) {
          if (range.end.difference(range.start) < const Duration(minutes: 15)) continue;
          windows.add(MuhuratTimeWindow(
            name: choghadiya.name,
            start: range.start,
            end: range.end,
          ));
        }
      }

      if (windows.isNotEmpty) {
        windows.sort((a, b) => a.start.compareTo(b.start));
        results.add(MuhuratCandidate(
          date: panchang.date,
          weekdayIndex: weekdayIndex,
          tithi: tithiElement.value,
          nakshatra: nakshatraElement.value,
          windows: List.unmodifiable(windows),
        ));
      }

      await Future<void>.delayed(Duration.zero);
    }
    return List.unmodifiable(results);
  }

  static int? _weekdayIndex(String weekday) {
    const weekdays = [
      'Sunday', 'Monday', 'Tuesday', 'Wednesday',
      'Thursday', 'Friday', 'Saturday',
    ];
    final index = weekdays.indexOf(weekday);
    return index < 0 ? null : index;
  }

  static DateTime _laterOf(DateTime a, DateTime b) =>
      a.isAfter(b) ? a : b;

  static DateTime _earlierOf(DateTime a, DateTime b) =>
      a.isBefore(b) ? a : b;

  static List<_TimeRange> _subtract(_TimeRange source, PanchangPeriod blocked) {
    if (!source.start.isBefore(blocked.end) || !source.end.isAfter(blocked.start)) {
      return [source];
    }
    final ranges = <_TimeRange>[];
    if (blocked.start.isAfter(source.start)) {
      ranges.add(_TimeRange(source.start, _earlierOf(source.end, blocked.start)));
    }
    if (blocked.end.isBefore(source.end)) {
      ranges.add(_TimeRange(_laterOf(source.start, blocked.end), source.end));
    }
    return ranges.where((range) => range.end.isAfter(range.start)).toList();
  }
}

class _ActivityRule {
  const _ActivityRule({required this.weekdays, required this.nakshatras});
  final Set<int> weekdays;
  final Set<String> nakshatras;
}

class _TimeRange {
  const _TimeRange(this.start, this.end);
  final DateTime start;
  final DateTime end;
}
