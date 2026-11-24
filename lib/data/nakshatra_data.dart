class NakshatraInfo {
  const NakshatraInfo(this.name, this.syllables);

  final String name;
  final List<String> syllables;
}

const nakshatras = <NakshatraInfo>[
  NakshatraInfo('Ashwini', ['Chu', 'Che', 'Cho', 'La']),
  NakshatraInfo('Bharani', ['Li', 'Lu', 'Le', 'Lo']),
  NakshatraInfo('Krittika', ['A', 'I', 'U', 'Ee']),
  NakshatraInfo('Rohini', ['O', 'Va', 'Vi', 'Vu']),
  NakshatraInfo('Mrigashira', ['Ve', 'Vo', 'Ka', 'Ki']),
  NakshatraInfo('Ardra', ['Ku', 'Gha', 'Ng', 'Chha']),
  NakshatraInfo('Punarvasu', ['Ke', 'Ko', 'Ha', 'Hi']),
  NakshatraInfo('Pushya', ['Hu', 'He', 'Ho', 'Da']),
  NakshatraInfo('Ashlesha', ['Di', 'Du', 'De', 'Do']),
  NakshatraInfo('Magha', ['Ma', 'Mi', 'Mu', 'Me']),
  NakshatraInfo('Purva Phalguni', ['Mo', 'Ta', 'Ti', 'Tu']),
  NakshatraInfo('Uttara Phalguni', ['Te', 'To', 'Pa', 'Pi']),
  NakshatraInfo('Hasta', ['Pu', 'Sha', 'Na', 'Tha']),
  NakshatraInfo('Chitra', ['Pe', 'Po', 'Ra', 'Ri']),
  NakshatraInfo('Swati', ['Ru', 'Re', 'Ro', 'Ta']),
  NakshatraInfo('Vishakha', ['Ti', 'Tu', 'Te', 'To']),
  NakshatraInfo('Anuradha', ['Na', 'Ni', 'Nu', 'Ne']),
  NakshatraInfo('Jyeshtha', ['No', 'Ya', 'Yi', 'Yu']),
  NakshatraInfo('Mula', ['Ye', 'Yo', 'Bha', 'Bhi']),
  NakshatraInfo('Purva Ashadha', ['Bhu', 'Dha', 'Pha', 'Dha']),
  NakshatraInfo('Uttara Ashadha', ['Bhe', 'Bho', 'Ja', 'Ji']),
  NakshatraInfo('Shravana', ['Ju', 'Je', 'Jo', 'Gha']),
  NakshatraInfo('Dhanishta', ['Ga', 'Gi', 'Gu', 'Ge']),
  NakshatraInfo('Shatabhisha', ['Go', 'Sa', 'Si', 'Su']),
  NakshatraInfo('Purva Bhadrapada', ['Se', 'So', 'Da', 'Di']),
  NakshatraInfo('Uttara Bhadrapada', ['Du', 'Tha', 'Jha', 'Na']),
  NakshatraInfo('Revati', ['De', 'Do', 'Cha', 'Chi']),
];

const rashiNames = <String>[
  'Mesha (Aries)',
  'Vrishabha (Taurus)',
  'Mithuna (Gemini)',
  'Karka (Cancer)',
  'Simha (Leo)',
  'Kanya (Virgo)',
  'Tula (Libra)',
  'Vrishchika (Scorpio)',
  'Dhanu (Sagittarius)',
  'Makara (Capricorn)',
  'Kumbha (Aquarius)',
  'Meena (Pisces)',
];

const rashiSymbols = <String>[
  '♈', '♉', '♊', '♋', '♌', '♍',
  '♎', '♏', '♐', '♑', '♒', '♓',
];
