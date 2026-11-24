import '../../data/nakshatra_data.dart';
import '../../models/birth_chart_result.dart';
import '../../models/matching/koota_result.dart';

class AshtakootaCalculator {
  static const calculationVersion = 'ashtakoota-baseline-1.0';

  static List<KootaResult> calculate({
    required BirthChartResult bride,
    required BirthChartResult groom,
  }) {
    final brideNak = nakshatras.indexWhere((item) => item.name == bride.nakshatra);
    final groomNak = nakshatras.indexWhere((item) => item.name == groom.nakshatra);
    final brideRashi = (bride.siderealMoonLongitude / 30).floor() % 12;
    final groomRashi = (groom.siderealMoonLongitude / 30).floor() % 12;

    if (brideNak < 0 || groomNak < 0) {
      throw StateError('Nakshatra data is missing for one of the birth charts.');
    }

    return [
      _varnaScore(_varnaRanks[brideRashi], _varnaRanks[groomRashi]),
      _vashya(brideRashi, groomRashi, bride.siderealMoonLongitude, groom.siderealMoonLongitude),
      _tara(brideNak, groomNak),
      _yoni(brideNak, groomNak),
      _grahaMaitri(brideRashi, groomRashi),
      _ganaResult(brideNak, groomNak),
      _bhakoot(brideRashi, groomRashi),
      _nadi(brideNak, groomNak),
    ];
  }

  static KootaResult _result(String key, String name, double max, double score,
      String bride, String groom, String summary, String explanation) =>
      KootaResult(
        key: key,
        name: name,
        maxPoints: max,
        points: score.clamp(0, max).toDouble(),
        brideValue: bride,
        groomValue: groom,
        summary: summary,
        explanation: explanation,
      );

  // Traditional Rashi Varna hierarchy: Brahmin > Kshatriya > Vaishya > Shudra.
  static const _varnaRanks = [3, 2, 1, 4, 3, 2, 1, 4, 3, 2, 1, 4];
  static const _varnaNames = ['Shudra', 'Vaishya', 'Kshatriya', 'Brahmin'];

  static KootaResult _varnaScore(int bride, int groom) => _result(
    'varna', 'Varna', 1, groom >= bride ? 1 : 0,
    _varnaNames[bride - 1], _varnaNames[groom - 1],
    groom >= bride ? 'Traditional Varna order is compatible' : 'Traditional Varna order differs',
    'Varna compares the traditional classifications of the Moon signs. This implementation applies the conventional groom-equal-or-higher rule; it is a traditional scoring convention, not a measure of personal worth.',
  );

  // Vashya sign groups. Sagittarius and Capricorn are split by their 15-degree halves.
  static String _vashyaGroup(int rashi, double longitude) {
    final degree = longitude % 30;
    if (rashi == 0 || rashi == 1 || (rashi == 8 && degree >= 15) || (rashi == 9 && degree < 15)) return 'Chatushpada';
    if ([2, 5, 6, 10].contains(rashi) || (rashi == 8 && degree < 15)) return 'Manava';
    if (rashi == 3 || rashi == 11 || (rashi == 9 && degree >= 15)) return 'Jalachara';
    if (rashi == 4) return 'Vanachara';
    return 'Keeta';
  }

  static const _vashyaGroups = ['Chatushpada', 'Manava', 'Jalachara', 'Vanachara', 'Keeta'];
  static const _vashyaMatrix = [
    [2.0, 1.0, 1.0, 0.5, 0.0],
    [1.0, 2.0, 1.0, 0.0, 0.0],
    [1.0, 1.0, 2.0, 0.5, 0.0],
    [0.5, 0.0, 0.5, 2.0, 0.0],
    [0.0, 0.0, 0.0, 0.0, 2.0],
  ];

  static KootaResult _vashya(int bride, int groom, double brideLongitude, double groomLongitude) {
    final a = _vashyaGroup(bride, brideLongitude);
    final b = _vashyaGroup(groom, groomLongitude);
    final score = _vashyaMatrix[_vashyaGroups.indexOf(a)][_vashyaGroups.indexOf(b)];
    return _result('vashya', 'Vashya', 2, score, a, b,
      score >= 1.5 ? 'Favorable traditional Vashya pairing' : 'Partial Vashya compatibility',
      'Vashya compares traditional sign groups associated with mutual influence. Sign groups are used as a baseline; regional tables and boundary conventions can differ.');
  }

