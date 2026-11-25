import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppLocale {
  AppLocale._();

  static const supported = <Locale>[Locale('en'), Locale('hi'), Locale('gu')];
  static const _storageKey = 'app_language_code';
  static final ValueNotifier<Locale> locale = ValueNotifier(const Locale('en'));
  static final Map<String, Map<String, String>> _values = {};

  static Future<void> initialize() async {
    for (final code in ['en', 'hi', 'gu']) {
      final raw = await rootBundle.loadString('assets/translations/$code.json');
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      _values[code] = decoded.map((key, value) => MapEntry(key, value.toString()));
    }
    final preferences = await SharedPreferences.getInstance();
    final saved = preferences.getString(_storageKey) ?? 'en';
    locale.value = Locale(supported.any((item) => item.languageCode == saved) ? saved : 'en');
  }

  static Future<void> setLanguage(String code) async {
    if (!['en', 'hi', 'gu'].contains(code)) return;
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_storageKey, code);
    locale.value = Locale(code);
  }

  static String text(String key) {
    return _values[locale.value.languageCode]?[key] ??
        _values['en']?[key] ??
        key;
  }
}

extension AppTranslation on BuildContext {
  String tr(String key) => AppLocale.text(key);
}
