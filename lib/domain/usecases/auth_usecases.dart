import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository repository;

  LoginUseCase(this.repository);

  Future<UserEntity?> call(String username, String password) =>
      repository.login(username, password);
}

class RegisterUseCase {
  final AuthRepository repository;

  RegisterUseCase(this.repository);

  Future<UserEntity> call(UserEntity user) => repository.register(user);
}

class CheckUsernameUseCase {
  final AuthRepository repository;

  CheckUsernameUseCase(this.repository);

  Future<bool> call(String username) => repository.isUsernameTaken(username);
}

class GetUserByIdUseCase {
  final AuthRepository repository;

  GetUserByIdUseCase(this.repository);

  Future<UserEntity?> call(int id) => repository.getUserById(id);
}

class UpdateUserUseCase {
  final AuthRepository repository;

  UpdateUserUseCase(this.repository);

  Future<void> call(UserEntity user) => repository.updateUser(user);
}
