import '../../models/kundali/kundali_graha.dart';

class ManglikAssessment {
  const ManglikAssessment({required this.fromLagna,required this.fromMoon,required this.fromVenus,required this.marsSignIndex,required this.marsHouseFromLagna});
  final bool? fromLagna,fromMoon,fromVenus;
  final int? marsSignIndex,marsHouseFromLagna;
  bool get hasAnyIndicator=>fromLagna==true||fromMoon==true||fromVenus==true;
  bool get isComplete=>fromLagna!=null&&fromMoon!=null&&fromVenus!=null;
}

class HouseCompatibilityProfile {
  const HouseCompatibilityProfile({required this.seventhHouseSign,required this.seventhHouseOccupants,required this.seventhLord,required this.seventhLordHouse});
  final int? seventhHouseSign;
  final List<String> seventhHouseOccupants;
  final String? seventhLord;
  final int? seventhLordHouse;
}

class AdvancedMatchingAnalysis {
  const AdvancedMatchingAnalysis({required this.brideManglik,required this.groomManglik,required this.brideSeventhHouse,required this.groomSeventhHouse});
  final ManglikAssessment brideManglik,groomManglik;
  final HouseCompatibilityProfile brideSeventhHouse,groomSeventhHouse;
}

class AdvancedMatchingService {
  static const _marsHouses={1,2,4,7,8,12};
  static const _lords=['Mars','Venus','Mercury','Moon','Sun','Mercury','Venus','Mars','Jupiter','Saturn','Saturn','Jupiter'];

  static AdvancedMatchingAnalysis calculate({required KundaliChart? bride,required KundaliChart? groom})=>AdvancedMatchingAnalysis(
    brideManglik:_manglik(bride),groomManglik:_manglik(groom),
    brideSeventhHouse:_seventh(bride),groomSeventhHouse:_seventh(groom),
  );

  static ManglikAssessment _manglik(KundaliChart? chart){
    if(chart==null)return const ManglikAssessment(fromLagna:null,fromMoon:null,fromVenus:null,marsSignIndex:null,marsHouseFromLagna:null);
    KundaliGraha? mars;
    KundaliGraha? moon;
    KundaliGraha? venus;
    for(final g in chart.grahas){if(g.name=='Mars')mars=g;if(g.name=='Moon')moon=g;if(g.name=='Venus')venus=g;}
    if(mars==null)return const ManglikAssessment(fromLagna:null,fromMoon:null,fromVenus:null,marsSignIndex:null,marsHouseFromLagna:null);
    int house(int sign)=>((mars!.signIndex-sign+12)%12)+1;
    final lagnaHouse=house(chart.ascendantSignIndex);
    return ManglikAssessment(
      fromLagna:_marsHouses.contains(lagnaHouse),
      fromMoon:moon==null?null:_marsHouses.contains(house(moon.signIndex)),
      fromVenus:venus==null?null:_marsHouses.contains(house(venus.signIndex)),
      marsSignIndex:mars.signIndex,marsHouseFromLagna:lagnaHouse,
    );
  }

  static HouseCompatibilityProfile _seventh(KundaliChart? chart){
    if(chart==null)return const HouseCompatibilityProfile(seventhHouseSign:null,seventhHouseOccupants:[],seventhLord:null,seventhLordHouse:null);
    final sign=(chart.ascendantSignIndex+6)%12;
    final lord=_lords[sign];
    int? lordHouse;
    final occupants=<String>[];
    for(final g in chart.grahas){
      if(g.signIndex==sign)occupants.add(g.name);
      if(g.name==lord)lordHouse=g.houseNumber;
    }
    return HouseCompatibilityProfile(seventhHouseSign:sign,seventhHouseOccupants:occupants,seventhLord:lord,seventhLordHouse:lordHouse);
  }
}
