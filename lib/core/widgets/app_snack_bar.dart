import 'package:admitly/core/constants/app_colors.dart';
import 'package:admitly/core/constants/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

enum SnackBarType { success, error, info, warning }

class AppSnackBar {
  AppSnackBar._();

  static void show(
    BuildContext context,
    String message, {
    SnackBarType type = SnackBarType.info,
    Duration duration = const Duration(seconds: 3),
  }) {
    final colors = context.colors;

    final (bg, icon) = switch (type) {
      SnackBarType.success => (colors.primary, Icons.check_circle_outline_rounded),
      SnackBarType.error   => (colors.red, Icons.error_outline_rounded),
      SnackBarType.warning => (colors.subtle, Icons.warning_amber_rounded),
      SnackBarType.info    => (colors.accent, Icons.info_outline_rounded),
    };

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          duration: duration,
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.all(16.w),
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          backgroundColor: bg,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
          content: Row(
            children: [
              Icon(icon, color: Colors.white, size: 20.w),
              SizedBox(width: 10.w),
              Expanded(
                child: Text(message,
                    style: AppTextStyles.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    )),
              ),
            ],
          ),
        ),
      );
  }
}
