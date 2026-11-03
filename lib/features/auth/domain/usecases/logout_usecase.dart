import 'package:admitly/core/errors/failures.dart';
import 'package:admitly/core/usecases/usecase.dart';
import 'package:admitly/features/auth/domain/repositories/auth_repository.dart';
import 'package:dartz/dartz.dart';

class LogoutUseCase extends UseCase<void, NoParams> {
  LogoutUseCase(this._repository);
  final AuthRepository _repository;

  @override
  Future<Either<Failure, void>> call(NoParams params) => _repository.logout();
}
