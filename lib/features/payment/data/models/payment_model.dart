import 'package:admitly/features/payment/domain/entities/payment_entity.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PaymentModel extends PaymentEntity {
  const PaymentModel({
    required super.id,
    required super.studentId,
    required super.parentId,
    required super.amount,
    required super.status,
    required super.paidAt,
  });

  factory PaymentModel.fromEntity(PaymentEntity e) => PaymentModel(
        id: e.id,
        studentId: e.studentId,
        parentId: e.parentId,
        amount: e.amount,
        status: e.status,
        paidAt: e.paidAt,
      );

  Map<String, dynamic> toMap() => {
        'studentId': studentId,
        'parentId': parentId,
        'amount': amount,
        'status': status,
        'paidAt': Timestamp.fromDate(paidAt),
      };
}
