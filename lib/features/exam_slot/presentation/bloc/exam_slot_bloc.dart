import 'package:admitly/features/exam_slot/domain/usecases/book_exam_slot_usecase.dart';
import 'package:admitly/features/exam_slot/domain/usecases/create_exam_slot_usecase.dart';
import 'package:admitly/features/exam_slot/domain/usecases/delete_exam_slot_usecase.dart';
import 'package:admitly/features/exam_slot/domain/usecases/get_all_slots_usecase.dart';
import 'package:admitly/features/exam_slot/domain/usecases/get_exam_slots_usecase.dart';
import 'package:admitly/features/exam_slot/domain/usecases/update_exam_slot_usecase.dart';
import 'package:admitly/features/exam_slot/presentation/bloc/exam_slot_event.dart';
import 'package:admitly/features/exam_slot/presentation/bloc/exam_slot_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ExamSlotBloc extends Bloc<ExamSlotEvent, ExamSlotState> {
  ExamSlotBloc({
    required GetExamSlotsUseCase getExamSlotsUseCase,
    required GetAllSlotsUseCase getAllSlotsUseCase,
    required BookExamSlotUseCase bookExamSlotUseCase,
    required CreateExamSlotUseCase createExamSlotUseCase,
    required UpdateExamSlotUseCase updateExamSlotUseCase,
    required DeleteExamSlotUseCase deleteExamSlotUseCase,
  })  : _getSlots = getExamSlotsUseCase,
        _getAllSlots = getAllSlotsUseCase,
        _bookSlot = bookExamSlotUseCase,
        _createSlot = createExamSlotUseCase,
        _updateSlot = updateExamSlotUseCase,
        _deleteSlot = deleteExamSlotUseCase,
        super(const ExamSlotInitial()) {
    on<ExamSlotsLoadRequested>(_onLoad);
    on<ExamAllSlotsLoadRequested>(_onLoadAll);
    on<ExamSlotBookRequested>(_onBook);
    on<ExamSlotCreateRequested>(_onCreate);
    on<ExamSlotUpdateRequested>(_onUpdate);
    on<ExamSlotDeleteRequested>(_onDelete);
  }

  final GetExamSlotsUseCase _getSlots;
  final GetAllSlotsUseCase _getAllSlots;
  final BookExamSlotUseCase _bookSlot;
  final CreateExamSlotUseCase _createSlot;
  final UpdateExamSlotUseCase _updateSlot;
  final DeleteExamSlotUseCase _deleteSlot;

  Future<void> _onLoad(ExamSlotsLoadRequested e, Emitter<ExamSlotState> emit) async {
    emit(const ExamSlotLoading());
    (await _getSlots()).fold((f) => emit(ExamSlotError(f.message)), (s) => emit(ExamSlotLoaded(s)));
  }

  Future<void> _onLoadAll(ExamAllSlotsLoadRequested e, Emitter<ExamSlotState> emit) async {
    emit(const ExamSlotLoading());
    (await _getAllSlots()).fold((f) => emit(ExamSlotError(f.message)), (s) => emit(ExamSlotLoaded(s)));
  }

  Future<void> _onBook(ExamSlotBookRequested e, Emitter<ExamSlotState> emit) async {
    emit(const ExamSlotLoading());
    (await _bookSlot(slotId: e.slotId, studentId: e.studentId))
        .fold((f) => emit(ExamSlotError(f.message)), (_) => emit(const ExamSlotBookSuccess()));
  }

  Future<void> _onCreate(ExamSlotCreateRequested e, Emitter<ExamSlotState> emit) async {
    emit(const ExamSlotLoading());
    final result = await _createSlot(e.slot);
    await result.fold(
      (f) async => emit(ExamSlotError(f.message)),
      (_) async {
        emit(const ExamSlotCreateSuccess());
        (await _getAllSlots()).fold((f) => emit(ExamSlotError(f.message)), (s) => emit(ExamSlotLoaded(s)));
      },
    );
  }

  Future<void> _onUpdate(ExamSlotUpdateRequested e, Emitter<ExamSlotState> emit) async {
    emit(const ExamSlotLoading());
    final result = await _updateSlot(e.slot);
    await result.fold(
      (f) async => emit(ExamSlotError(f.message)),
      (_) async {
        emit(const ExamSlotUpdateSuccess());
        (await _getAllSlots()).fold((f) => emit(ExamSlotError(f.message)), (s) => emit(ExamSlotLoaded(s)));
      },
    );
  }

  Future<void> _onDelete(ExamSlotDeleteRequested e, Emitter<ExamSlotState> emit) async {
    emit(const ExamSlotLoading());
    final result = await _deleteSlot(e.slotId);
    await result.fold(
      (f) async => emit(ExamSlotError(f.message)),
      (_) async {
        (await _getAllSlots()).fold((f) => emit(ExamSlotError(f.message)), (s) => emit(ExamSlotLoaded(s)));
      },
    );
  }
}
