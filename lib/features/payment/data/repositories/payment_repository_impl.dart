import 'package:admitly/core/errors/failures.dart';
import 'package:admitly/features/payment/data/datasources/payment_remote_datasource.dart';
import 'package:admitly/features/payment/data/models/payment_model.dart';
import 'package:admitly/features/payment/domain/entities/payment_entity.dart';
import 'package:admitly/features/payment/domain/repositories/payment_repository.dart';
import 'package:dartz/dartz.dart';

class PaymentRepositoryImpl implements PaymentRepository {
  const PaymentRepositoryImpl(this._datasource);
  final PaymentRemoteDatasource _datasource;

  @override
  Future<Either<Failure, void>> createPayment(PaymentEntity payment) async {
    try {
      await _datasource.createPayment(PaymentModel.fromEntity(payment));
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<PaymentEntity>>> getPaymentsByParent(String parentId) async {
    try {
      return Right(await _datasource.getPaymentsByParent(parentId));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<PaymentEntity>>> getAllPayments() async {
    try {
      return Right(await _datasource.getAllPayments());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
