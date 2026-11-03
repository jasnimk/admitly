import 'package:admitly/core/errors/failures.dart';
import 'package:admitly/features/exam_slot/domain/entities/exam_slot_entity.dart';
import 'package:dartz/dartz.dart';

abstract class ExamSlotRepository {
  Future<Either<Failure, List<ExamSlotEntity>>> getAvailableSlots();
  Future<Either<Failure, void>> bookSlot({
    required String slotId,
    required String studentId,
  });
}
