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
      location, birthDate.year, birthDate.month, birthDate.day, hour, minute,
    );
    final utcBirth = localBirth.toUtc();

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
    final kundaliChart = _calculateKundaliChart(
      utcBirth, latitude, longitude, ayanamsa,
    );
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
    final localSiderealDegrees = _normalize(
      astronomy.siderealTime(utcBirth) * 15.0 + longitude,
    );
    final theta = localSiderealDegrees * math.pi / 180;
    final phi = latitude * math.pi / 180;
    final epsilon = obliquity * math.pi / 180;

    final ascTropical = _normalize(
      math.atan2(
        -math.cos(theta),
        math.sin(epsilon) * math.tan(phi) +
            math.cos(epsilon) * math.sin(theta),
      ) * 180 / math.pi + 180,
    );
    final mcTropical = _normalize(
      math.atan2(math.sin(theta), math.cos(theta) * math.cos(epsilon)) *
          180 / math.pi,
    );
    final ascendant = _normalize(ascTropical - ayanamsa);
    final midheaven = _normalize(mcTropical - ayanamsa);
    final ascSign = (ascendant / 30).floor().clamp(0, 11).toInt();
    final bhavas = _calculateBhavas(ascendant, midheaven);

    double siderealPlanet(astronomy.Body body, DateTime at) {
      final apparent = astronomy.ecliptic(
        astronomy.geoVector(body, at, true),
      );
      return _normalize(apparent.eLon - AyanamshaService.lahiri(at));
    }

    double dailyMotion(astronomy.Body body) {
      final before = siderealPlanet(body, utcBirth.subtract(const Duration(hours: 12)));
      final after = siderealPlanet(body, utcBirth.add(const Duration(hours: 12)));
      final delta = _normalize(after - before);
      return delta > 180 ? delta - 360 : delta;
    }

    final positions = <({
      String name,
      String symbol,
      double longitude,
      double motion,
      bool retrograde,
    })>[];

    void addPlanet(String name, String symbol, astronomy.Body body) {
      final position = siderealPlanet(body, utcBirth);
      final motion = dailyMotion(body);
      positions.add((
        name: name,
        symbol: symbol,
        longitude: position,
        motion: motion,
        retrograde: motion < 0,
      ));
    }

    final sunNow = _normalize(astronomy.sunPosition(utcBirth).eLon - ayanamsa);
    final sunBefore = _normalize(astronomy.sunPosition(
      utcBirth.subtract(const Duration(hours: 12)),
    ).eLon - AyanamshaService.lahiri(utcBirth.subtract(const Duration(hours: 12))));
    final sunAfter = _normalize(astronomy.sunPosition(
      utcBirth.add(const Duration(hours: 12)),
    ).eLon - AyanamshaService.lahiri(utcBirth.add(const Duration(hours: 12))));
    final sunDelta = _normalize(sunAfter - sunBefore);
    final sunMotion = sunDelta > 180 ? sunDelta - 360 : sunDelta;
    positions.add((
      name: 'Sun', symbol: 'Su', longitude: sunNow,
      motion: sunMotion, retrograde: false,
    ));
    // GeoEngine's geocentric Moon routine is used consistently for Janma Rashi.
    final moonLongitude = _normalize(astronomy.eclipticGeoMoon(utcBirth).lon - ayanamsa);
    final moonBeforeDate = utcBirth.subtract(const Duration(hours: 12));
    final moonAfterDate = utcBirth.add(const Duration(hours: 12));
    final moonBefore = _normalize(
      astronomy.eclipticGeoMoon(moonBeforeDate).lon - AyanamshaService.lahiri(moonBeforeDate),
    );
    final moonAfter = _normalize(
      astronomy.eclipticGeoMoon(moonAfterDate).lon - AyanamshaService.lahiri(moonAfterDate),
    );
    final moonDelta = _normalize(moonAfter - moonBefore);
    final moonMotion = moonDelta > 180 ? moonDelta - 360 : moonDelta;
    positions.add((
      name: 'Moon', symbol: 'Mo', longitude: moonLongitude,
      motion: moonMotion, retrograde: false,
    ));
    addPlanet('Mars', 'Ma', astronomy.Body.Mars);
    addPlanet('Mercury', 'Me', astronomy.Body.Mercury);
    addPlanet('Jupiter', 'Ju', astronomy.Body.Jupiter);
    addPlanet('Venus', 'Ve', astronomy.Body.Venus);
    addPlanet('Saturn', 'Sa', astronomy.Body.Saturn);

    // Mean lunar node (Rahu) and its opposite point (Ketu).
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
      ..add((
        name: 'Rahu', symbol: 'Ra', longitude: rahu,
        motion: -0.05295, retrograde: true,
      ))
      ..add((
        name: 'Ketu', symbol: 'Ke', longitude: _normalize(rahu + 180),
        motion: -0.05295, retrograde: true,
      ));

    final grahas = positions.map((position) {
      final sign = (position.longitude / 30).floor().clamp(0, 11).toInt();
      final wholeSignHouse = ((sign - ascSign + 12) % 12) + 1;
      final bhavaNumber = _findBhava(position.longitude, bhavas);
      return KundaliGraha(
        name: position.name,
        symbol: position.symbol,
        longitude: position.longitude,
        signIndex: sign,
        houseNumber: wholeSignHouse,
        bhavaNumber: bhavaNumber,
        isRetrograde: position.retrograde,
        dailyMotion: position.motion,
      );
    }).toList();

    return KundaliChart(
      ascendantLongitude: ascendant,
      ascendantSignIndex: ascSign,
      midheavenLongitude: midheaven,
      bhavas: bhavas,
      grahas: grahas,
    );
  }

  /// Sripati-style Bhava Madhya: each quadrant (MC→Asc, Asc→IC, etc.)
  /// is divided into three equal house-centre intervals. Sandhi boundaries
  /// are the midpoints between adjacent Bhava Madhyas, as in the PDF method.
  static List<BhavaHouse> calculateBhavaHouses({
    required double ascendantLongitude,
    required double midheavenLongitude,
  }) => _calculateBhavas(ascendantLongitude, midheavenLongitude);

  static int houseForLongitude(double longitude, List<BhavaHouse> houses) =>
      _findBhava(longitude, houses);

  static List<BhavaHouse> _calculateBhavas(double ascendant, double mc) {
    final ic = _normalize(mc + 180);
    final descendant = _normalize(ascendant + 180);
    final mids = List<double>.filled(12, 0);
    mids[0] = ascendant;
    mids[1] = _along(ascendant, ic, 1 / 3);
    mids[2] = _along(ascendant, ic, 2 / 3);
    mids[3] = ic;
    mids[4] = _along(ic, descendant, 1 / 3);
    mids[5] = _along(ic, descendant, 2 / 3);
    mids[6] = descendant;
    mids[7] = _along(descendant, mc, 1 / 3);
    mids[8] = _along(descendant, mc, 2 / 3);
    mids[9] = mc;
    mids[10] = _along(mc, ascendant, 1 / 3);
    mids[11] = _along(mc, ascendant, 2 / 3);

    return List<BhavaHouse>.generate(12, (index) {
      final previous = mids[(index + 11) % 12];
      final current = mids[index];
      final next = mids[(index + 1) % 12];
      return BhavaHouse(
        number: index + 1,
        startLongitude: _along(previous, current, .5),
        middleLongitude: current,
        endLongitude: _along(current, next, .5),
      );
    }, growable: false);
  }

  static int _findBhava(double longitude, List<BhavaHouse> houses) {
    for (final house in houses) {
      final offset = _normalize(longitude - house.startLongitude);
      if (offset < house.width || (offset - house.width).abs() < 1e-8) {
        return house.number;
      }
    }
    return 1;
  }

  static double _along(double from, double to, double fraction) =>
      _normalize(from + _normalize(to - from) * fraction);

  static double _normalize(double value) => (value % 360 + 360) % 360;
}
