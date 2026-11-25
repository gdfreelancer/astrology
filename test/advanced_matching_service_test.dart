import 'package:flutter_test/flutter_test.dart';
import 'package:astrology/models/kundali/kundali_graha.dart';
import 'package:astrology/services/matching/advanced_matching_service.dart';

KundaliChart chart({required int lagna,required int mars,required int moon,required int venus})=>KundaliChart(
 ascendantLongitude:lagna*30,ascendantSignIndex:lagna,midheavenLongitude:0,bhavas:[],
 grahas:[
  KundaliGraha(name:'Mars',symbol:'Ma',longitude:mars*30,signIndex:mars,houseNumber:((mars-lagna+12)%12)+1,bhavaNumber:1),
  KundaliGraha(name:'Moon',symbol:'Mo',longitude:moon*30,signIndex:moon,houseNumber:1,bhavaNumber:1),
  KundaliGraha(name:'Venus',symbol:'Ve',longitude:venus*30,signIndex:venus,houseNumber:1,bhavaNumber:1),
  KundaliGraha(name:'Jupiter',symbol:'Ju',longitude:0,signIndex:0,houseNumber:1,bhavaNumber:1),
 ]);
void main(){
 test('Manglik checks Mars from Lagna, Moon and Venus independently',(){
  final result=AdvancedMatchingService.calculate(bride:chart(lagna:0,mars:6,moon:5,venus:4),groom:null);
  expect(result.brideManglik.fromLagna,true);
  expect(result.brideManglik.fromMoon,true);
  expect(result.brideManglik.fromVenus,false);
  expect(result.groomManglik.isComplete,false);
 });
 test('7th house profile reports sign, occupants and its ruler placement',(){
  final result=AdvancedMatchingService.calculate(bride:chart(lagna:0,mars:6,moon:5,venus:4),groom:null);
  expect(result.brideSeventhHouse.seventhHouseSign,6);
  expect(result.brideSeventhHouse.seventhLord,'Venus');
 });
}
