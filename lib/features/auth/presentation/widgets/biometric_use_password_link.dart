import 'package:admitly/core/constants/app_colors.dart';
import 'package:admitly/core/constants/app_text_styles.dart';
import 'package:flutter/material.dart';

class BiometricUsePasswordLink extends StatelessWidget {
  const BiometricUsePasswordLink({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onTap,
      child: Text(
        'Use password instead',
        style: AppTextStyles.plusJakartaSans(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: context.colors.secondary,
        ),
      ),
    );
  }
}
