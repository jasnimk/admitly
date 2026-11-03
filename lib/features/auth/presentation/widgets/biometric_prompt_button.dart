import 'package:admitly/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class BiometricPromptButton extends StatelessWidget {
  const BiometricPromptButton({super.key, required this.onTap, this.biometricType});

  final VoidCallback onTap;
  final String? biometricType;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isFace = biometricType == 'face';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 72.w,
        height: 72.w,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: colors.border, width: 1.5),
          color: colors.canvas,
        ),
        child: Icon(
          isFace ? Icons.face_outlined : Icons.fingerprint,
          size: 36.w,
          color: colors.primary,
        ),
      ),
    );
  }
}
