import 'package:admitly/core/errors/failures.dart';
import 'package:admitly/features/exam_slot/domain/repositories/exam_slot_repository.dart';
import 'package:dartz/dartz.dart';

class BookExamSlotUseCase {
  const BookExamSlotUseCase(this._repository);
  final ExamSlotRepository _repository;

  Future<Either<Failure, void>> call({
    required String slotId,
    required String studentId,
  }) =>
      _repository.bookSlot(slotId: slotId, studentId: studentId);
}
