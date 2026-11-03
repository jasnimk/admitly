import 'package:admitly/features/exam_slot/domain/usecases/book_exam_slot_usecase.dart';
import 'package:admitly/features/exam_slot/domain/usecases/get_exam_slots_usecase.dart';
import 'package:admitly/features/exam_slot/presentation/bloc/exam_slot_event.dart';
import 'package:admitly/features/exam_slot/presentation/bloc/exam_slot_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ExamSlotBloc extends Bloc<ExamSlotEvent, ExamSlotState> {
  ExamSlotBloc({
    required GetExamSlotsUseCase getExamSlotsUseCase,
    required BookExamSlotUseCase bookExamSlotUseCase,
  })  : _getSlots = getExamSlotsUseCase,
        _bookSlot = bookExamSlotUseCase,
        super(const ExamSlotInitial()) {
    on<ExamSlotsLoadRequested>(_onLoad);
    on<ExamSlotBookRequested>(_onBook);
  }

  final GetExamSlotsUseCase _getSlots;
  final BookExamSlotUseCase _bookSlot;

  Future<void> _onLoad(
      ExamSlotsLoadRequested event, Emitter<ExamSlotState> emit) async {
    emit(const ExamSlotLoading());
    final result = await _getSlots();
    result.fold(
      (f) => emit(ExamSlotError(f.message)),
      (slots) => emit(ExamSlotLoaded(slots)),
    );
  }

  Future<void> _onBook(
      ExamSlotBookRequested event, Emitter<ExamSlotState> emit) async {
    emit(const ExamSlotLoading());
    final result =
        await _bookSlot(slotId: event.slotId, studentId: event.studentId);
    result.fold(
      (f) => emit(ExamSlotError(f.message)),
      (_) => emit(const ExamSlotBookSuccess()),
    );
  }
}
