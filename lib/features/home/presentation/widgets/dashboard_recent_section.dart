import 'package:admitly/core/constants/app_colors.dart';
import 'package:admitly/core/constants/app_text_styles.dart';
import 'package:admitly/features/student/domain/entities/student_entity.dart';
import 'package:admitly/features/student/presentation/widgets/student_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DashboardRecentSection extends StatelessWidget {
  const DashboardRecentSection({
    super.key,
    required this.students,
    required this.onTap,
  });
  final List<StudentEntity> students;
  final void Function(StudentEntity) onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Recent Applications',
              style: AppTextStyles.plusJakartaSans(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: colors.text,
              ),
            ),
            const Spacer(),
            if (students.isNotEmpty)
              Text(
                'Latest ${students.length}',
                style: AppTextStyles.plusJakartaSans(fontSize: 12, color: colors.grey),
              ),
          ],
        ),
        SizedBox(height: 10.h),
        if (students.isEmpty)
          _EmptyApplications(colors: colors)
        else
          ...students.map(
            (s) => Padding(
              padding: EdgeInsets.only(bottom: 10.h),
              child: StudentCard(student: s, onTap: () => onTap(s)),
            ),
          ),
      ],
    );
  }
}

class _EmptyApplications extends StatelessWidget {
  const _EmptyApplications({required this.colors});
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(28.w),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        children: [
          Icon(Icons.folder_open_outlined, size: 40.w, color: colors.grey),
          SizedBox(height: 10.h),
          Text(
            'No applications yet',
            style: AppTextStyles.plusJakartaSans(
                fontSize: 14, fontWeight: FontWeight.w600, color: colors.text),
          ),
        ],
      ),
    );
  }
}
