import 'package:admitly/core/utils/app_logger.dart';
import 'package:admitly/features/student/domain/usecases/create_student_usecase.dart';
import 'package:admitly/features/student/domain/usecases/delete_student_usecase.dart';
import 'package:admitly/features/student/domain/usecases/get_students_usecase.dart';
import 'package:admitly/features/student/domain/usecases/update_student_usecase.dart';
import 'package:admitly/features/student/presentation/bloc/student_event.dart';
import 'package:admitly/features/student/presentation/bloc/student_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class StudentBloc extends Bloc<StudentEvent, StudentState> {
  StudentBloc({
    required CreateStudentUseCase createStudentUseCase,
    required GetStudentsByParentUseCase getStudentsByParentUseCase,
    required GetAllStudentsUseCase getAllStudentsUseCase,
    required UpdateStudentUseCase updateStudentUseCase,
    required DeleteStudentUseCase deleteStudentUseCase,
  })  : _create = createStudentUseCase,
        _getByParent = getStudentsByParentUseCase,
        _getAll = getAllStudentsUseCase,
        _update = updateStudentUseCase,
        _delete = deleteStudentUseCase,
        super(const StudentInitial()) {
    on<StudentLoadRequested>(_onLoad);
    on<StudentAllLoadRequested>(_onLoadAll);
    on<StudentCreateRequested>(_onCreate);
    on<StudentUpdateRequested>(_onUpdate);
    on<StudentDeleteRequested>(_onDelete);
  }

  final CreateStudentUseCase _create;
  final GetStudentsByParentUseCase _getByParent;
  final GetAllStudentsUseCase _getAll;
  final UpdateStudentUseCase _update;
  final DeleteStudentUseCase _delete;

  Future<void> _onLoad(StudentLoadRequested event, Emitter<StudentState> emit) async {
    emit(const StudentLoading());
    final result = await _getByParent(event.parentId);
    result.fold(
      (f) => emit(StudentError(f.message)),
      (students) => emit(StudentLoaded(students)),
    );
  }

  Future<void> _onLoadAll(StudentAllLoadRequested event, Emitter<StudentState> emit) async {
    emit(const StudentLoading());
    final result = await _getAll();
    result.fold(
      (f) => emit(StudentError(f.message)),
      (students) => emit(StudentLoaded(students)),
    );
  }

  Future<void> _onCreate(StudentCreateRequested event, Emitter<StudentState> emit) async {
    emit(const StudentLoading());
    final result = await _create(event.student);
    result.fold(
      (f) {
        appLogger.w('Create student failed: ${f.message}');
        emit(StudentError(f.message));
      },
      (student) {
        appLogger.i('Student created: ${student.id}');
        emit(StudentActionSuccess(student));
      },
    );
  }

  Future<void> _onUpdate(StudentUpdateRequested event, Emitter<StudentState> emit) async {
    emit(const StudentLoading());
    final result = await _update(event.student);
    result.fold(
      (f) => emit(StudentError(f.message)),
      (student) => emit(StudentActionSuccess(student)),
    );
  }

  Future<void> _onDelete(StudentDeleteRequested event, Emitter<StudentState> emit) async {
    emit(const StudentLoading());
    final result = await _delete(event.studentId);
    result.fold(
      (f) => emit(StudentError(f.message)),
      (_) => emit(const StudentActionSuccess(null)),
    );
  }
}
