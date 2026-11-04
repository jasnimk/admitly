import 'package:admitly/core/constants/app_colors.dart';
import 'package:admitly/core/constants/app_text_styles.dart';
import 'package:admitly/core/widgets/app_status_badge.dart';
import 'package:admitly/features/student/domain/entities/student_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class StudentHeaderCard extends StatelessWidget {
  const StudentHeaderCard({super.key, required this.student});
  final StudentEntity student;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 56.w,
            height: 56.w,
            decoration: BoxDecoration(
              color: colors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.person_rounded, size: 28.w, color: colors.primary),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  student.name,
                  style: AppTextStyles.plusJakartaSans(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: colors.text,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  student.applyingGrade,
                  style: AppTextStyles.plusJakartaSans(fontSize: 13, color: colors.grey),
                ),
              ],
            ),
          ),
          _statusBadge(colors, student.status),
        ],
      ),
    );
  }

  Widget _statusBadge(AppColors colors, ApplicationStatus status) {
    final color = switch (status) {
      ApplicationStatus.applicationCreated  => colors.subtle,
      ApplicationStatus.feePaid             => colors.accent,
      ApplicationStatus.feeSkipped          => colors.subtle,
      ApplicationStatus.slotBooked          => colors.accent,
      ApplicationStatus.examCompleted       => colors.accent,
      ApplicationStatus.admissionCompleted  => colors.primary,
    };
    return AppStatusBadge(label: status.label, color: color);
  }
}
