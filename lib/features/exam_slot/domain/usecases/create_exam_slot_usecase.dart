import 'package:admitly/core/errors/failures.dart';
import 'package:admitly/features/exam_slot/domain/entities/exam_slot_entity.dart';
import 'package:admitly/features/exam_slot/domain/repositories/exam_slot_repository.dart';
import 'package:dartz/dartz.dart';

class CreateExamSlotUseCase {
  const CreateExamSlotUseCase(this._repository);
  final ExamSlotRepository _repository;

  Future<Either<Failure, void>> call(ExamSlotEntity slot) =>
      _repository.createSlot(slot);
}
