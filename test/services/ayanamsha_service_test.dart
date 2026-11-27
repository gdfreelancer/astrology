import 'package:flutter_test/flutter_test.dart';
import 'package:astrology/services/astrology/ayanamsha_service.dart';

void main() {
  group('AyanamshaService', () {
    test('uses the documented J2000 mean Lahiri reference epoch', () {
      final value = AyanamshaService.lahiri(DateTime.utc(2000, 1, 1, 12));
      expect(value, closeTo(23.8570922222, 1e-8));
    });

    test('returns the same value for equivalent UTC instants', () {
      final utc = DateTime.utc(2000, 1, 1, 12);
      final localOffset = DateTime.parse('2000-01-01T17:30:00+05:30');
      expect(
        AyanamshaService.lahiri(utc),
        closeTo(AyanamshaService.lahiri(localOffset), 1e-12),
      );
    });

    test('exposes the calculation model and version', () {
      expect(AyanamshaService.systemName, contains('Lahiri'));
      expect(AyanamshaService.calculationModel, isNotEmpty);
      expect(AyanamshaService.calculationVersion, isNotEmpty);
    });
  });
}
