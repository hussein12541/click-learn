import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class QuizDbHelper {
  static Database? _db;

  static Future<Database> get database async {
    if (_db != null) return _db!;
    String path = join(await getDatabasesPath(), 'quiz_results.db');
    _db = await openDatabase(path, version: 1, onCreate: _onCreate);
    return _db!;
  }

  static Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE quiz_results (
        quizId TEXT PRIMARY KEY,
        score INTEGER,
        total INTEGER,
        wrongQuestions TEXT,
        selectedAnswers TEXT
      )
    ''');
  }

  static Future<void> saveResult({
    required String quizId,
    required int score,
    required int total,
    required List<int> wrongIndexes,
    required List<int?> selectedAnswers,
  }) async {
    final db = await database;
    await db.insert(
      'quiz_results',
      {
        'quizId': quizId,
        'score': score,
        'total': total,
        'wrongQuestions': wrongIndexes.join(','),
        'selectedAnswers': selectedAnswers.map((e) => e?.toString() ?? '').join(','),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<Map<String, dynamic>?> getResult(String quizId) async {
    final db = await database;
    final results = await db.query(
      'quiz_results',
      where: 'quizId = ?',
      whereArgs: [quizId],
    );
    if (results.isNotEmpty) return results.first;
    return null;
  }
}
