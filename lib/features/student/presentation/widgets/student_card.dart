import 'package:admitly/core/constants/app_colors.dart';
import 'package:admitly/core/constants/app_text_styles.dart';
import 'package:admitly/features/student/domain/entities/student_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

class StudentCard extends StatelessWidget {
  const StudentCard({super.key, required this.student, this.onTap});
  final StudentEntity student;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: colors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40.w,
                  height: 40.w,
                  decoration: BoxDecoration(
                    color: colors.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.person_outline_rounded,
                      size: 20.w, color: colors.primary),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        student.name,
                        style: AppTextStyles.plusJakartaSans(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: colors.text,
                        ),
                      ),
                      Text(
                        student.applyingGrade,
                        style: AppTextStyles.plusJakartaSans(
                            fontSize: 12, color: colors.grey),
                      ),
                    ],
                  ),
                ),
                _StatusChip(status: student.status),
              ],
            ),
            SizedBox(height: 12.h),
            Divider(color: colors.border, height: 1),
            SizedBox(height: 10.h),
            Row(
              children: [
                _InfoItem(
                  icon: Icons.cake_outlined,
                  label: DateFormat('dd MMM yyyy').format(student.dateOfBirth),
                  colors: colors,
                ),
                SizedBox(width: 16.w),
                _InfoItem(
                  icon: Icons.school_outlined,
                  label: student.previousSchool,
                  colors: colors,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  const _InfoItem({required this.icon, required this.label, required this.colors});
  final IconData icon;
  final String label;
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 13.w, color: colors.grey),
        SizedBox(width: 4.w),
        Text(
          label,
          style: AppTextStyles.plusJakartaSans(fontSize: 12, color: colors.grey),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});
  final ApplicationStatus status;

  Color _color(BuildContext context) {
    final colors = context.colors;
    return switch (status) {
      ApplicationStatus.applicationCreated => colors.blue,
      ApplicationStatus.feePaid           => colors.green,
      ApplicationStatus.feeSkipped        => colors.orange,
      ApplicationStatus.slotBooked        => colors.primary,
      ApplicationStatus.examCompleted     => colors.orange,
      ApplicationStatus.admissionCompleted => colors.green,
    };
  }

  @override
  Widget build(BuildContext context) {
    final color = _color(context);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Text(
        status.label,
        style: AppTextStyles.plusJakartaSans(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
