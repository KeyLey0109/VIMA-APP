import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class LoginRequested extends AuthEvent {
  final String username;
  final String password;

  const LoginRequested({required this.username, required this.password});

  @override
  List<Object?> get props => [username, password];
}

class RegisterRequested extends AuthEvent {
  final String username;
  final String password;
  final String? displayName;

  const RegisterRequested({
    required this.username,
    required this.password,
    this.displayName,
  });

  @override
  List<Object?> get props => [username, password, displayName];
}

class LogoutRequested extends AuthEvent {}

class CheckAuthStatus extends AuthEvent {}

class UpdateUserRequested extends AuthEvent {
  final String? displayName;
  final String? avatarPath;

  const UpdateUserRequested({this.displayName, this.avatarPath});

  @override
  List<Object?> get props => [displayName, avatarPath];
}

class ChangePasswordRequested extends AuthEvent {
  final String currentPassword;
  final String newPassword;

  const ChangePasswordRequested({
    required this.currentPassword,
    required this.newPassword,
  });

  @override
  List<Object?> get props => [currentPassword, newPassword];
}
