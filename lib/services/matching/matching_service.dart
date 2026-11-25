import '../../models/birth_chart_result.dart';
import '../../models/matching/matching_person.dart';
import '../../models/matching/matching_report.dart';
import 'ashtakoota_calculator.dart';

class MatchingService {
  static MatchingReport calculate({
    required String brideName,
    required BirthChartResult bride,
    required String groomName,
    required BirthChartResult groom,
  }) {
    final kootas = AshtakootaCalculator.calculate(bride: bride, groom: groom);
    return MatchingReport(
      createdAt: DateTime.now(),
      bride: MatchingPerson(
        name: brideName.trim().isEmpty ? 'Bride' : brideName.trim(),
        role: 'Bride',
        birthDate: DateTime(bride.birthLocal.year, bride.birthLocal.month, bride.birthLocal.day),
        birthTime: _time(bride.birthLocal.hour, bride.birthLocal.minute),
        placeName: bride.placeName,
        latitude: bride.latitude,
        longitude: bride.longitude,
        timeZoneId: bride.timeZoneId,
        rashi: bride.rashi,
        rashiSymbol: bride.rashiSymbol,
        nakshatra: bride.nakshatra,
        pada: bride.pada,
        siderealMoonLongitude: bride.siderealMoonLongitude,
        ayanamsa: bride.ayanamsa,
        nearBoundary: bride.nearBoundary,
        kundaliChart: bride.kundaliChart,
      ),
      groom: MatchingPerson(
        name: groomName.trim().isEmpty ? 'Groom' : groomName.trim(),
        role: 'Groom',
        birthDate: DateTime(groom.birthLocal.year, groom.birthLocal.month, groom.birthLocal.day),
        birthTime: _time(groom.birthLocal.hour, groom.birthLocal.minute),
        placeName: groom.placeName,
        latitude: groom.latitude,
        longitude: groom.longitude,
        timeZoneId: groom.timeZoneId,
        rashi: groom.rashi,
        rashiSymbol: groom.rashiSymbol,
        nakshatra: groom.nakshatra,
        pada: groom.pada,
        siderealMoonLongitude: groom.siderealMoonLongitude,
        ayanamsa: groom.ayanamsa,
        nearBoundary: groom.nearBoundary,
        kundaliChart: groom.kundaliChart,
      ),
      kootas: kootas,
      calculationVersion: AshtakootaCalculator.calculationVersion,
    );
  }

  static String _time(int hour, int minute) {
    final h = hour % 12 == 0 ? 12 : hour % 12;
    return '$h:${minute.toString().padLeft(2, '0')} ${hour >= 12 ? 'PM' : 'AM'}';
  }
}
