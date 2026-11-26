import 'package:flutter/material.dart';

class RemedyGraha {
  const RemedyGraha(this.id, this.name, this.mantra, this.count, this.deities,
      this.gem, this.weekday, this.lifeAreas, this.remedies);
  final String id, name, mantra, gem, weekday;
  final int count;
  final List<String> deities, lifeAreas, remedies;
}

class GemstoneInfo {
  const GemstoneInfo(this.id, this.name, this.hindi, this.graha, this.colour,
      this.weight, this.metal, this.finger, this.weekday, this.time,
      this.lifespan, this.avoid, this.note);
  final String id, name, hindi, graha, colour, weight, metal, finger,
      weekday, time, lifespan, avoid, note;
}

class LagnaGemstones {
  const LagnaGemstones(this.name, this.life, this.karaka, this.fortune);
  final String name, life, karaka, fortune;
}

const remedyGrahas = <RemedyGraha>[
  RemedyGraha('sun','Sun / Surya','ॐ घृणिः सूर्याय नमः',7000,'Agni · Vishnu','Ruby','Sunday','Father, authority, confidence and government matters',['Surya worship','Navagraha Shanti prayer','Sun mantra']),
  RemedyGraha('moon','Moon / Chandra','ॐ सों सोमाय नमः',11000,'Varuna · Shiva','Pearl','Monday','Mother, emotional life and mental peace',['Chandra worship','Navagraha Shanti prayer','Moon mantra']),
  RemedyGraha('mars','Mars / Mangala','ॐ अं अंगारकाय नमः',10000,'Subrahmanya','Red Coral','Tuesday','Siblings, courage, anger and action',['Mangala worship','Hanuman or Subrahmanya worship','Mars mantra']),
  RemedyGraha('mercury','Mercury / Budha','ॐ बुं बुधाय नमः',9000,'Mahavishnu · Durga','Emerald','Wednesday','Education, intellect, speech and business',['Budha worship','Mercury mantra']),
  RemedyGraha('jupiter','Jupiter / Guru','ॐ वृं बृहस्पतये नमः',19000,'Indra · Brahma','Yellow Sapphire','Thursday','Teachers, faith, finances, marriage and children',['Guru worship','Navagraha Shanti prayer','Jupiter mantra']),
  RemedyGraha('venus','Venus / Shukra','ॐ शुं शुक्राय नमः',16000,'Shachi · Lakshmi','Diamond','Friday','Relationships, comforts, vehicles and refinement',['Shukra worship','Venus mantra']),
  RemedyGraha('saturn','Saturn / Shani','ॐ शं शनैश्चराय नमः',23000,'Brahma · Bhairava','Blue Sapphire','Saturday','Work, service, responsibility and delays',['Shani worship','Shiva worship','Hanuman worship','Shani mantra']),
  RemedyGraha('rahu','Rahu','ॐ रां राहवे नमः',18000,'Bhairava · Saraswati','Hessonite','Saturday','Unconventional matters, confusion and fears',['Rahu worship','Rahu mantra']),
  RemedyGraha('ketu','Ketu','ॐ कें केतवे नमः',17000,'Ganesha','Cat’s Eye','Tuesday / Thursday','Detachment, spiritual practice and ancestral traditions',['Ketu worship','Ganesha worship','Ketu mantra']),
];

const gemstones = <GemstoneInfo>[
  GemstoneInfo('ruby','Ruby','माणिक्य','Sun','Red', '3 ratti minimum','Gold','Ring finger','Sunday','Morning','4 years','Diamond, Blue Sapphire, Hessonite','PDF p.13–14. Weight and lifespan are traditional statements, not a buying or health recommendation.'),
  GemstoneInfo('pearl','Pearl','मोती','Moon','White','3 ratti minimum','Silver','Little finger','Monday','Morning','2¼ years','Hessonite, Cat’s Eye','PDF p.13–14. Confirm quality and tradition-specific rules independently.'),
  GemstoneInfo('coral','Red Coral','मूंगा','Mars','Red','6 ratti minimum','Silver','Ring finger','Tuesday','Morning','3 years','Diamond, Blue Sapphire, Hessonite','PDF p.13–14.'),
  GemstoneInfo('emerald','Emerald','पन्ना','Mercury','Green','4 ratti minimum','Gold','Little finger','Wednesday','Morning','4 years','Pearl','PDF p.13–14.'),
  GemstoneInfo('yellow_sapphire','Yellow Sapphire','पुखराज','Jupiter','Yellow','4 ratti minimum','Gold','Index finger','Thursday','Morning','4 years','Diamond, Blue Sapphire','PDF p.13–14.'),
  GemstoneInfo('diamond','Diamond','हीरा','Venus','Clear','Not legible in source','Silver / Platinum','Little finger','Friday','Morning','7 years','Ruby, Red Coral, Yellow Sapphire','PDF p.13–14. Source weight entry is unclear; intentionally not inferred.'),
  GemstoneInfo('blue_sapphire','Blue Sapphire','नीलम','Saturn','Blue','4 ratti minimum','Panchdhatu / Silver','Middle finger','Saturday','Evening','5 years','Ruby, Red Coral, Yellow Sapphire','PDF p.13–14. The source also mentions iron ring as a Shani remedy on p.22.'),
  GemstoneInfo('hessonite','Hessonite','गोमेद','Rahu','Honey brown','5 ratti minimum','Ashtadhatu / Silver','Middle finger','Saturday','Sunset','3 years','Ruby, Pearl, Red Coral','PDF p.13–14.'),
  GemstoneInfo('cats_eye','Cat’s Eye','लहसुनिया','Ketu','Greenish / chatoyant','6 ratti minimum','Silver','Ring finger','Tuesday / Thursday','Sunset','3 years','Pearl','PDF p.13–14.'),
];

