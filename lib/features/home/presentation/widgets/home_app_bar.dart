import 'package:admitly/core/constants/app_colors.dart';
import 'package:admitly/core/constants/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  const HomeAppBar({super.key, required this.onLogout});

  final VoidCallback onLogout;

  @override
  Size get preferredSize => Size.fromHeight(56.h);

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return AppBar(
      backgroundColor: colors.white,
      elevation: 0,
      centerTitle: false,
      title: Text(
        'admitly',
        style: AppTextStyles.plusJakartaSans(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: colors.text,
          letterSpacing: -0.5,
        ),
      ),
      actions: [
        IconButton(
          onPressed: onLogout,
          icon: Icon(Icons.logout_rounded, size: 22.w, color: colors.grey),
          tooltip: 'Logout',
        ),
        SizedBox(width: 8.w),
      ],
    );
  }
}
