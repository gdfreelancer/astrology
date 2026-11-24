enum KundaliChartStyle {
  northIndian,
  southIndian,
  eastIndian;

  String get label {
    switch (this) {
      case KundaliChartStyle.northIndian:
        return 'North Indian';
      case KundaliChartStyle.southIndian:
        return 'South Indian';
      case KundaliChartStyle.eastIndian:
        return 'East Indian';
    }
  }

  String get description {
    switch (this) {
      case KundaliChartStyle.northIndian:
        return 'Fixed houses in a diamond-shaped chart.';
      case KundaliChartStyle.southIndian:
        return 'Fixed zodiac signs in a square layout.';
      case KundaliChartStyle.eastIndian:
        return 'Traditional regional square chart layout.';
    }
  }

  static KundaliChartStyle? fromStorage(String? value) {
    for (final style in values) {
      if (style.name == value) return style;
    }
    return null;
  }
}
