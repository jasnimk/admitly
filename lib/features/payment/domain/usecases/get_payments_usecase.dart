import 'package:admitly/core/errors/failures.dart';
import 'package:admitly/features/payment/domain/entities/payment_entity.dart';
import 'package:admitly/features/payment/domain/repositories/payment_repository.dart';
import 'package:dartz/dartz.dart';

class GetPaymentsByParentUseCase {
  GetPaymentsByParentUseCase(this._repository);
  final PaymentRepository _repository;

  Future<Either<Failure, List<PaymentEntity>>> call(String parentId) =>
      _repository.getPaymentsByParent(parentId);
}

class GetAllPaymentsUseCase {
  GetAllPaymentsUseCase(this._repository);
  final PaymentRepository _repository;

  Future<Either<Failure, List<PaymentEntity>>> call() =>
      _repository.getAllPayments();
}
