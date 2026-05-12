import '../../domain/entities/user_entity.dart';

/// Abstract repository for authentication
abstract class AuthRepository {
  Future<UserEntity?> login(String username, String password);
  Future<UserEntity> register(UserEntity user);
  Future<bool> isUsernameTaken(String username);
  Future<UserEntity?> getUserById(int id);
  Future<void> updateUser(UserEntity user);
}
