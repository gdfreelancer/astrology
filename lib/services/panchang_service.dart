import 'dart:math' as math;
import 'package:geoengine/geoengine.dart' as astro;
import 'package:timezone/timezone.dart' as tz;
import '../data/nakshatra_data.dart';
import '../l10n/app_locale.dart';
import '../models/panchang_data.dart';
import '../services/astrology/ayanamsha_service.dart';
import '../utils/astrology_math.dart';

class PanchangService {
  static const tithis=['Pratipada','Dwitiya','Tritiya','Chaturthi','Panchami','Shashthi','Saptami','Ashtami','Navami','Dashami','Ekadashi','Dwadashi','Trayodashi','Chaturdashi','Purnima'];
  static const yogas=['Vishkambha','Priti','Ayushman','Saubhagya','Shobhana','Atiganda','Sukarma','Dhriti','Shoola','Ganda','Vriddhi','Dhruva','Vyaghata','Harshana','Vajra','Siddhi','Vyatipata','Variyana','Parigha','Shiva','Siddha','Sadhya','Shubha','Shukla','Brahma','Indra','Vaidhriti'];
  static const weekdays=['Sunday','Monday','Tuesday','Wednesday','Thursday','Friday','Saturday'];
  static const rashis=['Mesha','Vrishabha','Mithuna','Karka','Simha','Kanya','Tula','Vrishchika','Dhanu','Makara','Kumbha','Meena'];
  static const ritus=['Vasanta','Vasanta','Grishma','Grishma','Varsha','Varsha','Sharad','Sharad','Hemanta','Hemanta','Shishira','Shishira'];
  static const dayChoghadiya=[
    ['Udveg','Char','Labh','Amrit','Kaal','Shubh','Rog','Udveg'],
    ['Amrit','Kaal','Shubh','Rog','Udveg','Char','Labh','Amrit'],
    ['Rog','Udveg','Char','Labh','Amrit','Kaal','Shubh','Rog'],
    ['Labh','Amrit','Kaal','Shubh','Rog','Udveg','Char','Labh'],
    ['Shubh','Rog','Udveg','Char','Labh','Amrit','Kaal','Shubh'],
    ['Char','Labh','Amrit','Kaal','Shubh','Rog','Udveg','Char'],
    ['Kaal','Shubh','Rog','Udveg','Char','Labh','Amrit','Kaal'],
  ];
  static const nightChoghadiya=[
    ['Shubh','Amrit','Char','Rog','Kaal','Labh','Udveg','Shubh'],
    ['Char','Rog','Kaal','Labh','Udveg','Shubh','Amrit','Char'],
    ['Kaal','Labh','Udveg','Shubh','Amrit','Char','Rog','Kaal'],
    ['Udveg','Shubh','Amrit','Char','Rog','Kaal','Labh','Udveg'],
    ['Labh','Udveg','Shubh','Amrit','Char','Rog','Kaal','Labh'],
    ['Rog','Kaal','Labh','Udveg','Shubh','Amrit','Char','Rog'],
    ['Amrit','Char','Rog','Kaal','Labh','Udveg','Shubh','Amrit'],
  ];

