import 'package:admitly/features/student/domain/entities/student_entity.dart';
import 'package:equatable/equatable.dart';

abstract class StudentEvent extends Equatable {
  const StudentEvent();
  @override
  List<Object?> get props => [];
}

class StudentLoadRequested extends StudentEvent {
  const StudentLoadRequested(this.parentId);
  final String parentId;
  @override
  List<Object?> get props => [parentId];
}

class StudentAllLoadRequested extends StudentEvent {
  const StudentAllLoadRequested();
}

class StudentCreateRequested extends StudentEvent {
  const StudentCreateRequested(this.student);
  final StudentEntity student;
  @override
  List<Object?> get props => [student];
}

class StudentUpdateRequested extends StudentEvent {
  const StudentUpdateRequested(this.student);
  final StudentEntity student;
  @override
  List<Object?> get props => [student];
}

class StudentDeleteRequested extends StudentEvent {
  const StudentDeleteRequested(this.studentId);
  final String studentId;
  @override
  List<Object?> get props => [studentId];
}
