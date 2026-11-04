import 'package:admitly/features/auth/domain/entities/user_entity.dart';
import 'package:equatable/equatable.dart';

abstract class AuthState extends Equatable {
  const AuthState();
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class AuthAuthenticated extends AuthState {
  const AuthAuthenticated(this.user);
  final UserEntity user;

  @override
  List<Object?> get props => [user];
}

class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

class AuthError extends AuthState {
  const AuthError(this.message);
  final String message;

  @override
  List<Object?> get props => [message];
}

class AuthBiometricRequired extends AuthState {
  const AuthBiometricRequired(this.user);
  final UserEntity user;

  @override
  List<Object?> get props => [user];
}

class AuthBiometricSetupAvailable extends AuthState {
  const AuthBiometricSetupAvailable(this.user);
  final UserEntity user;

  @override
  List<Object?> get props => [user];
}

class AuthPendingVerification extends AuthState {
  const AuthPendingVerification(this.user);
  final UserEntity user;

  @override
  List<Object?> get props => [user];
}

class AuthPasswordResetSent extends AuthState {
  const AuthPasswordResetSent();
}

class AuthProfileUpdated extends AuthState {
  const AuthProfileUpdated(this.user);
  final UserEntity user;

  @override
  List<Object?> get props => [user];
}
