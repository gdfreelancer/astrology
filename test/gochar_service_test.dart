import 'package:flutter_test/flutter_test.dart';
import 'package:astrology/models/kundali/kundali_graha.dart';
import 'package:astrology/services/gochar_service.dart';

void main(){
  test('Sade Sati identifies rising, peak, setting and inactive signs',(){
    expect(GocharService.sadeSati(natalMoonSignIndex:4,transitSaturnSignIndex:3).phase,0);
    expect(GocharService.sadeSati(natalMoonSignIndex:4,transitSaturnSignIndex:4).phase,1);
    expect(GocharService.sadeSati(natalMoonSignIndex:4,transitSaturnSignIndex:5).phase,2);
    expect(GocharService.sadeSati(natalMoonSignIndex:4,transitSaturnSignIndex:6).isActive,false);
  });
  test('Yoga detection returns no yoga for an empty chart',(){
    const chart=KundaliChart(ascendantLongitude:0,ascendantSignIndex:0,midheavenLongitude:270,bhavas:[],grahas:[]);
    expect(GocharService.detectYogas(chart),isEmpty);
  });
}
