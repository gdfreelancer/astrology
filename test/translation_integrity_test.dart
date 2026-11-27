import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('English, Hindi and Gujarati translation assets have identical keys', () async {
    const locales = ['en', 'hi', 'gu'];
    final decoded = <String, Map<String, dynamic>>{};

    for (final locale in locales) {
      final raw = await rootBundle.loadString('assets/translations/$locale.json');
      final value = jsonDecode(raw);
      expect(value, isA<Map<String, dynamic>>(), reason: '$locale must be a JSON object');
      decoded[locale] = value as Map<String, dynamic>;
    }

    final englishKeys = decoded['en']!.keys.toSet();
    for (final locale in locales.skip(1)) {
      expect(decoded[locale]!.keys.toSet(), equals(englishKeys),
          reason: '$locale must contain exactly the English translation keys');
    }
  });

  test('all translation values are non-empty strings', () async {
    for (final locale in locales) {
      final raw = await rootBundle.loadString('assets/translations/$locale.json');
      final translations = jsonDecode(raw) as Map<String, dynamic>;
      for (final entry in translations.entries) {
        expect(entry.value, isA<String>(),
            reason: '$locale.${entry.key} must be a string');
        expect((entry.value as String).trim(), isNotEmpty,
            reason: '$locale.${entry.key} must not be empty');
      }
    }
  });
}

const locales = ['en', 'hi', 'gu'];