const lagnaGemstones = <LagnaGemstones>[
  LagnaGemstones('Aries','Red Coral','Ruby','Yellow Sapphire'),
  LagnaGemstones('Taurus','Diamond','Emerald','Blue Sapphire'),
  LagnaGemstones('Gemini','Emerald','Diamond','Blue Sapphire'),
  LagnaGemstones('Cancer','Pearl','Red Coral','Yellow Sapphire'),
  LagnaGemstones('Leo','Ruby','Yellow Sapphire','Red Coral'),
  LagnaGemstones('Virgo','Emerald','Blue Sapphire','Diamond'),
  LagnaGemstones('Libra','Diamond','Blue Sapphire','Emerald'),
  LagnaGemstones('Scorpio','Red Coral','Yellow Sapphire','Pearl'),
  LagnaGemstones('Sagittarius','Yellow Sapphire','Red Coral','Ruby'),
  LagnaGemstones('Capricorn','Blue Sapphire','Diamond','Emerald'),
  LagnaGemstones('Aquarius','Blue Sapphire','Emerald','Diamond'),
  LagnaGemstones('Pisces','Yellow Sapphire','Pearl','Red Coral'),
];

const shaniDhaiya = <String, List<String>>{
  'Aries':['Neutral','Unfavourable','Favourable'],
  'Taurus':['Unfavourable','Favourable','Favourable'],
  'Gemini':['Favourable','Favourable','Unfavourable'],
  'Cancer':['Favourable','Unfavourable','Unfavourable'],
  'Leo':['Unfavourable','Unfavourable','Favourable'],
  'Virgo':['Unfavourable','Favourable','Favourable'],
  'Libra':['Favourable','Favourable','Unfavourable'],
  'Scorpio':['Favourable','Unfavourable','Neutral'],
  'Sagittarius':['Unfavourable','Neutral','Favourable'],
  'Capricorn':['Neutral','Favourable','Favourable'],
  'Aquarius':['Favourable','Favourable','Neutral'],
  'Pisces':['Favourable','Neutral','Unfavourable'],
};

const navagrahaShanti = 'ब्रह्मा मुरारिस्त्रिपुरान्तकारी भानुः शशी भूमिसुतो बुधश्च।\nगुरुश्च शुक्रः शनिराहुकेतवः सर्वे ग्रहाः शान्तिकरा भवन्तु॥';
const navagrahaMeaning = 'May Brahma, Vishnu, Shiva, the Sun, Moon, Mars, Mercury, Jupiter, Venus, Saturn, Rahu and Ketu bring peace and well-being.';

const navratnaArrangement = <List<String>>[
  ['Emerald (Mercury)','Diamond (Venus)','Pearl (Moon)'],
  ['Yellow Sapphire (Jupiter)','Ruby (Sun)','Red Coral (Mars)'],
  ['Cat’s Eye (Ketu)','Blue Sapphire (Saturn)','Hessonite (Rahu)'],
];

const rudrakshaNames = <String>[
  'Gauri Shankar','1 Mukhi','2 Mukhi','3 Mukhi','4 Mukhi','5 Mukhi',
  '6 Mukhi','7 Mukhi','8 Mukhi','9 Mukhi','10 Mukhi','11 Mukhi',
  '12 Mukhi','13 Mukhi','14 Mukhi','15 Mukhi',
];

const shaniRemedies = <String>[
  'Shani worship','Shani mantra chanting','Shani Yantra worship',
  'Shani Peeda Nivarak Yantra reference','Rudraksha reference',
  'Shiva worship and “ॐ नमः शिवाय” chanting','Hanuman worship',
  'Prayer and responsible conduct','Avoid harmful or unethical actions',
];

const kaalSarpRemedies = <String>[
  'Rahu and Ketu worship','Rahu and Ketu mantra chanting',
  'The PDF describes lighting a sesame-oil lamp before a Kaal Sarp Yantra and chanting “ॐ नमः शिवाय” 21,000 times.',
  'Krishna worship and “ॐ नमो भगवते वासुदेवाय” 108 times daily',
  'Nav Nag Stotra recitation','Shiva worship and offering water to the Shivling',
  'Sixteen Monday observances','Nag Panchami worship',
  'Shravan month Shiva Abhishek',
];

const remedyCautions = <String>[
  'The PDF presents traditional beliefs, not scientific or medical evidence.',
  'Never use a gemstone, mantra or ritual as a treatment or substitute for medical, mental-health, financial or legal advice.',
  'The PDF itself advises against gemstones of Maraka, Badhaka, debilitated or otherwise inauspicious planets. A Lagna table alone is not a personal recommendation.',
  'The source has incomplete or unclear entries. The diamond weight is not legible and is intentionally left unspecified.',
  'The source gives illustrations, but not detailed Mukhi-wise Rudraksha benefits or a complete set of nine individual planetary Yantras.',
];
