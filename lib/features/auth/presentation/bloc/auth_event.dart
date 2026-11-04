import 'package:admitly/features/auth/domain/entities/user_entity.dart';
import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();
  @override
  List<Object?> get props => [];
}

class AuthCheckRequested extends AuthEvent {
  const AuthCheckRequested();
}

class AuthLoginRequested extends AuthEvent {
  const AuthLoginRequested({required this.email, required this.password});
  final String email;
  final String password;

  @override
  List<Object?> get props => [email, password];
}

class AuthRegisterRequested extends AuthEvent {
  const AuthRegisterRequested({
    required this.email,
    required this.password,
    required this.name,
    required this.role,
  });
  final String email;
  final String password;
  final String name;
  final UserRole role;

  @override
  List<Object?> get props => [email, password, name, role];
}

class AuthGoogleSignInRequested extends AuthEvent {
  const AuthGoogleSignInRequested();
}

class AuthLogoutRequested extends AuthEvent {
  const AuthLogoutRequested();
}

class AuthBiometricLoginRequested extends AuthEvent {
  const AuthBiometricLoginRequested(this.user);
  final UserEntity user;

  @override
  List<Object?> get props => [user];
}

class AuthBiometricSetupRequested extends AuthEvent {
  const AuthBiometricSetupRequested({required this.user, required this.enable});
  final UserEntity user;
  final bool enable;

  @override
  List<Object?> get props => [user, enable];
}

class AuthCheckVerificationRequested extends AuthEvent {
  const AuthCheckVerificationRequested(this.user);
  final UserEntity user;

  @override
  List<Object?> get props => [user];
}

class AuthPasswordResetRequested extends AuthEvent {
  const AuthPasswordResetRequested(this.email);
  final String email;

  @override
  List<Object?> get props => [email];
}

class AuthProfileUpdateRequested extends AuthEvent {
  const AuthProfileUpdateRequested({required this.uid, required this.name});
  final String uid;
  final String name;

  @override
  List<Object?> get props => [uid, name];
}
