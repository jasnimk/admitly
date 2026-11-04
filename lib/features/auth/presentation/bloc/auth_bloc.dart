import 'package:admitly/core/services/biometric_service.dart';
import 'package:admitly/core/services/secure_storage_service.dart';
import 'package:admitly/core/usecases/usecase.dart';
import 'package:admitly/core/utils/app_logger.dart';
import 'package:admitly/features/auth/domain/entities/user_entity.dart';
import 'package:admitly/features/auth/domain/repositories/auth_repository.dart';
import 'package:admitly/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:admitly/features/auth/domain/usecases/google_signin_usecase.dart';
import 'package:admitly/features/auth/domain/usecases/login_usecase.dart';
import 'package:admitly/features/auth/domain/usecases/logout_usecase.dart';
import 'package:admitly/features/auth/domain/usecases/register_usecase.dart';
import 'package:admitly/features/auth/presentation/bloc/auth_event.dart';
import 'package:admitly/features/auth/presentation/bloc/auth_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({
    required LoginUseCase loginUseCase,
    required RegisterUseCase registerUseCase,
    required GoogleSignInUseCase googleSignInUseCase,
    required LogoutUseCase logoutUseCase,
    required GetCurrentUserUseCase getCurrentUserUseCase,
    required BiometricService biometricService,
    required SecureStorageService secureStorageService,
    required AuthRepository authRepository,
  })  : _login = loginUseCase,
        _register = registerUseCase,
        _googleSignIn = googleSignInUseCase,
        _logout = logoutUseCase,
        _getCurrentUser = getCurrentUserUseCase,
        _biometric = biometricService,
        _storage = secureStorageService,
        _repository = authRepository,
        super(const AuthInitial()) {
    on<AuthCheckRequested>(_onCheckRequested);
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthRegisterRequested>(_onRegisterRequested);
    on<AuthGoogleSignInRequested>(_onGoogleSignInRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);
    on<AuthBiometricLoginRequested>(_onBiometricLoginRequested);
    on<AuthBiometricSetupRequested>(_onBiometricSetupRequested);
    on<AuthCheckVerificationRequested>(_onCheckVerification);
    on<AuthPasswordResetRequested>(_onPasswordResetRequested);
    on<AuthProfileUpdateRequested>(_onProfileUpdateRequested);
  }

  final LoginUseCase _login;
  final RegisterUseCase _register;
  final GoogleSignInUseCase _googleSignIn;
  final LogoutUseCase _logout;
  final GetCurrentUserUseCase _getCurrentUser;
  final BiometricService _biometric;
  final SecureStorageService _storage;
  final AuthRepository _repository;

  Future<void> _onCheckRequested(AuthCheckRequested event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    final result = await _getCurrentUser(const NoParams());
    await result.fold(
      (_) async => emit(const AuthUnauthenticated()),
      (user) async {
        if (user == null) {
          emit(const AuthUnauthenticated());
          return;
        }
        final biometricEnabled = await _storage.isBiometricEnabled();
        if (biometricEnabled && await _biometric.isAvailable()) {
          if (!user.isVerified) {
            emit(AuthPendingVerification(user));
          } else {
            emit(AuthBiometricRequired(user));
          }
        } else {
          await _emitPostAuthState(user, emit);
        }
      },
    );
  }

  Future<void> _onLoginRequested(AuthLoginRequested event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    final result = await _login(LoginParams(email: event.email, password: event.password));
    await result.fold(
      (failure) async {
        appLogger.w('Login failure: ${failure.message}');
        emit(AuthError(failure.message));
      },
      (user) async {
        appLogger.i('Login success: ${user.uid}');
        await _emitPostAuthState(user, emit);
      },
    );
  }

  Future<void> _onRegisterRequested(AuthRegisterRequested event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    final result = await _register(
      RegisterParams(email: event.email, password: event.password, name: event.name, role: event.role),
    );
    await result.fold(
      (failure) async {
        appLogger.w('Register failure: ${failure.message}');
        emit(AuthError(failure.message));
      },
      (user) async {
        appLogger.i('Register success: ${user.uid}');
        await _emitPostAuthState(user, emit);
      },
    );
  }

  Future<void> _onGoogleSignInRequested(AuthGoogleSignInRequested event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    final result = await _googleSignIn(const NoParams());
    await result.fold(
      (failure) async {
        appLogger.w('Google sign-in failure: ${failure.message}');
        emit(AuthError(failure.message));
      },
      (user) async {
        appLogger.i('Google sign-in success: ${user.uid}');
        await _emitPostAuthState(user, emit);
      },
    );
  }

  Future<void> _onLogoutRequested(AuthLogoutRequested event, Emitter<AuthState> emit) async {
    await _logout(const NoParams());
    emit(const AuthUnauthenticated());
  }

  Future<void> _onBiometricLoginRequested(AuthBiometricLoginRequested event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    final success = await _biometric.authenticate(reason: 'Sign in to Admitly');
    if (success) {
      appLogger.i('Biometric auth success: ${event.user.uid}');
      emit(AuthAuthenticated(event.user));
    } else {
      emit(const AuthError('Biometric authentication failed. Use your password.'));
    }
  }

  Future<void> _onBiometricSetupRequested(AuthBiometricSetupRequested event, Emitter<AuthState> emit) async {
    await _storage.setBiometricEnabled(event.enable);
    appLogger.i('Biometric ${event.enable ? 'enabled' : 'skipped'} for ${event.user.uid}');
    emit(AuthAuthenticated(event.user));
  }

  Future<void> _onCheckVerification(AuthCheckVerificationRequested event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    final result = await _repository.refreshUser(event.user.uid);
    await result.fold(
      (failure) async => emit(AuthPendingVerification(event.user)),
      (user) async {
        appLogger.i('Verification check: isVerified=${user.isVerified}');
        await _emitPostAuthState(user, emit);
      },
    );
  }

  Future<void> _onPasswordResetRequested(AuthPasswordResetRequested event, Emitter<AuthState> emit) async {
    final result = await _repository.resetPassword(event.email);
    result.fold(
      (failure) {
        appLogger.w('Password reset failed: ${failure.message}');
        emit(AuthError(failure.message));
      },
      (_) {
        appLogger.i('Password reset sent: ${event.email}');
        emit(const AuthPasswordResetSent());
      },
    );
  }

  Future<void> _onProfileUpdateRequested(AuthProfileUpdateRequested event, Emitter<AuthState> emit) async {
    final result = await _repository.updateProfile(event.uid, event.name);
    result.fold(
      (failure) {
        appLogger.w('Profile update failed: ${failure.message}');
        emit(AuthError(failure.message));
      },
      (user) {
        appLogger.i('Profile updated: ${event.uid} name="${event.name}"');
        emit(AuthProfileUpdated(user));
      },
    );
  }

  Future<void> _emitPostAuthState(UserEntity user, Emitter<AuthState> emit) async {
    if (!user.isVerified) {
      emit(AuthPendingVerification(user));
      return;
    }
    final preferenceSet = await _storage.isBiometricPreferenceSet();
    if (!preferenceSet && await _biometric.isAvailable()) {
      emit(AuthBiometricSetupAvailable(user));
    } else {
      emit(AuthAuthenticated(user));
    }
  }
}
