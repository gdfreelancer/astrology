class RashiInfo {
  const RashiInfo({
    required this.number, required this.sanskrit, required this.gujarati,
    required this.hindi, required this.english, required this.symbol,
    required this.image, required this.ruler, required this.element,
    required this.nature, required this.gender, required this.direction,
    required this.bodyPart, required this.summary, required this.personality,
    required this.strengths, required this.challenges, required this.love,
    required this.career, required this.finance, required this.family,
    required this.wellbeing, required this.nakshatras,
  });
  final int number;
  final String sanskrit, gujarati, hindi, english, symbol, image, ruler, element, nature, gender, direction, bodyPart, summary, personality, love, career, finance, family, wellbeing;
  final List<String> strengths, challenges, nakshatras;
}