import 'package:equatable/equatable.dart';
import '../../../domain/entities/user_entity.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class Authenticated extends AuthState {
  final UserEntity user;

  const Authenticated(this.user);

  @override
  List<Object?> get props => [user];
}

class Unauthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
}

class RegisterSuccess extends AuthState {
  final UserEntity user;

  const RegisterSuccess(this.user);

  @override
  List<Object?> get props => [user];
}

class ProfileUpdated extends AuthState {
  final UserEntity user;

  const ProfileUpdated(this.user);

  @override
  List<Object?> get props => [user];
}

class PasswordChanged extends AuthState {
  final UserEntity user;

  const PasswordChanged(this.user);

  @override
  List<Object?> get props => [user];
}
