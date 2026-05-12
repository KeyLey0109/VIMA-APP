import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_data_source.dart';
import '../datasources/firestore_sync_service.dart';
import '../models/user_model.dart';

/// Implementation of AuthRepository
/// Falls back to Firebase when local login fails (cross-device support).
class AuthRepositoryImpl implements AuthRepository {
  final AuthLocalDataSource localDataSource;
  final FirestoreSyncService firestoreSyncService;

  AuthRepositoryImpl({
    required this.localDataSource,
    required this.firestoreSyncService,
  });

  @override
  Future<UserEntity?> login(String username, String password) async {
    // 1. Try local login first
    final localUser = await localDataSource.login(username, password);
    if (localUser != null) return localUser;

    // 2. If not found locally, try Firebase (gracefully handle offline)
    try {
      final firebaseUser =
          await firestoreSyncService.loginFromFirestore(username, password);
      if (firebaseUser == null) return null;

      // 3. Found on Firebase → create user locally so future logins are fast
      final registeredUser = await localDataSource.register(firebaseUser);
      return registeredUser;
    } catch (_) {
      // Offline or Firebase error — can't check cloud
      return null;
    }
  }

  @override
  Future<UserEntity> register(UserEntity user) async {
    final model = UserModel.fromEntity(user);
    final registeredUser = await localDataSource.register(model);

    // Sync user account to Firebase in background (non-blocking)
    final savedModel = UserModel.fromEntity(registeredUser);
    firestoreSyncService.syncUser(savedModel);

    return registeredUser;
  }

  @override
  Future<bool> isUsernameTaken(String username) async {
    return await localDataSource.isUsernameTaken(username);
  }

  @override
  Future<UserEntity?> getUserById(int id) async {
    return await localDataSource.getUserById(id);
  }

  @override
  Future<void> updateUser(UserEntity user) async {
    final model = UserModel.fromEntity(user);
    await localDataSource.updateUser(model);
    // Sync updated user info to Firebase in background (non-blocking)
    firestoreSyncService.syncUser(model);
  }
}
