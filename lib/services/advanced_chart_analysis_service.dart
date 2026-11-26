import 'dart:math' as math;
import '../models/kundali/kundali_graha.dart';

class GrahaAspect {
  const GrahaAspect(this.planet, this.targetHouse, this.aspectNumber, this.special, this.occupants);
  final KundaliGraha planet;
  final int targetHouse, aspectNumber;
  final bool special;
  final List<KundaliGraha> occupants;
}
class GrahaCondition {
  const GrahaCondition(this.planet, this.age, this.dignity, this.combust, this.sunDistance);
  final KundaliGraha planet;
  final String age, dignity;
  final bool combust;
  final double sunDistance;
}
class YogaFinding {
  const YogaFinding(this.name, this.description, this.caveat);
  final String name, description, caveat;
}
class AdvancedChartAnalysisService {
  AdvancedChartAnalysisService._();
  static const _special = <String,List<int>>{
    'Mars':[4,7,8], 'Jupiter':[5,7,9], 'Saturn':[3,7,10],
    'Rahu':[5,7,9], 'Ketu':[5,7,9],
  };
  static const _own = <String,List<int>>{
    'Sun':[4], 'Moon':[3], 'Mars':[0,7], 'Mercury':[2,5],
    'Jupiter':[8,11], 'Venus':[1,6], 'Saturn':[9,10],
  };
  static const _exalt = <String,int>{
    'Sun':0,'Moon':1,'Mars':9,'Mercury':5,'Jupiter':3,'Venus':11,'Saturn':6,
  };
  static const _debil = <String,int>{
    'Sun':6,'Moon':7,'Mars':3,'Mercury':11,'Jupiter':9,'Venus':5,'Saturn':0,
  };
  static List<GrahaAspect> aspects(KundaliChart chart) {
    final result=<GrahaAspect>[];
    for(final planet in chart.grahas) {
      final offsets=_special[planet.name] ?? const [7];
      for(final offset in offsets) {
        final house=((planet.houseNumber+offset-2)%12)+1;
        result.add(GrahaAspect(planet,house,offset,offset!=7,chart.inHouse(house)));
      }
    }
    return result;
  }
  static List<GrahaCondition> conditions(KundaliChart chart) {
    final sun=chart.grahas.where((g)=>g.name=='Sun').firstOrNull;
    return chart.grahas.map((g) {
      final d=g.longitude%30;
      const ages=['Bala','Kumara','Yuva','Vriddha','Mrita'];
      final segment=(d/6).floor().clamp(0,4).toInt();
      final age=ages[g.signIndex.isEven?segment:4-segment];
      final dignity=_exalt[g.name]==g.signIndex?'Exalted':
        _debil[g.name]==g.signIndex?'Debilitated':
        (_own[g.name]??const <int>[]).contains(g.signIndex)?'Own sign':'Neutral / sign-dependent';
      final separation=sun==null||g.name=='Sun'?180.0:_distance(g.longitude,sun.longitude);
      final orb=switch(g.name){'Moon'=>12.0,'Mars'=>17.0,'Mercury'=>14.0,'Jupiter'=>11.0,'Venus'=>10.0,'Saturn'=>15.0,_=>0.0};
      return GrahaCondition(g,age,dignity,orb>0&&separation<=orb,separation);
    }).toList(growable:false);
  }
  static List<YogaFinding> yogas(KundaliChart chart) {
    final result=<YogaFinding>[];
    KundaliGraha? p(String n)=>chart.grahas.where((g)=>g.name==n).firstOrNull;
    final sun=p('Sun'), moon=p('Moon'), mars=p('Mars'), mercury=p('Mercury'), jupiter=p('Jupiter');
    if(sun!=null&&mercury!=null&&_distance(sun.longitude,mercury.longitude)<=10) {
      result.add(const YogaFinding('Budhaditya Yoga','Sun and Mercury are closely conjunct (within 10 degrees).','Preliminary placement check only; lordship, strength, combustion and afflictions are not fully judged.'));
    }
    if(moon!=null&&mars!=null&&moon.signIndex==mars.signIndex) {
      result.add(const YogaFinding('Chandra-Mangala Yoga','Moon and Mars occupy the same Rashi.','House ownership, exact degrees, aspects and strength require further evaluation.'));
    }
    if(moon!=null&&jupiter!=null) {
      final gap=((jupiter.houseNumber-moon.houseNumber+12)%12)+1;
      if([1,4,7,10].contains(gap)) result.add(const YogaFinding('Gajakesari Yoga','Jupiter occupies a Kendra from the Moon.','This is only the basic condition; classical strength, dignity, affliction and cancellation rules are not fully evaluated.'));
    }
    if(result.isEmpty) result.add(const YogaFinding('No supported placement yoga detected','No supported basic conjunction or Moon-Jupiter Kendra condition was found.','This is not a complete yoga scan; absence here does not mean the chart has no yogas.'));
    return result;
  }
  static double _distance(double a,double b){final d=(a-b).abs()%360;return math.min(d,360-d);}
}
