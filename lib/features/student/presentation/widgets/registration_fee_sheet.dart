import 'package:admitly/core/constants/app_colors.dart';
import 'package:admitly/core/constants/app_text_styles.dart';
import 'package:admitly/core/widgets/app_bottom_sheet.dart';
import 'package:admitly/core/widgets/app_button.dart';
import 'package:admitly/core/widgets/app_snack_bar.dart';
import 'package:admitly/features/payment/domain/entities/payment_entity.dart';
import 'package:admitly/features/payment/domain/usecases/create_payment_usecase.dart';
import 'package:admitly/features/student/domain/entities/student_entity.dart';
import 'package:admitly/features/student/presentation/bloc/student_bloc.dart';
import 'package:admitly/features/student/presentation/bloc/student_event.dart';
import 'package:admitly/features/student/presentation/bloc/student_state.dart';
import 'package:admitly/injection_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

const _kRazorpayKeyId = 'rzp_test_TvlQDkQAxJmT4S';

Future<void> showRegistrationFeeSheet(
  BuildContext context, {
  required StudentEntity student,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => BlocProvider.value(
      value: context.read<StudentBloc>(),
      child: _RegistrationFeeSheet(student: student),
    ),
  );
}

class _RegistrationFeeSheet extends StatefulWidget {
  const _RegistrationFeeSheet({required this.student});
  final StudentEntity student;

  @override
  State<_RegistrationFeeSheet> createState() => _RegistrationFeeSheetState();
}

class _RegistrationFeeSheetState extends State<_RegistrationFeeSheet> {
  late final Razorpay _razorpay;
  bool _processing = false;

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _onPaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _onPaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _onExternalWallet);
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  void _onPaymentSuccess(PaymentSuccessResponse response) {
    if (!mounted) return;
    setState(() => _processing = true);

    final updated = widget.student.copyWith(
      status: ApplicationStatus.feePaid,
      paymentStatus: 'paid',
    );
    context.read<StudentBloc>().add(StudentUpdateRequested(updated));

    sl<CreatePaymentUseCase>().call(PaymentEntity(
      id: response.paymentId ?? '',
      studentId: widget.student.id,
      studentName: widget.student.name,
      parentId: widget.student.parentId,
      parentEmail: widget.student.parentEmail ?? '',
      amount: 500,
      status: 'paid',
      paidAt: DateTime.now(),
    ));
  }

  void _onPaymentError(PaymentFailureResponse response) {
    if (!mounted) return;
    setState(() => _processing = false);
    AppSnackBar.show(
      context,
      response.message ?? 'Payment failed. Please try again.',
      type: SnackBarType.error,
    );
  }

  void _onExternalWallet(ExternalWalletResponse response) {
    if (!mounted) return;
    AppSnackBar.show(
      context,
      'External wallet selected: ${response.walletName}',
      type: SnackBarType.success,
    );
  }

  void _openRazorpay() {
    final options = {
      'key': _kRazorpayKeyId,
      'amount': 50000, // in paise (₹500 = 50000 paise)
      'currency': 'INR',
      'name': 'Admitly',
      'description': 'Registration Fee — ${widget.student.name}',
      'prefill': {
        'contact': '9999999999',
        'email': widget.student.parentEmail ?? '',
      },
      'theme': {'color': '#15171F'},
    };
    _razorpay.open(options);
  }

  void _skip() {
    final updated = widget.student.copyWith(
      status: ApplicationStatus.feeSkipped,
      paymentStatus: 'skipped',
    );
    context.read<StudentBloc>().add(StudentUpdateRequested(updated));
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return BlocListener<StudentBloc, StudentState>(
      listener: (context, state) {
        if (state is StudentActionSuccess) {
          Navigator.pop(context);
          AppSnackBar.show(
            context,
            _processing ? 'Payment successful!' : 'Updated successfully',
            type: SnackBarType.success,
          );
        } else if (state is StudentError) {
          AppSnackBar.show(context, state.message, type: SnackBarType.error);
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: colors.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        ),
        padding: EdgeInsets.fromLTRB(24.w, 0, 24.w, 32.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const AppSheetHandle(),
            SizedBox(height: 20.h),
            Container(
              width: 60.w,
              height: 60.w,
              decoration: BoxDecoration(
                color: colors.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.receipt_long_outlined,
                  size: 28.w, color: colors.primary),
            ),
            SizedBox(height: 16.h),
            Text(
              'Registration Fee',
              style: AppTextStyles.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: colors.text,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'A one-time registration fee of ₹500 is required\nto process the application.',
              textAlign: TextAlign.center,
              style: AppTextStyles.plusJakartaSans(
                  fontSize: 13, color: colors.grey),
            ),
            SizedBox(height: 24.h),
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: colors.border),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Registration Fee',
                      style: AppTextStyles.plusJakartaSans(
                          fontSize: 14, color: colors.grey)),
                  Text('₹500',
                      style: AppTextStyles.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: colors.text,
                      )),
                ],
              ),
            ),
            SizedBox(height: 20.h),
            BlocBuilder<StudentBloc, StudentState>(
              builder: (context, state) => AppButton(
                label: 'Pay ₹500',
                onPressed: _processing || state is StudentLoading
                    ? null
                    : _openRazorpay,
                isLoading: _processing || state is StudentLoading,
              ),
            ),
            SizedBox(height: 10.h),
            BlocBuilder<StudentBloc, StudentState>(
              builder: (context, state) => AppButton(
                label: 'Skip for Now',
                variant: AppButtonVariant.outlined,
                onPressed: _processing || state is StudentLoading
                    ? null
                    : _skip,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
