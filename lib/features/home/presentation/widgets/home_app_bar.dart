import 'package:admitly/core/constants/app_colors.dart';
import 'package:admitly/core/constants/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  const HomeAppBar({super.key, required this.onLogout});

  final VoidCallback onLogout;

  @override
  Size get preferredSize => Size.fromHeight(56.h);

  Future<void> _confirmLogout(BuildContext context) async {
    final colors = context.colors;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        title: Text(
          'Sign out?',
          style: AppTextStyles.plusJakartaSans(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: colors.text,
          ),
        ),
        content: Text(
          'You will be signed out of your account.',
          style: AppTextStyles.plusJakartaSans(fontSize: 14, color: colors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              'Cancel',
              style: AppTextStyles.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: colors.grey,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              'Sign out',
              style: AppTextStyles.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: colors.primary,
              ),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true) onLogout();
  }

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
          onPressed: () => _confirmLogout(context),
          icon: Icon(Icons.logout_rounded, size: 22.w, color: colors.grey),
          tooltip: 'Logout',
        ),
        SizedBox(width: 8.w),
      ],
    );
  }
}
