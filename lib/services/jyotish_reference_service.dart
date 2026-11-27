import 'dart:math' as math;
import '../models/kundali/kundali_graha.dart';
import '../models/panchang_data.dart';

class CharaKaraka {
  const CharaKaraka(this.role, this.planet, this.degree);
  final String role;
  final KundaliGraha planet;
  final double degree;
}

class MaitriResult {
  const MaitriResult(this.first, this.second, this.natural, this.temporary, this.compound);
  final KundaliGraha first, second;
  final String natural, temporary, compound;
}

class HoraEntry {
  const HoraEntry(this.index, this.planet, this.start, this.end, this.isNight);
  final int index;
  final String planet;
  final DateTime start, end;
  final bool isNight;
  bool contains(DateTime value) => !value.isBefore(start) && value.isBefore(end);
}

class JyotishReferenceService {
  JyotishReferenceService._();

  static const _lords = ['Mars','Venus','Mercury','Moon','Sun','Mercury','Venus','Mars','Jupiter','Saturn','Saturn','Jupiter'];
  static const _naturalFriends = <String, Set<String>>{
    'Sun': {'Moon','Mars','Jupiter'}, 'Moon': {'Sun','Mercury'},
    'Mars': {'Sun','Moon','Jupiter'}, 'Mercury': {'Sun','Venus'},
    'Jupiter': {'Sun','Moon','Mars'}, 'Venus': {'Mercury','Saturn'},
    'Saturn': {'Mercury','Venus'}, 'Rahu': {}, 'Ketu': {},
  };
  static const _naturalEnemies = <String, Set<String>>{
    'Sun': {'Venus','Saturn'}, 'Moon': {}, 'Mars': {'Mercury'},
    'Mercury': {'Moon'}, 'Jupiter': {'Mercury','Venus'},
    'Venus': {'Sun','Moon'}, 'Saturn': {'Sun','Moon','Mars'},
    'Rahu': {}, 'Ketu': {},
  };
  static const _weekdayLords = ['Sun','Moon','Mars','Mercury','Jupiter','Venus','Saturn'];
  static const _horaOrder = ['Saturn','Jupiter','Mars','Sun','Venus','Mercury','Moon'];
  static const _rashi = [
    'Aries','Taurus','Gemini','Cancer','Leo','Virgo','Libra','Scorpio','Sagittarius','Capricorn','Aquarius','Pisces'
  ];
  static const _elements = ['Fire','Earth','Air','Water','Fire','Earth','Air','Water','Fire','Earth','Air','Water'];
  static const _modes = ['Movable','Fixed','Dual','Movable','Fixed','Dual','Movable','Fixed','Dual','Movable','Fixed','Dual'];
  static const _genders = ['Masculine','Feminine','Masculine','Feminine','Masculine','Feminine','Masculine','Feminine','Masculine','Feminine','Masculine','Feminine'];
  static const _dayStrength = [false,false,false,false,true,true,true,true,false,false,true,true];
  static const _directions = {'Sun':'East','Moon':'North-West','Mars':'South','Mercury':'North','Jupiter':'North-East','Venus':'South-East','Saturn':'West','Rahu':'South-West','Ketu':'North-West'};
  static const _colours = {'Sun':'Deep red / copper','Moon':'White','Mars':'Red','Mercury':'Green','Jupiter':'Yellow','Venus':'White / pastel','Saturn':'Dark blue / black','Rahu':'Smoky / dark blue','Ketu':'Grey / earthy'};
  static const _karakatva = {
    'Sun':'Soul, authority, father, vitality, government, confidence and leadership.',
    'Moon':'Mind, emotions, mother, nourishment, public life and fluids.',
    'Mars':'Courage, siblings, land, tools, energy, initiative and competition.',
    'Mercury':'Intellect, speech, writing, learning, calculation, trade and communication.',
    'Jupiter':'Wisdom, teachers, children, ethics, faith, higher learning and counsel.',
    'Venus':'Relationships, spouse, art, beauty, comforts, vehicles and pleasures.',
    'Saturn':'Work, service, discipline, delay, endurance, responsibility and longevity.',
    'Rahu':'Ambition, foreign themes, unconventional paths, innovation and worldly desire.',
    'Ketu':'Detachment, introspection, liberation, subtle insight and renunciation.',
  };
  static const _bodyParts = ['Head','Face, eyes, neck and mouth','Arms, shoulders and upper chest','Chest, heart and upper abdomen','Upper abdomen and solar plexus','Waist, intestines and lower abdomen','Lower abdomen and kidneys','Pelvic region and reproductive organs','Thighs','Knees and back','Calves, ankles and ears','Feet and lymphatic symbolism'];
  static const _avasthaNames = ['Deepta','Swastha','Mudita','Shanta','Shakta','Peedita','Deena','Khala','Bheeta','Vikala'];
  static const _avasthaNotes = [
    'Bright or exalted condition; traditionally associated with pronounced planetary expression.',
    'Own-sign condition; traditionally associated with steadiness and familiarity.',
    'Friendly-sign condition; traditionally associated with ease and support.',
    'Neutral or calm condition; interpretation depends on house lordship and aspects.',
    'A capable or empowered condition; the exact rule varies by classical text.',
    'Afflicted or pressured condition; requires conjunction, aspect and dignity judgement.',
    'Weak or debilitated condition; should be judged with cancellation and support factors.',
    'Unsettled or irregular condition; method-specific rules are required.',
    'Fearful or constrained condition; method-specific rules are required.',
    'Impaired or disturbed condition; method-specific rules are required.',
  ];

