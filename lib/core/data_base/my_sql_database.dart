import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart' as sqlDatabase;

import '../constant/constant.dart';
import 'crud.dart';

class MySqlDataBase extends CRUD {
  Database? _db;

  Future<Database?> getDatabase() async {
    if (_db == null || !_db!.isOpen) {
      await _initDatabase();
    }
    return _db;
  }

  Future<void> _initDatabase() async {
    String databasePath = await sqlDatabase.getDatabasesPath();
    String databaseName = "e_learning.db";
    String realDatabasePath = join(databasePath, databaseName);
    int version = 1;

    _db = await sqlDatabase.openDatabase(
      realDatabasePath,
      version: version,
      onCreate: _onCreate,
      onOpen: (db) async {
      await db.execute('PRAGMA foreign_keys = ON;');  // ✅ تأكيد تفعيل المفاتيح الخارجية
    },
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    /////////////////////////storiesTable/////////////////////////////////////
    await db.execute(
        "CREATE TABLE IF NOT EXISTS ${kStoryTableName}( id TEXT PRIMARY KEY)");


  }

  @override
  Future<bool> delete(
      {required String tableName,
      required String id,
      required String ColumnIDName}) async {
    final db = await getDatabase();
    int deleted = await db!.delete(
      tableName,
      where: "$ColumnIDName = ?",
      whereArgs: [id],
    );
    return deleted > 0;
  }

  @override
  Future<bool> insert(
      {required String tableName, required Map<String, dynamic> values}) async {
    final db = await getDatabase();
    int inserted = await db!.insert(tableName, values);
    return inserted > 0;
  }
  Future<int> insertReturnedId(
      {required String tableName, required Map<String, dynamic> values}) async {
    final db = await getDatabase();
    int inserted = await db!.insert(tableName, values);
    return inserted ;
  }

  @override
  Future<List<Map<String, Object?>>> select({required String tableName,required String? where}) async {
    final db = await getDatabase();
    if (where == null) {
      return await db!.query(tableName);
    } else {
      return await db!.query(tableName, where: where);
    }

  }

  @override
  // Future<List<Map<String, Object?>>> search(
  //     {required String tableName, required String searchWord , }) async {
  //   final db = await getDatabase();
  //   return await db!.query(tableName,
  //       where: "${ConstValue.kEducationStagesColumnName} LIKE ? AND ${ConstValue.kEducationStagesColumnStatus}==1",
  //       whereArgs: ['%$searchWord%']);
  // }

  @override
  Future<bool> update(
      {required String tableName,
      required String ColumnIDName,
      required String id,
      required Map<String, dynamic> values}) async {
    final db = await getDatabase();
    int updated = await db!.update(
      tableName,
      values,
      where: "$ColumnIDName = ?",
      whereArgs: [id],
    );
    return updated > 0;
  }

  @override
  Future<List<Map<String, Object?>>> selectUsingQuery({
    required String query,
    List<Object?>? arguments, // أضف هذا
  }) async {
    final db = await getDatabase();
    return await db!.rawQuery(query, arguments);
  }

}
