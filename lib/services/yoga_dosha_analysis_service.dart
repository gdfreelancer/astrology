import 'dart:math' as math;
import '../models/kundali/kundali_graha.dart';
import 'advanced_chart_analysis_service.dart';

enum YogaCategory { raja, dhana, vipareeta, mahapurusha, lunar, other }
enum YogaStatus { formed, modified, weakened }

class YogaAssessment {
  const YogaAssessment({required this.key,required this.category,required this.status,required this.planetNames,required this.formation,required this.modifiers,required this.caveat});
  final String key;
  final YogaCategory category;
  final YogaStatus status;
  final List<String> planetNames;
  final String formation;
  final List<String> modifiers;
  final String caveat;
}

/// Traditional placement screening; not a deterministic prediction engine.
class YogaDoshaAnalysisService {
  YogaDoshaAnalysisService._();
  static const _lords=['Mars','Venus','Mercury','Moon','Sun','Mercury','Venus','Mars','Jupiter','Saturn','Saturn','Jupiter'];
  static const _own=<String,List<int>>{'Sun':[4],'Moon':[3],'Mars':[0,7],'Mercury':[2,5],'Jupiter':[8,11],'Venus':[1,6],'Saturn':[9,10]};
  static const _exalt=<String,int>{'Sun':0,'Moon':1,'Mars':9,'Mercury':5,'Jupiter':3,'Venus':11,'Saturn':6};
  static const _debil=<String,int>{'Sun':6,'Moon':7,'Mars':3,'Mercury':11,'Jupiter':9,'Venus':5,'Saturn':0};

  static List<YogaAssessment> analyse(KundaliChart chart) {
    final byName={for(final g in chart.grahas)g.name:g};
    KundaliGraha? p(String n)=>byName[n];
    final conditions=AdvancedChartAnalysisService.conditions(chart);
    final out=<YogaAssessment>[];
    void add(String key,YogaCategory category,List<String> names,String formation) {
      final modifiers=<String>[];
      var severe=0;
      for(final n in names.toSet()) {
        final g=p(n); if(g==null)continue;
        if(_debil[n]==g.signIndex){modifiers.add('Debilitated placement');severe++;}
        else if(_exalt[n]==g.signIndex)modifiers.add('Exalted placement');
        else if((_own[n]??const <int>[]).contains(g.signIndex))modifiers.add('Own-sign placement');
        if(conditions.where((c)=>c.planet.name==n).firstOrNull?.combust==true){modifiers.add('Combustion screening flag');severe++;}
        if(g.isRetrograde)modifiers.add('Retrograde motion; not automatically weak');
      }
      out.add(YogaAssessment(key:key,category:category,status:severe>=2?YogaStatus.weakened:modifiers.isEmpty?YogaStatus.formed:YogaStatus.modified,planetNames:List.unmodifiable(names.toSet()),formation:formation,modifiers:List.unmodifiable(modifiers),caveat:'Placement-level screening only. Full Shadbala, Bhava Bala, planetary war, divisional confirmation and tradition-specific exceptions are not validated.'));
    }
    final moon=p('Moon'),jupiter=p('Jupiter'),sun=p('Sun'),mercury=p('Mercury'),mars=p('Mars');
    if(moon!=null&&jupiter!=null&&[0,3,6,9].contains((jupiter.signIndex-moon.signIndex+12)%12))add('gajakesari',YogaCategory.lunar,['Moon','Jupiter'],'Jupiter is in a Kendra from the Moon.');
    if(sun!=null&&mercury!=null&&sun.signIndex==mercury.signIndex)add('budhaditya',YogaCategory.other,['Sun','Mercury'],'Sun and Mercury occupy the same sign.');
    if(moon!=null&&mars!=null&&moon.signIndex==mars.signIndex)add('chandra_mangala',YogaCategory.dhana,['Moon','Mars'],'Moon and Mars occupy the same sign.');

    int signOfHouse(int h)=>(chart.ascendantSignIndex+h-1)%12;
    KundaliGraha? lord(int h)=>p(_lords[signOfHouse(h)]);
    bool linked(KundaliGraha? a,KundaliGraha? b){
      if(a==null||b==null)return false;
      if(a.name==b.name||a.signIndex==b.signIndex)return true;
      return AdvancedChartAnalysisService.aspects(chart).any((x)=>(x.planet.name==a.name&&x.occupants.any((g)=>g.name==b.name))||(x.planet.name==b.name&&x.occupants.any((g)=>g.name==a.name)));
    }
    final raja=<String>[];
    for(final k in [1,4,7,10])for(final t in [5,9])if(linked(lord(k),lord(t)))raja.add(lord(k)!.name+' with '+lord(t)!.name);
    if(raja.isNotEmpty)add('raja_yoga',YogaCategory.raja,raja,'Kendra and Trikona lords are connected: '+raja.join(', ')+'.');
    final dhana=<String>[];
    for(final w in [2,11])for(final t in [5,9])if(linked(lord(w),lord(t)))dhana.add(lord(w)!.name+' with '+lord(t)!.name);
    if(dhana.isNotEmpty)add('dhana_yoga',YogaCategory.dhana,dhana,'Wealth-house and Trikona lords are connected: '+dhana.join(', ')+'.');

    for(final h in [6,8,12]){
      final l=lord(h);
      if(l!=null&&[6,8,12].contains(l.houseNumber)){
        final key=h==6?'harsha':h==8?'sarala':'vimala';
        add('vipareeta_'+key,YogaCategory.vipareeta,[l.name],'A Dusthana lord is placed in a Dusthana.');
      }
    }
    const maha={'Mars':'ruchaka','Mercury':'bhadra','Jupiter':'hamsa','Venus':'malavya','Saturn':'shasha'};
    for(final e in maha.entries){
      final g=p(e.key);
      if(g!=null&&[1,4,7,10].contains(g.houseNumber)&&((_own[e.key]??const <int>[]).contains(g.signIndex)||_exalt[e.key]==g.signIndex))add('pancha_'+e.value,YogaCategory.mahapurusha,[e.key],'Planet occupies a Kendra in own or exaltation sign.');
    }
    bool kendra(int sign,int base)=>[1,4,7,10].contains((sign-base+12)%12+1);
    for(final g in chart.grahas){
      if(_debil[g.name]!=g.signIndex)continue;
      final dl=p(_lords[g.signIndex]);
      final el=p(_lords[_exalt[g.name]??g.signIndex]);
      final cancel=(dl!=null&&(kendra(dl.signIndex,chart.ascendantSignIndex)||(moon!=null&&kendra(dl.signIndex,moon.signIndex))))||(el!=null&&(kendra(el.signIndex,chart.ascendantSignIndex)||(moon!=null&&kendra(el.signIndex,moon.signIndex))));
      if(cancel)add('neecha_bhanga_'+g.name.toLowerCase(),YogaCategory.raja,[g.name],'Debilitated planet has a cancellation-related lord in a Kendra from Lagna or Moon.');
    }
    return List.unmodifiable(out);
  }
}
