import 'package:flutter_test/flutter_test.dart';

import '../../lib/models/kundali/kundali_graha.dart';
import '../../lib/services/matching/advanced_matching_service.dart';

KundaliGraha graha(String name, int sign, {double degree = 10}) {
  return KundaliGraha(
    name: name,
    symbol: name.substring(0, 1),
    longitude: sign * 30 + degree,
    signIndex: sign,
    houseNumber: ((sign - 0 + 12) % 12) + 1,
    bhavaNumber: ((sign - 0 + 12) % 12) + 1,
  );
}

KundaliChart chart(List<KundaliGraha> grahas, {int ascendant = 0}) {
  return KundaliChart(
    ascendantLongitude: ascendant * 30 + 10,
    ascendantSignIndex: ascendant,
    midheavenLongitude: 180,
    bhavas: const [],
    grahas: grahas,
  );
}

void main() {
  group('AdvancedMatchingService', () {
    test('reports Manglik reference points independently', () {
      final result = AdvancedMatchingService.calculate(
        bride: chart([
          graha('Mars', 3),
          graha('Moon', 2),
          graha('Venus', 1),
          graha('Jupiter', 11),
        ]),
        groom: null,
      );

      expect(result.brideManglik.fromLagna, isTrue);
      expect(result.brideManglik.fromMoon, isTrue);
      expect(result.brideManglik.fromVenus, isFalse);
      expect(result.groomManglik.isComplete, isFalse);
    });

    test('returns mitigation indicators without declaring cancellation', () {
      final result = AdvancedMatchingService.calculate(
        bride: chart([
          graha('Mars', 0),
          graha('Moon', 2),
          graha('Venus', 2),
          graha('Jupiter', 6),
        ], ascendant: 2),
        groom: null,
      );

      expect(result.brideManglik.mitigationIndicators, contains('mars_own_sign'));
      expect(result.brideManglik.hasAnyIndicator, isFalse);
    });

    test('analyses seventh-house lord dignity and graha drishti', () {
      final result = AdvancedMatchingService.calculate(
        bride: chart([
          graha('Venus', 1),
          graha('Mars', 3),
          graha('Jupiter', 0),
          graha('Moon', 2),
        ]),
        groom: null,
      );
      final profile = result.brideSeventhHouse;

      expect(profile.seventhHouseSign, 6);
      expect(profile.seventhLord, 'Venus');
      expect(profile.seventhLordDignity, 'own');
      expect(profile.seventhLordHouse, 2);
      expect(profile.seventhHouseAspectedBy, containsAll(['Mars', 'Jupiter']));
    });

    test('creates a descriptive Navamsa seventh-house profile', () {
      final result = AdvancedMatchingService.calculate(
        bride: chart([
          graha('Venus', 1),
          graha('Jupiter', 0),
          graha('Mars', 3),
          graha('Moon', 2),
          graha('Sun', 4),
          graha('Mercury', 5),
          graha('Saturn', 9),
        ]),
        groom: null,
      );

      final d9 = result.brideNavamsa;
      expect(d9, isNotNull);
      expect(d9!.ascendantSign, inInclusiveRange(0, 11));
      expect(d9.seventhHouseSign, inInclusiveRange(0, 11));
      expect(d9.seventhLord, isNotEmpty);
      expect(d9.seventhHouseOccupants, isA<List<String>>());
    });

    test('does not invent profiles when a saved report lacks D1 chart data', () {
      final result = AdvancedMatchingService.calculate(bride: null, groom: null);

      expect(result.brideNavamsa, isNull);
      expect(result.groomNavamsa, isNull);
      expect(result.brideSeventhHouse.seventhHouseSign, isNull);
      expect(result.brideManglik.fromLagna, isNull);
    });
  });
}
