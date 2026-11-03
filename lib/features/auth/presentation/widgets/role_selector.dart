import 'package:admitly/core/constants/app_colors.dart';
import 'package:admitly/core/constants/app_text_styles.dart';
import 'package:admitly/features/auth/domain/entities/user_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class RoleSelector extends StatelessWidget {
  const RoleSelector({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  final UserRole selected;
  final ValueChanged<UserRole> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _RoleTile(
          label: 'Parent',
          description: 'Applying for my child',
          icon: Icons.family_restroom_rounded,
          role: UserRole.parent,
          selected: selected,
          onTap: () => onChanged(UserRole.parent),
        ),
        SizedBox(width: 12.w),
        _RoleTile(
          label: 'Admission Team',
          description: 'School staff',
          icon: Icons.badge_outlined,
          role: UserRole.admissionTeam,
          selected: selected,
          onTap: () => onChanged(UserRole.admissionTeam),
        ),
      ],
    );
  }
}

class _RoleTile extends StatelessWidget {
  const _RoleTile({
    required this.label,
    required this.description,
    required this.icon,
    required this.role,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final String description;
  final IconData icon;
  final UserRole role;
  final UserRole selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isSelected = selected == role;

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: EdgeInsets.all(14.w),
          decoration: BoxDecoration(
            color: isSelected ? colors.primary : colors.white,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: isSelected ? colors.primary : colors.border,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                icon,
                size: 22.w,
                color: isSelected ? colors.white : colors.grey,
              ),
              SizedBox(height: 8.h),
              Text(
                label,
                style: AppTextStyles.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: isSelected ? colors.white : colors.text,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                description,
                style: AppTextStyles.plusJakartaSans(
                  fontSize: 11,
                  color: isSelected ? colors.white.withValues(alpha: 0.75) : colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
