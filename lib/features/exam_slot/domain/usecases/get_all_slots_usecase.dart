import 'package:admitly/core/errors/failures.dart';
import 'package:admitly/features/exam_slot/domain/entities/exam_slot_entity.dart';
import 'package:admitly/features/exam_slot/domain/repositories/exam_slot_repository.dart';
import 'package:dartz/dartz.dart';

class GetAllSlotsUseCase {
  const GetAllSlotsUseCase(this._repository);
  final ExamSlotRepository _repository;

  Future<Either<Failure, List<ExamSlotEntity>>> call() =>
      _repository.getAllSlots();
}
