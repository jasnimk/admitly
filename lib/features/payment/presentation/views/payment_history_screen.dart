import 'package:admitly/core/constants/app_colors.dart';
import 'package:admitly/core/widgets/app_loader.dart';
import 'package:admitly/core/constants/app_text_styles.dart';
import 'package:admitly/features/payment/domain/entities/payment_entity.dart';
import 'package:admitly/features/payment/presentation/bloc/payment_bloc.dart';
import 'package:admitly/features/payment/presentation/bloc/payment_event.dart';
import 'package:admitly/features/payment/presentation/bloc/payment_state.dart';
import 'package:admitly/features/payment/presentation/views/payment_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

class PaymentHistoryScreen extends StatelessWidget {
  const PaymentHistoryScreen({super.key, this.parentId});

  final String? parentId;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return BlocBuilder<PaymentBloc, PaymentState>(
      builder: (context, state) {
        if (state is PaymentLoading) {
          return const AppLoader();
        }
        if (state is PaymentError) {
          return Center(
            child: Text(state.message,
                style: AppTextStyles.plusJakartaSans(fontSize: 14, color: colors.error)),
          );
        }
        if (state is PaymentLoaded) {
          if (state.payments.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.receipt_long_outlined, size: 48.w, color: colors.fog),
                  SizedBox(height: 12.h),
                  Text('No payments yet',
                      style: AppTextStyles.plusJakartaSans(
                          fontSize: 15, fontWeight: FontWeight.w600, color: colors.text)),
                  SizedBox(height: 4.h),
                  Text('Payments will appear here once made.',
                      style: AppTextStyles.plusJakartaSans(fontSize: 13, color: colors.fog)),
                ],
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () async => context.read<PaymentBloc>().add(
                  parentId != null
                      ? PaymentLoadByParentRequested(parentId!)
                      : const PaymentLoadAllRequested(),
                ),
            child: ListView.separated(
              padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 100.h),
              itemCount: state.payments.length,
              separatorBuilder: (_, __) => SizedBox(height: 12.h),
              itemBuilder: (_, i) => _PaymentCard(
                payment: state.payments[i],
                onTap: () => showPaymentDetailSheet(
                  context,
                  payment: state.payments[i],
                ),
              ),
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}

class _PaymentCard extends StatelessWidget {
  const _PaymentCard({required this.payment, this.onTap});
  final PaymentEntity payment;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isPaid = payment.status == 'paid';
    final receiptNo = payment.id.length >= 8
        ? payment.id.substring(0, 8).toUpperCase()
        : payment.id.toUpperCase();

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14.r),
      child: Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        children: [
          // Header row
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 12.h),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(10.w),
                  decoration: BoxDecoration(
                    color: colors.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Icon(Icons.receipt_long_outlined,
                      size: 20.w, color: colors.primary),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        payment.studentName.isNotEmpty
                            ? payment.studentName
                            : 'Student',
                        style: AppTextStyles.plusJakartaSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: colors.text),
                      ),
                      Text(
                        'Receipt #$receiptNo',
                        style: AppTextStyles.plusJakartaSans(
                            fontSize: 11, color: colors.fog),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: isPaid
                        ? colors.primary.withValues(alpha: 0.08)
                        : colors.fog.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    isPaid ? 'Paid' : 'Skipped',
                    style: AppTextStyles.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isPaid ? colors.primary : colors.fog,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: colors.border),
          // Details row
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 14.h),
            child: Row(
              children: [
                _Detail(
                  label: 'Amount',
                  value: isPaid ? '₹${payment.amount}' : '—',
                  colors: colors,
                ),
                _Detail(
                  label: 'Type',
                  value: 'Registration Fee',
                  colors: colors,
                ),
                _Detail(
                  label: 'Date',
                  value: DateFormat('dd MMM yyyy').format(payment.paidAt),
                  colors: colors,
                ),
              ],
            ),
          ),
        ],
      ),
      ),
    );
  }
}

class _Detail extends StatelessWidget {
  const _Detail({required this.label, required this.value, required this.colors});
  final String label;
  final String value;
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: AppTextStyles.plusJakartaSans(fontSize: 11, color: colors.fog)),
          SizedBox(height: 2.h),
          Text(value,
              style: AppTextStyles.plusJakartaSans(
                  fontSize: 13, fontWeight: FontWeight.w600, color: colors.text)),
        ],
      ),
    );
  }
}