  static PanchangData calculate({required DateTime date,required PanchangLocation location}) {
    final zone=tz.getLocation(location.timeZoneId);
    final local=tz.TZDateTime(zone,date.year,date.month,date.day);
    final observer=astro.Observer(location.latitude,location.longitude,0);
    final rise=astro.searchRiseSet(astro.Body.Sun,observer,1,local.toUtc(),1.0);
    if(rise==null) throw StateError(AppLocale.text('p_sunrise_unavailable'));
    final sunrise=rise.date;
    final set=astro.searchRiseSet(astro.Body.Sun,observer,-1,sunrise.add(const Duration(seconds:1)),1.0);
    if(set==null) throw StateError(AppLocale.text('p_sunset_unavailable'));
    final sunset=set.date;
    final nextRise=astro.searchRiseSet(astro.Body.Sun,observer,1,sunset.add(const Duration(seconds:1)),1.5)?.date??sunset.add(const Duration(hours:12));
    final moonrise=astro.searchRiseSet(astro.Body.Moon,observer,1,local.toUtc(),1.0)?.date;
    final moonset=astro.searchRiseSet(astro.Body.Moon,observer,-1,local.toUtc(),1.0)?.date;
    final wd=tz.TZDateTime.from(sunrise,zone).weekday%7;
    final phase=_phase(sunrise);
    final ti=AstrologyMath.tithiIndex(_sun(sunrise),_moon(sunrise));
    final ni=AstrologyMath.nakshatraIndex(_moon(sunrise));
    final yi=AstrologyMath.yogaIndex(_sun(sunrise),_moon(sunrise));
    final ki=(phase/6).floor().clamp(0,59);
    final sign=(_sun(sunrise)/30).floor().clamp(0,11);
    final pada=AstrologyMath.padaNumber(_moon(sunrise));
    final paksha=ti<15?'Shukla Paksha':'Krishna Paksha';
    final lunarDay=(ti%15)+1;
    final yogaNumber=yi+1;
    final elements=<PanchangElement>[
      _element('Tithi',_tithi(ti),sunrise,_phase,12,paksha+' · Lunar day '+lunarDay.toString(),'Angular separation of the Sun and Moon; each tithi spans 12 degrees.'),
      PanchangElement(name:'Vara',value:weekdays[wd],start:sunrise,end:sunset,description:'Weekday at local sunrise',detail:'The Panchang weekday is determined by local sunrise.'),
      _element('Nakshatra',nakshatras[ni].name,sunrise,_moon,360/27,'Pada '+pada.toString()+' · Lunar mansion','The 27 Nakshatras divide the sidereal zodiac into equal segments of 13°20′.'),
      _element('Yoga',yogas[yi],sunrise,(d)=>(_sun(d)+_moon(d))%360,360/27,'Yoga '+yogaNumber.toString()+' of 27','Calculated from the sum of the sidereal longitudes of the Sun and Moon.'),
      _element('Karana',_karana(ki),sunrise,_phase,6,'Half of a lunar tithi','A karana is half of a tithi; seven movable and four fixed karanas are used.'),
    ];
    final day=sunset.difference(sunrise);
    final rahu=_dayPeriod(sunrise,day,const [8,2,7,5,6,4,3][wd],'Rahu Kaal');
    final yama=_dayPeriod(sunrise,day,const [5,4,3,2,1,7,6][wd],'Yamaganda');
    final gulika=_dayPeriod(sunrise,day,const [7,6,5,4,3,2,1][wd],'Gulika Kaal');
    final abStart=sunrise.add(Duration(microseconds:(day.inMicroseconds*7/15).round()));
    final abhijit=PanchangPeriod(name:'Abhijit Muhurat',start:abStart,end:abStart.add(Duration(microseconds:(day.inMicroseconds/15).round())),category:'Auspicious');
    final brahma=PanchangPeriod(name:'Brahma Muhurat',start:sunrise.subtract(const Duration(minutes:96)),end:sunrise.subtract(const Duration(minutes:48)),category:'Auspicious');
    return PanchangData(date:DateTime(date.year,date.month,date.day),location:location,sunrise:sunrise,sunset:sunset,nextSunrise:nextRise,moonrise:moonrise,moonset:moonset,elements:elements,weekday:weekdays[wd],paksha:paksha,lunarDay:lunarDay,sunRashi:rashis[sign],ritu:ritus[sign],ayana:sign>=9||sign<=2?'Uttarayana':'Dakshinayana',rahuKaal:rahu,yamaganda:yama,gulika:gulika,abhijit:abhijit,brahma:brahma,choghadiyaDay:_choghadiya(sunrise,sunset,dayChoghadiya[wd]),choghadiyaNight:_choghadiya(sunset,nextRise,nightChoghadiya[wd]),ayanamsha:AyanamshaService.lahiri(sunrise));
  }

