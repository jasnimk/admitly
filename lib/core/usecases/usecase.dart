import 'package:dartz/dartz.dart';
import 'package:admitly/core/errors/failures.dart';

abstract class UseCase<Output, Params> {
  Future<Either<Failure, Output>> call(Params params);
}

class NoParams {
  const NoParams();
}
