import 'package:flutter_test/flutter_test.dart';
import 'package:astrology/utils/astrology_input_validator.dart';

void main() {
  group('AstrologyInputValidator', () {
    test('accepts valid geographic coordinates', () {
      expect(
        () => AstrologyInputValidator.validateCoordinates(
          latitude: 23.0225,
          longitude: 72.5714,
        ),
        returnsNormally,
      );
      expect(
        () => AstrologyInputValidator.validateCoordinates(
          latitude: -90,
          longitude: 180,
        ),
        returnsNormally,
      );
    });

    test('rejects invalid or non-finite coordinates', () {
      expect(
        () => AstrologyInputValidator.validateCoordinates(
          latitude: 90.01,
          longitude: 0,
        ),
        throwsArgumentError,
      );
      expect(
        () => AstrologyInputValidator.validateCoordinates(
          latitude: 0,
          longitude: -180.01,
        ),
        throwsArgumentError,
      );
      expect(
        () => AstrologyInputValidator.validateCoordinates(
          latitude: double.nan,
          longitude: 0,
        ),
        throwsArgumentError,
      );
    });

    test('validates local clock fields without changing valid values', () {
      expect(
        () => AstrologyInputValidator.validateLocalBirthTime(
          hour: 0,
          minute: 0,
        ),
        returnsNormally,
      );
      expect(
        () => AstrologyInputValidator.validateLocalBirthTime(
          hour: 23,
          minute: 59,
        ),
        returnsNormally,
      );
      expect(
        () => AstrologyInputValidator.validateLocalBirthTime(
          hour: 24,
          minute: 0,
        ),
        throwsRangeError,
      );
      expect(
        () => AstrologyInputValidator.validateLocalBirthTime(
          hour: 12,
          minute: 60,
        ),
        throwsRangeError,
      );
    });

    test('requires a non-empty time-zone ID', () {
      expect(
        () => AstrologyInputValidator.validateTimeZoneId('Asia/Kolkata'),
        returnsNormally,
      );
      expect(
        () => AstrologyInputValidator.validateTimeZoneId('  '),
        throwsArgumentError,
      );
    });
  });
}
