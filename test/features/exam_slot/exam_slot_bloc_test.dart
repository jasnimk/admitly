import 'package:admitly/core/errors/failures.dart';
import 'package:admitly/features/exam_slot/domain/entities/exam_slot_entity.dart';
import 'package:admitly/features/exam_slot/domain/usecases/book_exam_slot_usecase.dart';
import 'package:admitly/features/exam_slot/domain/usecases/create_exam_slot_usecase.dart';
import 'package:admitly/features/exam_slot/domain/usecases/delete_exam_slot_usecase.dart';
import 'package:admitly/features/exam_slot/domain/usecases/get_all_slots_usecase.dart';
import 'package:admitly/features/exam_slot/domain/usecases/get_exam_slots_usecase.dart';
import 'package:admitly/features/exam_slot/domain/usecases/update_exam_slot_usecase.dart';
import 'package:admitly/features/exam_slot/presentation/bloc/exam_slot_bloc.dart';
import 'package:admitly/features/exam_slot/presentation/bloc/exam_slot_event.dart';
import 'package:admitly/features/exam_slot/presentation/bloc/exam_slot_state.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockGetExamSlotsUseCase extends Mock implements GetExamSlotsUseCase {}
class MockGetAllSlotsUseCase extends Mock implements GetAllSlotsUseCase {}
class MockBookExamSlotUseCase extends Mock implements BookExamSlotUseCase {}
class MockCreateExamSlotUseCase extends Mock implements CreateExamSlotUseCase {}
class MockUpdateExamSlotUseCase extends Mock implements UpdateExamSlotUseCase {}
class MockDeleteExamSlotUseCase extends Mock implements DeleteExamSlotUseCase {}

void main() {
  late MockGetExamSlotsUseCase getExamSlots;
  late MockGetAllSlotsUseCase getAllSlots;
  late MockBookExamSlotUseCase bookSlot;
  late MockCreateExamSlotUseCase createSlot;
  late MockUpdateExamSlotUseCase updateSlot;
  late MockDeleteExamSlotUseCase deleteSlot;

  final tSlot = ExamSlotEntity(
    id: 'slot001',
    date: DateTime(2024, 7, 15),
    timeLabel: '10:00 AM – 12:00 PM',
    venue: 'Main Hall',
    capacity: 30,
    bookedCount: 5,
  );

  final tSlots = [tSlot];

  setUp(() {
    getExamSlots = MockGetExamSlotsUseCase();
    getAllSlots = MockGetAllSlotsUseCase();
    bookSlot = MockBookExamSlotUseCase();
    createSlot = MockCreateExamSlotUseCase();
    updateSlot = MockUpdateExamSlotUseCase();
    deleteSlot = MockDeleteExamSlotUseCase();

    registerFallbackValue(tSlot);
  });

  ExamSlotBloc buildBloc() => ExamSlotBloc(
        getExamSlotsUseCase: getExamSlots,
        getAllSlotsUseCase: getAllSlots,
        bookExamSlotUseCase: bookSlot,
        createExamSlotUseCase: createSlot,
        updateExamSlotUseCase: updateSlot,
        deleteExamSlotUseCase: deleteSlot,
      );

  group('ExamSlotBloc — Load Slots', () {
    blocTest<ExamSlotBloc, ExamSlotState>(
      'emits [ExamSlotLoading, ExamSlotLoaded] on successful load',
      build: () {
        when(() => getExamSlots()).thenAnswer((_) async => Right(tSlots));
        return buildBloc();
      },
      act: (bloc) => bloc.add(const ExamSlotsLoadRequested()),
      expect: () => [isA<ExamSlotLoading>(), isA<ExamSlotLoaded>()],
      verify: (bloc) {
        final state = bloc.state as ExamSlotLoaded;
        expect(state.slots.length, 1);
        expect(state.slots.first.id, 'slot001');
      },
    );

    blocTest<ExamSlotBloc, ExamSlotState>(
      'emits [ExamSlotLoading, ExamSlotError] on load failure',
      build: () {
        when(() => getExamSlots())
            .thenAnswer((_) async => const Left(ServerFailure('Firestore error')));
        return buildBloc();
      },
      act: (bloc) => bloc.add(const ExamSlotsLoadRequested()),
      expect: () => [isA<ExamSlotLoading>(), isA<ExamSlotError>()],
    );
  });

  group('ExamSlotBloc — Book Slot', () {
    blocTest<ExamSlotBloc, ExamSlotState>(
      'emits [ExamSlotLoading, ExamSlotBookSuccess] on successful booking',
      build: () {
        when(() => bookSlot(slotId: any(named: 'slotId'), studentId: any(named: 'studentId')))
            .thenAnswer((_) async => const Right(null));
        return buildBloc();
      },
      act: (bloc) => bloc.add(const ExamSlotBookRequested(slotId: 'slot001', studentId: 'stu001')),
      expect: () => [isA<ExamSlotLoading>(), isA<ExamSlotBookSuccess>()],
    );

    blocTest<ExamSlotBloc, ExamSlotState>(
      'emits [ExamSlotLoading, ExamSlotError] when slot is full',
      build: () {
        when(() => bookSlot(slotId: any(named: 'slotId'), studentId: any(named: 'studentId')))
            .thenAnswer((_) async => const Left(ServerFailure('Slot is fully booked')));
        return buildBloc();
      },
      act: (bloc) => bloc.add(const ExamSlotBookRequested(slotId: 'slot001', studentId: 'stu002')),
      expect: () => [isA<ExamSlotLoading>(), isA<ExamSlotError>()],
      verify: (bloc) {
        final state = bloc.state as ExamSlotError;
        expect(state.message, 'Slot is fully booked');
      },
    );
  });

  group('ExamSlotBloc — Create Slot', () {
    blocTest<ExamSlotBloc, ExamSlotState>(
      'emits [ExamSlotLoading, ExamSlotCreateSuccess, ExamSlotLoaded] on success',
      build: () {
        when(() => createSlot(any())).thenAnswer((_) async => const Right(null));
        when(() => getAllSlots()).thenAnswer((_) async => Right(tSlots));
        return buildBloc();
      },
      act: (bloc) => bloc.add(ExamSlotCreateRequested(tSlot)),
      expect: () => [isA<ExamSlotLoading>(), isA<ExamSlotCreateSuccess>(), isA<ExamSlotLoaded>()],
    );

    blocTest<ExamSlotBloc, ExamSlotState>(
      'emits [ExamSlotLoading, ExamSlotError] on create failure',
      build: () {
        when(() => createSlot(any()))
            .thenAnswer((_) async => const Left(ServerFailure('Permission denied')));
        return buildBloc();
      },
      act: (bloc) => bloc.add(ExamSlotCreateRequested(tSlot)),
      expect: () => [isA<ExamSlotLoading>(), isA<ExamSlotError>()],
    );
  });
}