  static PanchangElement _element(String name,String value,DateTime at,double Function(DateTime) fn,double span,String description,String detail) {
    final idx=(fn(at)/span).floor();
    return PanchangElement(name:name,value:value,start:_boundary(at,fn,span,idx,-1),end:_boundary(at,fn,span,idx,1),description:description,detail:detail);
  }
  static DateTime _boundary(DateTime at,double Function(DateTime) fn,double span,int idx,int dir) {
    var previous=at;
    for(var i=1;i<=96;i++){
      final probe=at.add(Duration(minutes:30*i*dir));
      if((fn(probe)/span).floor()!=idx){
        var a=dir>0?previous:probe; var b=dir>0?probe:previous;
        for(var j=0;j<20;j++){
          final mid=a.add(Duration(microseconds:b.difference(a).inMicroseconds~/2));
          if((fn(mid)/span).floor()==idx){if(dir>0)a=mid;else b=mid;}else{if(dir>0)b=mid;else a=mid;}
        }
        return dir>0?b:a;
      }
      previous=probe;
    }
    return at;
  }
  static PanchangPeriod _dayPeriod(DateTime start,Duration duration,int segment,String name){
    final us=duration.inMicroseconds/8;
    final from=start.add(Duration(microseconds:(us*(segment-1)).round()));
    return PanchangPeriod(name:name,start:from,end:from.add(Duration(microseconds:us.round())),category:'Inauspicious period');
  }
  static List<PanchangPeriod> _choghadiya(DateTime start,DateTime end,List<String> names){
    final us=end.difference(start).inMicroseconds/8;
    return List.generate(8,(i){
      final name=names[i]; final good=['Amrit','Shubh','Labh','Char'].contains(name);
      return PanchangPeriod(name:name,start:start.add(Duration(microseconds:(us*i).round())),end:start.add(Duration(microseconds:(us*(i+1)).round())),category:good?'Favourable':'Avoid for auspicious starts');
    });
  }
  static List<PanchangObservance> upcomingObservances({required DateTime from,required PanchangLocation location,int days=45}){
    final zone=tz.getLocation(location.timeZoneId); final observer=astro.Observer(location.latitude,location.longitude,0);
    final out=<PanchangObservance>[];
    for(var i=0;i<days;i++){
      final d=DateTime(from.year,from.month,from.day+i); final local=tz.TZDateTime(zone,d.year,d.month,d.day);
      final rise=astro.searchRiseSet(astro.Body.Sun,observer,1,local.toUtc(),1.0); if(rise==null)continue;
      final idx=(_phase(rise.date)/12).floor().clamp(0,29);
      final title=_observance(idx);
      if(title!=null){
        final p=idx<15?'Shukla':'Krishna';
        out.add(PanchangObservance(date:d,title:title,subtitle:p+' Paksha · '+_tithi(idx),category:idx%15==10?'Vrat':'Tithi'));
      }
      final sunset=astro.searchRiseSet(astro.Body.Sun,observer,-1,rise.date.add(const Duration(seconds:1)),1.0);
      if(sunset!=null){
        final eveningIndex=(_phase(sunset.date)/12).floor().clamp(0,29);
        if(eveningIndex%15==12){
          final p=eveningIndex<15?'Shukla':'Krishna';
          out.add(PanchangObservance(date:d,title:'Pradosh Vrat',subtitle:p+' Paksha · Trayodashi at sunset',category:'Vrat'));
        }
      }
    }
    return out;
  }
  static List<PanchangCalendarDay> monthDays({required DateTime month,required PanchangLocation location}){
    final first=DateTime(month.year,month.month,1); final start=first.subtract(Duration(days:first.weekday%7));
    final zone=tz.getLocation(location.timeZoneId); final observer=astro.Observer(location.latitude,location.longitude,0);
    return List.generate(42,(i){
      final d=start.add(Duration(days:i)); final local=tz.TZDateTime(zone,d.year,d.month,d.day);
      final rise=astro.searchRiseSet(astro.Body.Sun,observer,1,local.toUtc(),1.0);
      final idx=rise==null?0:(_phase(rise.date)/12).floor().clamp(0,29);
      final short=idx==29?'Ama':idx==14?'Purn':tithis[idx%15].substring(0,math.min(4,tithis[idx%15].length).toInt());
      return PanchangCalendarDay(date:d,tithi:short,paksha:idx<15?'S':'K',isObservance:_observance(idx)!=null);
    });
  }
  static String? _observance(int i){final d=i%15;if(d==10)return 'Ekadashi';if(d==14)return i<15?'Purnima':'Amavasya';if(d==3)return 'Chaturthi Tithi';return null;}
  static String _tithi(int i)=>i==29?'Amavasya':tithis[i%15];
  static String _karana(int i)=>AstrologyMath.karanaName(i);
  static double _phase(DateTime d)=>AstrologyMath.angularSeparation(_sun(d),_moon(d));
  static double _moon(DateTime d)=>AstrologyMath.toSiderealLongitude(tropicalLongitude:astro.eclipticGeoMoon(d).lon,ayanamsha:AyanamshaService.lahiri(d));
  static double _sun(DateTime d)=>AstrologyMath.toSiderealLongitude(tropicalLongitude:astro.sunPosition(d).eLon,ayanamsha:AyanamshaService.lahiri(d));

