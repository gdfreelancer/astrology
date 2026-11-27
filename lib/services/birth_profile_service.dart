import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/birth_profile.dart';

class BirthProfileService {
  BirthProfileService._();

  static const _storageKey = 'saral_jyotish_birth_profiles_v1';
  static const _selectedProfileKey = 'saral_jyotish_selected_birth_profile_v1';

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
    final preferences = await SharedPreferences.getInstance();
    if (preferences.getString(_selectedProfileKey) == null) {
      await preferences.setString(_selectedProfileKey, profile.id);
    }
  }

  static Future<String?> getSelectedId() async {
    final preferences = await SharedPreferences.getInstance();
    final id = preferences.getString(_selectedProfileKey);
    final profiles = await getAll();
    if (id != null && profiles.any((profile) => profile.id == id)) return id;
    if (profiles.isEmpty) return null;
    await preferences.setString(_selectedProfileKey, profiles.first.id);
    return profiles.first.id;
  }

  static Future<BirthProfile?> getSelected() async {
    final id = await getSelectedId();
    if (id == null) return null;
    final profiles = await getAll();
    for (final profile in profiles) {
      if (profile.id == id) return profile;
    }
    return null;
  }

  static Future<void> select(String id) async {
    final profiles = await getAll();
    if (!profiles.any((profile) => profile.id == id)) {
      throw ArgumentError.value(id, 'id', 'Birth profile does not exist.');
    }
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_selectedProfileKey, id);
  }

  static Future<void> delete(String id) async {
    final profiles = await getAll();
    profiles.removeWhere((item) => item.id == id);
    await _write(profiles);
    final preferences = await SharedPreferences.getInstance();
    if (preferences.getString(_selectedProfileKey) == id) {
      if (profiles.isEmpty) {
        await preferences.remove(_selectedProfileKey);
      } else {
        await preferences.setString(_selectedProfileKey, profiles.first.id);
      }
    }
  }

  static Future<void> _write(List<BirthProfile> profiles) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(
      _storageKey,
      jsonEncode(profiles.map((item) => item.toJson()).toList()),
    );
  }
}
