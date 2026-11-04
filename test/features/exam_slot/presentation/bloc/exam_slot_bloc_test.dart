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

ExamSlotEntity _makeSlot({
  String id = 'slot1',
  int capacity = 30,
  int bookedCount = 0,
}) =>
    ExamSlotEntity(
      id: id,
      date: DateTime(2025, 7, 15),
      timeLabel: '10:00 AM',
      venue: 'Main Hall',
      capacity: capacity,
      bookedCount: bookedCount,
    );

void main() {
  late MockGetExamSlotsUseCase getSlots;
  late MockGetAllSlotsUseCase getAllSlots;
  late MockBookExamSlotUseCase bookSlot;
  late MockCreateExamSlotUseCase createSlot;
  late MockUpdateExamSlotUseCase updateSlot;
  late MockDeleteExamSlotUseCase deleteSlot;

  ExamSlotBloc buildBloc() => ExamSlotBloc(
        getExamSlotsUseCase: getSlots,
        getAllSlotsUseCase: getAllSlots,
        bookExamSlotUseCase: bookSlot,
        createExamSlotUseCase: createSlot,
        updateExamSlotUseCase: updateSlot,
        deleteExamSlotUseCase: deleteSlot,
      );

  setUp(() {
    getSlots = MockGetExamSlotsUseCase();
    getAllSlots = MockGetAllSlotsUseCase();
    bookSlot = MockBookExamSlotUseCase();
    createSlot = MockCreateExamSlotUseCase();
    updateSlot = MockUpdateExamSlotUseCase();
    deleteSlot = MockDeleteExamSlotUseCase();
  });

  group('ExamSlotBloc', () {
    // ── Load slots ────────────────────────────────────────────────────────────

    blocTest<ExamSlotBloc, ExamSlotState>(
      'emits [Loading, Loaded] when ExamSlotsLoadRequested succeeds',
      build: buildBloc,
      setUp: () {
        when(() => getSlots())
            .thenAnswer((_) async => Right([_makeSlot()]));
      },
      act: (bloc) => bloc.add(const ExamSlotsLoadRequested()),
      expect: () => [
        const ExamSlotLoading(),
        isA<ExamSlotLoaded>().having((s) => s.slots.length, 'length', 1),
      ],
    );

    blocTest<ExamSlotBloc, ExamSlotState>(
      'emits [Loading, Error] when ExamSlotsLoadRequested fails',
      build: buildBloc,
      setUp: () {
        when(() => getSlots())
            .thenAnswer((_) async => const Left(ServerFailure('load error')));
      },
      act: (bloc) => bloc.add(const ExamSlotsLoadRequested()),
      expect: () => [
        const ExamSlotLoading(),
        const ExamSlotError('load error'),
      ],
    );

    // ── Book slot ─────────────────────────────────────────────────────────────

    blocTest<ExamSlotBloc, ExamSlotState>(
      'emits [Loading, BookSuccess] when slot booking succeeds',
      build: buildBloc,
      setUp: () {
        when(() => bookSlot(slotId: 'slot1', studentId: 'stu1'))
            .thenAnswer((_) async => const Right(null));
      },
      act: (bloc) => bloc.add(
        const ExamSlotBookRequested(slotId: 'slot1', studentId: 'stu1'),
      ),
      expect: () => [
        const ExamSlotLoading(),
        const ExamSlotBookSuccess(),
      ],
    );

    blocTest<ExamSlotBloc, ExamSlotState>(
      'emits [Loading, Error] when slot booking fails (slot full)',
      build: buildBloc,
      setUp: () {
        when(() => bookSlot(slotId: 'slot1', studentId: 'stu1'))
            .thenAnswer((_) async => const Left(ServerFailure('Slot is full')));
      },
      act: (bloc) => bloc.add(
        const ExamSlotBookRequested(slotId: 'slot1', studentId: 'stu1'),
      ),
      expect: () => [
        const ExamSlotLoading(),
        const ExamSlotError('Slot is full'),
      ],
    );

    blocTest<ExamSlotBloc, ExamSlotState>(
      'emits [Loading, Error] when duplicate booking attempted',
      build: buildBloc,
      setUp: () {
        when(() => bookSlot(slotId: 'slot1', studentId: 'stu1'))
            .thenAnswer(
          (_) async => const Left(ServerFailure('Student already has a booked slot')),
        );
      },
      act: (bloc) => bloc.add(
        const ExamSlotBookRequested(slotId: 'slot1', studentId: 'stu1'),
      ),
      expect: () => [
        const ExamSlotLoading(),
        const ExamSlotError('Student already has a booked slot'),
      ],
    );

    // ── Create slot ───────────────────────────────────────────────────────────

    blocTest<ExamSlotBloc, ExamSlotState>(
      'emits [Loading, CreateSuccess, Loaded] when slot creation succeeds',
      build: buildBloc,
      setUp: () {
        final slot = _makeSlot();
        when(() => createSlot(slot))
            .thenAnswer((_) async => const Right(null));
        when(() => getAllSlots())
            .thenAnswer((_) async => Right([slot]));
      },
      act: (bloc) => bloc.add(ExamSlotCreateRequested(_makeSlot())),
      expect: () => [
        const ExamSlotLoading(),
        const ExamSlotCreateSuccess(),
        isA<ExamSlotLoaded>(),
      ],
    );

    // ── Slot availability ─────────────────────────────────────────────────────

    test('isAvailable returns false when slot is at capacity', () {
      final full = _makeSlot(capacity: 5, bookedCount: 5);
      expect(full.isAvailable, isFalse);
    });

    test('isAvailable returns true when slot has remaining capacity', () {
      final open = _makeSlot(capacity: 30, bookedCount: 10);
      expect(open.isAvailable, isTrue);
      expect(open.remaining, equals(20));
    });
  });
}