  /// Returns astronomical lunar phase/tithi boundaries and sidereal solar ingresses.
  /// Events are instants, not a regional festival/vrata decision calendar.
  static List<PanchangLunarEvent> upcomingLunarEvents({
    required DateTime from,
    required PanchangLocation location,
    int days = 90,
  }) {
    final zone = tz.getLocation(location.timeZoneId);
    final localStart = tz.TZDateTime(zone, from.year, from.month, from.day);
    final start = localStart.toUtc();
    final end = start.add(Duration(days: days));
    final events = <PanchangLunarEvent>[];
    var cursor = start;
    var phaseAtCursor = _phase(cursor);
    var sunAtCursor = _sun(cursor);
    const step = Duration(hours: 6);

    while (cursor.isBefore(end)) {
      final next = cursor.add(step).isAfter(end) ? end : cursor.add(step);
      final phaseAtNext = _phase(next);
      final phaseTravel = _forward(phaseAtCursor, phaseAtNext);
      if (phaseTravel > 0) {
        final firstBoundary = (phaseAtCursor / 90).floor() + 1;
        for (var boundaryNumber = firstBoundary; boundaryNumber <= 4; boundaryNumber++) {
          final target = boundaryNumber * 90.0;
          final distance = _forward(phaseAtCursor, target % 360);
          if (distance <= phaseTravel + 1e-7) {
            final instant = _findAngularBoundary(
              cursor, next, phaseAtCursor, distance, _phase,
            );
            final phase = (target % 360).round() % 360;
            final titleKey = switch (phase) {
              0 => 'lunar_new_moon',
              90 => 'lunar_first_quarter',
              180 => 'lunar_full_moon',
              _ => 'lunar_last_quarter',
            };
            final detailKey = phase == 90 || phase == 270
                ? 'lunar_quarter_detail'
                : phase == 0 ? 'lunar_new_moon_detail' : 'lunar_full_moon_detail';
            events.add(PanchangLunarEvent(
              time: instant,
              titleKey: titleKey,
              detailKey: detailKey,
              categoryKey: 'lunar_phase',
            ));
          }
        }

        final tithiStart = ((phaseAtCursor / 12).floor() + 1) * 12.0;
        final tithiDistance = _forward(phaseAtCursor, tithiStart % 360);
        if (tithiDistance <= phaseTravel + 1e-7) {
          final tithiIndex = (tithiStart.round() ~/ 12) % 30;
          if (tithiIndex == 10 || tithiIndex == 25) {
            final instant = _findAngularBoundary(
              cursor, next, phaseAtCursor, tithiDistance, _phase,
            );
            events.add(PanchangLunarEvent(
              time: instant,
              titleKey: 'lunar_ekadashi',
              detailKey: 'lunar_ekadashi_detail',
              categoryKey: 'lunar_tithi',
            ));
          }
        }
      }

      final sunAtNext = _sun(next);
      final sunTravel = _forward(sunAtCursor, sunAtNext);
      if (sunTravel > 0) {
        final nextSignBoundary = ((sunAtCursor / 30).floor() + 1) * 30.0;
        final distance = _forward(sunAtCursor, nextSignBoundary % 360);
        if (distance <= sunTravel + 1e-7) {
          final instant = _findAngularBoundary(
            cursor, next, sunAtCursor, distance, _sun,
          );
          final signIndex = (nextSignBoundary.round() ~/ 30) % 12;
          events.add(PanchangLunarEvent(
            time: instant,
            titleKey: 'lunar_sankranti',
            detailKey: 'lunar_sankranti_detail',
            categoryKey: 'solar_ingress',
            rashiIndex: signIndex,
          ));
        }
      }
      cursor = next;
      phaseAtCursor = phaseAtNext;
      sunAtCursor = sunAtNext;
    }

    events.sort((a, b) => a.time.compareTo(b.time));
    return events;
  }

  static double lunarIllumination(DateTime at) {
    final phase = _phase(at) * math.pi / 180;
    return ((1 - math.cos(phase)) / 2 * 100).clamp(0, 100).toDouble();
  }

  static String lunarPhaseKey(DateTime at) {
    final phase = _phase(at);
    if (phase < 22.5 || phase >= 337.5) return 'lunar_phase_new';
    if (phase < 67.5) return 'lunar_phase_waxing_crescent';
    if (phase < 112.5) return 'lunar_phase_first_quarter';
    if (phase < 157.5) return 'lunar_phase_waxing_gibbous';
    if (phase < 202.5) return 'lunar_phase_full';
    if (phase < 247.5) return 'lunar_phase_waning_gibbous';
    if (phase < 292.5) return 'lunar_phase_last_quarter';
    return 'lunar_phase_waning_crescent';
  }

  static DateTime _findAngularBoundary(
    DateTime low,
    DateTime high,
    double startAngle,
    double distance,
    double Function(DateTime) angleAt,
  ) {
    var left = low;
    var right = high;
    for (var i = 0; i < 32; i++) {
      final middle = left.add(Duration(
        microseconds: right.difference(left).inMicroseconds ~/ 2,
      ));
      final travelled = _forward(startAngle, angleAt(middle));
      if (travelled >= distance) {
        right = middle;
      } else {
        left = middle;
      }
    }
    return right;
  }

  static double _forward(double from, double to) =>
      (to - from + 360) % 360;

}
