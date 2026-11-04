import 'package:admitly/features/payment/domain/entities/payment_entity.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PaymentModel extends PaymentEntity {
  const PaymentModel({
    required super.id,
    required super.studentId,
    required super.studentName,
    required super.parentId,
    required super.parentEmail,
    required super.amount,
    required super.status,
    required super.paidAt,
  });

  factory PaymentModel.fromEntity(PaymentEntity e) => PaymentModel(
        id: e.id,
        studentId: e.studentId,
        studentName: e.studentName,
        parentId: e.parentId,
        parentEmail: e.parentEmail,
        amount: e.amount,
        status: e.status,
        paidAt: e.paidAt,
      );

  factory PaymentModel.fromMap(String id, Map<String, dynamic> map) => PaymentModel(
        id: id,
        studentId: map['studentId'] as String? ?? '',
        studentName: map['studentName'] as String? ?? '',
        parentId: map['parentId'] as String? ?? '',
        parentEmail: map['parentEmail'] as String? ?? '',
        amount: (map['amount'] as num?)?.toInt() ?? 0,
        status: map['status'] as String? ?? '',
        paidAt: (map['paidAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      );

  Map<String, dynamic> toMap() => {
        'studentId': studentId,
        'studentName': studentName,
        'parentId': parentId,
        'parentEmail': parentEmail,
        'amount': amount,
        'status': status,
        'paidAt': Timestamp.fromDate(paidAt),
      };
}
