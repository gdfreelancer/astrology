import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../models/kundali/kundali_chart_style.dart';

class KundaliPreferencesService {
  KundaliPreferencesService._();

  static const _storage = FlutterSecureStorage();
  static const _chartStyleKey = 'kundali_chart_style';

  static Future<KundaliChartStyle?> getChartStyle() async {
    final value = await _storage.read(key: _chartStyleKey);
    return KundaliChartStyle.fromStorage(value);
  }

  static Future<void> saveChartStyle(KundaliChartStyle style) {
    return _storage.write(key: _chartStyleKey, value: style.name);
  }

  static Future<void> clearChartStyle() {
    return _storage.delete(key: _chartStyleKey);
  }
}
