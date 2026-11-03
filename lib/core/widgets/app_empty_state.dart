import 'package:admitly/core/constants/app_colors.dart';
import 'package:admitly/core/constants/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppEmptyState extends StatelessWidget {
  const AppEmptyState({super.key, required this.message, this.icon, this.action});

  final String message;
  final IconData? icon;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon ?? Icons.inbox_outlined, size: 56.w, color: colors.fog),
          SizedBox(height: 12.h),
          Text(message,
              textAlign: TextAlign.center,
              style: AppTextStyles.plusJakartaSans(fontSize: 14, color: colors.fog)),
          if (action != null) ...[SizedBox(height: 16.h), action!],
        ],
      ),
    );
  }
}
