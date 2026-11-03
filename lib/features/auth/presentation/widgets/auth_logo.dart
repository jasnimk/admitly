import 'package:admitly/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AuthLogo extends StatelessWidget {
  const AuthLogo({super.key, this.size});

  final double? size;

  @override
  Widget build(BuildContext context) {
    final s = size ?? 72.w;
    return Image.asset(
      context.colors.isDark
          ? 'assets/logo/logo_light.png'
          : 'assets/logo/logo_dark.png',
      width: s,
      height: s,
      fit: BoxFit.contain,
    );
  }
}
