import 'package:admitly/core/usecases/usecase.dart';
import 'package:admitly/core/utils/app_logger.dart';
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
  })  : _login = loginUseCase,
        _register = registerUseCase,
        _googleSignIn = googleSignInUseCase,
        _logout = logoutUseCase,
        _getCurrentUser = getCurrentUserUseCase,
        super(const AuthInitial()) {
    on<AuthCheckRequested>(_onCheckRequested);
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthRegisterRequested>(_onRegisterRequested);
    on<AuthGoogleSignInRequested>(_onGoogleSignInRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);
  }

  final LoginUseCase _login;
  final RegisterUseCase _register;
  final GoogleSignInUseCase _googleSignIn;
  final LogoutUseCase _logout;
  final GetCurrentUserUseCase _getCurrentUser;

  Future<void> _onCheckRequested(AuthCheckRequested event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    final result = await _getCurrentUser(const NoParams());
    result.fold(
      (failure) => emit(const AuthUnauthenticated()),
      (user) => user != null ? emit(AuthAuthenticated(user)) : emit(const AuthUnauthenticated()),
    );
  }

  Future<void> _onLoginRequested(AuthLoginRequested event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    final result = await _login(LoginParams(email: event.email, password: event.password));
    result.fold(
      (failure) {
        appLogger.w('Login failure: ${failure.message}');
        emit(AuthError(failure.message));
      },
      (user) {
        appLogger.i('Login success: ${user.uid}');
        emit(AuthAuthenticated(user));
      },
    );
  }

  Future<void> _onRegisterRequested(AuthRegisterRequested event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    final result = await _register(
      RegisterParams(email: event.email, password: event.password, name: event.name),
    );
    result.fold(
      (failure) {
        appLogger.w('Register failure: ${failure.message}');
        emit(AuthError(failure.message));
      },
      (user) {
        appLogger.i('Register success: ${user.uid}');
        emit(AuthAuthenticated(user));
      },
    );
  }

  Future<void> _onGoogleSignInRequested(AuthGoogleSignInRequested event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    final result = await _googleSignIn(const NoParams());
    result.fold(
      (failure) {
        appLogger.w('Google sign-in failure: ${failure.message}');
        emit(AuthError(failure.message));
      },
      (user) {
        appLogger.i('Google sign-in success: ${user.uid}');
        emit(AuthAuthenticated(user));
      },
    );
  }

  Future<void> _onLogoutRequested(AuthLogoutRequested event, Emitter<AuthState> emit) async {
    await _logout(const NoParams());
    emit(const AuthUnauthenticated());
  }
}
