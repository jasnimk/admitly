import 'package:admitly/core/errors/failures.dart';
import 'package:admitly/features/exam_slot/domain/repositories/exam_slot_repository.dart';
import 'package:dartz/dartz.dart';

class DeleteExamSlotUseCase {
  const DeleteExamSlotUseCase(this._repo);
  final ExamSlotRepository _repo;

  Future<Either<Failure, void>> call(String slotId) => _repo.deleteSlot(slotId);
}