  static const _taraGood = {2, 4, 6, 8, 0};

  static KootaResult _tara(int bride, int groom) {
    final forward = ((groom - bride + 27) % 27) + 1;
    final reverse = ((bride - groom + 27) % 27) + 1;
    final a = forward % 9;
    final b = reverse % 9;
    final goodA = _taraGood.contains(a);
    final goodB = _taraGood.contains(b);
    final score = (goodA ? 1.5 : 0) + (goodB ? 1.5 : 0);
    return _result('tara', 'Tara', 3, score, 'Tara $forward', 'Tara $reverse',
      score == 3 ? 'Both Tara directions are favorable' : score == 0 ? 'Both Tara directions are challenging' : 'One Tara direction is favorable',
      'Tara evaluates the distance between the two birth Nakshatras in both directions. Sampat, Kshema, Sadhaka, Mitra and Parama Mitra are treated as favorable in this scoring convention.');
  }

  static const _yoniAnimals = [
    'Horse', 'Elephant', 'Sheep', 'Serpent', 'Serpent', 'Dog', 'Cat',
    'Sheep', 'Cat', 'Rat', 'Rat', 'Cow', 'Buffalo', 'Tiger', 'Buffalo',
    'Tiger', 'Deer', 'Deer', 'Dog', 'Monkey', 'Mongoose', 'Monkey',
    'Lion', 'Horse', 'Lion', 'Cow', 'Elephant',
  ];
  static const _yoniEnemies = {
    'Horse|Buffalo', 'Elephant|Lion', 'Sheep|Monkey',
    'Serpent|Mongoose', 'Dog|Deer', 'Cat|Rat', 'Cow|Tiger',
  };

  static KootaResult _yoni(int bride, int groom) {
    final a = _yoniAnimals[bride];
    final b = _yoniAnimals[groom];
    final pair = [a, b]..sort();
    final enemy = _yoniEnemies.contains(pair.join('|'));
    final score = a == b ? 4.0 : enemy ? 0.0 : 2.0;
    return _result('yoni', 'Yoni', 4, score, a, b,
      a == b ? 'Same Yoni classification' : enemy ? 'Traditional Yoni enemy pairing' : 'Neutral Yoni pairing',
      'Yoni compares the traditional animal symbols assigned to Nakshatras. This baseline awards full points for the same animal, zero for listed enemy pairs and partial points otherwise; some regional scoring tables distinguish additional friendly relationships.');
  }

  static const _planetLords = ['Mars', 'Venus', 'Mercury', 'Moon', 'Sun', 'Mercury', 'Venus', 'Mars', 'Jupiter', 'Saturn', 'Saturn', 'Jupiter'];
  static const _friends = {
    'Sun': ['Moon', 'Mars', 'Jupiter'],
    'Moon': ['Sun', 'Mercury'],
    'Mars': ['Sun', 'Moon', 'Jupiter'],
    'Mercury': ['Sun', 'Venus'],
    'Jupiter': ['Sun', 'Moon', 'Mars'],
    'Venus': ['Mercury', 'Saturn'],
    'Saturn': ['Mercury', 'Venus'],
  };
  static const _enemies = {
    'Sun': ['Venus', 'Saturn'],
    'Moon': <String>[],
    'Mars': ['Mercury'],
    'Mercury': ['Moon'],
    'Jupiter': ['Mercury', 'Venus'],
    'Venus': ['Sun', 'Moon'],
    'Saturn': ['Sun', 'Moon', 'Mars'],
  };

  static int _relationship(String a, String b) {
    if (a == b) return 1;
    if ((_friends[a] ?? []).contains(b)) return 1;
    if ((_enemies[a] ?? []).contains(b)) return -1;
    return 0;
  }

