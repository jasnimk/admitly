import 'package:admitly/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppLoadingScreen extends StatelessWidget {
  const AppLoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Scaffold(
      backgroundColor: colors.background,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              colors.isDark ? 'assets/logo/logo_light.png' : 'assets/logo/logo_dark.png',
              width: 64.w,
              height: 64.w,
              fit: BoxFit.contain,
            ),
            SizedBox(height: 24.h),
            SizedBox(
              width: 24.w,
              height: 24.w,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: colors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
