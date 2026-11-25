import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('English, Hindi and Gujarati translations have matching non-empty keys',
      () async {
    Future<Map<String, dynamic>> load(String locale) async {
      final source = await rootBundle.loadString(
        'assets/translations/$locale.json',
      );
      return jsonDecode(source) as Map<String, dynamic>;
    }

    final english = await load('en');
    final hindi = await load('hi');
    final gujarati = await load('gu');

    expect(hindi.keys.toSet(), equals(english.keys.toSet()));
    expect(gujarati.keys.toSet(), equals(english.keys.toSet()));

    for (final translations in [english, hindi, gujarati]) {
      for (final entry in translations.entries) {
        expect(entry.value, isA<String>(), reason: entry.key);
        expect(
          (entry.value as String).trim(),
          isNotEmpty,
          reason: 'Missing translation for ${entry.key}',
        );
      }
    }
  });
}
