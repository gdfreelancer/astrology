import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../models/birth_profile.dart';

class BirthProfileService {
  BirthProfileService._();

  static const _storageKey = 'saral_jyotish_birth_profiles_v1';

  static Future<List<BirthProfile>> getAll() async {
    final preferences = await SharedPreferences.getInstance();
    final raw = preferences.getString(_storageKey);
    if (raw == null || raw.isEmpty) return [];
    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .map((item) =>
              BirthProfile.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (_) {
      // Keep the app usable if a previous/corrupt local value cannot be read.
      return [];
    }
  }

  static Future<void> save(BirthProfile profile) async {
    final profiles = await getAll();
    final index = profiles.indexWhere((item) => item.id == profile.id);
    if (index < 0) {
      profiles.insert(0, profile);
    } else {
      profiles[index] = profile;
    }
    await _write(profiles);
  }

  static Future<void> delete(String id) async {
    final profiles = await getAll();
    profiles.removeWhere((item) => item.id == id);
    await _write(profiles);
  }

  static Future<void> _write(List<BirthProfile> profiles) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(
      _storageKey,
      jsonEncode(profiles.map((item) => item.toJson()).toList()),
    );
  }
}
