import 'package:admitly/core/errors/failures.dart';
import 'package:admitly/features/auth/domain/entities/user_entity.dart';
import 'package:dartz/dartz.dart';

abstract class AuthRepository {
  Future<Either<Failure, UserEntity>> login(String email, String password);
  Future<Either<Failure, UserEntity>> register(String email, String password, String name, UserRole role);
  Future<Either<Failure, UserEntity>> signInWithGoogle();
  Future<Either<Failure, void>> logout();
  Future<Either<Failure, UserEntity?>> getCurrentUser();
}
