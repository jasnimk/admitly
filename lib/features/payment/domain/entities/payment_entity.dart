import 'package:equatable/equatable.dart';

class PaymentEntity extends Equatable {
  const PaymentEntity({
    required this.id,
    required this.studentId,
    required this.parentId,
    required this.amount,
    required this.status,
    required this.paidAt,
  });

  final String id;
  final String studentId;
  final String parentId;
  final int amount;
  final String status;
  final DateTime paidAt;

  @override
  List<Object?> get props => [id, studentId, parentId, amount, status, paidAt];
}
