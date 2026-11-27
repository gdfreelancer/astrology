/// Input guards shared by astrology calculations.
///
/// These checks reject malformed inputs without changing valid historical
/// birth data or silently clamping coordinates/times.
class AstrologyInputValidator {
  AstrologyInputValidator._();

  static void validateCoordinates({
    required double latitude,
    required double longitude,
  }) {
    if (!latitude.isFinite || latitude < -90 || latitude > 90) {
      throw ArgumentError.value(latitude, 'latitude', 'Must be finite and between -90 and 90 degrees.');
    }
    if (!longitude.isFinite || longitude < -180 || longitude > 180) {
      throw ArgumentError.value(longitude, 'longitude', 'Must be finite and between -180 and 180 degrees.');
    }
  }

  static void validateLocalBirthTime({
    required int hour,
    required int minute,
  }) {
    if (hour < 0 || hour > 23) {
      throw RangeError.range(hour, 0, 23, 'hour');
    }
    if (minute < 0 || minute > 59) {
      throw RangeError.range(minute, 0, 59, 'minute');
    }
  }

  static void validateTimeZoneId(String timeZoneId) {
    if (timeZoneId.trim().isEmpty) {
      throw ArgumentError.value(timeZoneId, 'timeZoneId', 'An IANA time-zone ID is required.');
    }
  }

  static void validateDate(DateTime date) {
    if (date.year < 1 || date.year > 9999) {
      throw ArgumentError.value(date, 'date', 'Date is outside the supported range.');
    }
  }

  static double normalizeDegrees(double value) {
    if (!value.isFinite) {
      throw ArgumentError.value(value, 'value', 'Angle must be finite.');
    }
    return (value % 360 + 360) % 360;
  }
}
