import 'package:admitly/features/exam_slot/domain/usecases/book_exam_slot_usecase.dart';
import 'package:admitly/features/exam_slot/domain/usecases/create_exam_slot_usecase.dart';
import 'package:admitly/features/exam_slot/domain/usecases/get_all_slots_usecase.dart';
import 'package:admitly/features/exam_slot/domain/usecases/get_exam_slots_usecase.dart';
import 'package:admitly/features/exam_slot/presentation/bloc/exam_slot_event.dart';
import 'package:admitly/features/exam_slot/presentation/bloc/exam_slot_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ExamSlotBloc extends Bloc<ExamSlotEvent, ExamSlotState> {
  ExamSlotBloc({
    required GetExamSlotsUseCase getExamSlotsUseCase,
    required GetAllSlotsUseCase getAllSlotsUseCase,
    required BookExamSlotUseCase bookExamSlotUseCase,
    required CreateExamSlotUseCase createExamSlotUseCase,
  })  : _getSlots = getExamSlotsUseCase,
        _getAllSlots = getAllSlotsUseCase,
        _bookSlot = bookExamSlotUseCase,
        _createSlot = createExamSlotUseCase,
        super(const ExamSlotInitial()) {
    on<ExamSlotsLoadRequested>(_onLoad);
    on<ExamAllSlotsLoadRequested>(_onLoadAll);
    on<ExamSlotBookRequested>(_onBook);
    on<ExamSlotCreateRequested>(_onCreate);
  }

  final GetExamSlotsUseCase _getSlots;
  final GetAllSlotsUseCase _getAllSlots;
  final BookExamSlotUseCase _bookSlot;
  final CreateExamSlotUseCase _createSlot;

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
    (await _createSlot(e.slot))
        .fold((f) => emit(ExamSlotError(f.message)), (_) => emit(const ExamSlotCreateSuccess()));
  }
}
