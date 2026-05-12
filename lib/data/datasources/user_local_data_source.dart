import 'package:shared_preferences/shared_preferences.dart';

abstract class UserLocalDataSource {
  Future<void> cacheUserId(int userId);
  Future<int?> getCachedUserId();
  Future<void> clearCache();
}

class UserLocalDataSourceImpl implements UserLocalDataSource {
  final SharedPreferences sharedPreferences;
  static const cachedUserIdKey = 'CACHED_USER_ID';

  UserLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<void> cacheUserId(int userId) async {
    await sharedPreferences.setInt(cachedUserIdKey, userId);
  }

  @override
  Future<int?> getCachedUserId() async {
    return sharedPreferences.getInt(cachedUserIdKey);
  }

  @override
  Future<void> clearCache() async {
    await sharedPreferences.remove(cachedUserIdKey);
  }
}
