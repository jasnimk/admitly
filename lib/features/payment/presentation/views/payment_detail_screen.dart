import 'package:admitly/core/constants/app_colors.dart';
import 'package:admitly/core/constants/app_text_styles.dart';
import 'package:admitly/features/payment/domain/entities/payment_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

Future<void> showPaymentDetailSheet(
  BuildContext context, {
  required PaymentEntity payment,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _PaymentDetailSheet(payment: payment),
  );
}

class _PaymentDetailSheet extends StatelessWidget {
  const _PaymentDetailSheet({required this.payment});
  final PaymentEntity payment;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isPaid = payment.status == 'paid';

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.5,
      maxChildSize: 0.92,
      expand: false,
      builder: (_, scrollController) => Container(
        decoration: BoxDecoration(
          color: colors.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        ),
        child: Column(
          children: [
            // Handle + header
            SizedBox(height: 12.h),
            Center(
              child: Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: colors.border,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ),
            SizedBox(height: 16.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Row(
                children: [
                  Text(
                    'Payment Receipt',
                    style: AppTextStyles.plusJakartaSans(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: colors.text,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Icon(Icons.close, size: 22.w, color: colors.fog),
                  ),
                ],
              ),
            ),
            SizedBox(height: 8.h),
            Divider(color: colors.border, height: 1),
            Expanded(
              child: ListView(
                controller: scrollController,
                padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 32.h),
                children: [
                  // Status badge + amount
                  Center(
                    child: Column(
                      children: [
                        Container(
                          width: 64.w,
                          height: 64.w,
                          decoration: BoxDecoration(
                            color: isPaid
                                ? colors.primary.withValues(alpha: 0.08)
                                : colors.fog.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isPaid
                                ? Icons.check_circle_outline_rounded
                                : Icons.cancel_outlined,
                            size: 32.w,
                            color: isPaid ? colors.primary : colors.fog,
                          ),
                        ),
                        SizedBox(height: 10.h),
                        Text(
                          isPaid ? '₹${payment.amount}' : 'Fee Skipped',
                          style: AppTextStyles.plusJakartaSans(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: colors.text,
                          ),
                        ),
                        SizedBox(height: 6.h),
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 12.w, vertical: 4.h),
                          decoration: BoxDecoration(
                            color: isPaid
                                ? colors.primary.withValues(alpha: 0.08)
                                : colors.fog.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                          child: Text(
                            isPaid ? 'Payment Successful' : 'Skipped',
                            style: AppTextStyles.plusJakartaSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isPaid ? colors.primary : colors.fog,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 24.h),
                  // Details
                  _ReceiptCard(
                    colors: colors,
                    rows: [
                      _ReceiptRow(
                          label: 'Receipt No.',
                          value: payment.id,
                          copyable: true,
                          colors: colors),
                      _ReceiptRow(
                          label: 'Student',
                          value: payment.studentName.isNotEmpty
                              ? payment.studentName
                              : '—',
                          colors: colors),
                      if (payment.parentEmail.isNotEmpty)
                        _ReceiptRow(
                            label: 'Parent',
                            value: payment.parentEmail,
                            colors: colors),
                      _ReceiptRow(
                          label: 'Payment Type',
                          value: 'Registration Fee',
                          colors: colors),
                      _ReceiptRow(
                          label: 'Date',
                          value: DateFormat('dd MMMM yyyy')
                              .format(payment.paidAt),
                          colors: colors),
                      _ReceiptRow(
                          label: 'Time',
                          value: DateFormat('hh:mm a').format(payment.paidAt),
                          colors: colors),
                      if (isPaid)
                        _ReceiptRow(
                            label: 'Amount',
                            value: '₹${payment.amount}',
                            bold: true,
                            colors: colors),
                    ],
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

class _ReceiptCard extends StatelessWidget {
  const _ReceiptCard({required this.colors, required this.rows});
  final AppColors colors;
  final List<Widget> rows;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        children: rows
            .asMap()
            .entries
            .map((e) => Column(
                  children: [
                    e.value,
                    if (e.key < rows.length - 1)
                      Divider(height: 1, color: colors.border),
                  ],
                ))
            .toList(),
      ),
    );
  }
}

class _ReceiptRow extends StatelessWidget {
  const _ReceiptRow({
    required this.label,
    required this.value,
    required this.colors,
    this.copyable = false,
    this.bold = false,
  });
  final String label;
  final String value;
  final AppColors colors;
  final bool copyable;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 13.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110.w,
            child: Text(
              label,
              style: AppTextStyles.plusJakartaSans(
                  fontSize: 13, color: colors.fog),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.plusJakartaSans(
                fontSize: 13,
                fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
                color: colors.text,
              ),
              textAlign: TextAlign.right,
            ),
          ),
          if (copyable) ...[
            SizedBox(width: 8.w),
            GestureDetector(
              onTap: () {
                Clipboard.setData(ClipboardData(text: value));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Copied',
                        style: AppTextStyles.plusJakartaSans(
                            fontSize: 13, color: Colors.white)),
                    duration: const Duration(seconds: 1),
                    backgroundColor: colors.primary,
                  ),
                );
              },
              child: Icon(Icons.copy_rounded, size: 14.w, color: colors.fog),
            ),
          ],
        ],
      ),
    );
  }
}
