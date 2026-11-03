import 'package:admitly/core/constants/app_colors.dart';
import 'package:admitly/core/constants/app_text_styles.dart';
import 'package:admitly/core/widgets/app_status_badge.dart';
import 'package:admitly/features/auth/domain/entities/user_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class HomeWelcomeBanner extends StatelessWidget {
  const HomeWelcomeBanner({super.key, required this.user});

  final UserEntity user;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isAdmin = user.role == UserRole.admissionTeam;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: colors.primary,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppStatusBadge(
            label: isAdmin ? 'Admission Team' : 'Parent',
            color: colors.white,
          ),
          SizedBox(height: 10.h),
          Text(
            'Hello, ${user.name.split(' ').first} 👋',
            style: AppTextStyles.plusJakartaSans(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: colors.white,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            isAdmin
                ? 'Manage applications and exam slots'
                : 'Track your child\'s admission journey',
            style: AppTextStyles.plusJakartaSans(
              fontSize: 13,
              color: colors.white.withValues(alpha: 0.75),
            ),
          ),
        ],
      ),
    );
  }
}
