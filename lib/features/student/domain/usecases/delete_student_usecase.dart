import 'package:admitly/core/errors/failures.dart';
import 'package:admitly/features/student/domain/repositories/student_repository.dart';
import 'package:dartz/dartz.dart';

class DeleteStudentUseCase {
  DeleteStudentUseCase(this._repository);
  final StudentRepository _repository;

  Future<Either<Failure, void>> call(String id) => _repository.deleteStudent(id);
}
