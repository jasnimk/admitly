import 'package:equatable/equatable.dart';

abstract class ExamSlotEvent extends Equatable {
  const ExamSlotEvent();
  @override
  List<Object?> get props => [];
}

class ExamSlotsLoadRequested extends ExamSlotEvent {
  const ExamSlotsLoadRequested();
}

class ExamSlotBookRequested extends ExamSlotEvent {
  const ExamSlotBookRequested({required this.slotId, required this.studentId});
  final String slotId;
  final String studentId;
  @override
  List<Object?> get props => [slotId, studentId];
}
