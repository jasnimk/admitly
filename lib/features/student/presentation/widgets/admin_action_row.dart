import 'package:admitly/core/constants/app_colors.dart';
import 'package:admitly/core/constants/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AdminActionRow extends StatelessWidget {
  const AdminActionRow({
    super.key,
    required this.primary,
    required this.onEditScore,
    this.onEnablePayment,
  });
  final Widget primary;
  final VoidCallback onEditScore;
  final VoidCallback? onEnablePayment;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        primary,
        SizedBox(height: 8.h),
        GestureDetector(
          onTap: onEditScore,
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 8.h),
            child: Text(
              'Edit Exam Score',
              style: AppTextStyles.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        if (onEnablePayment != null) ...[
          Divider(height: 1, color: colors.border),
          GestureDetector(
            onTap: onEnablePayment,
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 8.h),
              child: Text(
                'Enable Payment',
                style: AppTextStyles.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: colors.primary,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
