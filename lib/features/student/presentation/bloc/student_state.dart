import 'package:admitly/features/student/domain/entities/student_entity.dart';
import 'package:equatable/equatable.dart';

abstract class StudentState extends Equatable {
  const StudentState();
  @override
  List<Object?> get props => [];
}

class StudentInitial extends StudentState {
  const StudentInitial();
}

class StudentLoading extends StudentState {
  const StudentLoading();
}

class StudentLoaded extends StudentState {
  const StudentLoaded(this.students);
  final List<StudentEntity> students;
  @override
  List<Object?> get props => [students];
}

class StudentActionSuccess extends StudentState {
  const StudentActionSuccess(this.student);
  final StudentEntity? student;
  @override
  List<Object?> get props => [student];
}

class StudentError extends StudentState {
  const StudentError(this.message);
  final String message;
  @override
  List<Object?> get props => [message];
}
