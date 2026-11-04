import 'package:admitly/features/payment/domain/entities/payment_entity.dart';
import 'package:equatable/equatable.dart';

abstract class PaymentState extends Equatable {
  const PaymentState();
  @override
  List<Object?> get props => [];
}

class PaymentInitial extends PaymentState {
  const PaymentInitial();
}

class PaymentLoading extends PaymentState {
  const PaymentLoading();
}

class PaymentLoaded extends PaymentState {
  const PaymentLoaded(this.payments);
  final List<PaymentEntity> payments;
  @override
  List<Object?> get props => [payments];
}

class PaymentError extends PaymentState {
  const PaymentError(this.message);
  final String message;
  @override
  List<Object?> get props => [message];
}
