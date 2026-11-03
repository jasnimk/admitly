import 'package:admitly/features/exam_slot/domain/entities/exam_slot_entity.dart';
import 'package:equatable/equatable.dart';

abstract class ExamSlotEvent extends Equatable {
  const ExamSlotEvent();
  @override
  List<Object?> get props => [];
}

class ExamSlotsLoadRequested extends ExamSlotEvent {
  const ExamSlotsLoadRequested();
}

class ExamAllSlotsLoadRequested extends ExamSlotEvent {
  const ExamAllSlotsLoadRequested();
}

class ExamSlotBookRequested extends ExamSlotEvent {
  const ExamSlotBookRequested({required this.slotId, required this.studentId});
  final String slotId;
  final String studentId;
  @override
  List<Object?> get props => [slotId, studentId];
}

class ExamSlotCreateRequested extends ExamSlotEvent {
  const ExamSlotCreateRequested(this.slot);
  final ExamSlotEntity slot;
  @override
  List<Object?> get props => [slot];
}

class ExamSlotUpdateRequested extends ExamSlotEvent {
  const ExamSlotUpdateRequested(this.slot);
  final ExamSlotEntity slot;
  @override
  List<Object?> get props => [slot];
}

class ExamSlotDeleteRequested extends ExamSlotEvent {
  const ExamSlotDeleteRequested(this.slotId);
  final String slotId;
  @override
  List<Object?> get props => [slotId];
}
