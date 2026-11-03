import 'package:admitly/core/constants/app_colors.dart';
import 'package:admitly/core/constants/app_text_styles.dart';
import 'package:admitly/core/widgets/app_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class BiometricSetupCard extends StatelessWidget {
  const BiometricSetupCard({
    super.key,
    required this.onEnable,
    required this.onSkip,
    this.isLoading = false,
  });

  final VoidCallback onEnable;
  final VoidCallback onSkip;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      children: [
        Container(
          width: 64.w,
          height: 64.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: colors.canvas,
            border: Border.all(color: colors.border),
          ),
          child: Icon(Icons.fingerprint, size: 32.w, color: colors.primary),
        ),
        SizedBox(height: 20.h),
        Text(
          'Enable biometric login?',
          style: AppTextStyles.plusJakartaSans(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: colors.text,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 8.h),
        Text(
          'Sign in faster next time using\nFace ID or fingerprint',
          style: AppTextStyles.plusJakartaSans(fontSize: 14, color: colors.grey),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 32.h),
        AppButton(
          label: 'Enable',
          onPressed: onEnable,
          isLoading: isLoading,
        ),
        SizedBox(height: 12.h),
        AppButton(
          label: 'Skip for now',
          onPressed: onSkip,
          variant: AppButtonVariant.text,
        ),
      ],
    );
  }
}
