import 'package:admitly/core/errors/failures.dart';
import 'package:admitly/features/student/domain/entities/student_entity.dart';
import 'package:admitly/features/student/domain/usecases/create_student_usecase.dart';
import 'package:admitly/features/student/domain/usecases/delete_student_usecase.dart';
import 'package:admitly/features/student/domain/usecases/get_students_usecase.dart';
import 'package:admitly/features/student/domain/usecases/update_student_usecase.dart';
import 'package:admitly/features/student/presentation/bloc/student_bloc.dart';
import 'package:admitly/features/student/presentation/bloc/student_event.dart';
import 'package:admitly/features/student/presentation/bloc/student_state.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockCreateStudentUseCase extends Mock implements CreateStudentUseCase {}
class MockGetStudentsByParentUseCase extends Mock implements GetStudentsByParentUseCase {}
class MockGetAllStudentsUseCase extends Mock implements GetAllStudentsUseCase {}
class MockUpdateStudentUseCase extends Mock implements UpdateStudentUseCase {}
class MockDeleteStudentUseCase extends Mock implements DeleteStudentUseCase {}

StudentEntity _makeStudent({
  String id = 's1',
  ApplicationStatus status = ApplicationStatus.applicationCreated,
}) =>
    StudentEntity(
      id: id,
      parentId: 'p1',
      name: 'Test Student',
      dateOfBirth: DateTime(2015, 6, 1),
      gender: Gender.male,
      previousSchool: 'ABC School',
      applyingGrade: 'Grade 1',
      status: status,
      createdAt: DateTime(2024, 1, 1),
    );

