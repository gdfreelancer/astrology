/// Shared sidereal correction used by birth-chart and Panchang calculations.
///
/// This is the app's Lahiri/Chitrapaksha mean-ayanamsha approximation. It is
/// deliberately named as an approximation: production astronomical accuracy
/// must be validated against a licensed/appropriately-licensed ephemeris.
class AyanamshaService {
  AyanamshaService._();

  static const String systemName = 'Lahiri (Chitrapaksha)';
  static const String calculationModel = 'Mean ayanamsha polynomial';
  static const String calculationVersion = '1.0.0';

  /// Returns the approximate Lahiri ayanamsha in degrees for [date].
  static double lahiri(DateTime date) {
    final utc = date.toUtc();
    final j2000 = DateTime.utc(2000, 1, 1, 12);
    final centuries = utc.difference(j2000).inMicroseconds /
        Duration.microsecondsPerDay /
        36525.0;
    final arcSeconds = (23 * 3600 + 51 * 60 + 25.532) +
        5029.0966 * centuries +
        1.11161 * centuries * centuries;
    return arcSeconds / 3600.0;
  }
}
