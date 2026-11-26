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

class GrahaStrengthIndicator {
  const GrahaStrengthIndicator(this.planet,this.naisargikaVirupa,this.directionalPeakHouse,this.directionalNote,this.motionNote);
  final KundaliGraha planet;
  final double naisargikaVirupa;
  final int directionalPeakHouse;
  final String directionalNote,motionNote;
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
  static List<GrahaStrengthIndicator> strengthIndicators(KundaliChart chart) {
    const natural=<String,double>{
      'Sun':60,'Moon':51.43,'Venus':42.86,'Jupiter':34.29,
      'Mercury':25.71,'Mars':17.14,'Saturn':8.57,
    };
    const peak=<String,int>{
      'Sun':10,'Mars':10,'Moon':4,'Venus':4,
      'Mercury':1,'Jupiter':1,'Saturn':7,
    };
    return chart.grahas.where((g)=>natural.containsKey(g.name)).map((g){
      final maxHouse=peak[g.name]!;
      final opposite=((maxHouse+5)%12)+1;
      final note=g.houseNumber==maxHouse?'Occupies the traditional directional peak house':
        g.houseNumber==opposite?'Occupies the opposite (minimum-direction) house':
        'Between the peak and opposite houses; exact Dig Bala needs house-midpoint geometry';
      final motion=g.isRetrograde?'Retrograde: traditional Cheshta Bala may be elevated; no numeric value calculated':
        'Direct: daily motion shown as '+g.dailyMotion.toStringAsFixed(3)+'°/day; no numeric Cheshta Bala calculated';
      return GrahaStrengthIndicator(g,natural[g.name]!,maxHouse,note,motion);
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
    final signLords=['Mars','Venus','Mercury','Moon','Sun','Mercury','Venus','Mars','Jupiter','Saturn','Saturn','Jupiter'];
    int houseSign(int house)=>(chart.ascendantSignIndex+house-1)%12;
    KundaliGraha? lordForHouse(int house)=>p(signLords[houseSign(house)]);
    bool linked(KundaliGraha? first,KundaliGraha? second) {
      if(first==null||second==null)return false;
      if(first.name==second.name||first.signIndex==second.signIndex)return true;
      final found=aspects(chart);
      return found.any((a)=>a.planet.name==first.name&&a.occupants.any((g)=>g.name==second.name))||
        found.any((a)=>a.planet.name==second.name&&a.occupants.any((g)=>g.name==first.name));
    }
    var rajYoga=false;
    for(final kendra in [1,4,7,10]) {
      for(final trikona in [5,9]) {
        if(linked(lordForHouse(kendra),lordForHouse(trikona)))rajYoga=true;
      }
    }
    if(rajYoga) result.add(const YogaFinding('Raja Yoga (basic lord connection)','A Kendra lord and a Trikona lord are conjunct, in the same sign or mutually connected by supported whole-sign aspects.','A preliminary connection scan only. Functional beneficence, exact exchange, dignity, strength, combustion and cancellation are not fully judged.'));
    var dhanaYoga=false;
    for(final wealthHouse in [2,11]) {
      for(final fortuneHouse in [5,9]) {
        if(linked(lordForHouse(wealthHouse),lordForHouse(fortuneHouse)))dhanaYoga=true;
      }
    }
    if(dhanaYoga) result.add(const YogaFinding('Dhana Yoga (basic lord connection)','A 2nd/11th lord is connected with a 5th/9th lord by conjunction, same sign or supported aspect.','This does not estimate wealth or guarantee financial outcomes; house strength and the full chart must be assessed.'));
    for(final dusthana in [6,8,12]) {
      final lord=lordForHouse(dusthana);
      if(lord!=null&&[6,8,12].contains(lord.houseNumber)) {
        final name=switch(dusthana){6=>'Harsha Yoga',8=>'Sarala Yoga',_=>'Vimala Yoga'};
        result.add(YogaFinding('Possible $name','The $dusthana-th house lord is placed in a 6th, 8th or 12th house.','A basic Vipreet Raja Yoga placement condition. Check the exact house lord, dignity, associations and classical exceptions before interpretation.'));
      }
    }
    final moonSign=moon?.signIndex;
    for(final graha in chart.grahas) {
      final debilSign=_debil[graha.name];
      if(debilSign==null||graha.signIndex!=debilSign)continue;
      final debilLord=p(signLords[debilSign]);
      final exaltSign=_exalt[graha.name]!;
      final exaltLord=p(signLords[exaltSign]);
      bool kendraFrom(int sign)=>[1,4,7,10].contains(((sign-chart.ascendantSignIndex+12)%12)+1);
      bool kendraFromMoon(int sign)=>moonSign!=null&&[1,4,7,10].contains(((sign-moonSign+12)%12)+1);
      if((debilLord!=null&&(kendraFrom(debilLord.signIndex)||kendraFromMoon(debilLord.signIndex)))||
         (exaltLord!=null&&(kendraFrom(exaltLord.signIndex)||kendraFromMoon(exaltLord.signIndex)))) {
        result.add(YogaFinding('Possible Neecha Bhanga','${graha.name} is in its debilitation sign and a cancellation-related lord is in a Kendra from Lagna or Moon.','This checks two commonly cited cancellation conditions only. Neecha Bhanga Raja Yoga has additional rules and strength requirements.'));
      }
    }
    if(result.isEmpty) result.add(const YogaFinding('No supported placement yoga detected','No supported placement combination was found by this limited scan.','This is not a complete yoga scan; absence here does not mean the chart has no yogas.'));
    return result;
  }
  static double _distance(double a,double b){final d=(a-b).abs()%360;return math.min(d,360-d);}
}
