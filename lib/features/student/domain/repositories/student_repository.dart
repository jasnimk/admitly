import 'package:admitly/core/errors/failures.dart';
import 'package:admitly/features/student/domain/entities/student_entity.dart';
import 'package:dartz/dartz.dart';

abstract class StudentRepository {
  Future<Either<Failure, StudentEntity>> createStudent(StudentEntity student);
  Future<Either<Failure, StudentEntity>> updateStudent(StudentEntity student);
  Future<Either<Failure, List<StudentEntity>>> getStudentsByParent(String parentId);
  Future<Either<Failure, List<StudentEntity>>> getAllStudents();
  Future<Either<Failure, StudentEntity>> getStudentById(String id);
}
