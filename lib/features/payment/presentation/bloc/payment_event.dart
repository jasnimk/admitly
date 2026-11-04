import 'package:equatable/equatable.dart';

abstract class PaymentEvent extends Equatable {
  const PaymentEvent();
  @override
  List<Object?> get props => [];
}

class PaymentLoadByParentRequested extends PaymentEvent {
  const PaymentLoadByParentRequested(this.parentId);
  final String parentId;
  @override
  List<Object?> get props => [parentId];
}

class PaymentLoadAllRequested extends PaymentEvent {
  const PaymentLoadAllRequested();
}