  static List<CharaKaraka> charaKarakas(KundaliChart chart, {bool includeRahu = true}) {
    final planets = chart.grahas.where((g) => g.name != 'Ketu' && (includeRahu || g.name != 'Rahu')).toList();
    planets.sort((a,b) {
      final av = a.name == 'Rahu' ? 30 - a.signDegree : a.signDegree;
      final bv = b.name == 'Rahu' ? 30 - b.signDegree : b.signDegree;
      return bv.compareTo(av);
    });
    const roles7 = ['Atmakaraka','Amatyakaraka','Bhratrikaraka','Matrikaraka','Putrakaraka','Gnatikaraka','Darakaraka'];
    const roles8 = ['Atmakaraka','Amatyakaraka','Bhratrikaraka','Matrikaraka','Pitṛkaraka','Putrakaraka','Gnatikaraka','Darakaraka'];
    final roles = planets.length == 8 ? roles8 : roles7;
    return [for(var i=0;i<math.min(planets.length,roles.length);i++) CharaKaraka(roles[i],planets[i],planets[i].signDegree)];
  }

  static List<MaitriResult> panchadhaMaitri(KundaliChart chart) {
    final planets = chart.grahas.where((g)=>_naturalFriends.containsKey(g.name)).toList();
    final result=<MaitriResult>[];
    for(var i=0;i<planets.length;i++) {
      for(var j=i+1;j<planets.length;j++) {
        final a=planets[i], b=planets[j];
        final naturalA=_naturalRelation(a.name,b.name), naturalB=_naturalRelation(b.name,a.name);
        final natural = naturalA==naturalB ? naturalA : 'Mixed / school-dependent';
        final gap=((b.signIndex-a.signIndex+12)%12)+1;
        final temporary = [2,3,4,10,11,12].contains(gap) ? 'Friend' : 'Enemy';
        final compound=_compound(natural,temporary);
        result.add(MaitriResult(a,b,natural,temporary,compound));
      }
    }
    return result;
  }
  static String _naturalRelation(String a,String b) {
    if((_naturalFriends[a]??{}).contains(b)) return 'Friend';
    if((_naturalEnemies[a]??{}).contains(b)) return 'Enemy';
    return 'Neutral';
  }
  static String _compound(String natural,String temporary) {
    if(natural=='Friend'&&temporary=='Friend') return 'Great friend';
    if(natural=='Enemy'&&temporary=='Enemy') return 'Great enemy';
    if(natural=='Friend'||temporary=='Friend') return 'Friend';
    if(natural=='Enemy'||temporary=='Enemy') return 'Enemy';
    return 'Neutral';
  }

  static String baladiAvastha(KundaliGraha planet) {
    const names=['Bala','Kumara','Yuva','Vriddha','Mrita'];
    final segment=(planet.signDegree/6).floor().clamp(0,4);
    return names[planet.signIndex.isEven?segment:4-segment];
  }

  static List<Map<String,String>> rashiAttributes() => [
    for(var i=0;i<12;i++) {
      'name':_rashi[i], 'element':_elements[i], 'modality':_modes[i],
      'gender':_genders[i], 'lord':_lords[i],
      'dayNight':_dayStrength[i]?'Day-strong':'Night-strong',
      'direction':_directionForRashi(i),
      'bodyPart':_bodyParts[i],
    }
  ];
  static String _directionForRashi(int i) => const ['East','South','West','North','East','South','West','North','East','South','West','North'][i];

  static List<HoraEntry> horas(PanchangData panchang) {
    final weekday=panchang.sunrise.weekday%7;
    final first=_weekdayLords[weekday];
    var index=_horaOrder.indexOf(first);
    if(index<0) index=0;
    final dayLength=panchang.sunset.difference(panchang.sunrise).inMicroseconds;
    final nightLength=panchang.nextSunrise.difference(panchang.sunset).inMicroseconds;
    final entries=<HoraEntry>[];
    for(var i=0;i<24;i++) {
      final isNight=i>=12;
      final start=isNight?panchang.sunset:panchang.sunrise;
      final length=isNight?nightLength:dayLength;
      final offset=isNight?i-12:i;
      final from=start.add(Duration(microseconds:(length*offset/12).round()));
      final to=start.add(Duration(microseconds:(length*(offset+1)/12).round()));
      final planet=_horaOrder[(index+i)%7];
      entries.add(HoraEntry(i+1,planet,from,to,isNight));
    }
    return entries;
  }

  static String? karakatva(String planet)=>_karakatva[planet];
  static String? direction(String planet)=>_directions[planet];
  static String? colour(String planet)=>_colours[planet];
  static List<String> get dashavidhaNames=>_avasthaNames;
  static List<String> get dashavidhaNotes=>_avasthaNotes;
}
