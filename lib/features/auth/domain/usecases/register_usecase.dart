import 'package:admitly/core/errors/failures.dart';
import 'package:admitly/core/usecases/usecase.dart';
import 'package:admitly/features/auth/domain/entities/user_entity.dart';
import 'package:admitly/features/auth/domain/repositories/auth_repository.dart';
import 'package:dartz/dartz.dart';

class RegisterParams {
  const RegisterParams({required this.email, required this.password, required this.name});
  final String email;
  final String password;
  final String name;
}

class RegisterUseCase extends UseCase<UserEntity, RegisterParams> {
  RegisterUseCase(this._repository);
  final AuthRepository _repository;

  @override
  Future<Either<Failure, UserEntity>> call(RegisterParams params) =>
      _repository.register(params.email, params.password, params.name);
}
