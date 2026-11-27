import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';

class RemedyDatabaseService {
  RemedyDatabaseService._();
  static final RemedyDatabaseService instance = RemedyDatabaseService._();
  Database? _database;

  Future<Database> get _db async {
    if (_database != null) return _database!;
    final root = await getDatabasesPath();
    _database = await openDatabase(
      path.join(root, 'saral_jyotish_remedies.db'),
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE mantra_progress (
            mantra_id TEXT PRIMARY KEY,
            target_count INTEGER NOT NULL,
            completed_count INTEGER NOT NULL DEFAULT 0,
            daily_count INTEGER NOT NULL DEFAULT 0,
            daily_date TEXT NOT NULL,
            updated_at TEXT NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE mantra_goals (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            mantra_id TEXT NOT NULL,
            title TEXT NOT NULL,
            target_count INTEGER NOT NULL,
            completed_count INTEGER NOT NULL DEFAULT 0,
            created_at TEXT NOT NULL,
            updated_at TEXT NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE mantra_favourites (
            mantra_id TEXT PRIMARY KEY,
            created_at TEXT NOT NULL
          )
        ''');
      },
    );
    return _database!;
  }

  Future<Map<String,int>> getDailyCounts() async {
    final today = _dateKey(DateTime.now());
    final rows = await (await _db).query('mantra_progress', where: 'daily_date = ?', whereArgs: [today]);
    return {for(final row in rows) row['mantra_id'] as String: row['daily_count'] as int};
  }

  String _dateKey(DateTime date) => '${date.year.toString().padLeft(4,'0')}-${date.month.toString().padLeft(2,'0')}-${date.day.toString().padLeft(2,'0')}';

  Future<Map<String,int>> getProgress() async {
    final rows = await (await _db).query('mantra_progress');
    return {for(final row in rows) row['mantra_id'] as String: row['completed_count'] as int};
  }

  Future<Set<String>> getFavourites() async {
    final rows = await (await _db).query('mantra_favourites');
    return rows.map((row)=>row['mantra_id'] as String).toSet();
  }

  Future<void> setProgress({required String id,required int target,required int completed,required int dailyDelta}) async {
    final db = await _db;
    final now = DateTime.now();
    final today = _dateKey(now);
    final rows = await db.query('mantra_progress', where: 'mantra_id = ?', whereArgs: [id], limit: 1);
    final old = rows.isEmpty ? null : rows.first;
    final oldDaily = old == null || old['daily_date'] != today ? 0 : (old['daily_count'] as int);
    final daily = (oldDaily + dailyDelta).clamp(0, 100000000).toInt();
    await db.insert('mantra_progress',{
      'mantra_id':id,'target_count':target,'completed_count':completed,
      'daily_count':daily,'daily_date':today,'updated_at':now.toIso8601String(),
    },conflictAlgorithm:ConflictAlgorithm.replace);
  }

  Future<List<Map<String,Object?>>> getGoals(String mantraId) async =>
      (await _db).query('mantra_goals',where:'mantra_id = ?',whereArgs:[mantraId],orderBy:'created_at DESC');

  Future<int> addGoal({required String mantraId,required String title,required int target}) async {
    final now=DateTime.now().toIso8601String();
    return (await _db).insert('mantra_goals',{
      'mantra_id':mantraId,'title':title,'target_count':target,
      'completed_count':0,'created_at':now,'updated_at':now,
    });
  }

  Future<void> updateGoal(int id,int completed) async {
    await (await _db).update('mantra_goals',{
      'completed_count':completed.clamp(0,100000000).toInt(),
      'updated_at':DateTime.now().toIso8601String(),
    },where:'id = ?',whereArgs:[id]);
  }

  Future<void> deleteGoal(int id) async =>
      (await _db).delete('mantra_goals',where:'id = ?',whereArgs:[id]);

  Future<void> setFavourite(String id,bool favourite) async {
    final db=await _db;
    if(favourite){
      await db.insert('mantra_favourites',{'mantra_id':id,'created_at':DateTime.now().toIso8601String()},conflictAlgorithm:ConflictAlgorithm.ignore);
    } else {
      await db.delete('mantra_favourites',where:'mantra_id = ?',whereArgs:[id]);
    }
  }
}
