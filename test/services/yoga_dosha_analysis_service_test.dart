import 'package:flutter_test/flutter_test.dart';
import 'package:astrology/models/kundali/kundali_graha.dart';
import 'package:astrology/services/yoga_dosha_analysis_service.dart';

KundaliChart makeChart({int asc=0,Map<String,int> signs=const {}}) {
  const names=['Sun','Moon','Mars','Mercury','Jupiter','Venus','Saturn','Rahu','Ketu'];
  const symbols=['Su','Mo','Ma','Me','Ju','Ve','Sa','Ra','Ke'];
  final grahas=<KundaliGraha>[];
  for(var i=0;i<names.length;i++){
    final sign=signs[names[i]]??i;
    grahas.add(KundaliGraha(name:names[i],symbol:symbols[i],longitude:sign*30.0+5,signIndex:sign,houseNumber:(sign-asc+12)%12+1,bhavaNumber:(sign-asc+12)%12+1));
  }
  return KundaliChart(ascendantLongitude:asc*30.0,ascendantSignIndex:asc,midheavenLongitude:0,bhavas:List.generate(12,(i)=>BhavaHouse(number:i+1,startLongitude:i*30.0,middleLongitude:i*30.0+15,endLongitude:(i+1)*30.0)),grahas:grahas);
}

void main(){
  test('detects Gajakesari only when Jupiter is in a Kendra from Moon',(){
    final yes=YogaDoshaAnalysisService.analyse(makeChart(signs:{'Moon':0,'Jupiter':3}));
    final no=YogaDoshaAnalysisService.analyse(makeChart(signs:{'Moon':0,'Jupiter':2}));
    expect(yes.any((x)=>x.key=='gajakesari'),isTrue);
    expect(no.any((x)=>x.key=='gajakesari'),isFalse);
  });
  test('detects same-sign Budhaditya and Chandra-Mangala combinations',(){
    final result=YogaDoshaAnalysisService.analyse(makeChart(signs:{'Sun':0,'Mercury':0,'Moon':2,'Mars':2}));
    expect(result.map((x)=>x.key),containsAll(['budhaditya','chandra_mangala']));
  });
  test('reports Raja and Dhana lord connections separately',(){
    final result=YogaDoshaAnalysisService.analyse(makeChart(asc:0,signs:{'Mars':0,'Jupiter':0,'Venus':1,'Saturn':9}));
    expect(result.any((x)=>x.key=='raja_yoga'),isTrue);
  });
  test('detects Manglik reference points separately and reports mitigations without cancelling',(){
    final chart=makeChart(asc:0,signs:{'Mars':6,'Moon':0,'Venus':1,'Jupiter':6});
    final doshas=YogaDoshaAnalysisService.analyseDoshas(chart);
    final manglik=doshas.firstWhere((x)=>x.key=='manglik');
    expect(manglik.bases,contains('Lagna'));
    expect(manglik.bases,contains('Moon'));
    expect(manglik.mitigationIndicators,contains('dosha_jupiter_influence'));
    expect(manglik.caveat,isNotEmpty);
  });
  test('detects strict Kala Sarpa only when all seven classical planets are within one node half',(){
    final chart=makeChart(signs:{
      'Rahu':0,'Ketu':6,'Sun':0,'Moon':1,'Mars':2,'Mercury':3,
      'Jupiter':4,'Venus':4,'Saturn':5,
    });
    expect(YogaDoshaAnalysisService.analyseDoshas(chart).any((x)=>x.key=='kala_sarpa'),isTrue);
    final broken=makeChart(signs:{
      'Rahu':0,'Ketu':6,'Sun':0,'Moon':1,'Mars':2,'Mercury':3,
      'Jupiter':4,'Venus':4,'Saturn':8,
    });
    expect(YogaDoshaAnalysisService.analyseDoshas(broken).any((x)=>x.key=='kala_sarpa'),isFalse);
  });
  test('detects close luminary-node conjunction as a Grahan screening only',(){
    final chart=makeChart(signs:{'Sun':0,'Rahu':0,'Moon':3,'Ketu':6});
    expect(YogaDoshaAnalysisService.analyseDoshas(chart).any((x)=>x.key=='surya_grahan'),isTrue);
    expect(YogaDoshaAnalysisService.analyseDoshas(chart).any((x)=>x.key=='chandra_grahan'),isFalse);
  });
  test('does not assign a universal good or bad score',(){
    final result=YogaDoshaAnalysisService.analyse(makeChart());
    expect(result.every((x)=>x.status==YogaStatus.formed||x.status==YogaStatus.modified||x.status==YogaStatus.weakened),isTrue);
    expect(result.every((x)=>x.caveat.isNotEmpty),isTrue);
  });
}
