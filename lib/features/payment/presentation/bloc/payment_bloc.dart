import 'package:admitly/features/payment/domain/usecases/get_payments_usecase.dart';
import 'package:admitly/features/payment/presentation/bloc/payment_event.dart';
import 'package:admitly/features/payment/presentation/bloc/payment_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PaymentBloc extends Bloc<PaymentEvent, PaymentState> {
  PaymentBloc({
    required GetPaymentsByParentUseCase getPaymentsByParent,
    required GetAllPaymentsUseCase getAllPayments,
  })  : _getByParent = getPaymentsByParent,
        _getAll = getAllPayments,
        super(const PaymentInitial()) {
    on<PaymentLoadByParentRequested>(_onLoadByParent);
    on<PaymentLoadAllRequested>(_onLoadAll);
  }

  final GetPaymentsByParentUseCase _getByParent;
  final GetAllPaymentsUseCase _getAll;

  Future<void> _onLoadByParent(
      PaymentLoadByParentRequested event, Emitter<PaymentState> emit) async {
    emit(const PaymentLoading());
    final result = await _getByParent(event.parentId);
    result.fold(
      (f) => emit(PaymentError(f.message)),
      (payments) => emit(PaymentLoaded(payments)),
    );
  }

  Future<void> _onLoadAll(
      PaymentLoadAllRequested event, Emitter<PaymentState> emit) async {
    emit(const PaymentLoading());
    final result = await _getAll();
    result.fold(
      (f) => emit(PaymentError(f.message)),
      (payments) => emit(PaymentLoaded(payments)),
    );
  }
}
