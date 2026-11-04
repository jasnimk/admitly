import 'package:equatable/equatable.dart';

class PaymentEntity extends Equatable {
  const PaymentEntity({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.parentId,
    required this.parentEmail,
    required this.amount,
    required this.status,
    required this.paidAt,
  });

  final String id;
  final String studentId;
  final String studentName;
  final String parentId;
  final String parentEmail;
  final int amount;
  final String status;
  final DateTime paidAt;

  @override
  List<Object?> get props => [id, studentId, studentName, parentId, parentEmail, amount, status, paidAt];
}
