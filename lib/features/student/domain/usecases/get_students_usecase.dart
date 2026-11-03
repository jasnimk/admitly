import 'package:admitly/core/errors/failures.dart';
import 'package:admitly/features/student/domain/entities/student_entity.dart';
import 'package:admitly/features/student/domain/repositories/student_repository.dart';
import 'package:dartz/dartz.dart';

class GetStudentsByParentUseCase {
  GetStudentsByParentUseCase(this._repository);
  final StudentRepository _repository;

  Future<Either<Failure, List<StudentEntity>>> call(String parentId) =>
      _repository.getStudentsByParent(parentId);
}

class GetAllStudentsUseCase {
  GetAllStudentsUseCase(this._repository);
  final StudentRepository _repository;

  Future<Either<Failure, List<StudentEntity>>> call() =>
      _repository.getAllStudents();
}
