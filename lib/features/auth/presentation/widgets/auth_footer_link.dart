import 'package:admitly/core/constants/app_colors.dart';
import 'package:admitly/core/constants/app_text_styles.dart';
import 'package:flutter/material.dart';

class AuthFooterLink extends StatelessWidget {
  const AuthFooterLink({
    super.key,
    required this.message,
    required this.actionLabel,
    required this.onTap,
  });

  final String message;
  final String actionLabel;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(message,
            style: AppTextStyles.plusJakartaSans(fontSize: 13, color: colors.grey)),
        GestureDetector(
          onTap: onTap,
          child: Text(actionLabel,
              style: AppTextStyles.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: colors.text,
              )),
        ),
      ],
    );
  }
}
