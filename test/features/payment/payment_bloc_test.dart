import 'package:admitly/core/errors/failures.dart';
import 'package:admitly/features/payment/domain/entities/payment_entity.dart';
import 'package:admitly/features/payment/domain/usecases/get_payments_usecase.dart';
import 'package:admitly/features/payment/presentation/bloc/payment_bloc.dart';
import 'package:admitly/features/payment/presentation/bloc/payment_event.dart';
import 'package:admitly/features/payment/presentation/bloc/payment_state.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockGetPaymentsByParentUseCase extends Mock implements GetPaymentsByParentUseCase {}
class MockGetAllPaymentsUseCase extends Mock implements GetAllPaymentsUseCase {}

void main() {
  late MockGetPaymentsByParentUseCase getPaymentsByParent;
  late MockGetAllPaymentsUseCase getAllPayments;

  final tPayments = [
    PaymentEntity(
      id: 'pay001',
      studentId: 'stu001',
      studentName: 'Alice',
      parentId: 'par001',
      parentEmail: 'parent@example.com',
      amount: 500,
      status: 'paid',
      paidAt: DateTime(2024, 7, 15),
    ),
  ];

  setUp(() {
    getPaymentsByParent = MockGetPaymentsByParentUseCase();
    getAllPayments = MockGetAllPaymentsUseCase();
  });

  PaymentBloc buildBloc() => PaymentBloc(
        getPaymentsByParent: getPaymentsByParent,
        getAllPayments: getAllPayments,
      );

  group('PaymentBloc — Load by Parent', () {
    blocTest<PaymentBloc, PaymentState>(
      'emits [PaymentLoading, PaymentLoaded] on success',
      build: () {
        when(() => getPaymentsByParent(any())).thenAnswer((_) async => Right(tPayments));
        return buildBloc();
      },
      act: (bloc) => bloc.add(const PaymentLoadByParentRequested('par001')),
      expect: () => [isA<PaymentLoading>(), isA<PaymentLoaded>()],
      verify: (bloc) {
        final state = bloc.state as PaymentLoaded;
        expect(state.payments.length, 1);
        expect(state.payments.first.id, 'pay001');
      },
    );

    blocTest<PaymentBloc, PaymentState>(
      'emits [PaymentLoading, PaymentLoaded] with empty list when no payments',
      build: () {
        when(() => getPaymentsByParent(any())).thenAnswer((_) async => const Right([]));
        return buildBloc();
      },
      act: (bloc) => bloc.add(const PaymentLoadByParentRequested('par999')),
      expect: () => [isA<PaymentLoading>(), isA<PaymentLoaded>()],
      verify: (bloc) {
        final state = bloc.state as PaymentLoaded;
        expect(state.payments, isEmpty);
      },
    );

    blocTest<PaymentBloc, PaymentState>(
      'emits [PaymentLoading, PaymentError] on failure',
      build: () {
        when(() => getPaymentsByParent(any()))
            .thenAnswer((_) async => const Left(ServerFailure('Network error')));
        return buildBloc();
      },
      act: (bloc) => bloc.add(const PaymentLoadByParentRequested('par001')),
      expect: () => [isA<PaymentLoading>(), isA<PaymentError>()],
      verify: (bloc) {
        final state = bloc.state as PaymentError;
        expect(state.message, 'Network error');
      },
    );
  });

  group('PaymentBloc — Load All', () {
    blocTest<PaymentBloc, PaymentState>(
      'emits [PaymentLoading, PaymentLoaded] with all payments on success',
      build: () {
        when(() => getAllPayments()).thenAnswer((_) async => Right(tPayments));
        return buildBloc();
      },
      act: (bloc) => bloc.add(const PaymentLoadAllRequested()),
      expect: () => [isA<PaymentLoading>(), isA<PaymentLoaded>()],
      verify: (bloc) {
        final state = bloc.state as PaymentLoaded;
        expect(state.payments.length, 1);
      },
    );

    blocTest<PaymentBloc, PaymentState>(
      'emits [PaymentLoading, PaymentError] on failure',
      build: () {
        when(() => getAllPayments())
            .thenAnswer((_) async => const Left(ServerFailure('Firestore unavailable')));
        return buildBloc();
      },
      act: (bloc) => bloc.add(const PaymentLoadAllRequested()),
      expect: () => [isA<PaymentLoading>(), isA<PaymentError>()],
    );
  });
}
