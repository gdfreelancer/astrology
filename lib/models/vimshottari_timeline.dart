class VimshottariPeriod {
  const VimshottariPeriod({
    required this.planet,
    required this.years,
    required this.start,
    required this.end,
  });

  final String planet;
  final int years;
  final DateTime start;
  final DateTime end;

  bool contains(DateTime date) =>
      !date.isBefore(start) && date.isBefore(end);
}

class VimshottariTimeline {
  const VimshottariTimeline({
    required this.birthNakshatra,
    required this.birthNakshatraLord,
    required this.balanceAtBirthYears,
    required this.mahadashas,
    required this.antardashas,
  });

  final String birthNakshatra;
  final String birthNakshatraLord;
  final double balanceAtBirthYears;
  final List<VimshottariPeriod> mahadashas;
  final List<VimshottariPeriod> antardashas;

  VimshottariPeriod? mahadashaAt(DateTime date) =>
      _periodAt(mahadashas, date);
  VimshottariPeriod? antardashaAt(DateTime date) =>
      _periodAt(antardashas, date);

  static VimshottariPeriod? _periodAt(
    List<VimshottariPeriod> periods,
    DateTime date,
  ) {
    for (final period in periods) {
      if (period.contains(date)) return period;
    }
    return null;
  }
}
