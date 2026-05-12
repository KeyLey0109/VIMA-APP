import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'app_database.dart';

/// Wraps a sqflite Database to satisfy the AppDatabase interface
class _SqfliteAppDatabase implements AppDatabase {
  final Database _db;
  _SqfliteAppDatabase(this._db);

  @override
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
  }) =>
      _db.query(
        table,
        distinct: distinct,
        columns: columns,
        where: where,
        whereArgs: whereArgs,
        groupBy: groupBy,
        having: having,
        orderBy: orderBy,
        limit: limit,
        offset: offset,
      );

  @override
  Future<int> insert(
    String table,
    Map<String, dynamic> values, {
    String? nullColumnHack,
    dynamic conflictAlgorithm,
  }) =>
      _db.insert(table, values,
          nullColumnHack: nullColumnHack,
          conflictAlgorithm:
              conflictAlgorithm as ConflictAlgorithm? ?? ConflictAlgorithm.abort);

  @override
  Future<int> update(
    String table,
    Map<String, dynamic> values, {
    String? where,
    List<Object?>? whereArgs,
    dynamic conflictAlgorithm,
  }) =>
      _db.update(table, values, where: where, whereArgs: whereArgs);

  @override
  Future<int> delete(
    String table, {
    String? where,
    List<Object?>? whereArgs,
  }) =>
      _db.delete(table, where: where, whereArgs: whereArgs);

  @override
  Future<List<Map<String, dynamic>>> rawQuery(
    String sql, [
    List<Object?>? arguments,
  ]) =>
      _db.rawQuery(sql, arguments);
}

/// Mobile/Desktop SQLite implementation using sqflite
class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _sqfliteDb;
  static AppDatabase? _appDb;

  DatabaseHelper._init();

  /// Returns the AppDatabase instance (platform-agnostic interface)
  Future<AppDatabase> get database async {
    if (_appDb != null) return _appDb!;
    _sqfliteDb = await _initDB('money_app.db');
    _appDb = _SqfliteAppDatabase(_sqfliteDb!);
    return _appDb!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 2,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL,
        display_name TEXT,
        avatar_path TEXT,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE budgets (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        month INTEGER NOT NULL,
        year INTEGER NOT NULL,
        amount REAL NOT NULL,
        UNIQUE(month, year)
      )
    ''');

    await db.execute('''
      CREATE TABLE transactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        amount REAL NOT NULL,
        category TEXT NOT NULL,
        date_time TEXT NOT NULL,
        image_path TEXT
      )
    ''');

    await db.execute('''
      INSERT INTO users (username, password, display_name, created_at)
      VALUES ('admin', 'admin123', 'VIMA Admin', '${DateTime.now().toIso8601String()}')
    ''');

    await db.execute('''
      CREATE INDEX idx_transactions_date_time ON transactions(date_time)
    ''');
    await db.execute('''
      CREATE UNIQUE INDEX idx_users_username ON users(username)
    ''');
  }

  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS users (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          username TEXT NOT NULL UNIQUE,
          password TEXT NOT NULL,
          display_name TEXT,
          avatar_path TEXT,
          created_at TEXT NOT NULL
        )
      ''');
    }
  }

  Future<void> close() async {
    if (_sqfliteDb != null) {
      await _sqfliteDb!.close();
      _sqfliteDb = null;
      _appDb = null;
    }
  }
}
