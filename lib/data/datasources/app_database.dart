/// Abstract interface for database operations.
/// Implemented by DatabaseHelper on both mobile (sqflite) and web (JSON store).
abstract class AppDatabase {
  Future<List<Map<String, dynamic>>> query(
    String table, {
    bool? distinct,
    List<String>? columns,
    String? where,
    List<Object?>? whereArgs,
    String? groupBy,
    String? having,
    String? orderBy,
    int? limit,
    int? offset,
  });

  Future<int> insert(
    String table,
    Map<String, dynamic> values, {
    String? nullColumnHack,
    dynamic conflictAlgorithm,
  });

  Future<int> update(
    String table,
    Map<String, dynamic> values, {
    String? where,
    List<Object?>? whereArgs,
    dynamic conflictAlgorithm,
  });

  Future<int> delete(
    String table, {
    String? where,
    List<Object?>? whereArgs,
  });

  Future<List<Map<String, dynamic>>> rawQuery(
    String sql, [
    List<Object?>? arguments,
  ]);
}
