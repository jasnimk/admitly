import 'package:admitly/core/constants/app_colors.dart';
import 'package:admitly/core/constants/app_text_styles.dart';
import 'package:admitly/core/widgets/app_button.dart';
import 'package:admitly/core/widgets/app_snack_bar.dart';
import 'package:admitly/features/student/domain/entities/student_entity.dart';
import 'package:admitly/features/student/presentation/bloc/student_bloc.dart';
import 'package:admitly/features/student/presentation/bloc/student_event.dart';
import 'package:admitly/features/student/presentation/bloc/student_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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

class _RegistrationFeeSheet extends StatelessWidget {
  const _RegistrationFeeSheet({required this.student});
  final StudentEntity student;

  void _pay(BuildContext context) {
    final updated = student.copyWith(
      status: ApplicationStatus.feePaid,
      paymentStatus: 'paid',
    );
    context.read<StudentBloc>().add(StudentUpdateRequested(updated));
  }

  void _skip(BuildContext context) {
    final updated = student.copyWith(
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
          AppSnackBar.show(context, 'Updated successfully',
              type: SnackBarType.success);
        } else if (state is StudentError) {
          AppSnackBar.show(context, state.message, type: SnackBarType.error);
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: colors.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        ),
        padding: EdgeInsets.fromLTRB(24.w, 20.h, 24.w, 32.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: colors.border,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
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
                onPressed: () => _pay(context),
                isLoading: state is StudentLoading,
              ),
            ),
            SizedBox(height: 10.h),
            BlocBuilder<StudentBloc, StudentState>(
              builder: (context, state) => AppButton(
                label: 'Skip for Now',
                variant: AppButtonVariant.outlined,
                onPressed: state is StudentLoading ? null : () => _skip(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
