import 'package:admitly/core/errors/failures.dart';
import 'package:admitly/core/usecases/usecase.dart';
import 'package:admitly/features/auth/domain/entities/user_entity.dart';
import 'package:admitly/features/auth/domain/repositories/auth_repository.dart';
import 'package:dartz/dartz.dart';

class LoginParams {
  const LoginParams({required this.email, required this.password});
  final String email;
  final String password;
}

class LoginUseCase extends UseCase<UserEntity, LoginParams> {
  LoginUseCase(this._repository);
  final AuthRepository _repository;

  @override
  Future<Either<Failure, UserEntity>> call(LoginParams params) =>
      _repository.login(params.email, params.password);
}