void main() {
  setUpAll(() {
    registerFallbackValue(_makeStudent());
  });

  late MockCreateStudentUseCase create;
  late MockGetStudentsByParentUseCase getByParent;
  late MockGetAllStudentsUseCase getAll;
  late MockUpdateStudentUseCase update;
  late MockDeleteStudentUseCase delete;

  StudentBloc buildBloc() => StudentBloc(
        createStudentUseCase: create,
        getStudentsByParentUseCase: getByParent,
        getAllStudentsUseCase: getAll,
        updateStudentUseCase: update,
        deleteStudentUseCase: delete,
      );

  setUp(() {
    create = MockCreateStudentUseCase();
    getByParent = MockGetStudentsByParentUseCase();
    getAll = MockGetAllStudentsUseCase();
    update = MockUpdateStudentUseCase();
    delete = MockDeleteStudentUseCase();
  });

  group('StudentBloc', () {
    // ── Load by parent ────────────────────────────────────────────────────────

    blocTest<StudentBloc, StudentState>(
      'emits [Loading, Loaded] when StudentLoadRequested succeeds',
      build: buildBloc,
      setUp: () {
        when(() => getByParent('p1'))
            .thenAnswer((_) async => Right([_makeStudent()]));
      },
      act: (bloc) => bloc.add(const StudentLoadRequested('p1')),
      expect: () => [
        const StudentLoading(),
        isA<StudentLoaded>().having((s) => s.students.length, 'length', 1),
      ],
    );

    blocTest<StudentBloc, StudentState>(
      'emits [Loading, Error] when StudentLoadRequested fails',
      build: buildBloc,
      setUp: () {
        when(() => getByParent('p1'))
            .thenAnswer((_) async => const Left(ServerFailure('fetch error')));
      },
      act: (bloc) => bloc.add(const StudentLoadRequested('p1')),
      expect: () => [
        const StudentLoading(),
        const StudentError('fetch error'),
      ],
    );

    // ── Load all ──────────────────────────────────────────────────────────────

    blocTest<StudentBloc, StudentState>(
      'emits [Loading, Loaded] when StudentAllLoadRequested succeeds',
      build: buildBloc,
      setUp: () {
        when(() => getAll())
            .thenAnswer((_) async => Right([_makeStudent(), _makeStudent(id: 's2')]));
      },
      act: (bloc) => bloc.add(const StudentAllLoadRequested()),
      expect: () => [
        const StudentLoading(),
        isA<StudentLoaded>().having((s) => s.students.length, 'length', 2),
      ],
    );

    // ── Create ────────────────────────────────────────────────────────────────

    blocTest<StudentBloc, StudentState>(
      'emits [Loading, ActionSuccess] when StudentCreateRequested succeeds',
      build: buildBloc,
      setUp: () {
        final student = _makeStudent();
        when(() => create(student))
            .thenAnswer((_) async => Right(student));
      },
      act: (bloc) => bloc.add(StudentCreateRequested(_makeStudent())),
      expect: () => [
        const StudentLoading(),
        isA<StudentActionSuccess>().having((s) => s.student?.id, 'id', 's1'),
      ],
    );

    blocTest<StudentBloc, StudentState>(
      'emits [Loading, Error] when StudentCreateRequested fails',
      build: buildBloc,
      setUp: () {
        when(() => create(any()))
            .thenAnswer((_) async => const Left(ServerFailure('create failed')));
      },
      act: (bloc) => bloc.add(StudentCreateRequested(_makeStudent())),
      expect: () => [
        const StudentLoading(),
        const StudentError('create failed'),
      ],
    );

    // ── Update ────────────────────────────────────────────────────────────────

    blocTest<StudentBloc, StudentState>(
      'emits [Loading, ActionSuccess] when StudentUpdateRequested succeeds',
      build: buildBloc,
      setUp: () {
        final student = _makeStudent(status: ApplicationStatus.feePaid);
        when(() => update(student))
            .thenAnswer((_) async => Right(student));
      },
      act: (bloc) => bloc.add(
        StudentUpdateRequested(_makeStudent(status: ApplicationStatus.feePaid)),
      ),
      expect: () => [
        const StudentLoading(),
        isA<StudentActionSuccess>().having(
          (s) => s.student?.status,
          'status',
          ApplicationStatus.feePaid,
        ),
      ],
    );

    // ── Delete ────────────────────────────────────────────────────────────────

    blocTest<StudentBloc, StudentState>(
      'emits [Loading, ActionSuccess(null)] when StudentDeleteRequested succeeds',
      build: buildBloc,
      setUp: () {
        when(() => delete('s1'))
            .thenAnswer((_) async => const Right(null));
      },
      act: (bloc) => bloc.add(const StudentDeleteRequested('s1')),
      expect: () => [
        const StudentLoading(),
        const StudentActionSuccess(null),
      ],
    );

    blocTest<StudentBloc, StudentState>(
      'emits [Loading, Error] when StudentDeleteRequested fails',
      build: buildBloc,
      setUp: () {
        when(() => delete('s1'))
            .thenAnswer((_) async => const Left(ServerFailure('delete failed')));
      },
      act: (bloc) => bloc.add(const StudentDeleteRequested('s1')),
      expect: () => [
        const StudentLoading(),
        const StudentError('delete failed'),
      ],
    );

    // ── Status workflow ───────────────────────────────────────────────────────

    blocTest<StudentBloc, StudentState>(
      'status progresses to slotBooked after update',
      build: buildBloc,
      setUp: () {
        final booked = _makeStudent(status: ApplicationStatus.slotBooked);
        when(() => update(booked)).thenAnswer((_) async => Right(booked));
      },
      act: (bloc) => bloc.add(
        StudentUpdateRequested(_makeStudent(status: ApplicationStatus.slotBooked)),
      ),
      expect: () => [
        const StudentLoading(),
        isA<StudentActionSuccess>().having(
          (s) => s.student?.status,
          'status',
          ApplicationStatus.slotBooked,
        ),
      ],
    );

    blocTest<StudentBloc, StudentState>(
      'status progresses to admissionCompleted after update',
      build: buildBloc,
      setUp: () {
        final completed = _makeStudent(status: ApplicationStatus.admissionCompleted);
        when(() => update(completed)).thenAnswer((_) async => Right(completed));
      },
      act: (bloc) => bloc.add(
        StudentUpdateRequested(
          _makeStudent(status: ApplicationStatus.admissionCompleted),
        ),
      ),
      expect: () => [
        const StudentLoading(),
        isA<StudentActionSuccess>().having(
          (s) => s.student?.status,
          'status',
          ApplicationStatus.admissionCompleted,
        ),
      ],
    );
  });
}
