class PanchangLocation {
  const PanchangLocation({
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.timeZoneId,
  });

  final String name;
  final double latitude;
  final double longitude;
  final String timeZoneId;
}

class PanchangPeriod {
  const PanchangPeriod({
    required this.name,
    required this.start,
    required this.end,
    this.category = '',
    this.description = '',
  });

  final String name;
  final DateTime start;
  final DateTime end;
  final String category;
  final String description;

  Duration get duration => end.difference(start);
}

class PanchangElement {
  const PanchangElement({
    required this.name,
    required this.value,
    required this.start,
    required this.end,
    required this.description,
    this.detail = '',
  });

  final String name;
  final String value;
  final DateTime start;
  final DateTime end;
  final String description;
  final String detail;
}

class PanchangData {
  const PanchangData({
    required this.date,
    required this.location,
    required this.sunrise,
    required this.sunset,
    required this.nextSunrise,
    required this.moonrise,
    required this.moonset,
    required this.elements,
    required this.weekday,
    required this.paksha,
    required this.lunarDay,
    required this.sunRashi,
    required this.ritu,
    required this.ayana,
    required this.rahuKaal,
    required this.yamaganda,
    required this.gulika,
    required this.abhijit,
    required this.brahma,
    required this.choghadiyaDay,
    required this.choghadiyaNight,
    required this.ayanamsha,
  });

  final DateTime date;
  final PanchangLocation location;
  final DateTime sunrise;
  final DateTime sunset;
  final DateTime nextSunrise;
  final DateTime? moonrise;
  final DateTime? moonset;
  final List<PanchangElement> elements;
  final String weekday;
  final String paksha;
  final int lunarDay;
  final String sunRashi;
  final String ritu;
  final String ayana;
  final PanchangPeriod rahuKaal;
  final PanchangPeriod yamaganda;
  final PanchangPeriod gulika;
  final PanchangPeriod abhijit;
  final PanchangPeriod brahma;
  final List<PanchangPeriod> choghadiyaDay;
  final List<PanchangPeriod> choghadiyaNight;
  final double ayanamsha;

  PanchangElement element(String name) =>
      elements.firstWhere((element) => element.name == name);
}

class PanchangObservance {
  const PanchangObservance({
    required this.date,
    required this.title,
    required this.subtitle,
    required this.category,
  });

  final DateTime date;
  final String title;
  final String subtitle;
  final String category;
}

class PanchangCalendarDay {
  const PanchangCalendarDay({
    required this.date,
    required this.tithi,
    required this.paksha,
    required this.isObservance,
  });

  final DateTime date;
  final String tithi;
  final String paksha;
  final bool isObservance;
}

class PanchangLunarEvent {
  const PanchangLunarEvent({
    required this.time,
    required this.titleKey,
    required this.detailKey,
    required this.categoryKey,
    this.rashiIndex,
  });

  /// Exact UTC instant found by numerical boundary search.
  final DateTime time;
  final String titleKey;
  final String detailKey;
  final String categoryKey;
  final int? rashiIndex;
}
