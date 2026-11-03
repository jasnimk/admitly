import 'package:admitly/features/exam_slot/domain/entities/exam_slot_entity.dart';
import 'package:equatable/equatable.dart';

abstract class ExamSlotState extends Equatable {
  const ExamSlotState();
  @override
  List<Object?> get props => [];
}

class ExamSlotInitial extends ExamSlotState {
  const ExamSlotInitial();
}

class ExamSlotLoading extends ExamSlotState {
  const ExamSlotLoading();
}

class ExamSlotLoaded extends ExamSlotState {
  const ExamSlotLoaded(this.slots);
  final List<ExamSlotEntity> slots;
  @override
  List<Object?> get props => [slots];
}

class ExamSlotBookSuccess extends ExamSlotState {
  const ExamSlotBookSuccess();
}

class ExamSlotCreateSuccess extends ExamSlotState {
  const ExamSlotCreateSuccess();
}

class ExamSlotError extends ExamSlotState {
  const ExamSlotError(this.message);
  final String message;
  @override
  List<Object?> get props => [message];
}