  static KootaResult _grahaMaitri(int bride, int groom) {
    final a = _planetLords[bride];
    final b = _planetLords[groom];
    final ab = _relationship(a, b);
    final ba = _relationship(b, a);
    final score = ab == 1 && ba == 1 ? 5.0
        : ab >= 0 && ba >= 0 ? (ab == 0 && ba == 0 ? 3.0 : 4.0)
        : ab == -1 && ba == -1 ? 0.0
        : (ab == -1 && ba == 0) || (ba == -1 && ab == 0) ? 1.0 : 0.5;
    return _result('graha_maitri', 'Graha Maitri', 5, score, a, b,
      score >= 4 ? 'Favorable planetary friendship' : score >= 2.5 ? 'Moderate planetary relationship' : 'Challenging planetary relationship',
      'Graha Maitri compares the natural friendship between the lords of the two Moon signs. This is a natural-friendship baseline and does not include temporary planetary relationships from full birth charts.');
  }

  static const _gana = [
    'Deva', 'Manushya', 'Rakshasa', 'Manushya', 'Deva', 'Manushya',
    'Deva', 'Deva', 'Rakshasa', 'Rakshasa', 'Manushya', 'Manushya',
    'Deva', 'Rakshasa', 'Deva', 'Rakshasa', 'Deva', 'Rakshasa',
    'Rakshasa', 'Manushya', 'Manushya', 'Deva', 'Rakshasa', 'Rakshasa',
    'Manushya', 'Manushya', 'Deva',
  ];
  static const _ganaMatrix = [
    [6.0, 5.0, 1.0],
    [5.0, 6.0, 0.0],
    [1.0, 0.0, 6.0],
  ];

  static KootaResult _ganaScore(int bride, int groom) {
    const groups = ['Deva', 'Manushya', 'Rakshasa'];
    final a = _gana[bride];
    final b = _gana[groom];
    final score = _ganaMatrix[groups.indexOf(a)][groups.indexOf(b)];
    return _result('gana', 'Gana', 6, score, a, b,
      score >= 5 ? 'Favorable Gana compatibility' : score >= 1 ? 'Mixed Gana compatibility' : 'Challenging Gana pairing',
      'Gana compares the traditional temperament groups of the birth Nakshatras: Deva, Manushya and Rakshasa. The matrix represents a commonly used baseline; some traditions apply gender-sensitive variations.');
  }

  static KootaResult _ganaResult(int bride, int groom) => _ganaScore(bride, groom);

  static KootaResult _bhakoot(int bride, int groom) {
    final distance = (groom - bride).abs();
    final dosha = [1, 4, 5, 7, 8, 11].contains(distance);
    final score = dosha ? 0.0 : 7.0;
    return _result('bhakoot', 'Bhakoot', 7, score,
      rashiNames[bride], rashiNames[groom],
      dosha ? 'Traditional Bhakoot Dosha pattern' : 'Favorable Rashi relationship',
      'Bhakoot compares the Moon-sign distance. The conventional 2/12, 5/9 and 6/8 relationships receive zero points in this baseline. Cancellation rules and regional interpretations are not evaluated here.');
  }

  static KootaResult _nadi(int bride, int groom) {
    // Explicit traditional sequence for the 27 Nakshatras (Adi/Madhya/Antya).
    const nadiByNakshatra = [
      'Adi','Madhya','Antya','Antya','Madhya','Adi','Adi','Madhya','Antya',
      'Antya','Madhya','Adi','Adi','Madhya','Antya','Antya','Madhya','Adi',
      'Adi','Madhya','Antya','Antya','Madhya','Adi','Adi','Madhya','Antya',
    ];
    final a = nadiByNakshatra[bride];
    final b = nadiByNakshatra[groom];
    final same = a == b;
    return _result('nadi', 'Nadi', 8, same ? 0 : 8, a, b,
      same ? 'Same Nadi classification' : 'Different Nadi classifications',
      'Nadi compares Adi, Madhya and Antya classifications assigned to the Nakshatras. This score does not apply Nadi Dosha cancellation rules or exceptions, which require additional traditional checks.');
  }

  static const rashiNames = [
    'Mesha (Aries)','Vrishabha (Taurus)','Mithuna (Gemini)','Karka (Cancer)',
    'Simha (Leo)','Kanya (Virgo)','Tula (Libra)','Vrishchika (Scorpio)',
    'Dhanu (Sagittarius)','Makara (Capricorn)','Kumbha (Aquarius)','Meena (Pisces)',
  ];
}
