import '../../data/nakshatra_data.dart';
import '../../models/matching/matching_person.dart';

class PoruthamItem {
  const PoruthamItem(this.name,this.score,this.maximum,this.explanation);
  final String name,explanation;
  final double score,maximum;
}
class PoruthamReport {
  const PoruthamReport(this.items);
  final List<PoruthamItem> items;
  double get total=>items.fold(0,(s,e)=>s+e.score);
  double get maximum=>items.fold(0,(s,e)=>s+e.maximum);
  bool get rajjuClear=>items.firstWhere((e)=>e.name=='Rajju').score>0;
  bool get vedhaClear=>items.firstWhere((e)=>e.name=='Vedha').score>0;
}
/// One documented directional Tamil-style 10-porutham convention.
class SouthIndianPoruthamService {
  SouthIndianPoruthamService._();
  static const _gana=['Deva','Manushya','Rakshasa','Manushya','Deva','Manushya','Deva','Deva','Rakshasa','Rakshasa','Manushya','Manushya','Deva','Rakshasa','Deva','Rakshasa','Deva','Rakshasa','Rakshasa','Manushya','Manushya','Deva','Rakshasa','Rakshasa','Manushya','Manushya','Deva'];
  static const _yoni=['Horse','Elephant','Sheep','Serpent','Serpent','Dog','Cat','Sheep','Cat','Rat','Rat','Cow','Buffalo','Tiger','Buffalo','Tiger','Deer','Deer','Dog','Monkey','Mongoose','Monkey','Lion','Horse','Lion','Cow','Elephant'];
  static const _rajju=['Pada','Kati','Nabhi','Kanta','Sira','Kanta','Nabhi','Kati','Pada','Pada','Kati','Nabhi','Kanta','Sira','Kanta','Nabhi','Kati','Pada','Pada','Kati','Nabhi','Kanta','Sira','Kanta','Nabhi','Kati','Pada'];
  static const _vedha=[18,17,15,14,13,21,11,10,8,8,7,6,5,4,3,2,1,0,26,25,24,23,22,22,20,19,18];
  static const _rashiLords=['Mars','Venus','Mercury','Moon','Sun','Mercury','Venus','Mars','Jupiter','Saturn','Saturn','Jupiter'];
  static const _vasya=<int,List<int>>{0:[4,7],1:[3,6],2:[5],3:[7,8],4:[6],5:[2,11],6:[9,5],7:[3,5],8:[11],9:[10,0],10:[0],11:[9]};
  static const _friends=<String,Set<String>>{
    'Sun':{'Moon','Mars','Jupiter'},'Moon':{'Sun','Mercury'},'Mars':{'Sun','Moon','Jupiter'},
    'Mercury':{'Sun','Venus'},'Jupiter':{'Sun','Moon','Mars'},'Venus':{'Mercury','Saturn'},
    'Saturn':{'Mercury','Venus'},'Rahu':{'Venus','Saturn'},'Ketu':{'Mars','Jupiter'},
  };
  static const _enemies=<String,Set<String>>{
    'Sun':{'Venus','Saturn'},'Mars':{'Mercury'},'Mercury':{'Moon'},
    'Jupiter':{'Mercury','Venus'},'Venus':{'Sun','Moon'},'Saturn':{'Sun','Moon','Mars'},
  };
  static const _yoniEnemies={'Horse|Buffalo','Buffalo|Horse','Elephant|Lion','Lion|Elephant','Sheep|Monkey','Monkey|Sheep','Serpent|Mongoose','Mongoose|Serpent','Dog|Deer','Deer|Dog','Cat|Rat','Rat|Cat','Cow|Tiger','Tiger|Cow'};
  static PoruthamReport calculate({required MatchingPerson bride,required MatchingPerson groom}) {
    final a=nakshatras.indexWhere((n)=>n.name==bride.nakshatra);
    final b=nakshatras.indexWhere((n)=>n.name==groom.nakshatra);
    final ar=rashiNames.indexOf(bride.rashi), br=rashiNames.indexOf(groom.rashi);
    if(a<0||b<0||ar<0||br<0) throw StateError('Birth Nakshatra or Rashi is not recognised.');
    final count=((b-a+27)%27)+1, rasiCount=((br-ar+12)%12)+1;
    final dina={2,4,6,8,9,11,13,15,18,20,24,26}.contains(count);
    final ganaA=_gana[a],ganaB=_gana[b];
    final ganaScore=ganaA==ganaB?6:((ganaA=='Deva'&&ganaB=='Manushya')||(ganaA=='Manushya'&&ganaB=='Deva'))?5:((ganaA=='Manushya'&&ganaB=='Rakshasa')||(ganaA=='Rakshasa'&&ganaB=='Manushya'))?1:0;
    final yA=_yoni[a],yB=_yoni[b], hostile=_yoniEnemies.contains('$yA|$yB');
    final yoniScore=yA==yB?4:hostile?0:2;
    final lordA=_rashiLords[ar],lordB=_rashiLords[br];
    final mutual=(_friends[lordA]?.contains(lordB)??false)&&(_friends[lordB]?.contains(lordA)??false);
    final oneWay=(_friends[lordA]?.contains(lordB)??false)||(_friends[lordB]?.contains(lordA)??false);
    final enemy=(_enemies[lordA]?.contains(lordB)??false)||(_enemies[lordB]?.contains(lordA)??false);
    final lordScore=lordA==lordB||mutual?5:enemy?0:oneWay?3:2;
    final rasiScore=(rasiCount==7||rasiCount==9||rasiCount==10||rasiCount==11||rasiCount==12)?2:rasiCount==3||rasiCount==5?1:rasiCount==2&&((br+1)%2==0)?2:0;
    final vasya=(_vasya[ar]?.contains(br)??false), rajju=_rajju[a]!=_rajju[b], vedha=_vedha[a]!=b;
    final mahendra={4,7,10,13,16,19,22,25}.contains(count);
    return PoruthamReport(List.unmodifiable(<PoruthamItem>[
      PoruthamItem('Dina',dina?3:0,3,'Bride-to-groom Nakshatra count: $count.'),
      PoruthamItem('Gana',ganaScore.toDouble(),6,'$ganaA with $ganaB.'),
      PoruthamItem('Mahendra',mahendra?2:0,2,'Bride-to-groom Nakshatra count: $count.'),
      PoruthamItem('Stree Deergha',count>13?2:count>9?1:0,2,'Count $count; full agreement above 13, partial above 9 in this variant.'),
      PoruthamItem('Yoni',yoniScore.toDouble(),4,'$yA with $yB'+(hostile?' (traditional enemy pair)':'')),
      PoruthamItem('Rasi',rasiScore.toDouble(),2,'Groom Moon sign is $rasiCount from bride Moon sign.'),
      PoruthamItem('Rasi Athipathi',lordScore.toDouble(),5,'Rashi lords: $lordA and $lordB.'),
      PoruthamItem('Vasya',vasya?2:0,2,vasya?'Groom sign appears in the selected bride-sign Vasya table.':'No match in the selected directional Vasya table.'),
      PoruthamItem('Rajju',rajju?1:0,1,'${_rajju[a]} and ${_rajju[b]} Rajju.'),
      PoruthamItem('Vedha',vedha?1:0,1,vedha?'No paired Vedha obstruction in the selected table.':'Traditional Vedha pair.'),
    ]));
  }
}
