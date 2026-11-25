import 'dart:math' as math;

import 'package:geoengine/geoengine.dart' as astronomy;
import 'package:timezone/timezone.dart' as tz;

import '../data/nakshatra_data.dart';
import '../models/birth_chart_result.dart';
import '../models/kundali/kundali_graha.dart';
import 'astrology/ayanamsha_service.dart';

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
    final ayanamsa = AyanamshaService.lahiri(utcBirth);
    final siderealLongitude = _normalize(tropicalLongitude - ayanamsa);

    const nakshatraSpan = 360.0 / 27.0;
    const padaSpan = nakshatraSpan / 4.0;
    final nakshatraIndex = (siderealLongitude / nakshatraSpan).floor();
    final withinNakshatra = siderealLongitude - nakshatraIndex * nakshatraSpan;
    final pada = (withinNakshatra / padaSpan).floor() + 1;
    final rashiIndex = (siderealLongitude / 30.0).floor().clamp(0, 11).toInt();

    final kundaliChart = _calculateKundaliChart(utcBirth, latitude, longitude, ayanamsa);

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
      kundaliChart: kundaliChart,
    );
  }


  static KundaliChart _calculateKundaliChart(
    DateTime utcBirth,
    double latitude,
    double longitude,
    double ayanamsa,
  ) {
    final obliquity = astronomy.eTilt(astronomy.AstroTime(utcBirth)).tobl;
    final localSiderealDegrees =
        ((astronomy.siderealTime(utcBirth) * 15.0 + longitude) % 360 + 360) % 360;
    final theta = localSiderealDegrees * math.pi / 180;
    final phi = latitude * math.pi / 180;
    final epsilon = obliquity * math.pi / 180;

    final ascTropical = _normalize(
      (math.atan2(
        -math.cos(theta),
        math.sin(epsilon) * math.tan(phi) +
            math.cos(epsilon) * math.sin(theta),
      ) * 180 / math.pi) + 180,
    );
    final ascendant = _normalize(ascTropical - ayanamsa);
    final ascSign = (ascendant / 30).floor().clamp(0, 11).toInt();

    double siderealPlanet(astronomy.Body body) {
      final apparent = astronomy.ecliptic(astronomy.geoVector(body, utcBirth, true));
      return _normalize(apparent.eLon - ayanamsa);
    }

    final positions = <({String name, String symbol, double longitude})>[
      (name: 'Sun', symbol: 'Su', longitude: _normalize(astronomy.sunPosition(utcBirth).eLon - ayanamsa)),
      (name: 'Moon', symbol: 'Mo', longitude: _normalize(astronomy.eclipticGeoMoon(utcBirth).lon - ayanamsa)),
      (name: 'Mars', symbol: 'Ma', longitude: siderealPlanet(astronomy.Body.Mars)),
      (name: 'Mercury', symbol: 'Me', longitude: siderealPlanet(astronomy.Body.Mercury)),
      (name: 'Jupiter', symbol: 'Ju', longitude: siderealPlanet(astronomy.Body.Jupiter)),
      (name: 'Venus', symbol: 'Ve', longitude: siderealPlanet(astronomy.Body.Venus)),
      (name: 'Saturn', symbol: 'Sa', longitude: siderealPlanet(astronomy.Body.Saturn)),
    ];

    final j2000 = DateTime.utc(2000, 1, 1, 12);
    final centuries = utcBirth.difference(j2000).inMicroseconds /
        Duration.microsecondsPerDay / 36525.0;
    final rahuTropical = _normalize(
      125.04452 - 1934.136261 * centuries +
          0.0020708 * centuries * centuries +
          centuries * centuries * centuries / 450000,
    );
    final rahu = _normalize(rahuTropical - ayanamsa);
    positions
      ..add((name: 'Rahu', symbol: 'Ra', longitude: rahu))
      ..add((name: 'Ketu', symbol: 'Ke', longitude: _normalize(rahu + 180)));

    final grahas = positions.map((position) {
      final sign = (position.longitude / 30).floor().clamp(0, 11).toInt();
      final house = ((sign - ascSign + 12) % 12) + 1;
      return KundaliGraha(
        name: position.name,
        symbol: position.symbol,
        longitude: position.longitude,
        signIndex: sign,
        houseNumber: house,
      );
    }).toList();

    return KundaliChart(
      ascendantLongitude: ascendant,
      ascendantSignIndex: ascSign,
      grahas: grahas,
    );
  }

  static double _normalize(double value) => (value % 360 + 360) % 360;
}
