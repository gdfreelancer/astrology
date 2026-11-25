import 'package:shared_preferences/shared_preferences.dart';

class SavedAppLocation {
  const SavedAppLocation({
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.timeZoneId,
  });

  final String name;
  final double latitude;
  final double longitude;
  final String timeZoneId;
}

class AppPreferencesService {
  AppPreferencesService._();

  static const _timeFormatKey = 'app_time_format';
  static const _rashiKey = 'default_rashi';
  static const _locationNameKey = 'panchang_default_location_name';
  static const _latitudeKey = 'panchang_default_location_latitude';
  static const _longitudeKey = 'panchang_default_location_longitude';
  static const _timeZoneKey = 'panchang_default_time_zone';

  static Future<bool> use24HourTime() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_timeFormatKey) ?? false;
  }

  static Future<void> setUse24HourTime(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_timeFormatKey, value);
  }

  static Future<String> defaultRashi() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_rashiKey) ?? 'Mesha';
  }

  static Future<void> setDefaultRashi(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_rashiKey, value);
  }

  static Future<SavedAppLocation> defaultLocation() async {
    final prefs = await SharedPreferences.getInstance();
    return SavedAppLocation(
      name: prefs.getString(_locationNameKey) ?? 'Ahmedabad, Gujarat, India',
      latitude: prefs.getDouble(_latitudeKey) ?? 23.0225,
      longitude: prefs.getDouble(_longitudeKey) ?? 72.5714,
      timeZoneId: prefs.getString(_timeZoneKey) ?? 'Asia/Kolkata',
    );
  }

  static Future<void> setDefaultLocation(SavedAppLocation location) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_locationNameKey, location.name);
    await prefs.setDouble(_latitudeKey, location.latitude);
    await prefs.setDouble(_longitudeKey, location.longitude);
    await prefs.setString(_timeZoneKey, location.timeZoneId);
  }
}
