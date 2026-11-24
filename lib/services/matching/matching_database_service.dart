import 'dart:convert';

import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';

import '../../models/matching/matching_report.dart';

class MatchingDatabaseService {
  MatchingDatabaseService._();
  static final MatchingDatabaseService instance = MatchingDatabaseService._();

  Database? _database;

  Future<Database> get _db async {
    if (_database != null) return _database!;
    final root = await getDatabasesPath();
    _database = await openDatabase(
      path.join(root, 'astrology_matching.db'),
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE matching_reports (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT NOT NULL,
            total_points REAL NOT NULL,
            created_at TEXT NOT NULL,
            payload TEXT NOT NULL
          )
        ''');
      },
    );
    return _database!;
  }

  Future<int> save(MatchingReport report) async {
    final db = await _db;
    return db.insert('matching_reports', {
      'title': '${report.bride.name} & ${report.groom.name}',
      'total_points': report.totalPoints,
      'created_at': report.createdAt.toIso8601String(),
      'payload': jsonEncode(report.toJson()),
    });
  }

  Future<List<MatchingReport>> getRecent({int limit = 30}) async {
    final db = await _db;
    final rows = await db.query('matching_reports', orderBy: 'created_at DESC', limit: limit);
    return rows.map((row) => MatchingReport.fromJson(
      jsonDecode(row['payload'] as String) as Map<String, dynamic>,
      id: row['id'] as int,
    )).toList();
  }

  Future<void> delete(int id) async {
    final db = await _db;
    await db.delete('matching_reports', where: 'id = ?', whereArgs: [id]);
  }
}
