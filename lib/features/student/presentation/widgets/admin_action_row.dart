import 'package:admitly/core/constants/app_colors.dart';
import 'package:admitly/core/constants/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AdminActionRow extends StatelessWidget {
  const AdminActionRow({
    super.key,
    required this.primary,
    required this.onEditScore,
  });
  final Widget primary;
  final VoidCallback onEditScore;

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
      ],
    );
  }
}
