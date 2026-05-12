import '../models/user_model.dart';
import 'app_database.dart';
import 'database_helper.dart';

/// Local data source for authentication operations
class AuthLocalDataSource {
  final DatabaseHelper databaseHelper;

  AuthLocalDataSource({required this.databaseHelper});

  Future<AppDatabase> get _db => databaseHelper.database;

  Future<UserModel?> login(String username, String password) async {
    final db = await _db;
    final maps = await db.query(
      'users',
      where: 'username = ? AND password = ?',
      whereArgs: [username, password],
    );
    if (maps.isEmpty) return null;
    return UserModel.fromMap(maps.first);
  }

  Future<UserModel> register(UserModel user) async {
    final db = await _db;
    final id = await db.insert('users', user.toMap());
    return UserModel(
      id: id,
      username: user.username,
      password: user.password,
      displayName: user.displayName,
      avatarPath: user.avatarPath,
      createdAt: user.createdAt,
    );
  }

  Future<bool> isUsernameTaken(String username) async {
    final db = await _db;
    final maps = await db.query(
      'users',
      where: 'username = ?',
      whereArgs: [username],
    );
    return maps.isNotEmpty;
  }

  Future<UserModel?> getUserById(int id) async {
    final db = await _db;
    final maps = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return UserModel.fromMap(maps.first);
  }

  Future<void> updateUser(UserModel user) async {
    final db = await _db;
    await db.update(
      'users',
      user.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }
}
