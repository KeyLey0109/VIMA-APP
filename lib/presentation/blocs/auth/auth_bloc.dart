import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/datasources/firestore_sync_service.dart';
import '../../../data/datasources/user_local_data_source.dart';
import '../../../domain/entities/user_entity.dart';
import '../../../domain/usecases/auth_usecases.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase loginUseCase;
  final RegisterUseCase registerUseCase;
  final CheckUsernameUseCase checkUsernameUseCase;
  final GetUserByIdUseCase getUserByIdUseCase;
  final UpdateUserUseCase updateUserUseCase;
  final UserLocalDataSource userLocalDataSource;
  final FirestoreSyncService firestoreSyncService;

  AuthBloc({
    required this.loginUseCase,
    required this.registerUseCase,
    required this.checkUsernameUseCase,
    required this.getUserByIdUseCase,
    required this.updateUserUseCase,
    required this.userLocalDataSource,
    required this.firestoreSyncService,
  }) : super(AuthInitial()) {
    on<CheckAuthStatus>(_onCheckAuthStatus);
    on<LoginRequested>(_onLogin);
    on<RegisterRequested>(_onRegister);
    on<LogoutRequested>(_onLogout);
    on<UpdateUserRequested>(_onUpdateUser);
    on<ChangePasswordRequested>(_onChangePassword);
  }

  Future<void> _onUpdateUser(
    UpdateUserRequested event,
    Emitter<AuthState> emit,
  ) async {
    if (state is Authenticated) {
      final currentUser = (state as Authenticated).user;
      final updatedUser = currentUser.copyWith(
        displayName: event.displayName ?? currentUser.displayName,
        avatarPath: event.avatarPath ?? currentUser.avatarPath,
      );

      try {
        await updateUserUseCase(updatedUser);
        emit(ProfileUpdated(updatedUser));
        emit(Authenticated(updatedUser));
      } catch (e) {
        emit(AuthError('Không thể cập nhật thông tin: ${e.toString()}'));
        emit(Authenticated(currentUser));
      }
    }
  }

  Future<void> _onChangePassword(
    ChangePasswordRequested event,
    Emitter<AuthState> emit,
  ) async {
    if (state is Authenticated) {
      final currentUser = (state as Authenticated).user;

      // Verify current password
      if (currentUser.password != event.currentPassword) {
        emit(const AuthError('Mật khẩu hiện tại không đúng'));
        emit(Authenticated(currentUser));
        return;
      }

      final updatedUser = currentUser.copyWith(password: event.newPassword);
      try {
        await updateUserUseCase(updatedUser);
        emit(PasswordChanged(updatedUser));
        emit(Authenticated(updatedUser));
      } catch (e) {
        emit(AuthError('Không thể đổi mật khẩu: ${e.toString()}'));
        emit(Authenticated(currentUser));
      }
    }
  }

  Future<void> _onCheckAuthStatus(
    CheckAuthStatus event,
    Emitter<AuthState> emit,
  ) async {
    final userId = await userLocalDataSource.getCachedUserId();
    if (userId != null) {
      final user = await getUserByIdUseCase(userId);
      if (user != null) {
        emit(Authenticated(user));
        // Background sync on app start
        _syncInBackground();
      } else {
        await userLocalDataSource.clearCache();
        emit(Unauthenticated());
      }
    } else {
      emit(Unauthenticated());
    }
  }

  Future<void> _onLogin(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await Future.delayed(const Duration(milliseconds: 800));

      final user = await loginUseCase(event.username, event.password);
      if (user != null) {
        if (user.id != null) {
          await userLocalDataSource.cacheUserId(user.id!);
          // Background sync: don't block login, run in background
          _syncInBackground();
        }
        emit(Authenticated(user));
      } else {
        emit(const AuthError('Tên đăng nhập hoặc mật khẩu không đúng'));
      }
    } catch (e) {
      emit(AuthError('Đã xảy ra lỗi: ${e.toString()}'));
    }
  }

  /// Runs Firebase sync in the background without blocking the UI.
  void _syncInBackground() {
    Future(() async {
      try {
        await firestoreSyncService.restoreDataFromFirestore();
        await firestoreSyncService.pushAllDataToFirestore();
      } catch (_) {
        // Silently fail — app works offline
      }
    });
  }

  Future<void> _onRegister(
    RegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await Future.delayed(const Duration(milliseconds: 800));

      final isTaken = await checkUsernameUseCase(event.username);
      if (isTaken) {
        emit(const AuthError('Tên đăng nhập đã tồn tại'));
        return;
      }

      final user = await registerUseCase(UserEntity(
        username: event.username,
        password: event.password,
        displayName: event.displayName ?? event.username,
        createdAt: DateTime.now(),
      ));

      if (user.id != null) {
        await userLocalDataSource.cacheUserId(user.id!);
      }

      emit(RegisterSuccess(user));
    } catch (e) {
      emit(AuthError('Đã xảy ra lỗi: ${e.toString()}'));
    }
  }

  Future<void> _onLogout(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await userLocalDataSource.clearCache();
    emit(Unauthenticated());
  }
}
