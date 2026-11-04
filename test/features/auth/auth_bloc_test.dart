import 'package:admitly/core/errors/failures.dart';
import 'package:admitly/core/services/biometric_service.dart';
import 'package:admitly/core/services/secure_storage_service.dart';
import 'package:admitly/core/usecases/usecase.dart';
import 'package:admitly/features/auth/domain/entities/user_entity.dart';
import 'package:admitly/features/auth/domain/repositories/auth_repository.dart';
import 'package:admitly/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:admitly/features/auth/domain/usecases/google_signin_usecase.dart';
import 'package:admitly/features/auth/domain/usecases/login_usecase.dart';
import 'package:admitly/features/auth/domain/usecases/logout_usecase.dart';
import 'package:admitly/features/auth/domain/usecases/register_usecase.dart';
import 'package:admitly/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:admitly/features/auth/presentation/bloc/auth_event.dart';
import 'package:admitly/features/auth/presentation/bloc/auth_state.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockLoginUseCase extends Mock implements LoginUseCase {}
class MockRegisterUseCase extends Mock implements RegisterUseCase {}
class MockGoogleSignInUseCase extends Mock implements GoogleSignInUseCase {}
class MockLogoutUseCase extends Mock implements LogoutUseCase {}
class MockGetCurrentUserUseCase extends Mock implements GetCurrentUserUseCase {}
class MockBiometricService extends Mock implements BiometricService {}
class MockSecureStorageService extends Mock implements SecureStorageService {}
class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockLoginUseCase loginUseCase;
  late MockRegisterUseCase registerUseCase;
  late MockGoogleSignInUseCase googleSignInUseCase;
  late MockLogoutUseCase logoutUseCase;
  late MockGetCurrentUserUseCase getCurrentUserUseCase;
  late MockBiometricService biometricService;
  late MockSecureStorageService secureStorageService;
  late MockAuthRepository authRepository;

  const tUser = UserEntity(
    uid: 'uid123',
    email: 'test@example.com',
    name: 'Test User',
    role: UserRole.parent,
    isVerified: true,
  );

  setUp(() {
    loginUseCase = MockLoginUseCase();
    registerUseCase = MockRegisterUseCase();
    googleSignInUseCase = MockGoogleSignInUseCase();
    logoutUseCase = MockLogoutUseCase();
    getCurrentUserUseCase = MockGetCurrentUserUseCase();
    biometricService = MockBiometricService();
    secureStorageService = MockSecureStorageService();
    authRepository = MockAuthRepository();

    registerFallbackValue(const LoginParams(email: '', password: ''));
    registerFallbackValue(const NoParams());
  });

  AuthBloc buildBloc() => AuthBloc(
        loginUseCase: loginUseCase,
        registerUseCase: registerUseCase,
        googleSignInUseCase: googleSignInUseCase,
        logoutUseCase: logoutUseCase,
        getCurrentUserUseCase: getCurrentUserUseCase,
        biometricService: biometricService,
        secureStorageService: secureStorageService,
        authRepository: authRepository,
      );

  group('AuthBloc — Login', () {
    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthAuthenticated] on successful login',
      build: () {
        when(() => loginUseCase(any())).thenAnswer((_) async => const Right(tUser));
        when(() => secureStorageService.isBiometricPreferenceSet()).thenAnswer((_) async => true);
        return buildBloc();
      },
      act: (bloc) => bloc.add(const AuthLoginRequested(email: 'test@example.com', password: 'pass123')),
      expect: () => [isA<AuthLoading>(), isA<AuthAuthenticated>()],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthError] on login failure',
      build: () {
        when(() => loginUseCase(any())).thenAnswer((_) async => const Left(AuthFailure('Invalid credentials')));
        return buildBloc();
      },
      act: (bloc) => bloc.add(const AuthLoginRequested(email: 'bad@example.com', password: 'wrong')),
      expect: () => [isA<AuthLoading>(), isA<AuthError>()],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthPendingVerification] when user not verified',
      build: () {
        const unverifiedUser = UserEntity(
          uid: 'uid456',
          email: 'new@example.com',
          name: 'New User',
          role: UserRole.admissionTeam,
          isVerified: false,
        );
        when(() => loginUseCase(any())).thenAnswer((_) async => const Right(unverifiedUser));
        return buildBloc();
      },
      act: (bloc) => bloc.add(const AuthLoginRequested(email: 'new@example.com', password: 'pass123')),
      expect: () => [isA<AuthLoading>(), isA<AuthPendingVerification>()],
    );
  });

  group('AuthBloc — Logout', () {
    blocTest<AuthBloc, AuthState>(
      'emits [AuthUnauthenticated] on logout',
      build: () {
        when(() => logoutUseCase(any())).thenAnswer((_) async => const Right(null));
        return buildBloc();
      },
      act: (bloc) => bloc.add(const AuthLogoutRequested()),
      expect: () => [isA<AuthUnauthenticated>()],
    );
  });

  group('AuthBloc — Password Reset', () {
    blocTest<AuthBloc, AuthState>(
      'emits [AuthPasswordResetSent] on success',
      build: () {
        when(() => authRepository.resetPassword(any())).thenAnswer((_) async => const Right(null));
        return buildBloc();
      },
      act: (bloc) => bloc.add(const AuthPasswordResetRequested('test@example.com')),
      expect: () => [isA<AuthPasswordResetSent>()],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthError] when email not found',
      build: () {
        when(() => authRepository.resetPassword(any()))
            .thenAnswer((_) async => const Left(AuthFailure('No account found with this email')));
        return buildBloc();
      },
      act: (bloc) => bloc.add(const AuthPasswordResetRequested('nobody@example.com')),
      expect: () => [isA<AuthError>()],
      verify: (bloc) {
        final state = bloc.state as AuthError;
        expect(state.message, 'No account found with this email');
      },
    );
  });

  group('AuthBloc — Profile Update', () {
    blocTest<AuthBloc, AuthState>(
      'emits [AuthProfileUpdated] on success',
      build: () {
        when(() => authRepository.updateProfile(any(), any()))
            .thenAnswer((_) async => const Right(tUser));
        return buildBloc();
      },
      act: (bloc) => bloc.add(const AuthProfileUpdateRequested(uid: 'uid123', name: 'New Name')),
      expect: () => [isA<AuthProfileUpdated>()],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthError] on profile update failure',
      build: () {
        when(() => authRepository.updateProfile(any(), any()))
            .thenAnswer((_) async => const Left(ServerFailure('Update failed')));
        return buildBloc();
      },
      act: (bloc) => bloc.add(const AuthProfileUpdateRequested(uid: 'uid123', name: 'New Name')),
      expect: () => [isA<AuthError>()],
    );
  });
}
