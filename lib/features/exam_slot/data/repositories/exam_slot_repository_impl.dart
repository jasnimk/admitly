import 'package:admitly/core/errors/failures.dart';
import 'package:admitly/features/exam_slot/data/datasources/exam_slot_remote_datasource.dart';
import 'package:admitly/features/exam_slot/domain/entities/exam_slot_entity.dart';
import 'package:admitly/features/exam_slot/domain/repositories/exam_slot_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';

class ExamSlotRepositoryImpl implements ExamSlotRepository {
  const ExamSlotRepositoryImpl(this._dataSource);
  final ExamSlotRemoteDataSource _dataSource;

  @override
  Future<Either<Failure, List<ExamSlotEntity>>> getAvailableSlots() async {
    try {
      return Right(await _dataSource.getAvailableSlots());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ExamSlotEntity>>> getAllSlots() async {
    try {
      return Right(await _dataSource.getAllSlots());
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

  @override
  Future<Either<Failure, void>> createSlot(ExamSlotEntity slot) async {
    try {
      await _dataSource.createSlot({
        'date': Timestamp.fromDate(slot.date),
        'timeLabel': slot.timeLabel,
        'venue': slot.venue,
        'capacity': slot.capacity,
        'bookedCount': 0,
      });
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
