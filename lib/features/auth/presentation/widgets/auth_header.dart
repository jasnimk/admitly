import 'package:admitly/core/constants/app_colors.dart';
import 'package:admitly/core/constants/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AuthHeader extends StatelessWidget {
  const AuthHeader({super.key, required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Column(
      children: [
        Text(title,
            style: AppTextStyles.plusJakartaSans(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: colors.text,
            )),
        SizedBox(height: 4.h),
        Text(subtitle,
            style: AppTextStyles.plusJakartaSans(
              fontSize: 13,
              color: colors.grey,
            )),
      ],
    );
  }
}
