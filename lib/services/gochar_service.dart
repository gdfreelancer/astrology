import 'dart:math' as math;
import 'package:geoengine/geoengine.dart' as astronomy;
import '../models/kundali/kundali_graha.dart';
import 'astrology/ayanamsha_service.dart';

class TransitPosition {
  const TransitPosition({required this.name, required this.symbol, required this.longitude, required this.signIndex, required this.isRetrograde});
  final String name, symbol;
  final double longitude;
  final int signIndex;
  final bool isRetrograde;
  double get degreeInSign => longitude % 30;
}

class DetectedYoga {
  const DetectedYoga({required this.key, required this.descriptionKey, required this.planetNames});
  final String key, descriptionKey;
  final List<String> planetNames;
}

class SadeSatiStatus {
  const SadeSatiStatus({required this.isActive, required this.phase, required this.saturnSignIndex, required this.moonSignIndex});
  final bool isActive;
  /// 0 = rising (12th), 1 = peak (same sign), 2 = setting (2nd).
  final int? phase;
  final int saturnSignIndex, moonSignIndex;
}

class GocharReport {
  const GocharReport({required this.date, required this.transits, required this.sadeSati, required this.yogas});
  final DateTime date;
  final List<TransitPosition> transits;
  final SadeSatiStatus sadeSati;
  final List<DetectedYoga> yogas;
}

class GocharService {
  GocharService._();
  static double _norm(double value) => (value % 360 + 360) % 360;

  static List<TransitPosition> positionsAt(DateTime date) {
    final utc = date.toUtc();
    double planet(astronomy.Body body) {
      final vector = astronomy.geoVector(body, utc, true);
      final tropical = astronomy.ecliptic(vector).eLon;
      return _norm(tropical - AyanamshaService.lahiri(utc));
    }
    double moon() {
      return _norm(astronomy.eclipticGeoMoon(utc).lon - AyanamshaService.lahiri(utc));
    }
    double rahu() {
      final j2000 = DateTime.utc(2000, 1, 1, 12);
      final t = utc.difference(j2000).inMicroseconds / Duration.microsecondsPerDay / 36525.0;
      final tropical = _norm(125.04452 - 1934.136261*t + 0.0020708*t*t + t*t*t/450000);
      return _norm(tropical - AyanamshaService.lahiri(utc));
    }
    final definitions = <(String,String,double)>[
      ('Sun','Su', _norm(astronomy.sunPosition(utc).eLon - AyanamshaService.lahiri(utc))),
      ('Moon','Mo',moon()), ('Mars','Ma',planet(astronomy.Body.Mars)),
      ('Mercury','Me',planet(astronomy.Body.Mercury)), ('Jupiter','Ju',planet(astronomy.Body.Jupiter)),
      ('Venus','Ve',planet(astronomy.Body.Venus)), ('Saturn','Sa',planet(astronomy.Body.Saturn)),
      ('Rahu','Ra',rahu()), ('Ketu','Ke',_norm(rahu()+180)),
    ];
    return definitions.map((item) {
      final beforeDate = utc.subtract(const Duration(hours: 12));
      final afterDate = utc.add(const Duration(hours: 12));
      double at(DateTime d) {
        if (item.$1 == 'Moon') return _norm(astronomy.eclipticGeoMoon(d).lon - AyanamshaService.lahiri(d));
        if (item.$1 == 'Sun') return _norm(astronomy.sunPosition(d).eLon - AyanamshaService.lahiri(d));
        if (item.$1 == 'Rahu') {
          final t = d.difference(DateTime.utc(2000,1,1,12)).inMicroseconds / Duration.microsecondsPerDay / 36525.0;
          return _norm(125.04452 - 1934.136261*t + .0020708*t*t + t*t*t/450000 - AyanamshaService.lahiri(d));
        }
        if (item.$1 == 'Ketu') return _norm(atRahu(d)+180);
        final body = switch(item.$1) {
          'Mars' => astronomy.Body.Mars, 'Mercury' => astronomy.Body.Mercury,
          'Jupiter' => astronomy.Body.Jupiter, 'Venus' => astronomy.Body.Venus,
          _ => astronomy.Body.Saturn,
        };
        return _norm(astronomy.ecliptic(astronomy.geoVector(body,d,true)).eLon - AyanamshaService.lahiri(d));
      }
      double atRahu(DateTime d) {
        final t = d.difference(DateTime.utc(2000,1,1,12)).inMicroseconds / Duration.microsecondsPerDay / 36525.0;
        return _norm(125.04452 - 1934.136261*t + .0020708*t*t + t*t*t/450000 - AyanamshaService.lahiri(d));
      }
      final delta = _norm(at(afterDate)-at(beforeDate));
      final signed = delta > 180 ? delta-360 : delta;
      return TransitPosition(name:item.$1,symbol:item.$2,longitude:item.$3,signIndex:(item.$3/30).floor(),isRetrograde:signed<0);
    }).toList(growable:false);
  }

