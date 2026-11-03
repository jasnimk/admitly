import 'package:admitly/core/errors/failures.dart';
import 'package:admitly/features/student/domain/entities/student_entity.dart';
import 'package:admitly/features/student/domain/repositories/student_repository.dart';
import 'package:dartz/dartz.dart';

class CreateStudentUseCase {
  CreateStudentUseCase(this._repository);
  final StudentRepository _repository;

  Future<Either<Failure, StudentEntity>> call(StudentEntity student) =>
      _repository.createStudent(student);
}
