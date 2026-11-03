import 'package:admitly/core/errors/failures.dart';
import 'package:admitly/features/payment/domain/entities/payment_entity.dart';
import 'package:dartz/dartz.dart';

abstract class PaymentRepository {
  Future<Either<Failure, void>> createPayment(PaymentEntity payment);
}
