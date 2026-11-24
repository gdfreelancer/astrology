import 'dart:math' as math;

import 'package:geoengine/geoengine.dart' as astronomy;
import 'package:timezone/timezone.dart' as tz;

import '../data/nakshatra_data.dart';
import '../models/birth_chart_result.dart';

class BirthChartService {
  static BirthChartResult calculate({
    required DateTime birthDate,
    required int hour,
    required int minute,
    required String timeZoneId,
    required String placeName,
    required double latitude,
    required double longitude,
    required String gender,
  }) {
    final location = tz.getLocation(timeZoneId);
    final localBirth = tz.TZDateTime(
      location,
      birthDate.year,
      birthDate.month,
      birthDate.day,
      hour,
      minute,
    );
    final utcBirth = localBirth.toUtc();

    // GeoEngine returns the geocentric Moon in the true ecliptic of date.
    final moon = astronomy.eclipticGeoMoon(utcBirth);
    final tropicalLongitude = _normalize(moon.lon);
    final ayanamsa = _lahiriAyanamsa(utcBirth);
    final siderealLongitude = _normalize(tropicalLongitude - ayanamsa);

    const nakshatraSpan = 360.0 / 27.0;
    const padaSpan = nakshatraSpan / 4.0;
    final nakshatraIndex = (siderealLongitude / nakshatraSpan).floor();
    final withinNakshatra = siderealLongitude - nakshatraIndex * nakshatraSpan;
    final pada = (withinNakshatra / padaSpan).floor() + 1;
    final rashiIndex = (siderealLongitude / 30.0).floor().clamp(0, 11);

    final boundaryDistance = math.min(
      withinNakshatra % padaSpan,
      padaSpan - (withinNakshatra % padaSpan),
    );

    return BirthChartResult(
      birthLocal: localBirth,
      birthUtc: utcBirth,
      placeName: placeName,
      latitude: latitude,
      longitude: longitude,
      timeZoneId: timeZoneId,
      gender: gender,
      tropicalMoonLongitude: tropicalLongitude,
      ayanamsa: ayanamsa,
      siderealMoonLongitude: siderealLongitude,
      moonLatitude: moon.lat,
      moonDistanceAu: moon.dist,
      rashi: rashiNames[rashiIndex],
      rashiSymbol: rashiSymbols[rashiIndex],
      nakshatra: nakshatras[nakshatraIndex].name,
      pada: pada,
      namingSyllable: nakshatras[nakshatraIndex].syllables[pada - 1],
      nakshatraProgress: withinNakshatra / nakshatraSpan,
      nearBoundary: boundaryDistance < 0.03,
    );
  }

  // Lahiri/Chitrapaksha mean ayanamsha polynomial, anchored at J2000.0.
  // The Moon model itself is from GeoEngine (Astronomy Engine).
  static double _lahiriAyanamsa(DateTime utc) {
    final j2000 = DateTime.utc(2000, 1, 1, 12);
    final centuries = utc.difference(j2000).inMicroseconds /
        Duration.microsecondsPerDay /
        36525.0;
    final arcSeconds =
        (23 * 3600 + 51 * 60 + 25.532) +
        5029.0966 * centuries +
        1.11161 * centuries * centuries;
    return arcSeconds / 3600.0;
  }

  static double _normalize(double value) => (value % 360 + 360) % 360;
}
