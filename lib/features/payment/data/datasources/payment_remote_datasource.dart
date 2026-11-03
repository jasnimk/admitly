import 'package:admitly/features/payment/data/models/payment_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

abstract class PaymentRemoteDatasource {
  Future<void> createPayment(PaymentModel payment);
}

class PaymentRemoteDatasourceImpl implements PaymentRemoteDatasource {
  PaymentRemoteDatasourceImpl(this._db);
  final FirebaseFirestore _db;

  @override
  Future<void> createPayment(PaymentModel payment) async {
    await _db.collection('payments').add(payment.toMap());
  }
}
