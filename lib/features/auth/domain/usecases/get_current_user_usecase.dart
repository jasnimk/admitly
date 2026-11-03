import 'package:admitly/core/errors/failures.dart';
import 'package:admitly/core/usecases/usecase.dart';
import 'package:admitly/features/auth/domain/entities/user_entity.dart';
import 'package:admitly/features/auth/domain/repositories/auth_repository.dart';
import 'package:dartz/dartz.dart';

class GetCurrentUserUseCase extends UseCase<UserEntity?, NoParams> {
  GetCurrentUserUseCase(this._repository);
  final AuthRepository _repository;

  @override
  Future<Either<Failure, UserEntity?>> call(NoParams params) =>
      _repository.getCurrentUser();
}
