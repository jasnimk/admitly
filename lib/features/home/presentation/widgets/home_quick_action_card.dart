import 'package:admitly/core/constants/app_colors.dart';
import 'package:admitly/core/constants/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class HomeQuickActionCard extends StatelessWidget {
  const HomeQuickActionCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.badge,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final String? badge;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: colors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 44.w,
              height: 44.w,
              decoration: BoxDecoration(
                color: colors.canvas,
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(icon, size: 22.w, color: colors.primary),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: AppTextStyles.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: colors.text,
                      )),
                  SizedBox(height: 2.h),
                  Text(subtitle,
                      style: AppTextStyles.plusJakartaSans(
                        fontSize: 12,
                        color: colors.grey,
                      )),
                ],
              ),
            ),
            if (badge != null)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                decoration: BoxDecoration(
                  color: colors.primary,
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Text(badge!,
                    style: AppTextStyles.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: colors.white,
                    )),
              )
            else
              Icon(Icons.chevron_right_rounded, size: 20.w, color: colors.lightGrey),
          ],
        ),
      ),
    );
  }
}
