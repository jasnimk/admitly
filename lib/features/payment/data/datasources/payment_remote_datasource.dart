import 'package:admitly/features/payment/data/models/payment_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

abstract class PaymentRemoteDatasource {
  Future<void> createPayment(PaymentModel payment);
  Future<List<PaymentModel>> getPaymentsByParent(String parentId);
  Future<List<PaymentModel>> getAllPayments();
}

class PaymentRemoteDatasourceImpl implements PaymentRemoteDatasource {
  PaymentRemoteDatasourceImpl(this._db);
  final FirebaseFirestore _db;

  CollectionReference get _col => _db.collection('payments');

  @override
  Future<void> createPayment(PaymentModel payment) async {
    await _col.add(payment.toMap());
  }

  @override
  Future<List<PaymentModel>> getPaymentsByParent(String parentId) async {
    final snap = await _col
        .where('parentId', isEqualTo: parentId)
        .orderBy('paidAt', descending: true)
        .get();
    return snap.docs
        .map((d) => PaymentModel.fromMap(d.id, d.data() as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<PaymentModel>> getAllPayments() async {
    final snap = await _col.orderBy('paidAt', descending: true).get();
    return snap.docs
        .map((d) => PaymentModel.fromMap(d.id, d.data() as Map<String, dynamic>))
        .toList();
  }
}
