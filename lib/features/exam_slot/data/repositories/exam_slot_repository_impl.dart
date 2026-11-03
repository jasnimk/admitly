import 'package:admitly/core/errors/failures.dart';
import 'package:admitly/features/exam_slot/data/datasources/exam_slot_remote_datasource.dart';
import 'package:admitly/features/exam_slot/domain/entities/exam_slot_entity.dart';
import 'package:admitly/features/exam_slot/domain/repositories/exam_slot_repository.dart';
import 'package:dartz/dartz.dart';

class ExamSlotRepositoryImpl implements ExamSlotRepository {
  const ExamSlotRepositoryImpl(this._dataSource);
  final ExamSlotRemoteDataSource _dataSource;

  @override
  Future<Either<Failure, List<ExamSlotEntity>>> getAvailableSlots() async {
    try {
      final slots = await _dataSource.getAvailableSlots();
      return Right(slots);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> bookSlot({
    required String slotId,
    required String studentId,
  }) async {
    try {
      await _dataSource.bookSlot(slotId: slotId, studentId: studentId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
