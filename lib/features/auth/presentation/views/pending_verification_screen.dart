import 'package:admitly/core/constants/app_colors.dart';
import 'package:admitly/core/constants/app_text_styles.dart';
import 'package:admitly/core/widgets/app_button.dart';
import 'package:admitly/core/widgets/app_snack_bar.dart';
import 'package:admitly/features/auth/domain/entities/user_entity.dart';
import 'package:admitly/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:admitly/features/auth/presentation/bloc/auth_event.dart';
import 'package:admitly/features/auth/presentation/bloc/auth_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PendingVerificationScreen extends StatelessWidget {
  const PendingVerificationScreen({super.key, required this.user});

  final UserEntity user;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.background,
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthPendingVerification) {
            AppSnackBar.show(
              context,
              'Still pending — check your email for the approval notification.',
              type: SnackBarType.info,
            );
          }
        },
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 80.w,
                  height: 80.w,
                  decoration: BoxDecoration(
                    color: colors.primary.withValues(alpha: 0.08),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.hourglass_empty_rounded,
                    size: 38.w,
                    color: colors.primary,
                  ),
                ),
                SizedBox(height: 28.h),
                Text(
                  'Pending Approval',
                  style: AppTextStyles.plusJakartaSans(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: colors.text,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 12.h),
                Text(
                  'Hi ${user.name.split(' ').first}, your Admission Team account is being reviewed.',
                  style: AppTextStyles.plusJakartaSans(
                    fontSize: 15,
                    color: colors.grey,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8.h),
                Text(
                  'You\'ll receive an email once an admin approves your account.',
                  style: AppTextStyles.plusJakartaSans(
                    fontSize: 14,
                    color: colors.grey,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 40.h),
                BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) => AppButton(
                    label: 'Check Approval Status',
                    onPressed: () => context
                        .read<AuthBloc>()
                        .add(AuthCheckVerificationRequested(user)),
                    isLoading: state is AuthLoading,
                  ),
                ),
                SizedBox(height: 12.h),
                AppButton(
                  label: 'Back to Login',
                  variant: AppButtonVariant.outlined,
                  onPressed: () {
                    context.read<AuthBloc>().add(const AuthLogoutRequested());
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
