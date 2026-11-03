import 'package:admitly/core/errors/failures.dart';
import 'package:admitly/features/payment/domain/entities/payment_entity.dart';
import 'package:admitly/features/payment/domain/repositories/payment_repository.dart';
import 'package:dartz/dartz.dart';

class CreatePaymentUseCase {
  const CreatePaymentUseCase(this._repository);
  final PaymentRepository _repository;

  Future<Either<Failure, void>> call(PaymentEntity payment) =>
      _repository.createPayment(payment);
}
