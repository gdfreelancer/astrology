import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/birth_profile.dart';

class RecentKundaliReport {
  const RecentKundaliReport({
    required this.profile,
    required this.rashi,
    required this.nakshatra,
    required this.createdAt,
  });

  final BirthProfile profile;
  final String rashi;
  final String nakshatra;
  final DateTime createdAt;

  Map<String, dynamic> toJson() => {
        'profile': profile.toJson(),
        'rashi': rashi,
        'nakshatra': nakshatra,
        'createdAt': createdAt.toIso8601String(),
      };

  factory RecentKundaliReport.fromJson(Map<String, dynamic> json) =>
      RecentKundaliReport(
        profile: BirthProfile.fromJson(
          json['profile'] as Map<String, dynamic>,
        ),
        rashi: json['rashi'] as String? ?? '',
        nakshatra: json['nakshatra'] as String? ?? '',
        createdAt: DateTime.parse(json['createdAt'] as String),
      );
}

class KundaliHistoryService {
  KundaliHistoryService._();

  static const _storageKey = 'saral_jyotish_recent_kundali_reports_v1';
  static const _maxReports = 8;

  static Future<List<RecentKundaliReport>> getRecent() async {
    final preferences = await SharedPreferences.getInstance();
    final raw = preferences.getString(_storageKey);
    if (raw == null || raw.isEmpty) return const [];
    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .map((item) => RecentKundaliReport.fromJson(
                item as Map<String, dynamic>,
              ))
          .toList(growable: false);
    } catch (_) {
      return const [];
    }
  }

  static Future<void> record(RecentKundaliReport report) async {
    final reports = await getRecent();
    reports.removeWhere((item) =>
        item.profile.id == report.profile.id &&
        item.createdAt == report.createdAt);
    reports.insert(0, report);
    if (reports.length > _maxReports) {
      reports.removeRange(_maxReports, reports.length);
    }
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(
      _storageKey,
      jsonEncode(reports.map((item) => item.toJson()).toList()),
    );
  }
}
