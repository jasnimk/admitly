import 'package:admitly/core/errors/failures.dart';
import 'package:admitly/features/student/data/datasources/student_remote_datasource.dart';
import 'package:admitly/features/student/domain/entities/student_entity.dart';
import 'package:admitly/features/student/domain/repositories/student_repository.dart';
import 'package:dartz/dartz.dart';

class StudentRepositoryImpl implements StudentRepository {
  StudentRepositoryImpl(this._dataSource);
  final StudentRemoteDataSource _dataSource;

  @override
  Future<Either<Failure, StudentEntity>> createStudent(StudentEntity student) async {
    try {
      return Right(await _dataSource.createStudent(student));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, StudentEntity>> updateStudent(StudentEntity student) async {
    try {
      return Right(await _dataSource.updateStudent(student));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteStudent(String id) async {
    try {
      await _dataSource.deleteStudent(id);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<StudentEntity>>> getStudentsByParent(String parentId) async {
    try {
      return Right(await _dataSource.getStudentsByParent(parentId));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<StudentEntity>>> getAllStudents() async {
    try {
      return Right(await _dataSource.getAllStudents());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

}