  static SadeSatiStatus sadeSati({required int natalMoonSignIndex, required int transitSaturnSignIndex}) {
    final distance = (transitSaturnSignIndex - natalMoonSignIndex + 12) % 12;
    final phase = distance == 11 ? 0 : distance == 0 ? 1 : distance == 1 ? 2 : null;
    return SadeSatiStatus(isActive:phase != null,phase:phase,saturnSignIndex:transitSaturnSignIndex,moonSignIndex:natalMoonSignIndex);
  }

  static List<DetectedYoga> detectYogas(KundaliChart chart) {
    final sun = _findGraha(chart,'Sun');
    final moon = _findGraha(chart,'Moon');
    final mars = _findGraha(chart,'Mars');
    final mercury = _findGraha(chart,'Mercury');
    final jupiter = _findGraha(chart,'Jupiter');
    final results=<DetectedYoga>[];
    if (moon!=null && jupiter!=null && _isKendra((jupiter.signIndex-moon.signIndex+12)%12)) {
      results.add(const DetectedYoga(key:'gajakesari',descriptionKey:'yoga_gajakesari_desc',planetNames:['Moon','Jupiter']));
    }
    if (sun!=null && mercury!=null && sun.signIndex==mercury.signIndex) {
      results.add(const DetectedYoga(key:'budhaditya',descriptionKey:'yoga_budhaditya_desc',planetNames:['Sun','Mercury']));
    }
    if (moon!=null && mars!=null && moon.signIndex==mars.signIndex) {
      results.add(const DetectedYoga(key:'chandra_mangal',descriptionKey:'yoga_chandra_mangal_desc',planetNames:['Moon','Mars']));
    }
    for (final pair in <(KundaliGraha?,String)>[(mars,'ruchaka'),(mercury,'bhadra'),(jupiter,'hamsa'),(venus(chart),'malavya'),(_findGraha(chart,'Saturn'),'shasha')]) {
      final g=pair.$1;
      if(g!=null && _isKendra(g.houseNumber-1) && _isOwnOrExalted(g.name,g.signIndex)) {
        results.add(DetectedYoga(key:'pancha_mahapurusha_${pair.$2}',descriptionKey:'yoga_pancha_desc',planetNames:[g.name]));
      }
    }
    return results;
  }
  static KundaliGraha? _findGraha(KundaliChart chart,String name) { for(final graha in chart.grahas){if(graha.name==name)return graha;} return null; }
  static bool _isKendra(int offset)=>offset==0||offset==3||offset==6||offset==9;
  static bool _isOwnOrExalted(String name,int sign)=>switch(name){
    'Mars'=>sign==0||sign==7, 'Mercury'=>sign==2||sign==5,
    'Jupiter'=>sign==8||sign==11||sign==3, 'Venus'=>sign==1||sign==6||sign==11,
    'Saturn'=>sign==9||sign==10||sign==6, _=>false,
  };

  static GocharReport calculate({required KundaliChart natalChart,required DateTime date}) {
    final transits=positionsAt(date);
    final moon=natalChart.grahas.firstWhere((g)=>g.name=='Moon');
    final saturn=transits.firstWhere((g)=>g.name=='Saturn');
    return GocharReport(date:date,transits:transits,sadeSati:sadeSati(natalMoonSignIndex:moon.signIndex,transitSaturnSignIndex:saturn.signIndex),yogas:detectYogas(natalChart));
  }
}
